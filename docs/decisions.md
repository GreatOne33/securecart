# SecureCart Design Decisions

This document records important architectural and engineering decisions made during SecureCart development.

Architectural Decision Records (ADRs) capture significant engineering decisions, their rationale, and the long-term direction of the SecureCart platform.

---

## ADR-001: Health Probe Strategy

**Introduced:** v0.3.0

SecureCart uses HTTP-based startup, readiness, and liveness probes for the frontend NGINX container.

The probes currently check `/` on port 80 because the frontend does not yet expose dedicated health endpoints.

Readiness is used to control whether a Pod receives Service traffic. Liveness is used to restart an unhealthy frontend container. Startup protects initialization by preventing readiness and liveness checks from running until the application has successfully started.

A future backend API should expose dedicated endpoints such as:

- `/startup`
- `/ready`
- `/health`

These endpoints should evaluate application dependencies appropriately rather than relying only on the root application path.

---

## ADR-002: Resource Request Strategy

**Introduced:** v0.3.0

SecureCart uses Burstable Quality of Service by configuring requests lower than limits.

This approach reserves sufficient CPU and memory for scheduling while allowing temporary resource bursts during increased workload.

Current frontend allocation:

- CPU Request: 100m
- CPU Limit: 250m
- Memory Request: 128Mi
- Memory Limit: 256Mi

These values are intentionally conservative for the lightweight frontend and will be revisited after Metrics Server and application monitoring are introduced.

---

## ADR-003: Ingress and TLS Strategy

**Introduced:** v0.4.0

SecureCart uses the NGINX Ingress Controller for host-based HTTP and HTTPS routing.

Kind maps host ports 80 and 443 into the control-plane node. The Ingress Controller is scheduled onto that same node so incoming traffic reaches its host ports.

TLS terminates at the Ingress Controller. The controller forwards HTTP traffic internally to the ClusterIP Service.

A self-signed certificate is used for local development. Production deployments will use a trusted certificate authority through AWS Certificate Manager or cert-manager.

---

## ADR-004: Frontend NetworkPolicy Strategy

**Introduced:** v0.6.0

SecureCart isolates frontend Pods using a namespace-scoped ingress NetworkPolicy.

The policy permits TCP port 80 only from Pods in the dedicated `ingress-nginx` namespace. Traffic from other namespaces is denied.

A separate default-deny policy is not used because the allow policy itself selects and isolates the frontend Pods.

This design provides a clear least-privilege boundary while remaining maintainable for the current local architecture. When additional application components are introduced, more specific Pod-to-Pod rules will be added.

---

## ADR-005: Frontend Containerization Strategy

**Introduced:** v0.7.0

SecureCart originally generated frontend content using a Kubernetes Init Container, ConfigMap template, and shared `emptyDir` volume.

This design was intentionally selected during Phase 1 to demonstrate Kubernetes concepts including Init Containers, ConfigMaps, shared volumes, and runtime configuration rendering.

As the project matured, the responsibility for rendering the frontend was moved into the application container itself.

The SecureCart frontend image now includes:

- HTML template
- Startup entrypoint
- Runtime configuration rendering using `envsubst`
- NGINX web server

Kubernetes now provides runtime configuration through ConfigMaps and the Downward API while the application image owns its startup process.

This architectural change provides several advantages:

- The frontend image can run locally with Docker or in Kubernetes without modification.
- The Deployment manifest is significantly simpler.
- Shared rendering volumes are no longer required.
- Application startup logic remains with the application rather than the orchestration platform.
- The container image becomes portable across container platforms including Docker, Kubernetes, Amazon ECS, and Amazon EKS.

This approach aligns with the principle that applications should own their initialization whenever practical, while Kubernetes remains responsible for deployment, scheduling, and runtime configuration.

---

## ADR-006: Backend Service and Network Segmentation Strategy

**Introduced:** v0.8.0

SecureCart runs the backend API as an independently containerized FastAPI workload inside Kubernetes.

The backend is deployed using a Kubernetes Deployment with multiple replicas and is exposed internally through the `securecart-backend-service` ClusterIP Service on TCP port 8000.

A ClusterIP Service was selected because the backend does not require direct external access. Workloads inside the cluster communicate with the backend using Kubernetes DNS rather than individual Pod IP addresses.

The frontend uses:

```text
securecart-backend-service:8000

```

as the stable backend network endpoint.

Backend Pods are identified using:

```text
app=securecart
component=backend

```

Ingress to the backend Pods is restricted using a Kubernetes NetworkPolicy.

The policy permits TCP port 8000 only from Pods matching the frontend workload identity:

```text
Frontend Pods -> Backend Pods   Allowed
Other Pods    -> Backend Pods   Denied

```

The policy relies on Kubernetes workload labels rather than Pod IP addresses because Pod addresses are ephemeral and should not be treated as stable application identities.

This design keeps the backend internal to the cluster while applying least-privilege network access between application tiers.

Future components such as databases, workers, or additional services will receive their own workload identities and NetworkPolicies rather than broadening the existing backend rule.

---

## ADR-007: Frontend Reverse Proxy Strategy

**Introduced:** v0.8.0

SecureCart uses the frontend NGINX container as a reverse proxy for backend API requests.

External clients access SecureCart through the existing HTTPS Ingress endpoint:

```text
https://securecart.local

```

Requests for frontend content are served directly by the frontend NGINX container.

Requests under:

```text
/api/

```

are proxied by frontend NGINX to the internal FastAPI backend through:

```text
securecart-backend-service:8000

```

The resulting request path is:

```text

Client
  |
  | HTTPS
  v
NGINX Ingress Controller
  |
  v
Frontend Service
  |
  v
Frontend NGINX
  |
  | /api/*
  v
Backend ClusterIP Service
  |
  v
FastAPI Backend Pods

```

This design was selected instead of exposing the backend directly through Kubernetes Ingress.

Keeping the backend behind the frontend provides several advantages:

-   The backend remains an internal ClusterIP Service.
-   External clients require only one application origin.
-   Kubernetes-internal DNS names are not exposed to browser clients.
-   Frontend-to-backend traffic can be controlled using NetworkPolicy.
-   Backend Pod and Service implementation details remain hidden from external clients.
-   Frontend and backend routing responsibilities remain clearly separated.

The backend destination is configured when the frontend container starts using:

```text
BACKEND_HOST
BACKEND_PORT

```

For the local Kubernetes environment:

```text
BACKEND_HOST=securecart-backend-service
BACKEND_PORT=8000

```

The NGINX configuration is rendered from a template when the frontend container starts.

This allows the same frontend image to use different backend destinations across local Docker, Kubernetes, and future cloud environments without rebuilding the image.

The design preserves separation of responsibilities:

```text
Ingress Controller
    External HTTPS routing

Frontend NGINX
    Application routing and API proxying

Backend Service
    Kubernetes service discovery

NetworkPolicy
    Workload-to-workload network authorization

FastAPI
    Application and API logic

```

Future AWS deployment will preserve this separation where practical while allowing implementation details such as ingress, load balancing, DNS, and TLS termination to evolve.

---

ADR-008: Backend API Framework and Health Strategy

Introduced: v0.8.0

SecureCart uses Python with FastAPI for the backend application API.

FastAPI was selected to provide a lightweight API layer with built-in request validation, response modeling, OpenAPI generation, and integration with Python type annotations.

Pydantic models define the structure of API resources such as SecureCart products. This provides an explicit application contract rather than relying on unvalidated data structures.

The backend currently exposes:

```text
GET /health
GET /api/status
GET /api/products
GET /api/products/{product_id}

```

Unlike the frontend, the backend exposes a dedicated /health endpoint.

Kubernetes health probes use this endpoint instead of the application root path. This separates application health checking from normal API functionality and establishes a foundation for more sophisticated health checks as backend dependencies are introduced.

The current /health endpoint verifies that the FastAPI application is running and able to respond to requests.

When PostgreSQL is introduced, the health strategy will be revisited so readiness can reflect whether the application is capable of serving requests that depend on required backend services.

The backend originally used in-memory product data during initial API development.

This is intentionally temporary.

The planned architecture is:

```text

Frontend
   |
   v
FastAPI Backend
   |
   v
PostgreSQL

```

Database integration will replace the current in-memory product data while preserving the external API contract where practical.

---

## ADR-009: PostgreSQL StatefulSet and Persistent Storage Strategy

**Introduced:** v0.9.0

SecureCart uses PostgreSQL as the persistent data layer for the backend application.

PostgreSQL is deployed using a Kubernetes StatefulSet rather than a standard Deployment.

A StatefulSet was selected because the database requires stable workload identity and persistent storage that survives Pod recreation.

The PostgreSQL workload currently runs as a single replica:

```text
securecart-postgres-0
```

A single replica is used intentionally. Increasing the StatefulSet replica count without configuring PostgreSQL replication would not provide safe database high availability.

The StatefulSet uses a volumeClaimTemplate to request persistent storage.

The resulting storage relationship is:
```text
StatefulSet
    |
    v
securecart-postgres-0
    |
    v
PersistentVolumeClaim
    |
    v
PersistentVolume

```

The local Kind environment uses the default standard StorageClass backed by the local-path provisioner.

The PostgreSQL PVC currently requests:
```text
1 GiB
ReadWriteOnce

```
Persistent storage is kept separate from the Pod lifecycle.

This behavior was validated by:

- Creating data in PostgreSQL
- Deleting securecart-postgres-0
- Allowing the StatefulSet to recreate the Pod
- Verifying that the same PVC remained bound
- Confirming that the database data remained available

The database is exposed internally through the headless Kubernetes Service:
```text
securecart-postgres
```

The backend connects to PostgreSQL using Kubernetes DNS rather than Pod IP addresses.

PostgreSQL credentials and database configuration are supplied through a Kubernetes Secret.

This design allows database Pods to be recreated without losing application data and establishes a foundation for future migration to a production-grade managed or replicated PostgreSQL architecture.

Future AWS deployment may replace the local PostgreSQL StatefulSet with a managed database service such as Amazon RDS while preserving the backend's database abstraction and external API contract.

---

## ADR-010: Database Access and Network Segmentation Strategy

**Introduced:** v0.9.0

SecureCart applies least-privilege network access to the PostgreSQL data tier.

The PostgreSQL workload is identified using:

```text
app=securecart
component=database
```

A Kubernetes NetworkPolicy selects the database Pods and permits inbound TCP traffic on port 5432 only from workloads carrying the backend identity:
```text
app=securecart
component=backend
```

The intended access model is:
```text
Backend Pods  -> PostgreSQL :5432   Allowed
Frontend Pods -> PostgreSQL :5432   Denied
Other Pods    -> PostgreSQL :5432   Denied
```

This design prevents application tiers from receiving database access solely because they are running inside the same Kubernetes cluster.

The frontend does not connect directly to PostgreSQL.

Instead, the application request path remains:

```text
Client
  |
  v
Ingress
  |
  v
Frontend
  |
  v
Backend
  |
  v
PostgreSQL

```

The backend is the only application tier authorized to communicate directly with the database.

Database credentials are stored in a Kubernetes Secret and supplied only to workloads that require them.

Network authorization and database authentication therefore provide separate security controls:

```text
NetworkPolicy
    determines whether the connection is permitted

PostgreSQL authentication
    determines whether the client is authorized by the database
```

The NetworkPolicy was validated using three workload identities:
```text
Unlabeled workload -> PostgreSQL   Denied
Frontend workload  -> PostgreSQL   Denied
Backend workload   -> PostgreSQL   Allowed
```

This design follows the principle of least privilege and limits lateral movement between application tiers.

Future database services, workers, or administrative workloads will receive explicit access rules rather than broad access to the PostgreSQL tier.

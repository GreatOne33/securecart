# SecureCart Architecture

This document describes the current SecureCart application architecture, component responsibilities, request flows, network boundaries, and planned evolution.

SecureCart is currently a multi-tier containerized application running on a local Kubernetes cluster using Kind.

---

## Current Architecture

```text
                         External Client
                                |
                              HTTPS
                                |
                                v
                     NGINX Ingress Controller
                         TLS Termination
                                |
                              HTTP
                                |
                                v
                     securecart-service :80
                                |
                                v
                 +-----------------------------+
                 | SecureCart Frontend Pods    |
                 |                             |
                 | NGINX                       |
                 | Runtime Config Rendering    |
                 | /api/* Reverse Proxy        |
                 +-----------------------------+
                                |
                                | HTTP :8000
                                |
                                v
                securecart-backend-service :8000
                                |
                     +----------+----------+
                     |                     |
                     v                     v
              +-------------+       +-------------+
              |   FastAPI   |       |   FastAPI   |
              | Backend Pod |       | Backend Pod |
              +-------------+       +-------------+
```

The frontend and backend are independently containerized workloads.

The frontend is the externally reachable application tier. The backend remains internal to the Kubernetes cluster and is accessed through the frontend NGINX reverse proxy.

---

## Component Responsibilities

### NGINX Ingress Controller

The NGINX Ingress Controller provides the external entry point into SecureCart.

Responsibilities:

- Accept HTTPS traffic for `securecart.local`
- Terminate TLS
- Redirect HTTP traffic to HTTPS
- Route requests to `securecart-service`
- Provide the boundary between external traffic and the application

TLS currently uses a self-signed certificate for local development.

---

### Frontend Service

`securecart-service` is a Kubernetes ClusterIP Service that provides a stable network endpoint for the frontend Pods.

The Service selects workloads using:

```text
app=securecart
component=frontend
```

The Service distributes traffic across healthy frontend replicas.

---

### Frontend

The SecureCart frontend runs as a custom NGINX container.

The image contains:

- NGINX
- HTML template
- NGINX configuration template
- Container startup entrypoint
- Runtime configuration rendering

The container renders its application configuration during startup using environment variables supplied by Kubernetes.

This allows the same container image to operate in different environments without rebuilding the image.

Frontend Pods receive runtime configuration from Kubernetes ConfigMaps and Pod metadata through the Downward API.

The frontend has two primary responsibilities:

```text
/           -> Serve frontend content
/api/*      -> Proxy requests to the backend
```

API requests are forwarded to:

```text
securecart-backend-service:8000
```

---

### Backend Service

`securecart-backend-service` is an internal Kubernetes ClusterIP Service.

It provides a stable DNS name and virtual IP for the FastAPI backend while allowing backend Pods to be replaced or scaled independently.

The Service selects workloads using:

```text
app=securecart
component=backend
```

Applications communicate with the backend using Kubernetes service discovery rather than individual Pod IP addresses.

---

### Backend

The SecureCart backend is a Python application built with FastAPI.

The backend currently provides:

```text
GET /health
GET /api/status
GET /api/products
GET /api/products/{product_id}
```

Pydantic models define API response structures and provide an explicit application contract.

The backend currently uses in-memory product data while the persistent data layer is under development.

Multiple backend replicas run behind `securecart-backend-service`.

Backend Pods receive runtime configuration and Pod metadata from Kubernetes.

---

## HTTPS Request Flow

Requests for frontend content follow:

```text
Client
  |
  | HTTPS
  v
NGINX Ingress Controller
  |
  | TLS termination
  | HTTP
  v
securecart-service
  |
  v
Frontend Pod
  |
  v
NGINX
  |
  v
Frontend Content
```

External traffic remains encrypted until it reaches the Ingress Controller.

TLS terminates at the Ingress Controller, which forwards HTTP traffic to the internal frontend Service.

---

## API Request Flow

API requests use the same external application endpoint:

```text
https://securecart.local/api/*
```

The request path is:

```text
Client
  |
  | HTTPS
  v
NGINX Ingress Controller
  |
  | HTTP
  v
securecart-service :80
  |
  v
Frontend NGINX
  |
  | /api/*
  | HTTP :8000
  v
securecart-backend-service
  |
  v
FastAPI Backend Pod
```

The backend is not directly exposed through Kubernetes Ingress.

Frontend NGINX acts as the application reverse proxy and forwards API requests using Kubernetes DNS.

This provides a single external application origin while keeping backend implementation details internal to the cluster.

---

## Service Discovery

SecureCart uses Kubernetes Services and DNS for communication between application tiers.

The frontend does not communicate directly with backend Pod IP addresses.

Instead, it uses:

```text
securecart-backend-service:8000
```

Kubernetes resolves the Service name and forwards connections to eligible backend endpoints.

This allows backend Pods to be restarted, replaced, or scaled without requiring frontend configuration changes.

---

## Runtime Configuration

SecureCart separates container images from environment-specific runtime configuration.

The frontend container receives configuration from Kubernetes and renders its templates when the container starts.

Configuration sources include:

```text
Configuration sources include:

ConfigMap
   |
   +------> Application configuration
   |
   v
Frontend Container

Deployment Environment Variables
   |
   +------> Backend service location
   |
   v
Frontend Container

Downward API
   |
   +------> Pod metadata
   |
   v
Frontend / Backend

```

Examples include:

- Application name
- Environment
- Version
- Company
- Backend host
- Backend port
- Pod name

BACKEND_HOST and BACKEND_PORT are currently defined directly in the frontend Deployment, while general frontend configuration is provided through the ConfigMap.

This allows application images to remain portable while Kubernetes supplies environment-specific values.

---

## Health Management

### Frontend

The frontend uses HTTP-based Kubernetes probes against port 80:

- Startup probe
- Readiness probe
- Liveness probe

These probes determine when frontend Pods can receive traffic and when unhealthy containers should be restarted.

### Backend

The FastAPI backend provides a dedicated:

```text
/health
```

endpoint.

Kubernetes uses the health endpoint to determine backend application health.

The dedicated endpoint separates application health checking from normal API functionality.

As dependencies such as PostgreSQL are introduced, the backend health strategy will evolve so readiness can represent whether the application is capable of serving dependency-backed requests.

---

## Network Security Boundaries

SecureCart applies Kubernetes NetworkPolicies to both application tiers.

### Frontend Boundary

Frontend Pods accept TCP port 80 traffic only from the `ingress-nginx` namespace.

```text
ingress-nginx -> Frontend :80    ALLOWED

Other Pods    -> Frontend :80    DENIED
```

### Backend Boundary

Backend Pods accept TCP port 8000 traffic only from workloads carrying the SecureCart frontend identity:

```text
app=securecart
component=frontend
```

The intended boundary is:

```text
Frontend Pods -> Backend :8000   ALLOWED

Other Pods    -> Backend :8000   DENIED
```

Together, these policies establish the application communication path:

```text
External Client
      |
      v
Ingress Controller
      |
      | Allowed
      v
Frontend
      |
      | Allowed
      v
Backend

Unauthorized Pod
      |
      +------X------> Frontend
      |
      +------X------> Backend
```

This applies least-privilege network access between application tiers.

---

## Workload Identity

SecureCart uses Kubernetes labels to identify application workloads.

Frontend:

```text
app=securecart
component=frontend
```

Backend:

```text
app=securecart
component=backend
```

Services and NetworkPolicies use these identities rather than Pod names or Pod IP addresses.

This is important because Kubernetes Pods are ephemeral and may be recreated with different names and addresses.

---

## Scaling and Availability

The frontend and backend run as Kubernetes Deployments.

Deployments provide:

- Declarative replica management
- Pod replacement
- Self-healing
- Rolling updates
- Rollbacks

ClusterIP Services provide stable network endpoints in front of those changing Pod replicas.

The backend currently runs multiple replicas behind:

```text
securecart-backend-service
```

Requests can therefore be served by different backend Pods without clients needing to know individual Pod addresses.

---

## Current Trust Model

The current application architecture intentionally exposes only the frontend tier.

```text
Internet / Client
       |
       v
    Ingress
       |
       v
    Frontend
       |
       v
    Backend
```

Each application tier is granted only the network access required for its current responsibility.

The backend is not directly exposed to external clients.

Future components will follow the same approach rather than receiving broad network access by default.

---

## Planned Data Layer

The next architectural milestone introduces PostgreSQL and persistent storage.

The planned application flow is:

```text
External Client
      |
      v
Ingress Controller
      |
      v
Frontend
      |
      v
Backend
      |
      v
PostgreSQL
      |
      v
Persistent Storage
```

The backend will replace its current in-memory product catalog with database-backed data.

The database will not be externally exposed.

A dedicated NetworkPolicy will restrict database access to workloads that require it.

Persistent storage will be introduced independently from the lifecycle of individual database Pods.

This section represents planned architecture and is not yet implemented.

---

## Long-Term Architecture

SecureCart is designed to evolve from the current local Kind environment toward AWS.

Planned technologies include:

- Terraform
- Amazon ECR
- Amazon EKS
- AWS IAM
- AWS VPC networking
- AWS Load Balancer Controller
- AWS Certificate Manager
- Helm
- GitHub Actions
- Prometheus
- Grafana

The current architecture intentionally establishes application boundaries that can later be mapped to cloud infrastructure without redesigning the entire application.

The implementation of these components will be documented as later project phases are completed.

---

## Persistent Data Architecture

**Introduced:** v0.9.0

SecureCart now includes PostgreSQL as the persistent data layer for the application.

The application architecture consists of three primary application tiers:

```text
Frontend
    |
    v
Backend
    |
    v
PostgreSQL
```

Each tier has a separate responsibility and communicates through Kubernetes Services rather than directly addressing individual Pods.

---

## Current End-to-End Architecture

```text
                         External Client
                                |
                              HTTPS
                                |
                                v
                    NGINX Ingress Controller
                         TLS Termination
                                |
                                | HTTP :80
                                v
                     securecart-service
                       ClusterIP Service
                                |
                                v
                 +-----------------------------+
                 | SecureCart Frontend Pods    |
                 |                             |
                 | NGINX                       |
                 | Runtime HTML Rendering      |
                 | /api/* Reverse Proxy        |
                 +-----------------------------+
                                |
                                | TCP :8000
                                | NetworkPolicy
                                v
                securecart-backend-service
                       ClusterIP Service
                                |
                    +-----------+-----------+
                    |                       |
                    v                       v
          +-------------------+   +-------------------+
          | FastAPI Backend   |   | FastAPI Backend   |
          | Pod               |   | Pod               |
          +-------------------+   +-------------------+
                    |                       |
                    +-----------+-----------+
                                |
                                | PostgreSQL
                                | TCP :5432
                                | NetworkPolicy
                                v
                     securecart-postgres
                       Headless Service
                                |
                                v
                  +--------------------------+
                  | PostgreSQL StatefulSet   |
                  |                          |
                  | securecart-postgres-0    |
                  +--------------------------+
                                |
                                v
                    PersistentVolumeClaim
                                |
                                v
                       PersistentVolume
```

The external client communicates only with the NGINX Ingress Controller.

The frontend, backend, and PostgreSQL workloads remain internal to the Kubernetes cluster.

---

## Application Request Flow

A request for product data follows this path:

```text
Client
  |
  | HTTPS
  v
NGINX Ingress Controller
  |
  | HTTP :80
  v
Frontend Service
  |
  v
Frontend NGINX
  |
  | /api/*
  | HTTP :8000
  v
Backend Service
  |
  v
FastAPI Backend
  |
  | SQL
  | TCP :5432
  v
PostgreSQL
  |
  v
Persistent Storage
```

For example:

```text
GET https://securecart.local/api/products
```

is received by the Ingress Controller and routed to the frontend Service.

The frontend NGINX container recognizes `/api/*` and proxies the request to:

```text
securecart-backend-service:8000
```

The FastAPI backend receives the API request and queries PostgreSQL through:

```text
securecart-postgres:5432
```

PostgreSQL retrieves the requested product data from persistent storage and returns it to the backend.

The response then travels back through the same application tiers to the client.

---

## PostgreSQL Architecture

PostgreSQL is deployed as a Kubernetes StatefulSet:

```text
securecart-postgres
```

The current database topology contains one PostgreSQL Pod:

```text
securecart-postgres-0
```

A single replica is used intentionally because additional PostgreSQL replicas require database-level replication and coordination rather than simply increasing the Kubernetes replica count.

The StatefulSet provides stable workload identity and manages persistent storage through a `volumeClaimTemplate`.

---

## PostgreSQL Service Discovery

PostgreSQL is exposed internally through the headless Service:

```text
securecart-postgres
```

with:

```yaml
clusterIP: None
```

The backend therefore connects to the database using Kubernetes DNS:

```text
securecart-postgres:5432
```

rather than using the PostgreSQL Pod IP address.

This separates application connectivity from the lifecycle of an individual database Pod.

If `securecart-postgres-0` is recreated, the backend continues using the same Kubernetes service identity.

---

## Persistent Storage Architecture

PostgreSQL data is stored independently of the database Pod lifecycle.

```text
PostgreSQL StatefulSet
        |
        v
securecart-postgres-0
        |
        v
PersistentVolumeClaim
postgres-data-securecart-postgres-0
        |
        v
PersistentVolume
        |
        v
Kind Local Storage
```

The PostgreSQL StatefulSet requests:

```text
Capacity:    1 GiB
Access Mode: ReadWriteOnce
StorageClass: standard
```

The Kind `standard` StorageClass dynamically provisions the PersistentVolume.

This allows the PostgreSQL container and Pod to be replaced without automatically destroying the database data.

Persistence was validated by deliberately deleting:

```text
securecart-postgres-0
```

The StatefulSet recreated the Pod, the existing PersistentVolumeClaim remained bound, and the SecureCart product catalog remained available through the application API.

---

## Application Data Flow

Product data is no longer stored in the FastAPI application process.

The data ownership model is now:

```text
Frontend
    |
    | API request
    v
FastAPI
    |
    | SQL query
    v
PostgreSQL
    |
    | persistent data
    v
PersistentVolume
```

FastAPI remains responsible for application and API behavior.

PostgreSQL is responsible for persistent application data.

The PersistentVolume provides storage independently of the PostgreSQL Pod lifecycle.

This separation prevents backend Pod recreation from affecting application data.

---

## Configuration and Secret Flow

Runtime configuration and sensitive configuration are supplied separately.

```text
                    Kubernetes
                  Configuration
                       |
          +------------+-------------+
          |                          |
          v                          v
      ConfigMap                    Secret
          |                          |
          v                          v
Frontend / Backend        Backend / PostgreSQL
```

ConfigMaps provide non-sensitive runtime application configuration.

The Downward API supplies Kubernetes runtime metadata such as Pod identity.

Kubernetes Secrets provide sensitive database configuration and credentials.

Database credentials are not embedded directly into the application source code.

---

## Network Security Architecture

SecureCart applies least-privilege communication between each application tier.

```text
                  ALLOWED
ingress-nginx --------------> Frontend
                                 |
                                 | ALLOWED
                                 v
                              Backend
                                 |
                                 | ALLOWED
                                 v
                             PostgreSQL
```

Each workload is isolated using Kubernetes NetworkPolicies.

The permitted paths are:

```text
ingress-nginx -> Frontend   TCP :80
Frontend      -> Backend    TCP :8000
Backend       -> PostgreSQL TCP :5432
```

Traffic outside those explicitly permitted paths is denied for the selected workloads.

The resulting trust boundaries are:

```text
ingress-nginx -> Frontend :80       ALLOWED
Other Pods    -> Frontend :80       DENIED

Frontend      -> Backend :8000      ALLOWED
Other Pods    -> Backend :8000      DENIED

Backend       -> PostgreSQL :5432   ALLOWED
Frontend      -> PostgreSQL :5432   DENIED
Other Pods    -> PostgreSQL :5432   DENIED
```

This prevents workloads from receiving access to another application tier merely because they run inside the same Kubernetes cluster.

---

## Database Security Boundary

The PostgreSQL tier is not exposed through the NGINX Ingress Controller.

External clients cannot directly access:

```text
securecart-postgres:5432
```

The frontend also does not communicate directly with PostgreSQL.

Database access must traverse the application architecture:

```text
Client
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

The backend is therefore the only SecureCart application tier permitted to establish PostgreSQL connections.

NetworkPolicy controls whether a workload can establish the network connection, while PostgreSQL authentication separately controls database access.

These controls provide independent layers of authorization.

---

## Stateful and Stateless Workloads

SecureCart now contains both stateless and stateful Kubernetes workloads.

### Stateless

```text
Frontend Deployment
Backend Deployment
```

Frontend and backend Pods can be destroyed and replaced without preserving Pod-local application state.

Multiple replicas can be distributed behind Kubernetes Services.

### Stateful

```text
PostgreSQL StatefulSet
```

PostgreSQL requires persistent storage and stable workload identity.

Its data lifecycle is therefore separated from the lifecycle of the PostgreSQL Pod using Kubernetes persistent storage.

This distinction is an important architectural boundary within SecureCart.

---

## Current Kubernetes Workload Model

```text
Deployments
├── securecart-frontend
│   └── 3 replicas
│
└── securecart-backend
    └── 2 replicas

StatefulSets
└── securecart-postgres
    └── 1 replica

Services
├── securecart-service
├── securecart-backend-service
└── securecart-postgres

Persistent Storage
└── postgres-data-securecart-postgres-0
    └── PersistentVolume

NetworkPolicies
├── allow-ingress-to-frontend
├── allow-frontend-to-backend
└── allow-backend-to-postgres
```

---

## Current Architecture Summary

SecureCart has evolved from a stateless frontend application into a stateful multi-tier Kubernetes architecture.

```text
                         Internet
                            |
                           HTTPS
                            |
                            v
                         Ingress
                            |
                            v
                         Frontend
                            |
                         TCP 8000
                            |
                            v
                          Backend
                            |
                         TCP 5432
                            |
                            v
                        PostgreSQL
                            |
                            v
                    Persistent Storage
```

The architecture currently demonstrates:

- Containerized application workloads
- Stateless Deployments
- StatefulSets
- Kubernetes Services
- Internal DNS-based service discovery
- PersistentVolumes and PersistentVolumeClaims
- Dynamic storage provisioning
- Runtime configuration
- Secret-based database configuration
- HTTPS/TLS termination
- Reverse proxy routing
- Health management
- Resource management
- Least-privilege NetworkPolicies
- Persistent application data
- Separation of stateless compute from stateful storage

The next architectural evolution will focus on making database provisioning reproducible through schema initialization and migrations before moving further into DevOps automation.

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

---

## Database Migration Architecture

SecureCart now manages database schema changes through a version-controlled migration workflow.

The migration path is:

```text
Git Repository
      |
      v
Alembic Migration Files
      |
      v
Kubernetes Database Migration Job
      |
      v
PostgreSQL

```

The migration Job runs as a finite Kubernetes workload rather than as part of every backend Pod startup.

It performs:
```text
alembic upgrade head
        |
        v
python seed.py
```

The Job then terminates after successful completion.

This separates deployment-time database initialization from the long-running FastAPI application workload.

The migration workload uses:
```text
app=securecart
component=database-migration
```

and receives explicit NetworkPolicy authorization to connect to PostgreSQL on TCP port 5432.

## Container Image Supply Path

SecureCart frontend and backend images are now published to GitHub Container Registry.

Current application images:
```text
ghcr.io/greatone33/securecart-frontend:0.3.0
ghcr.io/greatone33/securecart-backend:0.4.1
```

The application image delivery path is now:
```text
Application Source
      |
      v
Docker Build
      |
      v
GitHub Container Registry
      |
      v
Kubernetes Image Pull
      |
      v
Running Workload

```

This replaces the previous local-only development path that depended on loading images directly into Kind.

The same backend image is used by:
```text
Backend Deployment
Database Migration Job
```

with Kubernetes selecting the appropriate command and workload behavior.

This establishes a reusable artifact boundary that can later be automated through CI/CD.

## Runtime Security Architecture

SecureCart applies workload-specific container security controls.

#### Frontend
```text
Runtime User:        UID/GID 101
Privilege Escalation: Disabled
Linux Capabilities:   Dropped
Root Filesystem:      Read Only
Writable Path:        /tmp
Container Port:       8080

```

The frontend uses an unprivileged NGINX runtime.

A Kubernetes emptyDir is mounted at /tmp to provide only the writable runtime storage required for generated configuration, HTML content, PID files, and NGINX temporary data.

The Kubernetes Service continues to expose port 80 while forwarding traffic to container port 8080.

#### Backend
```text
Runtime User:        UID/GID 999
Privilege Escalation: Disabled
Linux Capabilities:   Dropped
Root Filesystem:      Read Only
Container Port:       8000

```

The FastAPI backend runs entirely as the dedicated securecart user.

#### Database Migration Job
```text
Runtime User:        UID/GID 999
Privilege Escalation: Disabled
Linux Capabilities:   Dropped
Root Filesystem:      Read Only

```

The migration workload uses the same hardened backend image while running Alembic and the seed process as a finite Job.

#### PostgreSQL

PostgreSQL uses a different security model because its initialization process requires filesystem permission management on persistent storage.

The long-running PostgreSQL process executes as:
```text
UID 70
GID 70
```

Persistent database data remains writable through the PostgreSQL PersistentVolumeClaim.

A forced non-root startup experiment demonstrated that applying the same runtime model used by the stateless workloads prevented PostgreSQL from initializing a fresh volume.

The production architecture therefore preserves the required PostgreSQL initialization behavior while allowing the database server itself to operate using its dedicated non-root runtime identity.

## Current Database Trust Boundary

The PostgreSQL NetworkPolicy now permits two explicitly authorized workload identities:
```text
Backend
Database Migration
```

The effective database access model is:
```text
Backend             ─────> PostgreSQL :5432
Database Migration  ─────> PostgreSQL :5432

Frontend            ──X──> PostgreSQL :5432
Other Workloads     ──X──> PostgreSQL :5432
```

The normal user request path remains:
```text
Client
  |
  | HTTPS
  v
NGINX Ingress Controller
  |
  v
Frontend
  |
  | HTTP :8000
  v
FastAPI Backend
  |
  | PostgreSQL :5432
  v
PostgreSQL
  |
  v
Persistent Storage

```

The database lifecycle path is separate:
```text
Database Migration Job
        |
        | PostgreSQL :5432
        v
PostgreSQL

```

## Current Deployment Architecture

```text
                           GitHub
                              |
                              v
                 GitHub Container Registry
                    |                   |
                    |                   |
                    v                   v
              Frontend Image      Backend Image
                    |                   |
                    |                   +------------------+
                    |                                      |
                    v                                      v
             Frontend Deployment                    Backend Deployment
               3 replicas                            2 replicas
                    |                                      |
                    |                                      |
                    +------------------+-------------------+
                                       |
                                       v
                              Kubernetes Services
                                       |
                                       v
                                  PostgreSQL
                                StatefulSet 1/1
                                       |
                                       v
                              PersistentVolumeClaim
                                       |
                                       v
                                PersistentVolume

Backend Image
      |
      v
Database Migration Job
      |
      v
PostgreSQL

```

## Current Architecture Summary - v1.0.0

SecureCart now demonstrates a reproducible, hardened, registry-backed Kubernetes application architecture.

The platform currently includes:

- Containerized frontend and backend workloads
- Unprivileged frontend NGINX runtime
- Non-root FastAPI backend runtime
- Read-only application root filesystems
- Explicit writable runtime storage
- Linux capability reduction
- Privilege escalation prevention
- Version-controlled PostgreSQL schema migrations
- Idempotent application data seeding
- Kubernetes database migration Job
- Explicit database migration NetworkPolicy authorization
- PostgreSQL persistent storage
- StatefulSet-based database lifecycle
- PersistentVolume and PersistentVolumeClaim management
- Registry-hosted application artifacts
- Kubernetes image pulls from GitHub Container Registry
- HTTPS/TLS ingress
- Internal service discovery
- Least-privilege application-tier segmentation

The next architectural evolution is packaging these Kubernetes resources as a reusable Helm chart before introducing CI/CD automation.

---

# Helm Deployment Architecture - v1.1.0

## Helm Release Management Layer

SecureCart v1.1.0 introduces Helm as the deployment packaging and release management layer between repository-controlled configuration and the Kubernetes API.

Prior to Helm, SecureCart's Kubernetes architecture was represented and deployed through individual manifests under:

```text
kubernetes/base/
```

The underlying Kubernetes architecture remains the same, but the deployment interface is now parameterized through the SecureCart Helm chart:

```text
helm/securecart/
```

The deployment path is:

```text
              SecureCart Repository
                       |
          +------------+------------+
          |                         |
          v                         v
     values.yaml               Helm Templates
          |                         |
          +------------+------------+
                       |
                       v
                 Helm Rendering
                       |
                       v
                  Helm Release
                       |
                       v
              Kubernetes API Server
                       |
          +------------+------------+
          |            |            |
          v            v            v
      Frontend      Backend     PostgreSQL
          |            |            ^
          |            |            |
          +----------->+----------->+
                       |
                       v
                Migration Job
```

Helm does not replace Kubernetes.

Helm renders Kubernetes resource definitions and manages their deployment state, while Kubernetes remains responsible for workload scheduling, reconciliation, scaling, health management, networking, and storage.

## Helm Chart Architecture

The chart packages the SecureCart application resources into a single deployable unit.

```text
helm/securecart/
|
+-- Chart.yaml
+-- values.yaml
|
+-- templates/
    |
    +-- configmap.yaml
    |
    +-- frontend-deployment.yaml
    +-- frontend-service.yaml
    |
    +-- backend-deployment.yaml
    +-- backend-service.yaml
    |
    +-- postgres-statefulset.yaml
    +-- postgres-service.yaml
    |
    +-- database-migration-job.yaml
    |
    +-- frontend-ingress.yaml
    |
    +-- allow-ingress-to-frontend.yaml
    +-- allow-frontend-to-backend.yaml
    +-- allow-backend-to-postgres.yaml
```

The chart currently renders:

```text
3 NetworkPolicies
1 ConfigMap
3 Services
2 Deployments
1 StatefulSet
1 Job
1 Ingress
```

The chart therefore packages the existing application, database, ingress, and network-security architecture without changing the intended application trust boundaries.

## Configuration Architecture

Helm separates deployment configuration from Kubernetes resource structure.

```text
                   values.yaml
                       |
        +--------------+--------------+
        |              |              |
        v              v              v
     global         frontend        backend
        |              |              |
        +--------------+--------------+
                       |
        +--------------+--------------+
        |              |              |
        v              v              v
     postgres       migration       ingress
                       |
                       v
                 networkPolicy
```

The values layer controls deployment settings including:

```text
Application metadata
Replica counts
Container image repositories
Container image tags
Image pull policies
Container ports
Service ports
CPU requests and limits
Memory requests and limits
PostgreSQL persistence
Storage class
Storage size
Ingress host
TLS configuration
NetworkPolicy enablement
```

Templates consume these values to produce Kubernetes resources.

For example:

```text
frontend.replicaCount
        |
        v
frontend-deployment.yaml
        |
        v
Deployment.spec.replicas
```

and:

```text
postgres.persistence.size
        |
        v
postgres-statefulset.yaml
        |
        v
volumeClaimTemplates.resources.requests.storage
```

This allows deployment configuration to change without duplicating or directly editing the resource templates.

## Helm Validation Architecture

SecureCart uses multiple validation layers before Helm-managed configuration is applied to the cluster.

```text
Helm Chart
    |
    v
helm lint
    |
    |  Chart and template validation
    v
helm template
    |
    |  Rendered Kubernetes manifests
    v
kubectl --dry-run=server
    |
    |  Kubernetes API validation
    v
kubectl diff
    |
    |  Desired-state comparison
    v
Helm Install / Upgrade
```

Each layer validates a different part of the deployment path.

`helm lint` validates the Helm chart.

`helm template` exposes the fully rendered Kubernetes resources for inspection.

Server-side dry-run validates the rendered resources against the Kubernetes API without persisting the changes.

`kubectl diff` compares the rendered desired state with live cluster state before deployment.

## Helm Release Lifecycle

SecureCart is now represented as a Helm release named:

```text
securecart
```

in the:

```text
default
```

namespace.

Helm maintains revision history for the release:

```text
              helm install
                   |
                   v
              Revision 1
                   |
              helm upgrade
                   |
                   v
              Revision 2
                   |
             helm rollback
                   |
                   v
              Revision 3
```

The initial release lifecycle was validated as:

```text
Revision 1
  Install
  Frontend replicas: 3

Revision 2
  Upgrade
  Frontend replicas: 4

Revision 3
  Rollback to revision 1 configuration
  Frontend replicas: 3
```

Helm revision state and Kubernetes workload state remain related but distinct.

Helm determines the desired release configuration.

Kubernetes reconciles that desired configuration against the running workloads.

## Kubernetes Reconciliation During Helm Operations

The Helm upgrade test demonstrated Kubernetes reconciliation behavior.

Changing:

```text
frontend.replicaCount: 3
```

to:

```text
frontend.replicaCount: 4
```

did not modify the frontend Pod template.

The existing ReplicaSet therefore remained valid.

Kubernetes reconciled:

```text
Desired replicas: 4
Current replicas: 3
Difference:       1
```

by creating one additional frontend Pod.

The original three Pods remained running.

During rollback, the desired replica count returned to three and Kubernetes removed the additional replica without replacing the original Pods.

This produces the following operational distinction:

```text
Replica count change
        |
        v
Scale existing ReplicaSet

Pod template change
        |
        v
Create new ReplicaSet
        |
        v
Rolling Deployment update
```

Helm initiates desired-state changes, but Kubernetes determines the workload reconciliation required to reach that state.

## Helm Ownership Model

The first Helm installation adopted SecureCart resources that already existed in the cluster.

The resources received Helm management metadata:

```text
app.kubernetes.io/managed-by: Helm

meta.helm.sh/release-name: securecart

meta.helm.sh/release-namespace: default
```

The ownership transition did not inherently require workload recreation.

This separates two concepts:

```text
Resource ownership
    Who manages the Kubernetes resource

Workload reconciliation
    What Kubernetes must change to reach desired state
```

Helm can therefore assume management of a compatible existing resource without necessarily replacing the Pods controlled by that resource.

## Deployment Source of Truth

SecureCart now maintains two related Kubernetes representations.

```text
kubernetes/base/
        |
        +--> Foundational Kubernetes manifests
        |
        +--> Architecture reference
        |
        +--> Kubernetes learning and troubleshooting


helm/securecart/
        |
        +--> Parameterized Kubernetes templates
        |
        +--> Deployment configuration
        |
        +--> Helm release management
        |
        +--> Preferred automated deployment interface
```

The base manifests document the Kubernetes architecture directly.

The Helm chart packages that architecture into the interface that will be consumed by future deployment automation.

This establishes the future deployment boundary:

```text
Developer
    |
    v
Source Control
    |
    v
CI/CD
    |
    v
Helm
    |
    v
Kubernetes
```

## Current Deployment Architecture - v1.1.0

The complete local deployment architecture is now:

```text
                        Git Repository
                              |
             +----------------+----------------+
             |                                 |
             v                                 v
      Application Source                  Helm Chart
             |                                 |
             v                                 v
      Container Build                      values.yaml
             |                                 |
             v                                 v
 GitHub Container Registry              Helm Templates
             |                                 |
             |                                 v
             |                            Helm Release
             |                                 |
             +----------------+----------------+
                              |
                              v
                     Kubernetes Cluster
                              |
             +----------------+----------------+
             |                |                |
             v                v                v
          Ingress         Migration Job    PostgreSQL
             |                |                ^
             v                |                |
          Frontend            +--------------->|
             |                                 |
             v                                 |
          Backend -----------------------------+
```

Application traffic continues to follow:

```text
Client
  |
  v
HTTPS Ingress
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

Database migration traffic follows:

```text
Database Migration Job
          |
          v
      PostgreSQL
```

NetworkPolicy continues to enforce the application trust boundaries:

```text
Ingress Controller -> Frontend :8080     ALLOWED

Frontend           -> Backend  :8000     ALLOWED

Backend            -> PostgreSQL :5432   ALLOWED

Migration Job      -> PostgreSQL :5432   ALLOWED

Unauthorized workloads -> PostgreSQL     DENIED
```

Helm changes how this architecture is packaged, configured, deployed, upgraded, and rolled back.

It does not weaken or bypass the Kubernetes security boundaries established by the underlying resources.

The next architectural layer will introduce CI/CD automation that consumes the Helm chart as the deployment interface.
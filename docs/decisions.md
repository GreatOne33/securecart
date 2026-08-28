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
**Updated:** v1.0.0

SecureCart applies least-privilege network access to the PostgreSQL data tier.

The PostgreSQL workload is identified using:

```text
app=securecart
component=database
```

A Kubernetes NetworkPolicy selects the database Pods and permits inbound TCP traffic on port 5432 only from explicitly authorized workloads.

Authorized workload identities are:
```text
app=securecart
component=backend
```

and:
```text
app=securecart
component=database-migration
```

The intended access model is:
```text
Backend Pods          -> PostgreSQL :5432   Allowed
Database Migration    -> PostgreSQL :5432   Allowed
Frontend Pods         -> PostgreSQL :5432   Denied
Other Pods            -> PostgreSQL :5432   Denied

```

This design prevents application tiers from receiving database access solely because they are running inside the same Kubernetes cluster.

The frontend does not connect directly to PostgreSQL.

Instead, the normal application request path remains:

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

Database schema management follows a separate deployment path:
```text
Database Migration Job
  |
  v
PostgreSQL

```

The backend and database migration workload are the only SecureCart workloads currently authorized to communicate directly with PostgreSQL.

Database credentials are stored in a Kubernetes Secret and supplied only to workloads that require them.

Network authorization and database authentication therefore provide separate security controls:

```text
NetworkPolicy
    determines whether the network connection is permitted

PostgreSQL authentication
    determines whether the client is authorized by the database

```

The policy was validated using multiple workload identities:
```text
Unlabeled workload        -> PostgreSQL   Denied
Frontend workload         -> PostgreSQL   Denied
Backend workload          -> PostgreSQL   Allowed
Database migration        -> PostgreSQL   Allowed

```

This design follows the principle of least privilege and limits lateral movement between application tiers.

Future workers, administrative services, or other database clients will receive explicit access rules rather than broad PostgreSQL access.

## ADR-011: Database Migration and Seed Strategy

Introduced: v1.0.0

SecureCart uses Alembic to manage PostgreSQL schema evolution.

Database schema changes are stored as version-controlled migration files alongside the backend application.

The current migration lifecycle is:
```text
Version-Controlled Migration
        |
        v
Alembic
        |
        v
PostgreSQL Schema

```

The initial migration creates the SecureCart products table.

This design replaces manual schema creation using interactive psql commands.

A fresh PostgreSQL database can be initialized using:
```bash
alembic upgrade head
```

SecureCart also uses a separate seed script to populate the initial product catalog.

Schema migration and seed data are intentionally kept as separate concerns:
```text
alembic upgrade head
        |
        v
Schema created
        |
        v
python seed.py
        |
        v
Initial catalog populated

```

The seed process is idempotent.

If existing products are detected, the script skips them rather than inserting duplicates.

This allows migration and seed operations to be safely repeated during development and deployment.

The migration process was validated against completely empty temporary databases before being integrated into Kubernetes.

This design ensures that the database structure and initial application data can be recreated from repository-controlled artifacts.

## ADR-012: Kubernetes Database Migration Job Strategy

Introduced: v1.0.0

SecureCart executes database schema migrations using a dedicated Kubernetes Job.

The migration Job uses the SecureCart backend container image because the image contains:
```text
Alembic
alembic.ini
migration files
seed.py
PostgreSQL client libraries
```

The Job performs:
```text
alembic upgrade head
        |
        v
python seed.py

```

and terminates after successful completion.

A Kubernetes Job was selected instead of running migrations inside every backend Pod.

Running migration logic as part of backend Pod startup could result in multiple replicas attempting schema changes simultaneously during scaling or rolling updates.

The dedicated Job separates finite deployment operations from the long-running application workload.

The migration workload has its own Kubernetes identity:
```text
app=securecart
component=database-migration

```

The PostgreSQL NetworkPolicy explicitly authorizes this identity to communicate with the database on TCP port 5432.

This avoids disguising the migration workload as a backend Pod and preserves a clear least-privilege trust model.

The migration Job was validated against both:

- An already initialized SecureCart database
- A completely empty temporary PostgreSQL database

Against an existing database, migrations completed without destructive changes and the seed script skipped existing products.

Against an empty database, the Job created the schema and populated the initial product catalog.

This demonstrates that Kubernetes can initialize SecureCart's database without manual host-side migration commands.

### Helm Migration Lifecycle

After SecureCart adopted Helm, the migration Job lifecycle was refined to support repeatable application upgrades.

The Job remains a dedicated Kubernetes migration workload, but Helm now executes it as:

```text
pre-install
pre-upgrade
```

rather than treating the completed Job as an ordinary long-lived release resource.

This change was required because Kubernetes Job pod templates are immutable.

The migration Job uses the versioned backend image. Updating the backend image therefore changes the Job pod template. Attempting to patch an already completed fixed-name Job during a later Helm upgrade causes Kubernetes to reject the change.

The Helm chart now defines:

```yaml
annotations:
  "helm.sh/hook": pre-install,pre-upgrade
  "helm.sh/hook-weight": "-5"
  "helm.sh/hook-delete-policy": before-hook-creation
```

The resulting release lifecycle is:

```text
Helm Install / Upgrade
          |
          v
Migration Hook
          |
          v
alembic upgrade head
          |
          v
python seed.py
          |
          v
Application Release
```

This preserves the original ADR decision to separate database migration from backend Pod startup while aligning the finite migration workload with the Helm release operation that requires it.

The migration Job therefore remains an independently identifiable, least-privilege Kubernetes workload, but its lifecycle is controlled by Helm release hooks rather than ordinary resource patching.

---

## ADR-013: Container Runtime Hardening Strategy

Introduced: v1.0.0

SecureCart applies workload-specific runtime hardening rather than enforcing identical security controls across all containers.

The frontend, backend, and database migration workloads run as non-root users.

Backend

The backend runs as:
```text
uid=999(securecart)
gid=999(securecart)
```

The backend security context enforces:
```text
runAsNonRoot
no privilege escalation
all Linux capabilities dropped
read-only root filesystem
```

### Database Migration Job

The migration Job uses the same hardened SecureCart backend runtime identity:
```text
uid=999(securecart)
gid=999(securecart)
```

and the same runtime restrictions.

### Frontend

The frontend uses an unprivileged NGINX image and runs as:
```text
uid=101(nginx)
gid=101(nginx)
```

NGINX listens on unprivileged container port 8080.

The Kubernetes Service continues to expose port 80 and forwards traffic to container port 8080.

The frontend root filesystem is read-only.

Because NGINX requires limited writable runtime storage, Kubernetes provides an ephemeral emptyDir mounted at:
```text
/tmp
```

This creates the runtime boundary:
```text
Container root filesystem   Read Only
/tmp                        Writable

```

The frontend therefore receives only the writable filesystem area required for operation.

This strategy reduces runtime privileges while preserving required application behavior.

## ADR-014: PostgreSQL Security Compatibility Strategy

Introduced: v1.0.0

PostgreSQL receives a different runtime security profile from the stateless SecureCart application containers.

The PostgreSQL container initially appeared to execute with root privileges when inspected using an interactive container command.

Further inspection of the actual database process through /proc/1/status showed:
```text
Uid: 70 70 70 70
Gid: 70 70 70 70
```

The running PostgreSQL server therefore operates as:
```text
uid=70(postgres)
gid=70(postgres)
```

A controlled experiment was performed to determine whether Kubernetes could force PostgreSQL to run as UID and GID 70 from the beginning of the container lifecycle.

The test used:
```text
runAsUser: 70
runAsGroup: 70
runAsNonRoot: true
fsGroup: 70
```

against a fresh persistent volume.

The Pod failed during initialization with:
```text
chmod: /var/lib/postgresql/data: Operation not permitted
```

and:

```text
initdb: error: could not change permissions of directory
"/var/lib/postgresql/data": Operation not permitted
```

The experiment demonstrated that the PostgreSQL initialization workflow requires filesystem permission changes that were prevented by forcing non-root execution from container startup.

SecureCart therefore does not force PostgreSQL into the same runtime model used by the frontend and backend.

Instead:
```text
Container initialization behavior is preserved
        |
        v
PostgreSQL completes required filesystem preparation
        |
        v
Database server runs as UID/GID 70

```

Compatible security controls are applied without preventing database initialization.

This decision reflects the principle that security controls must be validated against actual workload requirements.

A control that prevents required initialization or causes application unavailability is adapted rather than enforced blindly.

The PostgreSQL persistent volume remains writable because database state must survive Pod recreation.

Future PostgreSQL hardening may be revisited when the application moves to a managed database platform or a database image specifically designed for fully non-root initialization.

## ADR-015: Container Registry and Image Versioning Strategy

Introduced: v1.0.0

SecureCart publishes versioned application container images to GitHub Container Registry.

Current application images are:
```text
ghcr.io/greatone33/securecart-backend:0.4.1
ghcr.io/greatone33/securecart-frontend:0.3.0
```

Previously, local Kubernetes development required:
```text
docker build
    |
    v
kind load docker-image
    |
    v
Kind cluster

```

The registry-backed workflow is now:
```text
docker build
    |
    v
GitHub Container Registry
    |
    v
Kubernetes image pull
    |
    v
Application workload

```

Kubernetes Deployments and the database migration Job reference GHCR image locations rather than local-only image names.

Registry accessibility was validated independently from the authenticated development environment by logging Docker out of GHCR and successfully pulling the published images.

This demonstrates that the application artifacts are not dependent on the developer's local Docker cache.

Versioned registry images establish a clear artifact boundary between:
```text
Application source
        |
        v
Container build
        |
        v
Versioned image
        |
        v
Kubernetes deployment

```

This strategy prepares SecureCart for future CI/CD automation.

GitHub Actions will eventually build, test, scan, and publish container images automatically.

The AWS deployment phase may replace GHCR with Amazon ECR while preserving the same registry-based deployment model.

---

## ADR-016: Helm Packaging and Release Management Strategy

**Introduced:** v1.1.0

SecureCart uses Helm as the package and release management layer for Kubernetes deployments.

Prior to this decision, SecureCart resources were deployed and managed through individual Kubernetes manifests under:

```text
kubernetes/base/
```

These manifests remain the foundational representation of the application's Kubernetes architecture, but static manifests require configuration changes to be made directly within individual resource definitions.

As the project moves toward automated deployment and multiple environments, SecureCart requires a reusable deployment interface that separates Kubernetes resource structure from environment-specific configuration.

Helm was selected to provide this abstraction.

The deployment model is:

```text
Deployment Configuration
        values.yaml
            |
            v
     Helm Templates
            |
            v
   Rendered Kubernetes
       Resources
            |
            v
      Helm Release
            |
            v
    Kubernetes Cluster
```

The SecureCart Helm chart is maintained under:

```text
helm/securecart/
```

The chart manages the application's:

```text
ConfigMap
Frontend Deployment and Service
Backend Deployment and Service
PostgreSQL StatefulSet and Service
Database Migration Job
Ingress
NetworkPolicies
```

Deployment-specific configuration is centralized in `values.yaml`.

This includes values such as:

```text
Replica counts
Container image repositories and tags
Image pull policies
Container and Service ports
Resource requests and limits
PostgreSQL storage configuration
Ingress configuration
TLS configuration
NetworkPolicy enablement
```

This approach allows the same resource templates to be reused with different deployment configurations rather than maintaining duplicate Kubernetes manifests for each environment.

Helm also establishes release state and revision history.

SecureCart deployments can therefore follow the lifecycle:

```text
helm install
     |
     v
Release Revision
     |
     v
helm upgrade
     |
     v
New Revision
     |
     v
helm rollback
     |
     v
Restored Configuration
```

A rollback creates a new Helm revision while preserving previous release history.

This behavior was validated by:

- Installing SecureCart as Helm release revision 1
- Upgrading the frontend replica count from three to four, creating revision 2
- Confirming Kubernetes added only the required additional replica
- Rolling back to revision 1 configuration
- Confirming Helm created revision 3
- Confirming Kubernetes returned the frontend to three replicas
- Validating the application and PostgreSQL-backed API after rollback

Existing Kubernetes resources were initially adopted into the Helm release using Helm ownership metadata rather than deleting and recreating the application.

Workload ownership and workload lifecycle are treated separately.

Helm becoming the manager of an existing Kubernetes resource does not itself require the underlying Pods to be recreated. Kubernetes performs workload changes according to differences in the desired resource specification.

The repository therefore retains two related deployment representations:

```text
kubernetes/base/
    Foundational Kubernetes manifests and architecture reference

helm/securecart/
    Parameterized deployment package and release interface
```

The Helm chart becomes the preferred deployment interface for future automated application deployments.

The base manifests remain valuable for direct Kubernetes learning, architecture inspection, troubleshooting, and understanding the resources generated by the chart.

Future CI/CD automation will deploy SecureCart through the Helm release interface rather than independently applying each Kubernetes manifest.

This establishes the intended deployment path:

```text
Source Control
      |
      v
CI/CD Pipeline
      |
      v
Helm Release
      |
      v
Kubernetes
```

This design provides a consistent foundation for local Kubernetes deployments and the future Amazon EKS deployment.

---

## ADR-017: CI Security Gate Strategy

**Introduced:** v1.2.0

SecureCart uses independent CI security gates to evaluate different security boundaries before changes are accepted.

Security scanning is separated by concern rather than relying on a single scanner or a single aggregate security job.

The current security model is:

```text
Source and Git History
        |
        v
Secret Detection
    Gitleaks
        |
        +-------------------+
        |                   |
        v                   v
Python Dependencies    Container Images
    pip-audit              Trivy
        |                   |
        +---------+---------+
                  |
                  v
           CI Gate Result
```

### Secret Detection

Gitleaks scans repository history for committed secrets.

This control protects the source-control boundary and is intentionally independent from application build or dependency validation.

### Dependency Vulnerability Scanning

pip-audit evaluates the Python dependency set defined by the backend requirements.

This control identifies known vulnerabilities in application-level Python dependencies.

Dependency scanning does not replace container scanning because application dependencies represent only one layer of the resulting runtime artifact.

### Container Vulnerability Scanning

Trivy evaluates the built backend and frontend container images.

The container security gate currently blocks images containing fixable vulnerabilities with either of the following severities:

```text
HIGH
CRITICAL
```

Unfixed vulnerabilities are reported by the scanner but are not currently used to fail the build.

The policy therefore evaluates actionable HIGH and CRITICAL findings rather than claiming that an accepted image contains zero vulnerabilities of any severity.

Both application images are scanned independently so a vulnerable backend or frontend image can fail the CI workflow.

### Fail-Closed Validation

Security controls are not considered complete solely because the scanner executes successfully.

Each security gate is deliberately tested with a controlled violation to verify that the CI workflow rejects the change.

The validation model is:

```text
Clean Baseline
      |
      v
Introduce Controlled Violation
      |
      v
Security Check Fails
      |
      v
Remove or Revert Violation
      |
      v
Security Check Passes
```

This approach has been used to validate secret detection, dependency vulnerability scanning, and container vulnerability scanning.

For the container vulnerability gate, a controlled regression removed the backend image's operating-system package upgrade step. Trivy then detected three fixable HIGH-severity findings and returned a non-zero exit code, causing the GitHub Actions security check to fail.

Reverting the controlled regression restored the hardened image and returned the complete CI workflow to a passing state.

### Independent Security Boundaries

The security gates remain separate CI jobs.

This provides clear failure attribution and prevents one security domain from obscuring another.

The resulting model is:

```text
Gitleaks
   |
   +--> Source and secret exposure

pip-audit
   |
   +--> Application dependency vulnerabilities

Trivy
   |
   +--> Container and operating-system vulnerabilities
```

A passing result from one security gate does not imply that another security boundary is safe.

This layered design establishes defense in depth within CI while keeping each policy explicit, independently testable, and explainable.

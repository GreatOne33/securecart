# SecureCart

> A production-style cloud-native application built to demonstrate Kubernetes, AWS, Terraform, DevSecOps, and Cloud Infrastructure engineering practices from development through production deployment.

---

## 🚧 Project Status

**Status:** In Progress

**Current Phase:** DevOps Engineering

### Phase 1 - Kubernetes Foundations ✅

- Kubernetes Deployments
- Services
- ConfigMaps
- Secrets
- Init Containers
- Health Probes
- Resource Requests & Limits
- Ingress with TLS
- NetworkPolicies

### Phase 2 - Application Development ✅

- Containerized SecureCart frontend
- Python FastAPI backend
- Containerized backend API
- Kubernetes backend Deployment and Service
- Frontend-to-backend NetworkPolicy
- NGINX API reverse proxy
- PostgreSQL persistent data layer
- PostgreSQL StatefulSet
- PersistentVolume and PersistentVolumeClaim storage
- FastAPI-to-PostgreSQL integration
- Database-backed product catalog
- Backend-to-PostgreSQL NetworkPolicy
- End-to-end persistence validation

SecureCart now runs as a stateful multi-tier Kubernetes application.

The frontend is packaged as a self-contained NGINX container that renders runtime configuration during startup. The backend runs as an independently containerized FastAPI application with multiple Kubernetes replicas. PostgreSQL provides persistent application data through a StatefulSet and dynamically provisioned persistent storage.

Application traffic follows a least-privilege path:

```text
Client
  |
  | HTTPS
  v
Ingress Controller
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
  |
  | TCP 5432
  v
PostgreSQL
  |
  v
Persistent Storage

```

NetworkPolicies restrict communication between application tiers so that only explicitly authorized workloads can communicate with the frontend, backend, and database.

Current milestone:

- Expand GitHub Actions continuous integration
- Introduce automated testing and security validation
- Add trusted container artifact publishing
- Automate Helm-based Kubernetes deployments

SecureCart is an ongoing engineering project designed to simulate the work of a Cloud Infrastructure / Platform Engineer. The project follows production-style engineering practices including Infrastructure as Code, Git-based workflows, documentation, containerization, application networking, persistent storage, and Kubernetes deployments.

---

## 🎯 Project Goals

- Build a production-style Kubernetes platform locally using Kind
- Deploy a multi-tier e-commerce application
- Package applications using Helm
- Build secure CI/CD automation with GitHub Actions
- Provision AWS infrastructure using Terraform
- Deploy to Amazon EKS
- Apply Cloud Security best practices
- Document engineering decisions throughout development

---

## ✨ Current Features

- Multi-tier Kubernetes application architecture
- Custom containerized NGINX frontend
- Python FastAPI backend
- PostgreSQL persistent data layer
- PostgreSQL StatefulSet
- PersistentVolumeClaim-based storage
- Database-backed product catalog
- Psycopg PostgreSQL integration
- Pydantic API response models
- Runtime application configuration
- Kubernetes Downward API integration
- Multiple frontend and backend replicas
- Kubernetes ClusterIP service discovery
- Headless PostgreSQL Service
- NGINX reverse proxy for `/api/*`
- HTTPS/TLS through NGINX Ingress
- Startup, readiness, and liveness probes
- Resource requests and limits
- Frontend, backend, and database NetworkPolicies
- Least-privilege tier-to-tier communication
- Persistent data across PostgreSQL Pod recreation
- End-to-end HTTPS application routing
- Alembic database schema migrations
- Idempotent database seed automation
- Kubernetes database migration Job
- Version-controlled database lifecycle
- Non-root frontend and backend containers
- Read-only application container root filesystems
- Dropped Linux capabilities
- Disabled privilege escalation
- Explicit writable runtime paths
- Versioned frontend and backend container images
- GitHub Container Registry image publishing

---

## 📈 Current Progress

### Infrastructure

- [x] GitHub Repository
- [x] Ubuntu Cloud Lab
- [x] Docker
- [x] kubectl
- [x] Kind
- [x] Helm

### Kubernetes

- [x] Kind Cluster
- [x] Pods
- [x] Deployments
- [x] ReplicaSets
- [x] Self-Healing
- [x] Scaling
- [x] ClusterIP Services
- [x] Service Discovery
- [x] Kubernetes DNS
- [x] Rolling Updates
- [x] Rollbacks

### Configuration

- [x] ConfigMaps
- [x] Kubernetes Secrets
- [x] Secret Environment Variables
- [x] Secret Volume Mounts
- [x] Init Containers
- [x] emptyDir Volumes
- [x] Downward API
- [x] Dynamic SecureCart Frontend

### Reliability

- [x] Startup Probes
- [x] Readiness Probes
- [x] Liveness Probes
- [x] Service endpoint health management
- [x] Container restart validation

### Resource Management

- [x] CPU Requests
- [x] Memory Requests
- [x] CPU Limits
- [x] Memory Limits
- [x] Burstable QoS

### Networking

- [x] ClusterIP Services
- [x] Kubernetes DNS
- [x] NGINX Ingress
- [x] Host-based Routing
- [x] HTTPS/TLS
- [x] HTTP Redirects
- [x] Backend Service Discovery
- [x] EndpointSlice Validation
- [x] Frontend NGINX Reverse Proxy
- [x] Internal API Routing

### Network Security

- [x] Isolate frontend Pods
- [x] Allow ingress-nginx namespace on TCP 80
- [x] Block unauthorized frontend access
- [x] Isolate backend Pods
- [x] Allow frontend workloads to backend TCP 8000
- [x] Block unauthorized backend access
- [x] Validate allowed and denied traffic paths

#### Application Containerization

- [x] Custom frontend Docker image
- [x] Docker entrypoint rendering
- [x] Local frontend Docker validation
- [x] Frontend image loaded into Kind
- [x] Deployment migrated to custom frontend image
- [x] Removed Init Container architecture
- [x] Custom backend Docker image
- [x] Local backend Docker validation
- [x] Backend image loaded into Kind
- [x] Frontend and backend local integration testing

### Backend API

- [x] Python FastAPI application
- [x] Health endpoint
- [x] Runtime status endpoint
- [x] Product collection endpoint
- [x] Individual product endpoint
- [x] Pydantic response models
- [x] HTTP 404 handling
- [x] Request validation
- [x] OpenAPI documentation
- [x] Kubernetes backend Deployment
- [x] Multiple backend replicas
- [x] Backend ClusterIP Service
- [x] Backend health probes
- [x] Backend Pod metadata through Downward API

### Application Integration

- [x] Frontend-to-backend Kubernetes DNS
- [x] NGINX `/api/*` reverse proxy
- [x] Frontend-to-backend NetworkPolicy
- [x] Backend Service load distribution
- [x] Local Docker integration test
- [x] End-to-end Kubernetes integration test

### Database and Persistent Storage

- [x] PostgreSQL
- [x] PostgreSQL StatefulSet
- [x] Headless PostgreSQL Service
- [x] PersistentVolumeClaim
- [x] Dynamically provisioned PersistentVolume
- [x] Stateful storage validation
- [x] PostgreSQL Pod recreation testing
- [x] FastAPI-to-PostgreSQL connectivity
- [x] Database connectivity endpoint
- [x] PostgreSQL-backed product catalog
- [x] Application-level persistence validation
- [x] Backend-to-PostgreSQL NetworkPolicy
- [x] Unauthorized database access validation
- [x] Least-privilege backend database access

### Database Lifecycle

- [x] Alembic migration framework
- [x] Version-controlled database schema
- [x] Empty-database migration validation
- [x] Idempotent product seed process
- [x] Kubernetes database migration Job
- [x] Migration workload database authorization
- [x] Repeatable migration and seed execution

### Container Security

- [x] Non-root backend runtime
- [x] Non-root frontend runtime
- [x] Read-only application root filesystems
- [x] Linux capabilities dropped
- [x] Privilege escalation disabled
- [x] Explicit writable frontend `/tmp`
- [x] PostgreSQL runtime identity investigation
- [x] PostgreSQL compatibility-preserving security configuration

### Container Registry

- [x] Versioned backend image
- [x] Versioned frontend image
- [x] GitHub Container Registry publishing
- [x] Registry image pull validation

### Helm and Release Management

- [x] Package SecureCart as a Helm chart
- [x] Parameterize deployment configuration with `values.yaml`
- [x] Validate chart with `helm lint`
- [x] Validate rendered manifests with `helm template`
- [x] Validate rendered resources against the Kubernetes API
- [x] Adopt existing Kubernetes resources into a Helm release
- [x] Validate Helm upgrade behavior
- [x] Validate Helm revision history
- [x] Validate Helm rollback behavior

### Continuous Integration

- [x] Configure GitHub Actions
- [x] Validate backend Python syntax and application imports
- [x] Validate frontend and backend container builds
- [x] Validate Helm charts and rendered Kubernetes manifests
- [x] Apply least-privilege workflow permissions
- [x] Gitleaks secret detection
- [x] Full-history secret scanning
- [x] Controlled secret-detection gate validation
- [x] Python dependency vulnerability scanning with `pip-audit`
- [x] Controlled vulnerable-dependency gate validation

#### Next

- [ ] Add automated application tests
- [ ] Expand CI security gates
- [ ] Add trusted container artifact publishing
- [ ] Automate Helm-based Kubernetes deployments
- [ ] Add post-deployment validation

---

## 🏗️ Current Architecture

```text
                         External Client
                                |
                              HTTPS
                                |
                                v
                     NGINX Ingress Controller
                                |
                                v
                     securecart-service :80
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
                                | TCP 8000
                                | NetworkPolicy
                                v
                securecart-backend-service :8000
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
                                | TCP 5432
                                | NetworkPolicy
                                v
                     securecart-postgres
                     Headless Service
                                |
                                v
                  +--------------------------+
                  | PostgreSQL StatefulSet   |
                  | securecart-postgres-0    |
                  +--------------------------+
                                |
                                v
                    PersistentVolumeClaim
                                |
                                v
                       PersistentVolume

```

```text
Configuration:
  ConfigMap ----------> Frontend / Backend
  Downward API -------> Pod Runtime Metadata
  Secret -------------> Application / Database Credentials

Network Boundaries:
  ingress-nginx ------> Frontend :80       ALLOWED
  Other workloads ---> Frontend :80       DENIED
  Frontend -----------> Backend :8000      ALLOWED
  Other workloads ---> Backend :8000      DENIED
  Backend ------------> PostgreSQL :5432   ALLOWED
  Frontend -----------> PostgreSQL :5432   DENIED
  Other workloads ---> PostgreSQL :5432   DENIED

```
---

## 🛠️ Technology Stack

### Cloud

- AWS *(planned)*

### Application

- Python
- FastAPI
- Pydantic
- Uvicorn
- NGINX
- PostgreSQL
- Psycopg
- Alembic

### Containers and Orchestration

- Docker
- Dockerfiles
- Kubernetes
- Kind
- Helm

### Kubernetes

- Deployments
- Services
- ConfigMaps
- Secrets
- Init Containers
- ReplicaSets
- Downward API
- emptyDir Volumes
- Ingress
- IngressClass
- TLS Secrets
- EndpointSlices
- Resource Requests and Limits
- Health Probes
- NetworkPolicies
- Kubernetes DNS
- StatefulSets
- PersistentVolumes
- PersistentVolumeClaims
- StorageClasses
- Headless Services
- Jobs

### Infrastructure as Code

- Terraform *(planned)*

### DevOps

- GitHub Container Registry
- Versioned container images
- Git-based workflows
- GitHub Actions
- Continuous integration
- Gitleaks secret detection
- CI security gates
- `pip-audit` dependency vulnerability scanning

### Version Control

- Git
- GitHub

---

## 🚀 Deploy Locally

SecureCart can be deployed to a local Kubernetes cluster using Helm.

The Helm chart is the preferred deployment interface and packages the frontend, backend, PostgreSQL database, database migration Job, Services, Ingress, ConfigMap, and NetworkPolicies into a single release.

The original Kubernetes manifests under `kubernetes/base/` remain available as the foundational Kubernetes implementation and architecture reference.

### Prerequisites

The local environment requires:

- Docker
- Kind
- kubectl
- Helm
- NGINX Ingress Controller
- Local DNS or `/etc/hosts` resolution for `securecart.local`
- TLS certificate and Kubernetes TLS Secret
- PostgreSQL Kubernetes Secret

Verify the primary tools:

```bash
docker --version
kind version
kubectl version --client
helm version
```

### Create the Kind Cluster

Create or start the SecureCart Kind cluster using the project's existing local cluster configuration.

Verify the cluster:

```bash
kubectl get nodes
```

Expected nodes:

```text
securecart-control-plane
securecart-worker
```

Both nodes should report:

```text
Ready
```

### Verify NGINX Ingress

SecureCart uses the NGINX Ingress Controller for external application traffic.

Verify that the controller is running:

```bash
kubectl get pods \
  -n ingress-nginx
```

The ingress controller must be available before validating the external HTTPS application path.

### Configure Local Host Resolution

The SecureCart Ingress uses:

```text
securecart.local
```

Verify that the hostname resolves to the local ingress endpoint.

For the local Kind environment, `/etc/hosts` can be used when required:

```text
127.0.0.1 securecart.local
```

Verify resolution:

```bash
getent hosts securecart.local
```

### PostgreSQL Secret

The Helm chart expects an existing Kubernetes Secret named:

```text
securecart-postgres-secret
```

The Secret provides:

```text
POSTGRES_DB
POSTGRES_USER
POSTGRES_PASSWORD
```

Do not commit plaintext database credentials to the repository.

Verify that the Secret exists:

```bash
kubectl get secret securecart-postgres-secret
```

### TLS Secret

SecureCart terminates HTTPS at the NGINX Ingress and expects the TLS Secret:

```text
securecart-tls
```

Verify that the Secret exists:

```bash
kubectl get secret securecart-tls
```

The default Helm configuration references this Secret through:

```yaml
ingress:
  enabled: true
  className: nginx
  host: securecart.local

  tls:
    enabled: true
    secretName: securecart-tls
```

### Validate the Helm Chart

Before installing the application, validate the chart:

```bash
helm lint helm/securecart
```

Render the Kubernetes resources locally:

```bash
helm template securecart \
  helm/securecart
```

For Kubernetes API validation, render the chart to a temporary manifest:

```bash
helm template securecart \
  helm/securecart \
  > /tmp/securecart-rendered.yaml
```

Then perform a server-side dry run:

```bash
kubectl apply \
  --dry-run=server \
  -f /tmp/securecart-rendered.yaml
```

This validates the rendered resources against the Kubernetes API without persisting them.

### Install SecureCart with Helm

Install the application:

```bash
helm install securecart \
  helm/securecart
```

The default release is installed into the current Kubernetes namespace.

Verify the Helm release:

```bash
helm list
```

Inspect release status:

```bash
helm status securecart
```

Inspect release history:

```bash
helm history securecart
```

A successful initial installation should create Helm release revision 1.

### Verify Kubernetes Resources

Verify the application workloads:

```bash
kubectl get deployments,statefulsets,jobs,pods
```

Verify application Services:

```bash
kubectl get svc
```

Verify the Ingress:

```bash
kubectl get ingress
```

Verify NetworkPolicies:

```bash
kubectl get networkpolicy
```

Verify persistent storage:

```bash
kubectl get pvc
```

The expected application architecture includes:

```text
Frontend Deployment
        |
        v
Frontend Service
        |
        v
Backend Deployment
        |
        v
Backend Service
        |
        v
PostgreSQL StatefulSet
        |
        v
PersistentVolumeClaim
```

The database migration Job initializes the version-controlled database schema and seed data before the application consumes the PostgreSQL-backed catalog.

### Validate the Application

Test the PostgreSQL-backed product API:

```bash
curl --max-time 10 -i \
  https://securecart.local/api/products
```

Expected HTTP status:

```text
HTTP/2 200
```

Test backend database connectivity:

```bash
curl --max-time 10 -i \
  https://securecart.local/api/db-status
```

Expected response:

```json
{
  "database": "PostgreSQL",
  "status": "connected",
  "test_query": 1
}
```

This validates the application path:

```text
Client
  |
  v
NGINX Ingress
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

### Helm Configuration

Default deployment configuration is stored in:

```text
helm/securecart/values.yaml
```

The values file controls configuration including:

```text
Application metadata
Frontend replica count
Backend replica count
Container image repositories and tags
Image pull policies
Service ports
CPU and memory requests
CPU and memory limits
PostgreSQL storage
Ingress configuration
TLS configuration
NetworkPolicy enablement
```

Inspect the default values:

```bash
cat helm/securecart/values.yaml
```

Render the chart with a temporary override:

```bash
helm template securecart \
  helm/securecart \
  --set frontend.replicaCount=4
```

This changes the rendered configuration without modifying `values.yaml`.

### Upgrade the Helm Release

After modifying the chart or deployment configuration, upgrade the existing release:

```bash
helm upgrade securecart \
  helm/securecart
```

Values can also be overridden during an upgrade.

For example:

```bash
helm upgrade securecart \
  helm/securecart \
  --set frontend.replicaCount=4
```

Verify the Deployment:

```bash
kubectl get deployment securecart-frontend
```

Inspect the new Helm revision:

```bash
helm history securecart
```

Helm creates a new release revision for a successful upgrade.

### Roll Back a Release

View the release history:

```bash
helm history securecart
```

Restore a previous revision:

```bash
helm rollback securecart <revision>
```

For example:

```bash
helm rollback securecart 1
```

Verify the resulting release:

```bash
helm status securecart
helm history securecart
```

Then validate the application again:

```bash
curl --max-time 10 -i \
  https://securecart.local/api/products

curl --max-time 10 -i \
  https://securecart.local/api/db-status
```

A rollback creates a new Helm revision while restoring the selected previous release configuration.

### Helm Release Lifecycle

The local deployment workflow is now:

```text
Source Code
    |
    v
Container Images
    |
    v
GitHub Container Registry
    |
    v
Helm Chart + values.yaml
    |
    v
helm install / helm upgrade
    |
    v
Helm Release
    |
    v
Kubernetes
```

Helm provides application packaging, configuration, release history, upgrades, and rollback.

Kubernetes remains responsible for workload reconciliation.

For example, changing only the frontend replica count causes Kubernetes to scale the existing ReplicaSet rather than recreate every frontend Pod.

### Raw Kubernetes Manifests

The original Kubernetes manifests are retained under:

```text
kubernetes/base/
```

These manifests remain useful for:

- Understanding the Kubernetes resources directly
- Kubernetes learning
- Architecture inspection
- Troubleshooting
- Comparing Helm-rendered resources with the underlying implementation

Helm is now the preferred deployment interface for SecureCart.

The base manifests remain the foundational Kubernetes architecture reference.

## 📁 Repository Structure

```text
securecart/
├── app/
│   ├── backend/
│   │   ├── migrations/
│   │   │   ├── versions/
│   │   │   │   └── bc2cf364d1fc_create_products_table.py
│   │   │   ├── env.py
│   │   │   ├── README
│   │   │   └── script.py.mako
│   │   ├── alembic.ini
│   │   ├── Dockerfile
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   └── seed.py
│   │
│   └── frontend/
│       ├── Dockerfile
│       ├── docker-entrypoint.sh
│       ├── index.html.template
│       └── nginx.conf.template
│
├── docs/
│   ├── testing/
│   │   └── health-probes.md
│   ├── architecture.md
│   ├── decisions.md
│   ├── engineering-journal.md
│   ├── roadmap.md
│   └── troubleshooting.md
│
├── helm/
│   └── securecart/
│       ├── templates/
│       │   ├── allow-backend-to-postgres.yaml
│       │   ├── allow-frontend-to-backend.yaml
│       │   ├── allow-ingress-to-frontend.yaml
│       │   ├── backend-deployment.yaml
│       │   ├── backend-service.yaml
│       │   ├── configmap.yaml
│       │   ├── database-migration-job.yaml
│       │   ├── frontend-deployment.yaml
│       │   ├── frontend-ingress.yaml
│       │   ├── frontend-service.yaml
│       │   ├── postgres-service.yaml
│       │   └── postgres-statefulset.yaml
│       ├── Chart.yaml
│       └── values.yaml
│
├── kind/
│   └── cluster.yaml
│
├── kubernetes/
│   └── base/
│       ├── network-policies/
│       │   ├── allow-backend-to-postgres.yaml
│       │   ├── allow-frontend-to-backend.yaml
│       │   └── allow-ingress-to-frontend.yaml
│       ├── secrets/
│       │   ├── postgres-secret-example.yaml
│       │   └── secret-example.yaml
│       ├── backend-deployment.yaml
│       ├── backend-service.yaml
│       ├── configmap.yaml
│       ├── database-migration-job.yaml
│       ├── frontend-deployment.yaml
│       ├── frontend-ingress.yaml
│       ├── frontend-service.yaml
│       ├── postgres-service.yaml
│       └── postgres-statefulset.yaml
│
├── .gitignore
├── LICENSE
└── README.md
```

### Application

`app/` contains the SecureCart application source and container definitions.

The backend includes the FastAPI application, PostgreSQL integration, Alembic migration framework, and idempotent database seed process.

The frontend contains the unprivileged NGINX-based application image, runtime entrypoint, application template, and reverse-proxy configuration.

### Helm

`helm/securecart/` contains the preferred Kubernetes deployment package.

The chart parameterizes deployment configuration through `values.yaml` and renders the complete SecureCart Kubernetes architecture, including:

- Frontend and backend Deployments
- Application Services
- PostgreSQL StatefulSet and headless Service
- Database migration Job
- ConfigMap
- HTTPS Ingress
- Application NetworkPolicies

Helm provides release installation, upgrades, revision history, and rollback.

### Kubernetes

`kubernetes/base/` contains the foundational Kubernetes manifests used to build and validate the application architecture before Helm packaging.

These manifests remain useful for:

- Kubernetes learning
- Direct resource inspection
- Architecture reference
- Troubleshooting
- Comparing raw manifests with Helm-rendered resources

### Kind

`kind/cluster.yaml` defines the local multi-node Kind cluster used for SecureCart development and testing.

### Documentation

`docs/` contains the project's engineering documentation:

- `architecture.md` — application and deployment architecture
- `decisions.md` — Architecture Decision Records
- `engineering-journal.md` — implementation history and lessons learned
- `roadmap.md` — project milestones
- `troubleshooting.md` — investigated failures and resolutions
- `testing/` — focused validation procedures

## 📚 Documentation

Project documentation is maintained throughout development.

- [Engineering Journal](docs/engineering-journal.md)
- [Architecture](docs/architecture.md)
- [Design Decisions](docs/decisions.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Roadmap](docs/roadmap.md)

---

## 🚀 Current Focus

**Current milestone:** Secure CI/CD automation with GitHub Actions

SecureCart has completed its initial Helm packaging and release-management milestone.

SecureCart now also includes an initial GitHub Actions continuous integration pipeline. Every push and pull request to `main` automatically validates the backend application, builds both application container images, and validates the Helm deployment package before changes progress further through the delivery lifecycle.

The application now includes:

- Version-controlled PostgreSQL schema migrations with Alembic
- Idempotent database seed automation
- Kubernetes database migration Job
- Persistent PostgreSQL storage
- Least-privilege application NetworkPolicies
- Hardened non-root frontend and backend containers
- Read-only application root filesystems
- Dropped Linux capabilities and disabled privilege escalation
- Versioned application container images
- GitHub Container Registry publishing
- Helm-based Kubernetes application packaging
- Parameterized deployment configuration through `values.yaml`
- Helm release ownership and revision history
- Validated Helm upgrade and rollback workflows
- End-to-end HTTPS application validation
- GitHub Actions continuous integration
- Automated backend syntax and application import validation
- Automated frontend and backend container build validation
- Automated Helm linting and manifest rendering
- Least-privilege GitHub Actions workflow permissions
- Gitleaks secret detection security gate
- Full-history repository secret scanning
- Controlled secret-detection gate validation
- Python dependency vulnerability scanning with `pip-audit`
- Controlled dependency vulnerability gate validation

SecureCart's CI security controls have been validated through controlled failure and recovery tests. Gitleaks successfully blocked a synthetic credential pattern, and `pip-audit` blocked an isolated pull request containing `urllib3==1.26.5`, detecting 10 known vulnerabilities before the dependency was removed and the pipeline returned to a passing state.

The current deployment lifecycle is:

```text
Application Source
       |
       v
Container Images
       |
       v
GitHub Container Registry
       |
       v
    Helm Chart
       |
       v
   Helm Release
       |
       v
Kubernetes Workloads
       |
       +------> Database Migration Job
       |               |
       |               v
       |           PostgreSQL
       |
       +------> Frontend / Backend
```

The current Helm release lifecycle supports:

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
```

Upcoming work:

- Add container image vulnerability scanning
- Add Kubernetes and Helm configuration scanning
- Add trusted container artifact publishing
- Automate Helm-based Kubernetes deployments
- Add post-deployment validation

**Long-term goal:** Deploy SecureCart to Amazon EKS using Terraform, Helm, and GitHub Actions.

---

## 🎓 Learning Objectives

This project is designed to strengthen practical experience in:

- Kubernetes
- Cloud Infrastructure
- Infrastructure as Code
- DevSecOps
- Cloud Security
- Platform Engineering

---

## 📄 License

MIT License
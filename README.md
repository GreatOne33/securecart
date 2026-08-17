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

Next milestone:

- Create a Helm chart
- Configure GitHub Actions
- Introduce automated testing
- Automate Kubernetes deployments

SecureCart is an ongoing engineering project designed to simulate the work of a Cloud Infrastructure / Platform Engineer. The project follows production-style engineering practices including Infrastructure as Code, Git-based workflows, documentation, containerization, application networking, persistent storage, and Kubernetes deployments.

---

## 🎯 Project Goals

- Build a production-style Kubernetes platform locally using Kind
- Deploy a multi-tier e-commerce application
- Package applications using Helm
- Automate deployments with GitHub Actions
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

#### Next

- [ ] Create Helm chart
- [ ] Configure GitHub Actions
- [ ] Automated testing
- [ ] Automated Kubernetes deployments

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
- GitHub Actions *(planned)*
- CI/CD automation *(planned)*

### Version Control

- Git
- GitHub

---

## ▶️ Deploy Locally

The following steps deploy the complete SecureCart application to a local Kind cluster.

The deployment includes:

- SecureCart frontend
- FastAPI backend
- Kubernetes Services
- NGINX Ingress Controller
- HTTPS/TLS
- Frontend and backend NetworkPolicies

### Prerequisites

Ensure the following tools are installed:

- Docker
- Kind
- kubectl
- Git
- OpenSSL
- curl

Verify installation:

```bash
docker --version
kind --version
kubectl version --client
git --version
openssl version
curl --version
```

---

### Clone the Repository

```bash
git clone https://github.com/GreatOne33/securecart.git

cd securecart
```

---

### Create the Kind Cluster

```bash
kind create cluster \
  --name securecart \
  --config kind/cluster.yaml
```

Verify the cluster:

```bash
kubectl cluster-info

kubectl get nodes
```

Expected:

```text
NAME                       STATUS   ROLES           AGE
securecart-control-plane   Ready    control-plane
securecart-worker          Ready    <none>
```

---

### Application Images

SecureCart uses versioned container images published to GitHub Container Registry.

Frontend:

```text
ghcr.io/greatone33/securecart-frontend:0.3.0
```

Backend:

```text
ghcr.io/greatone33/securecart-backend:0.4.1
```

The Kubernetes Deployments and database migration Job pull these images directly from GHCR.

Verify the published images:

```bash
docker pull \
  ghcr.io/greatone33/securecart-frontend:0.3.0

docker pull \
  ghcr.io/greatone33/securecart-backend:0.4.1
```

The registry-backed deployment model replaces the previous local Kind image-loading workflow.

```text
Application Source
      |
      v
Container Build
      |
      v
GitHub Container Registry
      |
      v
Kubernetes Image Pull

```
---

### Deploy Application Configuration

Apply the SecureCart ConfigMap:

```bash
kubectl apply \
  -f kubernetes/base/configmap.yaml
```

Apply the example Secret:

```bash
kubectl apply \
  -f kubernetes/base/secrets/secret-example.yaml
```

### Deploy PostgreSQL

Apply the PostgreSQL Secret example:

```bash
kubectl apply \
  -f kubernetes/base/secrets/postgres-secret-example.yaml
```

> The example Secret contains development-only credentials. Production credentials must not be committed to source control.

Create the PostgreSQL headless Service:

```bash
kubectl apply \
  -f kubernetes/base/postgres-service.yaml
```

Deploy the PostgreSQL StatefulSet:

```bash
kubectl apply \
  -f kubernetes/base/postgres-statefulset.yaml
```

Wait for PostgreSQL to become Ready:

```bash
kubectl rollout status \
  statefulset/securecart-postgres
```

Verify the database Pod and persistent storage:

```bash
kubectl get pod securecart-postgres-0

kubectl get pvc

kubectl get pv
```

Verify PostgreSQL readiness:

```bash
kubectl exec securecart-postgres-0 -- \
  pg_isready \
  -U securecart_app \
  -d securecart
```

Expected:

```text
/var/run/postgresql:5432 - accepting connections
```

### Initialize the Database

SecureCart manages its PostgreSQL schema through version-controlled Alembic migrations and populates initial application data through an idempotent seed process.

Run the Kubernetes database migration Job:

```bash
kubectl apply \
  -f kubernetes/base/database-migration-job.yaml
```

Wait for the Job to complete:

```bash
kubectl wait \
  --for=condition=complete \
  job/securecart-db-migration \
  --timeout=120s
```

Review the migration and seed output:

```bash
kubectl logs \
  job/securecart-db-migration
```

Expected output on an already initialized database resembles:

```text
Skipping existing product: SecureCart T-Shirt
Skipping existing product: SecureCart Hoodie
Skipping existing product: SecureCart Sticker Pack
```

Verify the resulting database schema:

```bash
kubectl exec securecart-postgres-0 -- \
  psql \
  -U securecart_app \
  -d securecart \
  -c "\dt"
```

The database should contain the Alembic version table and SecureCart product table.

The migration Job provides a repeatable deployment-time database lifecycle:

```text
Alembic Migration
       |
       v
PostgreSQL Schema
       |
       v
Idempotent Seed
       |
       v
Application Data

```

---

### Deploy the Backend

Deploy the FastAPI backend:

```bash
kubectl apply \
  -f kubernetes/base/backend-deployment.yaml

kubectl apply \
  -f kubernetes/base/backend-service.yaml
```

Wait for the backend rollout:

```bash
kubectl rollout status \
  deployment/securecart-backend
```

Verify the backend Pods and Service:

```bash
kubectl get pods \
  -l app=securecart,component=backend

kubectl get svc securecart-backend-service
```

Verify that the Service discovered the backend Pods:

```bash
kubectl get endpointslice \
  -l kubernetes.io/service-name=securecart-backend-service \
  -o wide
```

---

### Apply the PostgreSQL NetworkPolicy

Restrict PostgreSQL ingress to explicitly authorized SecureCart database clients:

```bash
kubectl apply \
  -f kubernetes/base/network-policies/allow-backend-to-postgres.yaml
```

Verify:
```bash
kubectl get networkpolicy
```

The complete application trust boundaries are:
```text
ingress-nginx -> Frontend :80            ALLOWED
Other Pods    -> Frontend :80            DENIED

Frontend      -> Backend :8000           ALLOWED
Other Pods    -> Backend :8000           DENIED

Backend       -> PostgreSQL :5432        ALLOWED
Migration Job -> PostgreSQL :5432        ALLOWED
Frontend      -> PostgreSQL :5432        DENIED
Other Pods    -> PostgreSQL :5432        DENIED

```

### Deploy the Frontend

Deploy the SecureCart frontend:

```bash
kubectl apply \
  -f kubernetes/base/frontend-deployment.yaml

kubectl apply \
  -f kubernetes/base/frontend-service.yaml
```

Wait for the frontend rollout:

```bash
kubectl rollout status \
  deployment/securecart-frontend
```

Verify the frontend Pods and Service:

```bash
kubectl get pods \
  -l app=securecart,component=frontend

kubectl get svc securecart-service
```

At this point both application tiers should be running:

```text
Frontend Pods
      |
      v
securecart-backend-service
      |
      v
Backend Pods
```

---

### Install the NGINX Ingress Controller

Install ingress-nginx for Kind:

```bash
kubectl apply \
  -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

---

### Pin the Ingress Controller to the Mapped Node

The Kind cluster maps host ports 80 and 443 to the control-plane node.

Label the node:

```bash
kubectl label node securecart-control-plane \
  ingress-ready=true \
  --overwrite
```

Configure the Ingress Controller to run on that node:

```bash
kubectl patch deployment ingress-nginx-controller \
  -n ingress-nginx \
  --type=merge \
  -p '{
    "spec": {
      "template": {
        "spec": {
          "nodeSelector": {
            "kubernetes.io/os": "linux",
            "ingress-ready": "true"
          }
        }
      }
    }
  }'

```

Wait for the controller:

```bash
kubectl rollout status \
  deployment/ingress-nginx-controller \
  -n ingress-nginx
```

Verify:

```bash
kubectl get pods \
  -n ingress-nginx \
  -o wide
```

---

### Generate Local TLS Certificates

Create a local TLS directory:

```bash
mkdir -p .local/tls
```

Generate a self-signed certificate:

```bash
openssl req \
  -x509 \
  -nodes \
  -newkey rsa:2048 \
  -sha256 \
  -days 365 \
  -keyout .local/tls/securecart.local.key \
  -out .local/tls/securecart.local.crt \
  -subj "/CN=securecart.local/O=SecureCart" \
  -addext "subjectAltName=DNS:securecart.local"
```

---

### Create the Kubernetes TLS Secret

```bash
kubectl create secret tls securecart-tls \
  --cert=.local/tls/securecart.local.crt \
  --key=.local/tls/securecart.local.key
```

Verify:

```bash
kubectl get secret securecart-tls
```

---

### Deploy the Ingress

```bash
kubectl apply \
  -f kubernetes/base/frontend-ingress.yaml
```

Verify:

```bash
kubectl get ingress
```

---

### Configure Local DNS

Add the following entry to your hosts file:

```text
127.0.0.1 securecart.local
```

Linux/macOS:

```text
/etc/hosts
```

Windows:

```text
C:\Windows\System32\drivers\etc\hosts
```

---

### Verify HTTPS Access

Verify that the frontend is accessible through the Ingress Controller:

```bash
curl --max-time 5 -I \
  https://securecart.local
```

Expected:

```text
HTTP/2 200
```

You may also browse to:

```text
https://securecart.local
```

The browser may warn about the self-signed development certificate.

---

### Apply the Frontend NetworkPolicy

Restrict frontend ingress to the NGINX Ingress Controller:

```bash
kubectl apply \
  -f kubernetes/base/network-policies/allow-ingress-to-frontend.yaml
```

Verify:

```bash
kubectl get networkpolicy
```

---

### Apply the Backend NetworkPolicy

Restrict backend ingress to SecureCart frontend workloads:

```bash
kubectl apply \
  -f kubernetes/base/network-policies/allow-frontend-to-backend.yaml
```

Verify:

```bash
kubectl get networkpolicy
```

The intended network boundaries are:

```text
ingress-nginx -> Frontend :80       ALLOWED
Other Pods    -> Frontend :80       DENIED

Frontend      -> Backend :8000      ALLOWED
Other Pods    -> Backend :8000      DENIED
```

### Validate PostgreSQL Network Isolation

Verify that an unauthorized workload cannot reach PostgreSQL:

```bash
kubectl run postgres-test \
  --image=postgres:17-alpine \
  --restart=Never \
  --rm -i \
  -- pg_isready \
  -h securecart-postgres \
  -p 5432 \
  -t 5
  ```
  Expected:

  ```text
  securecart-postgres:5432 - no response
  ```

  Verify that a frontend workload cannot reach PostgreSQL:
  ```text
  kubectl run frontend-postgres-test \
  --image=postgres:17-alpine \
  --restart=Never \
  --labels="app=securecart,component=frontend" \
  --rm -i \
  -- pg_isready \
  -h securecart-postgres \
  -p 5432 \
  -t 5
  ```

Expected:
```text
  securecart-postgres:5432 - no response
  ```

Verify that a backend workload can reach PostgreSQL:
```text
kubectl run backend-postgres-test \
  --image=postgres:17-alpine \
  --restart=Never \
  --labels="app=securecart,component=backend" \
  --rm -i \
  -- pg_isready \
  -h securecart-postgres \
  -p 5432 \
  -t 5
```

Expected:
```text
securecart-postgres:5432 - accepting connections
```

This validates the database trust boundary:
```text
Backend ------------> PostgreSQL :5432   ALLOWED
Migration Job ------> PostgreSQL :5432   ALLOWED
Frontend -----------> PostgreSQL :5432   DENIED
Other workloads ----> PostgreSQL :5432   DENIED
```

---

### Validate Frontend Network Isolation

Traffic through the NGINX Ingress Controller should succeed:

```bash
curl --max-time 5 -I \
  https://securecart.local
```

Expected:

```text
HTTP/2 200
```

Direct traffic from an unauthorized Pod to the frontend should fail:

```bash
kubectl run network-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -i \
  -- wget -T 5 -qO- \
  http://securecart-service
```

Expected:

```text
wget: download timed out
```

---

### Validate Backend Network Isolation

Verify that an unauthorized Pod cannot access the backend:

```bash
kubectl run backend-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -i \
  -- wget -T 5 -qO- \
  http://securecart-backend-service:8000/api/status
```

Expected:

```text
wget: download timed out
```

Now test using the SecureCart frontend workload identity:

```bash
kubectl run frontend-network-test \
  --image=busybox:1.36 \
  --restart=Never \
  --labels="app=securecart,component=frontend" \
  --rm -i \
  -- wget -qO- \
  http://securecart-backend-service:8000/api/status
```

Expected output resembles:

```json
{
  "application": "SecureCart Backend",
  "version": "0.1.0",
  "environment": "Staging",
  "pod": "securecart-backend-...",
  "status": "running"
}
```

This validates:

```text
Frontend workload -> Backend :8000   ALLOWED
Other workload    -> Backend :8000   DENIED
```

---

### Validate End-to-End API Routing

Finally, test the complete SecureCart application path:

```bash
curl -i \
  https://securecart.local/api/products
```

Expected:

```text
HTTP/2 200
content-type: application/json
```

The response should contain the SecureCart product catalog.

This validates the complete request path:

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
  |
  | SQL / TCP 5432
  v
PostgreSQL
  |
  v
Persistent Storage
```

The frontend, backend, and PostgreSQL database remain internal Kubernetes workloads. Only the application entry point is exposed through Ingress.

---

### Validate Database Persistence

Verify the current product catalog:

```bash
curl -i \
  https://securecart.local/api/products
```

Delete the PostgreSQL Pod:

```bash
kubectl delete pod securecart-postgres-0
```

The StatefulSet automatically recreates the database Pod.

Wait until it becomes Ready:

```bash
kubectl get pods -w
```

Then query the product API again:

```bash
curl -i \
  https://securecart.local/api/products
```

The product catalog should remain available because PostgreSQL data is stored independently of the Pod lifecycle through the PersistentVolumeClaim.

Verify that the claim remains bound:

```bash
kubectl get pvc

kubectl get pv
```

---

### Final Deployment Verification

Verify the complete application:

```bash
kubectl get deployments

kubectl get statefulsets

kubectl get pods

kubectl get svc

kubectl get pvc

kubectl get pv

kubectl get ingress

kubectl get networkpolicy
```

Frontend and backend Deployments should be available, the PostgreSQL StatefulSet should report `1/1` Ready, the database PVC should be `Bound`, and all application Pods should be Ready.

---

### Clean Up

Delete the local cluster when finished:

```bash
kind delete cluster \
  --name securecart
```

---

## 📁 Repository Structure

```text
securecart/
├── app/
│   ├── frontend/
│   │   ├── Dockerfile
│   │   ├── docker-entrypoint.sh
│   │   ├── index.html.template
│   │   └── nginx.conf.template
│   │
│   └── backend/
│       ├── migrations/
│       ├── alembic.ini
│       ├── Dockerfile
│       ├── main.py
│       ├── requirements.txt
│       └── seed.py
│
├── docs/
│   ├── architecture.md
│   ├── decisions.md
│   ├── engineering-journal.md
│   ├── roadmap.md
│   └── troubleshooting.md
│
├── kind/
│   └── cluster.yaml
│
└── kubernetes/
    └── base/
        ├── backend-deployment.yaml
        ├── backend-service.yaml
        ├── configmap.yaml
        ├── database-migration-job.yaml
        ├── frontend-deployment.yaml
        ├── frontend-ingress.yaml
        ├── frontend-service.yaml
        ├── postgres-service.yaml
        ├── postgres-statefulset.yaml
        ├── network-policies/
        │   ├── allow-backend-to-postgres.yaml
        │   ├── allow-frontend-to-backend.yaml
        │   └── allow-ingress-to-frontend.yaml
        └── secrets/
            ├── postgres-secret-example.yaml
            └── secret-example.yaml
```

---

## 📚 Documentation

Project documentation is maintained throughout development.

- [Engineering Journal](docs/engineering-journal.md)
- [Architecture](docs/architecture.md)
- [Design Decisions](docs/decisions.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Roadmap](docs/roadmap.md)

---

## 🚀 Current Focus

**Current milestone:** Helm packaging and deployment standardization

SecureCart has entered the DevOps engineering phase.

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
- End-to-end HTTPS application validation

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
Kubernetes Workloads
       |
       +------> Database Migration Job
       |               |
       |               v
       |           PostgreSQL
       |
       +------> Frontend / Backend
```

Upcoming work:
- Create a Helm chart
- Configure GitHub Actions
- Introduce automated testing
- Automate Kubernetes deployments

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
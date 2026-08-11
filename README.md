# SecureCart

> A production-style cloud-native application built to demonstrate Kubernetes, AWS, Terraform, DevSecOps, and Cloud Infrastructure engineering practices from development through production deployment.

---

## 🚧 Project Status

**Status:** In Progress

**Current Phase:** Application Development

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

### Phase 2 - Application Development 🚧

✅ Containerized SecureCart frontend
✅ Python FastAPI backend
✅ Containerized backend API
✅ Kubernetes backend Deployment and Service
✅ Frontend-to-backend NetworkPolicy
✅ NGINX API reverse proxy
✅ End-to-end frontend-to-backend integration

SecureCart now runs as a multi-tier Kubernetes application.

The frontend is packaged as a self-contained NGINX container that renders runtime configuration during startup. The backend runs as an independently containerized FastAPI application with multiple Kubernetes replicas.

API requests are routed through the frontend NGINX container to an internal Kubernetes ClusterIP Service:

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

```

**Next milestone:**

- Deploy PostgreSQL
- Configure persistent storage
- Connect the FastAPI backend to PostgreSQL
- Replace in-memory product data with database-backed data

SecureCart is an ongoing engineering project designed to simulate the work of a Cloud Infrastructure / Platform Engineer. The project follows production-style engineering practices including Infrastructure as Code, Git-based workflows, documentation, containerization, application networking, and Kubernetes deployments.

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
- Pydantic API response models
- Runtime application configuration
- Kubernetes Downward API integration
- Multiple frontend and backend replicas
- Kubernetes ClusterIP service discovery
- NGINX reverse proxy for `/api/*`
- HTTPS/TLS through NGINX Ingress
- Startup, readiness, and liveness probes
- Resource requests and limits
- Frontend and backend NetworkPolicies
- Least-privilege frontend-to-backend communication
- End-to-end HTTPS application routing

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

#### Next

- [ ] Deploy PostgreSQL
- [ ] Configure Persistent Volumes
- [ ] Configure Persistent Volume Claims
- [ ] Connect FastAPI to PostgreSQL
- [ ] Replace in-memory product data with database-backed data

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
                  +-------------+-------------+
                  |                           |
                  v                           v
        +-------------------+       +-------------------+
        | FastAPI Backend   |       | FastAPI Backend   |
        | Pod               |       | Pod               |
        +-------------------+       +-------------------+

Configuration:
  ConfigMap ----------> Frontend / Backend
  Downward API -------> Pod Runtime Metadata

Network Boundaries:
  ingress-nginx ------> Frontend :80       ALLOWED
  Other workloads ---> Frontend :80       DENIED
  Frontend -----------> Backend :8000      ALLOWED
  Other workloads ---> Backend :8000      DENIED

Future:
  FastAPI Backend ---> PostgreSQL ---> Persistent Storage

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

### Infrastructure as Code

- Terraform *(planned)*

### DevOps

- GitHub Actions *(planned)*
- CI/CD automation *(planned)*
- Git-based workflows

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

### Build the Application Images

Build the SecureCart frontend:

```bash
docker build \
  -t securecart-frontend:0.2.0 \
  app/frontend
```

Build the SecureCart backend:

```bash
docker build \
  -t securecart-backend:0.1.0 \
  app/backend
```

Verify both images:

```bash
docker images | grep securecart
```

---

### Load the Images into Kind

Kind nodes use their own container runtime, so locally built images must be loaded into the cluster.

Load the frontend image:

```bash
kind load docker-image \
  securecart-frontend:0.2.0 \
  --name securecart
```

Load the backend image:

```bash
kind load docker-image \
  securecart-backend:0.1.0 \
  --name securecart
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
```

The backend remains internal to the Kubernetes cluster and is not exposed directly through Ingress.

---

### Final Deployment Verification

Verify the complete application:

```bash
kubectl get deployments

kubectl get pods

kubectl get svc

kubectl get ingress

kubectl get networkpolicy
```

Both frontend and backend Deployments should be available and all application Pods should be Ready.

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
│       ├── Dockerfile
│       ├── main.py
│       └── requirements.txt
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
        ├── frontend-deployment.yaml
        ├── frontend-ingress.yaml
        ├── frontend-service.yaml
        ├── network-policies/
        │   ├── allow-frontend-to-backend.yaml
        │   └── allow-ingress-to-frontend.yaml
        └── secrets/
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

**Current milestone:** Add the SecureCart persistent data layer

The stateless multi-tier application architecture is now operational:

```text
Frontend -> FastAPI Backend
```

Upcoming work:

- Deploy PostgreSQL
- Configure Persistent Volumes
- Configure Persistent Volume Claims
- Connect FastAPI to PostgreSQL
- Replace in-memory product data with database-backed data
- Apply least-privilege network access between the backend and database

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
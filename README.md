# SecureCart

> A production-style cloud-native application built to demonstrate Kubernetes, AWS, Terraform, DevSecOps, and Cloud Infrastructure engineering practices from development through production deployment.

---

## 🚧 Project Status

**Status:** In Progress

**Current Phase:** Application Development

SecureCart is an ongoing engineering project designed to simulate the work of a Cloud Infrastructure / Platform Engineer. The project follows production-style engineering practices including Infrastructure as Code, Git-based workflows, documentation, and Kubernetes deployments.

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

- Multi-replica Kubernetes Deployment
- ClusterIP Service
- Kubernetes DNS
- Rolling Updates
- Rollbacks
- ConfigMap-driven configuration
- Kubernetes Secrets
- Dynamic HTML generation
- Init Containers
- Downward API
- Startup, Readiness, and Liveness Probes
- CPU and Memory Requests
- CPU and Memory Limits
- Burstable QoS
- Application-aware Service traffic management
- Production-style documentation
- NGINX Ingress Controller
- Host-based Routing
- HTTPS/TLS
- HTTP → HTTPS Redirect
- Locally generated TLS certificate
- System trust-store validation with curl
- Namespace-scoped NetworkPolicies
- Least-privilege ingress controls
- Internal traffic segmentation
- Add the Custom SecureCart frontend Image
- Removed the init Container from the Current Architecture 

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

### Network Security

- [x] Isolate frontend Pods
- [x] Allow ingress-nginx namespace on TCP 80
- [x] Block unauthorized Pod access
- [x] Validate allowed and denied traffic paths

#### Next

- [X] Containerize custom frontend
- [ ] Build backend API
- [ ] Containerize backend

---

## 🏗️ Current Architecture

```text
                         Kubernetes Cluster

                               Browser
                                  │
                            HTTPS :443
                                  │
                                  ▼
                     NGINX Ingress Controller
                         TLS Termination
                                  │
                                  ▼
                       securecart-ingress
                                  │
                                  ▼
                  securecart-service (ClusterIP)
                                  │
               ┌──────────────────┼──────────────────┐
               ▼                  ▼                  ▼
        Frontend Pod       Frontend Pod       Frontend Pod
        

```

---

## 🛠️ Technology Stack

### Cloud

- AWS *(planned)*

### Containers and Orchestration

- Docker
- Kubernetes
- Kind
- NGINX
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

## Clone the Repository

```bash
git clone https://github.com/GreatOne33/securecart.git

cd securecart
```

---

## Create the Kind Cluster

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

```
NAME                 STATUS   ROLES           AGE
securecart-control-plane   Ready   control-plane
securecart-worker          Ready   <none>
```

---

## Deploy SecureCart

```bash
kubectl apply -f kubernetes/base/configmap.yaml
kubectl apply -f kubernetes/base/secrets/secret-example.yaml
kubectl apply -f kubernetes/base/frontend-content.yaml
kubectl apply -f kubernetes/base/frontend-deployment.yaml
kubectl apply -f kubernetes/base/frontend-service.yaml
```

Verify:

```bash
kubectl get deployments

kubectl get pods
```

Wait until the pod shows:

```
READY   STATUS
1/1     Running
```

---

## Deploy the Service

```bash
kubectl apply \
  -f kubernetes/base/frontend-service.yaml
```

Verify:

```bash
kubectl get svc
```

---

## Install the NGINX Ingress Controller

```bash
kubectl apply \
  -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```
````markdown
## Pin the Ingress Controller to the Mapped Node

```bash
kubectl label node securecart-control-plane \
  ingress-ready=true \
  --overwrite

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
kubectl rollout status deployment/ingress-nginx-controller \
  -n ingress-nginx
```

Verify:
``` bash
kubectl rollout status deployment/ingress-nginx-controller \
  -n ingress-nginx

kubectl get pods -n ingress-nginx -o wide
```

---

## Generate Local TLS Certificates

Create a directory:

```bash
mkdir -p .local/tls
```

Generate the certificate:

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

## Create the Kubernetes TLS Secret

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

## Deploy the Ingress

```bash
kubectl apply \
  -f kubernetes/base/frontend-ingress.yaml
```

Verify:

```bash
kubectl get ingress
```

---

## Configure Local DNS

Add the following entry to your hosts file.

Linux/macOS:

```
/etc/hosts
```

Windows:

```
C:\Windows\System32\drivers\etc\hosts
```

Add:

```
127.0.0.1 securecart.local
```

---

## Verify HTTPS Access

```bash
curl --max-time 5 -I https://securecart.local
```

Expected:

```
HTTP/2 200
```

You may also browse to:

```
https://securecart.local
```

Your browser will warn about the self-signed certificate. Accept the warning to continue.

---

## Apply the Frontend NetworkPolicy

```bash
kubectl apply \
  -f kubernetes/base/network-policies/allow-ingress-to-frontend.yaml
```

Verify:

```bash
kubectl get networkpolicy
```

Expected:

```
NAME                         POD-SELECTOR
allow-ingress-to-frontend    app=securecart,component=frontend
```

---

## Validate Allowed Traffic

Traffic through the Ingress Controller should still succeed.

```bash
curl --max-time 5 -I https://securecart.local
```

Expected:

```
HTTP/2 200
```

---

## Validate Blocked Internal Traffic

Launch a temporary BusyBox pod.

```bash
kubectl run network-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -it \
  -- wget -T 5 -qO- http://securecart-service
```

Expected:

```
wget: download timed out
```

This demonstrates that:

- External traffic entering through the NGINX Ingress Controller is permitted.
- Direct pod-to-service traffic is denied by the NetworkPolicy.
- The frontend is isolated according to the principle of least privilege.

---

## Clean Up

Delete the cluster when finished.

```bash
kind delete cluster --name securecart

```
---

## 📁 Repository Structure

```text
securecart/
├── docs/
├── kind/
├── kubernetes/
│   └── base/
├── .gitignore
├── LICENSE
└── README.md

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

**Current milestone:** Containerize the SecureCart frontend

Upcoming work:

- Create a SecureCart-owned frontend image
- Replace the stock NGINX runtime-rendering approach
- Build and test the image locally
- Deploy the custom image to Kubernetes

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
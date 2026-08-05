# SecureCart

> A production-style cloud-native application built to demonstrate Kubernetes, AWS, Terraform, DevSecOps, and Cloud Infrastructure engineering practices from development through production deployment.

---

## 🚧 Project Status

**Status:** In Progress

**Current Phase:** Kubernetes Fundamentals

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

### Next

- [ ] NetworkPolicies

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

- Docker
- kubectl
- Kind

### Create the cluster

```bash
kind create cluster --name securecart --config kind/cluster.yaml
```

### Validate the cluster
```bash
kubectl cluster-info --context kind-securecart
```

### Deploy SecureCart

```bash
kubectl apply -f kubernetes/base/configmap.yaml
kubectl apply -f kubernetes/base/secrets/secret-example.yaml
kubectl apply -f kubernetes/base/frontend-content.yaml
kubectl apply -f kubernetes/base/frontend-deployment.yaml
kubectl apply -f kubernetes/base/frontend-service.yaml
```

### Verify the deployment

```bash
kubectl rollout status deployment/securecart-frontend
kubectl get pods
kubectl get services
kubectl get configmaps
kubectl get secrets

```

## Health Probes

SecureCart uses three Kubernetes health probes to improve application reliability.

| Probe | Purpose |
|--------|---------|
| Startup | Prevents readiness and liveness checks until the application has started successfully. |
| Readiness | Determines when a Pod is ready to receive Service traffic. |
| Liveness | Restarts the container if the application becomes unhealthy. |

### Verify health probes

```bash
kubectl describe pod <pod-name> | grep -E "Startup|Readiness|Liveness"
```

```bash
kubectl get endpointslice \
  -l kubernetes.io/service-name=securecart-service \
  -o wide
  
```

### Test the application internally

```bash
kubectl run service-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -i \
  -- wget -qO- http://securecart-service

```

### Install the Ingress Controller
```bash

kubectl apply -f \
  https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait \
  --namespace ingress-nginx \
  --for=condition=Ready \
  pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

```
### Pin the Controller to the Mapped Node
``` bash
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
### Verify the Ingress Controller
```
kubectl rollout status deployment/ingress-nginx-controller \
  -n ingress-nginx

kubectl get pods -n ingress-nginx -o wide

```
### Generate Local TLS Material
``` bash
mkdir -p .local/tls

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
  ### Create the TLS Secret

  ``` bash
  kubectl create secret tls securecart-tls \
  --cert=.local/tls/securecart.local.crt \
  --key=.local/tls/securecart.local.key

  ```
  Apply the Ingress

  ``` bash

  kubectl apply -f kubernetes/base/frontend-ingress.yaml

  ```


#### Configure Local Hostname

```bash
echo "127.0.0.1 securecart.local" | sudo tee -a /etc/hosts
```

### Trust Local TLS Certificate

```bash
sudo cp .local/tls/securecart.local.crt \
  /usr/local/share/ca-certificates/

sudo update-ca-certificates

```

### Access SecureCart

- HTTP: `http://securecart.local`
- HTTPS: `https://securecart.local`

> The local self-signed certificate may still display a browser warning. TLS termination and certificate validation were confirmed with `curl` and `openssl`.

### Delete the local cluster

```bash
kind delete cluster --name securecart

```

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

**Current milestone:** Kubernetes NetworkPolicies

Upcoming work:

- Establish default-deny network isolation
- Permit only required Ingress-to-frontend traffic
- Validate blocked and allowed communication paths
- Document least-privilege network controls

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
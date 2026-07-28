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
- Dynamic HTML generation
- Init Containers
- Downward API
- Production-style documentation

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
- [x] Init Containers
- [x] emptyDir Volumes
- [x] Downward API
- [x] Dynamic SecureCart Frontend

### Next

- [ ] Secrets
- [ ] Health Probes
- [ ] Ingress
- [ ] Network Policies
- [ ] Resource Limits

---

## 🏗️ Current Architecture

```text
                         Kubernetes Cluster
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  Client Pod                                              │
│      │                                                   │
│      ▼                                                   │
│  securecart-service                                      │
│  ClusterIP Service                                       │
│      │                                                   │
│      ▼                                                   │
│  securecart-frontend Deployment                          │
│  3 replicas                                              │
│      │                                                   │
│      ├── Init Container                                  │
│      │     ├── Reads HTML template ConfigMap             │
│      │     ├── Reads application ConfigMap               │
│      │     ├── Reads Pod name through Downward API       │
│      │     └── Writes rendered HTML to emptyDir          │
│      │                                                   │
│      └── NGINX Container                                 │
│            └── Serves rendered HTML from emptyDir        │
│                                                          │
└──────────────────────────────────────────────────────────┘
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
- Init Containers
- ReplicaSets

### Infrastructure as Code

- Terraform

### DevOps

- Helm
- GitHub Actions (planned)

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
kubectl apply -f kubernetes/base/frontend-content.yaml
kubectl apply -f kubernetes/base/frontend-deployment.yaml
kubectl apply -f kubernetes/base/frontend-service.yaml
```

### Verify the deployment

```bash
kubectl rollout status deployment/securecart-frontend
kubectl get pods
kubectl get services
```

### Test the application internally

```bash
kubectl run service-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -i \
  -- wget -qO- http://securecart-service
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

**Current milestone:** Kubernetes Secrets

Upcoming work:

- Add health probes
- Configure Ingress
- Add resource requests and limits
- Configure NetworkPolicies

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
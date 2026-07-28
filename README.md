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

## 🏗️ Current Architecture

Browser
    │
ClusterIP Service
    │
Deployment (3 Replicas)
    │
NGINX Containers
    │
Init Container
    │
ConfigMap

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

## 🛠️ Technology Stack

### Cloud

- AWS (planned)
- Kind

### Containers

- Docker
- Kubernetes
- NGINX

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

## 📁 Repository Structure

```text
securecart/
├── app/
├── docs/
├── helm/
├── kind/
├── kubernetes/
├── scripts/
└── terraform/
```

---

## 📚 Documentation

Project documentation is maintained throughout development.

## 📚 Documentation

- docs/engineering-journal.md
- docs/architecture.md
- docs/decisions.md
- docs/troubleshooting.md
- docs/roadmap.md

---

## 🚀 Current Focus

## 🚀 Current Focus

Current milestone:

- Kubernetes Secrets
- Health Probes
- Ingress
- Containerizing the SecureCart frontend

Long-term goal:

Deploy the complete SecureCart platform to Amazon EKS using Terraform, Helm, and GitHub Actions.

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
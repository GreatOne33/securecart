# SecureCart Roadmap

## Phase 1 - Kubernetes Fundamentals

- [x] Build Ubuntu Cloud Lab
- [x] Install Docker
- [x] Install kubectl
- [x] Install Kind
- [x] Install Helm
- [x] Create GitHub repository

### Kubernetes Core

- [x] Create Kind cluster
- [x] Deploy first Pod
- [x] Create Deployment
- [x] Understand ReplicaSets
- [x] Demonstrate Kubernetes self-healing
- [x] Scale Deployments
- [x] Create ClusterIP Service
- [x] Understand label selectors
- [x] Verify Kubernetes service discovery
- [x] Test Kubernetes DNS resolution
- [x] Perform Rolling Updates
- [x] Perform Rollbacks

### Configuration Management

- [x] Configure ConfigMaps
- [x] Build custom SecureCart frontend
- [x] Render HTML using Init Containers
- [x] Use emptyDir shared volumes
- [x] Inject Pod metadata with the Downward API
- [x] Demonstrate ConfigMap updates
- [x] Configure Kubernetes Secrets
- [x] Validate Secret environment variables
- [x] Validate Secret volume mounts
- [x] Apply Principle of Least Privilege

### Platform Hardening

- [ ] Add Health Probes
- [ ] Configure Ingress
- [ ] Enable HTTPS/TLS
- [ ] Configure Resource Requests & Limits
- [ ] Configure NetworkPolicies

---

## Phase 2 - Application

- [ ] Containerize custom frontend
- [ ] Build backend API
- [ ] Containerize backend
- [ ] Connect frontend to backend
- [ ] Deploy PostgreSQL
- [ ] Configure Persistent Volumes
- [ ] Configure Persistent Volume Claims

---

## Phase 3 - DevOps

- [ ] Build production Docker images
- [ ] Publish images to registry
- [ ] Create Helm chart
- [ ] Configure GitHub Actions
- [ ] Automated testing
- [ ] Automated Kubernetes deployments

---

## Phase 4 - AWS

- [ ] Provision infrastructure with Terraform
- [ ] Configure IAM Roles
- [ ] Create VPC Networking
- [ ] Deploy Amazon ECR
- [ ] Deploy Amazon EKS
- [ ] Configure AWS Load Balancer Controller
- [ ] External DNS
- [ ] HTTPS Certificates (ACM)
- [ ] Deploy SecureCart to AWS

---

## Phase 5 - Production

- [ ] Horizontal Pod Autoscaler
- [ ] Monitoring (Prometheus)
- [ ] Dashboards (Grafana)
- [ ] Centralized Logging
- [ ] Security Hardening
- [ ] Cost Optimization
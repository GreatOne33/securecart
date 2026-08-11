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

- [x] Configure Startup, Readiness, and Liveness Probes
- [X] Configure Resource Requests & Limits
- [X] Configure Ingress
- [X] Enable HTTPS/TLS
- [X] Configure NetworkPolicies

---

## Phase 2 - Application

### Frontend

- [x] Containerize custom frontend
- [x] Move frontend rendering into container startup
- [x] Configure NGINX reverse proxy for API traffic
- [x] Build SecureCart frontend image v0.2.0

### Backend API

- [x] Build Python FastAPI backend
- [x] Create health and status endpoints
- [x] Create product API endpoints
- [x] Implement Pydantic response models
- [x] Implement product lookup and API error handling
- [x] Containerize backend

### Kubernetes Backend

- [x] Deploy backend to Kubernetes
- [x] Configure backend health probes
- [x] Inject backend Pod metadata with the Downward API
- [x] Run multiple backend replicas
- [x] Create backend ClusterIP Service
- [x] Verify backend service discovery and EndpointSlices
- [x] Validate traffic distribution across backend replicas
- [x] Restrict backend access with NetworkPolicy

### Application Integration

- [x] Connect frontend to backend
- [x] Configure frontend-to-backend service discovery
- [x] Proxy `/api/*` traffic through frontend NGINX
- [x] Validate frontend-to-backend NetworkPolicy
- [x] Validate end-to-end HTTPS request path

### Data Layer

- [ ] Deploy PostgreSQL
- [ ] Configure Persistent Volumes
- [ ] Configure Persistent Volume Claims
- [ ] Connect backend to PostgreSQL
- [ ] Replace in-memory product data with database-backed data

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
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

- [x] Containerize custom frontend
- [x] Build backend API
- [x] Containerize backend
- [x] Connect frontend to backend
- [x] Deploy PostgreSQL
- [x] Deploy PostgreSQL using StatefulSet
- [x] Configure Persistent Volumes
- [x] Configure Persistent Volume Claims
- [x] Validate persistent storage across Pod recreation
- [x] Connect FastAPI backend to PostgreSQL
- [x] Migrate product catalog from in-memory data to PostgreSQL
- [x] Validate database-backed API persistence
- [x] Configure backend-to-PostgreSQL NetworkPolicy
- [x] Validate least-privilege database access

---

## Phase 3 - DevOps

- [x] Implement Alembic database schema migrations
- [x] Add idempotent database seed automation
- [x] Create Kubernetes database migration Job
- [x] Harden production-style frontend and backend container images
- [x] Publish versioned application images to GitHub Container Registry
- [x] Package Kubernetes application with Helm and validate release lifecycle
- [x] Configure GitHub Actions continuous integration
- [x] Add backend syntax and application import validation
- [x] Add frontend and backend container build validation
- [x] Add Helm lint and manifest rendering validation
- [x] Apply least-privilege GitHub Actions workflow permissions
- [x] Add Gitleaks secret detection security gate
- [x] Validate secret detection with a controlled known-positive test
- [x] Validate CI recovery after removing synthetic credential history
- [ ] Add automated application testing
- [x] Add dependency vulnerability scanning with `pip-audit`
- [x] Validate dependency security gate with a known-vulnerable package
- [x] Validate CI recovery after dependency remediation
- [ ] Add container image vulnerability scanning
- [ ] Add Kubernetes and Helm configuration scanning
- [ ] Add trusted container artifact publishing
- [ ] Automate Kubernetes deployments
- [ ] Add post-deployment validation

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
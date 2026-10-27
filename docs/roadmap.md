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
- [x] Automate Kubernetes deployments using trusted GHCR artifacts and immutable image digests
- [x] Validate fresh Helm installation, workload readiness, and database migration
- [x] Add automated post-deployment HTTP smoke tests
- [x] Validate frontend, API routing, PostgreSQL connectivity, and seeded products in GitHub Actions
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
- [x] Add automated application testing
- [x] Validate application test gate with a controlled API regression
- [x] Validate CI recovery after application behavior remediation
- [x] Add dependency vulnerability scanning with `pip-audit`
- [x] Validate dependency security gate with a known-vulnerable package
- [x] Validate CI recovery after dependency remediation
- [x] Add frontend and backend container vulnerability scanning with Trivy
- [x] Enforce fixable HIGH and CRITICAL container vulnerability policy
- [x] Validate container security gate with a controlled vulnerable image
- [x] Validate CI recovery after container vulnerability remediation
- [x] Add Kubernetes configuration scanning of rendered Helm manifests with Trivy
- [x] Validate Kubernetes configuration security gate with a controlled HIGH misconfiguration
- [x] Validate CI recovery after Kubernetes configuration remediation
- [x] Add trusted container artifact publishing to GitHub Container Registry
- [x] Bind published container artifacts to the validated source commit
- [x] Record immutable backend and frontend registry digests
- [x] Validate automated GHCR publication and package authorization
- [x] Automate Kubernetes deployments
- [x] Add post-deployment validation

---

## Phase 4 - AWS

- [x] Establish Terraform remote state with native S3 state locking
- [x] Provision AWS network foundation with Terraform
- [x] Create multi-AZ VPC networking
- [x] Configure public and private subnet routing
- [x] Configure cost-conscious NAT egress for private workloads
- [x] Add an S3 Gateway Endpoint for private S3 connectivity
- [x] Validate infrastructure destroy and reproducible reconstruction
- [x] Validate Terraform idempotency with a zero-change plan

### Terraform Architecture Refactor

- [x] Extract reusable Terraform network module
- [x] Extract reusable Terraform registry and identity module
- [x] Create independent lab network and registry environment roots
- [x] Isolate network and registry Terraform remote state
- [x] Make NAT Gateway optional and disabled by default
- [x] Retire legacy Terraform root after verifying empty state
- [x] Exclude saved Terraform plans from Git
- [x] Validate modular network Terraform configuration
- [x] Validate modular registry and identity Terraform configuration
- [x] Review network plan: 15 additions, no changes or destroys
- [x] Review registry plan: 8 additions, no changes or destroys
- [x] Deploy and verify modular registry and identity infrastructure
- [ ] Deploy and verify modular network infrastructure
- [ ] Evaluate private workload egress requirements before EKS deployment
- [x] Configure IAM Roles
- [x] Deploy Amazon ECR

### GitHub OIDC and Trusted Artifact Publishing

- [x] Configure GitHub Actions OIDC federation with AWS
- [x] Configure least-privilege IAM permissions for ECR publishing
- [x] Diagnose GitHub immutable OIDC subject mismatch
- [x] Correct IAM trust policy using exact immutable subject matching
- [x] Validate GitHub Actions authentication using AWS STS
- [x] Publish frontend and backend images to Amazon ECR
- [x] Verify matching container image digests across GHCR and ECR
- [x] Independently verify published ECR images using AWS CLI
- [x] Remove temporary OIDC diagnostic and validate workflow
- [x] Validate controlled teardown of registry and identity infrastructure
- [ ] Merge OIDC diagnostic cleanup PR
- [ ] Redeploy registry and identity infrastructure before further ECR testing
- [ ] Revalidate trusted publishing after infrastructure restoration

### AWS Kubernetes Deployment

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

# SecureCart Engineering Journal

---

## Session 1 - Development Environment & Kubernetes Lab

### Goal

Build the local Kubernetes development environment for SecureCart using Kind.

### Completed

- Created the SecureCart GitHub repository.
- Built the initial project structure.
- Installed Docker.
- Installed kubectl.
- Installed Kind.
- Installed Helm.
- Created the first two-node Kind cluster.
- Verified cluster connectivity using kubectl.

### Challenges

#### VMware Disk Expansion

Increasing the virtual disk size did not immediately provide additional storage inside Ubuntu.

Resolution:
- Removed VMware snapshots.
- Expanded the partition using `growpart`.
- Resized the filesystem using `resize2fs`.
- Verified the operating system recognized the additional space.

#### Kind Installation

The initial Kind installation attempt failed because the download/checksum approach was incorrect.

Resolution:
- Downloaded the official Kind binary.
- Installed it into `/usr/local/bin`.
- Verified the installation with:

```bash
kind version

```


### Lessons Learned

- Expanding a VMware virtual disk requires both resizing the guest partition and the filesystem.
- Installing tools from the official project documentation helps avoid outdated installation methods.
- Infrastructure configuration should be stored in source control so environments can be recreated consistently.

### Next Session

- Deploy the first Kubernetes workload.
- Learn Pods and Deployments.

## Session 2 - First Kubernetes Pod

### Goal

Deploy and inspect the first SecureCart workload on the local Kind cluster.

### Completed

- Created a Kubernetes Pod manifest for the SecureCart frontend.
- Deployed an NGINX container to the cluster.
- Verified the Pod reached the Running and Ready states.
- Inspected Pod scheduling, container status, and Kubernetes events.
- Tested the application using kubectl port forwarding.
- Deleted the standalone Pod and confirmed Kubernetes did not recreate it.

### Lessons Learned

- A Pod is Kubernetes' smallest deployable workload unit.
- Labels provide metadata that other Kubernetes resources can use to identify workloads.
- Declaring a container port does not expose the workload outside the Pod.
- Port forwarding provides temporary local access for testing.
- A standalone Pod is not automatically recreated after deletion.
- Deployments provide workload reconciliation and self-healing behavior.

### Next

- Replace the standalone Pod with a Deployment.
- Configure replicas.
- Test Kubernetes workload recovery.

# Session 3 – Deployments, ReplicaSets, and Self-Healing

## Goal

Replace the standalone Pod with a Deployment and understand how Kubernetes maintains desired state.

## Completed

- Deleted the standalone Pod.
- Created `frontend-deployment.yaml`.
- Learned the relationship between Deployment, ReplicaSet, and Pod.
- Applied the Deployment to the Kind cluster.
- Verified Deployment, ReplicaSet, and Pod resources using `kubectl`.
- Deleted a running Pod and observed Kubernetes automatically create a replacement.
- Scaled the Deployment from one replica to three replicas.
- Observed additional Pods transition through Pending, ContainerCreating, and Running.
- Scaled the Deployment back to one replica.

## Key Concepts Learned

### Desired State

A Deployment does not manage individual Pods directly. Instead, it defines the desired number of replicas, and Kubernetes continuously reconciles the actual state with the desired state.

### ReplicaSet

The ReplicaSet monitors the number of running Pods. If a Pod is deleted or fails, it creates a replacement to maintain the configured replica count.

### Self-Healing

Deleting a Pod does not impact the Deployment. Kubernetes automatically creates a new Pod to restore the desired state.

### Scaling

Increasing the replica count creates additional Pods automatically. Decreasing the replica count removes excess Pods while maintaining application availability.

## Commands Used

```bash
kubectl apply -f kubernetes/base/frontend-deployment.yaml
kubectl get deployments
kubectl get rs
kubectl get pods
kubectl get pods --watch
kubectl delete pod <pod-name>
kubectl scale deployment securecart-frontend --replicas=3
kubectl scale deployment securecart-frontend --replicas=1
```

### Challenges

Understanding how Deployments, ReplicaSets, and Pods relate to one another before seeing them in action.

### Lessons Learned
Pods should generally be managed by a Deployment.
Deployments define the desired state of an application.
ReplicaSets enforce the desired number of Pods.
Pods are ephemeral and should not be relied upon individually.
Kubernetes continuously reconciles actual state with desired state.
Declarative configuration (YAML) is the source of truth, while imperative commands such as kubectl scale modify the live cluster.

# Session 4 – Services and Service Discovery

## Goal

Understand how Kubernetes Services provide stable networking for dynamic Pods and learn how applications discover one another inside the cluster.

## Architecture

Deployment
↓
ReplicaSet
↓
Pods
↑
Service
↑
Kubernetes DNS

## Tasks Completed

- Created the first ClusterIP Service.
- Applied `frontend-service.yaml`.
- Verified the Service received a ClusterIP.
- Learned how Services use label selectors.
- Verified the Service discovered frontend Pods automatically.
- Used Kubernetes DNS to reach the application by Service name.
- Tested connectivity from a temporary BusyBox Pod.
- Observed the temporary Pod being removed automatically.
- Verified the Service continued routing traffic after Pod replacement.

## Commands Used

```bash
kubectl apply -f kubernetes/base/frontend-service.yaml

kubectl get svc

kubectl describe service securecart-service

kubectl get endpointslices

kubectl run service-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -it \
  -- wget -qO- http://securecart-service

kubectl get pods
```

## Challenges

Understanding how a Service can locate Pods without using Pod names or Pod IP addresses.

## Lessons Learned

- Pod IP addresses are ephemeral and change when Pods are recreated.
- Services provide a stable virtual IP and DNS name.
- Services discover Pods using label selectors.
- Kubernetes DNS allows workloads to communicate using Service names.
- EndpointSlices maintain the list of healthy backend Pods for a Service.
- Clients communicate with Services rather than individual Pods.

## Key Takeaways

- Deployments manage application lifecycle.
- ReplicaSets maintain the desired number of Pods.
- Services provide stable networking.
- Labels connect Services to Pods.
- DNS makes Service discovery transparent to applications.

## Next Session

Perform rolling updates and rollbacks to deploy new application versions with zero downtime.

# Session 5 - Rolling Updates and Rollbacks

## Goal

Learn how Kubernetes Deployments release new application versions and restore previous versions without replacing the stable Service.

## Starting State

- Deployment: `securecart-frontend`
- Replicas: 3
- Original image: `nginx:1.27-alpine`
- Service: `securecart-service`
- Deployment revision: 1

## Tasks Completed

- Inspected the Deployment and its rolling-update strategy.
- Verified the Deployment had three available replicas.
- Reviewed the initial Deployment revision history.
- Updated the frontend image from `nginx:1.27-alpine` to `nginx:1.28-alpine`.
- Watched Kubernetes replace the Pods through a rolling update.
- Verified that Kubernetes created a new ReplicaSet.
- Confirmed the old ReplicaSet was retained with zero replicas.
- Verified the Deployment was using the updated image.
- Rolled the Deployment back to `nginx:1.27-alpine`.
- Verified the Service continued routing traffic after the update and rollback.

## Commands Used

```bash
kubectl get deployment

kubectl describe deployment securecart-frontend

kubectl rollout history deployment/securecart-frontend

kubectl get pods --watch

kubectl set image deployment/securecart-frontend \
  frontend=nginx:1.28-alpine

kubectl rollout status deployment/securecart-frontend

kubectl get replicasets

kubectl get deployment securecart-frontend \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

kubectl rollout undo deployment/securecart-frontend

kubectl run service-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -it \
  -- wget -qO- http://securecart-service
```

## Architecture Observed

```text
Deployment
    |
    +-- Old ReplicaSet: nginx:1.27-alpine
    |       Replicas scaled from 3 to 0
    |
    +-- New ReplicaSet: nginx:1.28-alpine
            Replicas scaled from 0 to 3
```

During the rollback, Kubernetes restored the previous Pod template and scaled its ReplicaSet back up.

## Lessons Learned

- A Deployment manages application releases through ReplicaSets.
- Changing the Pod template creates a new Deployment revision.
- A rolling update gradually replaces old Pods with new Pods.
- The old ReplicaSet is retained to support rollback.
- A rollback restores a previous Pod-template configuration.
- A stable Service continues selecting healthy Pods even when the underlying ReplicaSets and Pod IP addresses change.
- The container name must be specified correctly when using `kubectl set image`.
- Deployment revisions track changes to the Pod template, not changes to the Service.

## Key Takeaways
Kubernetes separates application networking from application releases:

```text
Stable Service
      |
Changing healthy Pods
      |
Deployment revisions and ReplicaSets
```

This allows clients to continue using the same Service name while Kubernetes updates or restores the application workload.

## Next Session

Configure application settings externally using Kubernetes ConfigMaps.

## Session 6: Custom Frontend and ConfigMap Updates

### Goal

Replace the default NGINX page with a custom SecureCart frontend and demonstrate how ConfigMap changes affect running Pods.

### Tasks Completed

- Created an HTML template stored in a ConfigMap
- Added an init container to render the template with `envsubst`
- Used an `emptyDir` volume to share generated content with NGINX
- Used the Downward API to inject the Pod name
- Verified the application through the Kubernetes Service
- Updated the environment from Development to Staging
- Updated the version from 1.0 to 1.1
- Confirmed existing Pods retained the original environment variables
- Restarted the Deployment
- Confirmed new Pods loaded the updated ConfigMap values

### Challenges

ConfigMap values injected as environment variables did not change inside existing Pods after the ConfigMap was updated.

### Lessons Learned

Environment variables are populated when a container starts. Updating the ConfigMap object does not modify the environment of already-running containers. The Pods must be recreated for the new values to take effect.

The init container also runs only when a Pod starts, so the generated HTML is not recreated until Kubernetes creates a new Pod.

### Key Takeaways

- ConfigMaps separate configuration from the container image
- Environment-variable-based ConfigMaps require Pod recreation
- Init containers can perform application setup before the main container starts
- `emptyDir` volumes allow containers in the same Pod to share generated files
- The Downward API can expose Kubernetes metadata to an application

# Session 7: Kubernetes Secrets

**Date:** July 29, 2026

**Milestone:** SecureCart v0.2.0

**Status:** Completed

## Objective

Implement Kubernetes Secrets to securely manage sensitive application configuration and understand how applications consume sensitive data in Kubernetes.

## Implementation

Created an Opaque Kubernetes Secret using placeholder values for:

- DATABASE_USERNAME
- DATABASE_PASSWORD
- API_KEY

Applied the Secret to the cluster and verified it using:

- `kubectl get secrets`
- `kubectl describe secret`

Observed that `kubectl describe` displays the Secret keys and their sizes, but not the stored values.

## Validation

Validated that:

- Secret values can be injected through `secretKeyRef`
- `kubectl describe secret` does not display the stored values
- Sensitive values can be verified without printing them
- Environment variables are scoped to individual containers
- Kubernetes Secrets can also be mounted as read-only volumes
- Mounted Secrets create one file per Secret key
- Secret volumes are mounted as symbolic links managed by Kubernetes

## Security Concepts Learned

- Kubernetes Secrets are Base64 encoded, not encrypted.
- Production clusters should enable encryption at rest.
- RBAC controls access to Kubernetes Secrets.
- Secrets should only be injected into containers that require them.

## Engineering Decision

For the current frontend-only architecture, Secret values were temporarily injected into the frontend container to validate Secret consumption.

After validation, the Secret references were removed from the frontend Deployment because the NGINX container does not require database credentials or API keys.

This follows the Principle of Least Privilege and keeps the Deployment aligned with production security practices.

## Lessons Learned

- ConfigMaps should be used for non-sensitive configuration.
- Secrets should be used for sensitive application configuration.
- Kubernetes supports two primary methods of consuming Secrets:
  - Environment variables
  - Read-only mounted volumes
- Temporary validation configurations should be removed once testing is complete.

## Session 8 - Kubernetes Health Probes

**Milestone:** Application Health and Reliability
**Status:** Completed

### Objective

Configure Kubernetes health probes for the SecureCart frontend and validate how Kubernetes manages startup, Service traffic, container restarts, and application recovery.

### Implementation

Added HTTP-based probes to the `frontend` container:

- Startup probe
- Readiness probe
- Liveness probe

All probes check the NGINX root path on port 80.

The startup probe allows approximately 60 seconds for initialization before Kubernetes considers startup unsuccessful.

### Readiness Validation

The served `index.html` file was temporarily renamed inside one frontend Pod.

Observed behavior:

- The NGINX process remained running.
- The readiness probe returned HTTP 403.
- The Pod changed from Ready to NotReady.
- The container was not restarted.
- The Pod IP was removed from the Service EndpointSlice.
- Healthy replicas continued receiving traffic.

After restoring the file:

- The readiness probe succeeded.
- The Pod returned to Ready.
- Its IP was automatically restored to the Service EndpointSlice.

### Liveness Validation

The frontend content was intentionally broken again after configuring the liveness probe.

Observed behavior:

- Readiness failed and removed the Pod from Service traffic.
- Liveness failed repeatedly.
- Kubernetes restarted the frontend container.
- The Init Container did not run again because the Pod was not recreated.
- The `emptyDir` volume survived the container restart.
- The broken content remained in the shared volume.
- Repeated failures caused the container to enter `CrashLoopBackOff`.

The Pod was then deleted manually.

The ReplicaSet created a replacement Pod with:

- A fresh `emptyDir` volume
- A rerun of the Init Container
- Regenerated frontend content
- Successful health probes
- Restoration to the Service EndpointSlice

### Startup Probe Validation

Configured a startup probe to check the frontend every five seconds with a failure threshold of twelve.

This allows approximately sixty seconds for application initialization.

Once the startup probe succeeds, Kubernetes begins executing the readiness and liveness probes.

### Engineering Decisions

- Used HTTP probes because SecureCart currently serves content through NGINX.
- Used the root path for the current frontend because no dedicated health endpoint exists yet.
- Kept startup, readiness, and liveness probes together for learning and demonstration.
- Retained initial delays for readiness and liveness to make each probe configuration explicit.
- Recognized that the startup probe is more valuable for the future backend API than for the fast-starting NGINX frontend.

### Commands Used
kubectl describe pod <pod-name> | grep -E "Startup|Readiness|Liveness"

kubectl get endpointslice \
  -l kubernetes.io/service-name=securecart-service \
  -o wide

kubectl exec <pod-name> -- \
  mv /usr/share/nginx/html/index.html \
     /usr/share/nginx/html/index.html.disabled

kubectl delete pod <pod-name>

### Lessons Learned

- A running container is not necessarily a healthy application.
- Readiness failures remove Pods from Service traffic without restarting them.
- Liveness failures restart containers.
- Container restart does not recreate the Pod.
- `emptyDir` survives container restarts but is deleted when the Pod is removed.
- Init Containers rerun only when a new Pod is created.
- Liveness probes cannot repair persistent broken state.
- EndpointSlice is the modern API for viewing Service backends.

## Session 9 - Resource Requests & Limits

**Milestone:** Kubernetes Resource Management

**Status:** Completed

---

### Objective

Configure CPU and memory requests and limits for the SecureCart frontend to improve scheduling decisions, resource management, and workload reliability.

---

### Implementation

Added resource requests and limits to the frontend Deployment.

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"

  limits:
    cpu: "250m"
    memory: "256Mi"

```

### Validation

---

Verified:

- Deployment rolled out successfully
- New ReplicaSet created
- Resources stored in Deployment
- Requests and limits applied to Pods
- QoS changed from BestEffort to Burstable

### Validation commands included:

```bash
kubectl describe pod <pod-name>

kubectl get deployment securecart-frontend \
  -o jsonpath='{.spec.template.spec.containers[0].resources}'

```

### Observations

---

Before this change:

  QoS Class: BestEffort

After configuring requests and limits:

  QoS Class: Burstable

The scheduler now reserves:

  100m CPU
  128Mi Memory

Each container may burst up to:

  250m CPU
  256Mi Memory

---

Metrics

Attempted to inspect runtime usage with:

```
kubectl top pods

```

### Result:

  Metrics API not available

The local Kind cluster does not include Metrics Server by default.

Requests, limits, scheduling, and QoS remain fully functional without Metrics Server.

Runtime utilization will be explored during the Monitoring and Autoscaling milestones.

### Lessons Learned
- Requests influence scheduling.
- Limits restrict maximum resource usage.
- CPU is throttled when limits are exceeded.
- Memory limits can trigger OOMKills.
- Requests and limits determine QoS.
- Most web applications operate in the Burstable QoS class.

## Session 10 — Kubernetes Ingress & TLS

**Milestone:** Ingress and Secure Traffic Management

**Status:** Completed

### Objective

- Expose SecureCart through an NGINX Ingress Controller and secure external traffic using HTTPS.

### Implemented
- Installed the NGINX Ingress Controller
- Configured host-based routing
- Created a Kubernetes Ingress resource
- Added Kind host port mappings for ports 80 and 443
- Generated a self-signed TLS certificate
- Created a Kubernetes TLS Secret
- Configured TLS termination at the Ingress Controller
- Enabled automatic HTTP to HTTPS redirection
- Imported the certificate into the Ubuntu trust store

### Validation

Verified:

- HTTPS returns HTTP/2 200 OK
- HTTP redirects with 308 Permanent Redirect
- TLS certificate contains the securecart.local Subject Alternative Name
- TLS Secret is successfully loaded by the Ingress Controller
- SecureCart is accessible through both curl and a web browser

### Commands used:
```bash
curl -I https://securecart.local

curl -I http://securecart.local

openssl s_client \
  -connect securecart.local:443 \
  -servername securecart.local

```

### Challenges

Initial connection failures

After recreating the Kind cluster, requests to securecart.local returned:
```text

  Recv failure: Connection reset by peer
```

Root cause:

The Ingress Controller scheduled onto the worker node while the Kind host port mappings forwarded traffic into the control-plane node.

Resolution:

- Labeled the control-plane node
- Applied a node selector to the Ingress Controller
- Redeployed the controller onto the control-plane node

Result:

- Ingress traffic successfully reached the SecureCart Service.

### Local certificate trust

The application successfully served HTTPS, but browsers continued displaying Not Secure because SecureCart uses a self-signed certificate for local development.

The certificate was added to the Ubuntu trust store and validated using curl and openssl.

In production, certificates would be issued by a trusted Certificate Authority using cert-manager and Let's Encrypt (or an enterprise PKI).

### Lessons Learned
- An Ingress resource only defines routing rules; an Ingress Controller performs the routing.
- Host-based routing depends on the HTTP Host header.
- TLS termination occurs at the Ingress Controller.
- Backend Services can continue using HTTP while client traffic remains encrypted.
- Kind host port mappings must align with the node running the Ingress Controller.
- Self-signed certificates are suitable for local development but are not a replacement for production certificates.

## Session 11 - Kubernetes NetworkPolicies

**Milestone:** Network Segmentation and Least-Privilege Access
**Status:** Completed

### Objective

Restrict inbound access to the SecureCart frontend so that traffic is accepted only through the NGINX Ingress Controller.

### Baseline Validation

Before applying a NetworkPolicy:

- A temporary BusyBox Pod could reach `securecart-service`.
- HTTPS through `securecart.local` returned `HTTP/2 200`.

This confirmed that Kubernetes networking allowed traffic by default.

### Initial Isolation Test

Created a policy selecting the frontend Pods with no ingress allow rules.

Observed:

- BusyBox traffic timed out.
- HTTPS through the Ingress Controller timed out.
- All frontend Pods remained Running and Ready.

This demonstrated that application health and network reachability are separate concerns.

### Troubleshooting

The initial allow policies did not restore connectivity, even after validating:

- Frontend Pod labels
- Ingress Controller Pod labels
- Namespace labels
- The stored NetworkPolicy YAML
- Direct frontend Pod-IP access
- Service access from the Ingress Controller
- Namespace-only and port-only allow rules

Restarted the Kind networking DaemonSet:

```bash
kubectl rollout restart daemonset/kindnet -n kube-system

kubectl rollout status daemonset/kindnet \
  -n kube-system \
  --timeout=180s

```

After the restart, policy changes were enforced correctly.

### Final Policy

Configured a single NetworkPolicy that:

- Selects the SecureCart frontend Pods
- Isolates them for ingress traffic
- Permits TCP port 80 only from the `ingress-nginx` namespace

A separate default-deny policy was not required because selecting the frontend Pods with an ingress policy already isolates them.

### Final Validation

Allowed path:

```bash
curl --max-time 5 -I https://securecart.local

```

Result:

```text
HTTP/2 200

```

Blocked path:

```bash
kubectl run network-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -i \
  -- wget -T 5 -qO- http://securecart-service

```

Result:

```text
wget: download timed out

```

### Lessons Learned

- Kubernetes networking permits Pod-to-Pod communication by default.
- A NetworkPolicy selects and isolates Pods; a separate deny policy is not always needed.
- NetworkPolicies are based on Pod and namespace identity rather than fixed Pod IP addresses.
- Application health does not guarantee network reachability.
- CNI behavior must be considered when troubleshooting policy enforcement.
- Restarting kindnet reconciled stale policy behavior in the local Kind environment.
- Least-privilege access was achieved by permitting only the dedicated Ingress namespace.

## Session 12 - Containerizing the SecureCart Frontend

**Milestone:** Application Containerization

**Status:** Completed

### Objective

Replace the Kubernetes Init Container rendering approach with a self-contained SecureCart frontend image capable of generating application content during container startup.

### Background

During Phase 1, SecureCart generated its frontend using:

- ConfigMap
- Init Container
- emptyDir volume
- NGINX container

This demonstrated several important Kubernetes concepts, but it tightly coupled application rendering to Kubernetes.

The objective of this session was to move application rendering into the frontend container itself, allowing the image to run both locally with Docker and inside Kubernetes.

### Implementation

Completed the following:

- Created `app/frontend/`
- Added a custom Dockerfile
- Created a startup script using `envsubst`
- Embedded the HTML template into the image
- Configured the entrypoint to render the application during container startup
- Built the first SecureCart-owned Docker image
- Tested the image locally using Docker
- Loaded the image into the Kind cluster
- Updated the frontend Deployment to use the custom image

### Validation

Verified:

- Docker container rendered the application correctly
- Environment variables populated successfully
- Downward API continued injecting the Pod name
- HTTPS access through the Ingress Controller remained functional
- Kubernetes successfully rolled out the new Deployment
- The frontend continued serving traffic after the migration

Validation commands included:

```bash
docker build -t securecart-frontend:0.1.0 app/frontend

docker run \
  -p 8081:80 \
  --rm \
  -e APP_NAME=SecureCart \
  -e ENVIRONMENT=Development \
  -e VERSION=2.0.0 \
  -e COMPANY="GreatOne Labs" \
  -e POD_NAME=docker-local \
  securecart-frontend:0.1.0

kind load docker-image securecart-frontend:0.1.0 \
  --name securecart

kubectl rollout status deployment/securecart-frontend

curl -I https://securecart.local
```

### Architecture Evolution

Previous architecture:

```text
ConfigMap
      │
      ▼
Init Container
      │
      ▼
emptyDir
      │
      ▼
NGINX
```

New architecture:

```text
ConfigMap
      │
      ▼
Docker EntryPoint
      │
      ▼
Rendered HTML
      │
      ▼
NGINX
```

Application rendering is now performed inside the container instead of by Kubernetes.

### Challenges

#### NetworkPolicy behavior after rollout

Following the Deployment rollout, internal Pod-to-Service traffic was unexpectedly allowed despite the existing NetworkPolicy.

Observed behavior:

- HTTPS access through the Ingress Controller continued working.
- Temporary BusyBox Pods could again reach `securecart-service`.

Investigation confirmed that:

- NetworkPolicy configuration was unchanged.
- Frontend Pod labels were correct.
- Ingress namespace labels remained correct.

The issue was resolved by restarting the Kind networking DaemonSet (`kindnet`), after which NetworkPolicy enforcement returned to the expected least-privilege behavior.

### Engineering Decisions

- Shifted application rendering into the container image.
- Reduced Kubernetes-specific startup logic.
- Preserved ConfigMap-driven configuration.
- Continued using the Downward API for runtime metadata.
- Maintained immutable container images while injecting runtime configuration.

### Lessons Learned

- Containers should own application startup whenever practical.
- Kubernetes should orchestrate workloads rather than generate application content.
- Docker images become significantly more portable when startup logic resides inside the container.
- The same image can now run locally and in Kubernetes without modification.
- Runtime configuration can still be injected cleanly using ConfigMaps and the Downward API.
- Kind networking may occasionally require reconciliation after Deployment changes when NetworkPolicies are in use.

### Key Takeaways

This session marked the transition from learning Kubernetes primitives to building production-style containerized applications.

SecureCart no longer depends on Kubernetes Init Containers to generate application content. Instead, Kubernetes is responsible for scheduling and configuration while the application image owns its startup process.

## Session 13 - Backend API and Multi-Tier Application Integration

**Date:** August 10, 2026

**Milestone:** Backend API and Frontend-to-Backend Integration

**Status:** Completed

### Objective

Extend SecureCart from a frontend-only Kubernetes application into a multi-tier application by building a Python backend API, containerizing it, deploying it to Kubernetes, restricting access with NetworkPolicy, and integrating the frontend with the backend through an internal Kubernetes Service.

### Backend Development

Created the backend application under:

```text
app/backend/
```

The backend was implemented using Python, FastAPI, Uvicorn, and Pydantic.

A Python virtual environment was created to isolate local application dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

The .venv directory was added to .gitignore so local Python dependencies are not committed to source control.

### Initial API Endpoints

Implemented the first application endpoints:

```text
GET /health
GET /api/status
GET /api/products
GET /api/products/{product_id}

```
The health endpoint provides a simple application health check:
```text
{
  "status": "healthy"
}

```

The status endpoint exposes runtime application information including:

- Application name
- Version
- Environment
- Pod or container name
- Runtime status

The products endpoint introduced the first application data served by SecureCart.

### API Modeling and Validation

Created Pydantic models for the product API rather than returning completely unstructured dictionaries.

The product model defines:

- id
- name
- price
- in_stock

FastAPI uses these models to validate response data and generate API documentation.

The generated OpenAPI documentation was verified through the FastAPI /docs interface.

### Product Lookup and HTTP Behavior

Implemented an endpoint for retrieving an individual product:

```text
GET /api/products/{product_id}
```

Validated multiple API outcomes:

```text
/api/products/2       -> 200 OK
/api/products/999     -> 404 Not Found
/api/products/banana  -> 422 validation response

```

This demonstrated the distinction between:

- Successful application responses
- Application-level missing resources
- Framework-level input validation

FastAPI automatically validated that product_id must be an integer.

### Backend Containerization

Created a Docker image for the FastAPI backend:

```text
securecart-backend:0.1.0

```

The container was tested locally before Kubernetes deployment.

Validation included:

```bash
curl -i http://localhost:8001/health
curl -i http://localhost:8001/api/status
curl -i http://localhost:8001/api/products

```

The container successfully returned application health, runtime metadata, and product data.

### Kubernetes Backend Deployment

Loaded the backend image into the local Kind cluster:

```bash
kind load docker-image \
  securecart-backend:0.1.0 \
  --name securecart

```

Created:

```text
kubernetes/base/backend-deployment.yaml

```

The backend Deployment runs two replicas of the FastAPI application.

The Deployment also provides Kubernetes runtime configuration to the application, including environment information and the Pod name through the Downward API.

The rollout was validated using:

```bash
kubectl rollout status deployment/securecart-backend

kubectl get pods \
  -l app=securecart,component=backend

```

Both backend Pods reached the Running and Ready states.

### Container Debugging Observation

Attempted to test the API from inside the backend container using wget.

The command failed because the backend image does not contain wget.

Instead of modifying the production image only for debugging, Python's standard library was used:

```bash
kubectl exec <backend-pod> -- \
  python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8000/api/status').read().decode())"

```

This successfully verified that the FastAPI process was reachable from inside its own container.

### Backend Service and Service Discovery

Created:

```text

kubernetes/base/backend-service.yaml

```

The backend is exposed internally through a ClusterIP Service:

```text

securecart-backend-service:8000

```

Verified that the Service discovered both backend replicas through EndpointSlices.

Internal connectivity was tested using a temporary BusyBox Pod:

```bash
kubectl run backend-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -i \
  -- wget -qO- http://securecart-backend-service:8000/api/status

```

The request successfully reached the FastAPI backend.

### Service Load Distribution

Repeated requests were sent through securecart-backend-service.

Responses were observed from both backend Pods.

This demonstrated that clients communicate with the stable Service endpoint while Kubernetes distributes requests across the available backend endpoints.

The client did not need to know individual backend Pod names or IP addresses.

### Backend Network Segmentation

Created:

```text
kubernetes/base/network-policies/allow-frontend-to-backend.yaml

```

The policy selects backend Pods:

```text
The policy selects backend Pods:

```

and permits inbound TCP traffic on port 8000 only from Pods matching:

```text
app=securecart
component=frontend

```

After NetworkPolicy enforcement was reconciled, an unlabeled temporary BusyBox Pod could no longer reach the backend Service:

```text
wget: download timed out
```

A test Pod carrying the frontend identity labels successfully reached the backend.

This validated the intended least-privilege path:

```text
Frontend -> Backend    ALLOWED
Other Pods -> Backend  BLOCKED
```

### Kind NetworkPolicy Behavior

The local Kind environment again exhibited delayed or stale NetworkPolicy enforcement after policy changes.

The policy YAML and Pod labels were correct, but traffic behavior did not initially reflect the configured policy.

Restarting the Kind networking DaemonSet reconciled enforcement:

```bash
kubectl rollout restart daemonset/kindnet -n kube-system

kubectl rollout status daemonset/kindnet \
  -n kube-system \
  --timeout=180s
```

After the restart:

- Unapproved Pod traffic timed out.
- Frontend-labeled traffic successfully reached the backend.

This reinforced the importance of distinguishing configuration errors from local CNI implementation behavior during troubleshooting.

### Frontend Reverse Proxy

The frontend was extended so browser requests can reach the backend without exposing the FastAPI Service externally.

Created:

```text
app/frontend/nginx.conf.template
```

NGINX now proxies requests under:

```text
/api/

```

to a configurable backend destination.

The frontend startup process renders the NGINX configuration using:

```text
BACKEND_HOST
BACKEND_PORT

```

This allows the same frontend image to use different backend locations depending on its runtime environment.

For Kubernetes:

```text

BACKEND_HOST=securecart-backend-service
BACKEND_PORT=8000

```

The frontend therefore discovers the backend through Kubernetes DNS rather than using Pod IP addresses.

### Frontend Image v0.2.0

Built a new frontend image:

```text
securecart-frontend:0.2.0

```

The new image contains both:

- Runtime HTML rendering
- NGINX API reverse-proxy configuration

The image was first tested locally with Docker before being deployed to Kubernetes.

Local Multi-Container Validation

Ran the frontend and backend as separate Docker containers.

The frontend remained accessible at:

```text
http://localhost:8081
```

A request to:

```text
http://localhost:8081/api/products
```

was received by frontend NGINX and proxied to the backend container.

The backend returned the SecureCart product catalog successfully.

This proved the frontend/backend integration independently of Kubernetes before deploying the same architecture into the cluster.

### Kubernetes Multi-Tier Integration

Loaded securecart-frontend:0.2.0 into Kind and updated the frontend Deployment.

The frontend was configured to use:

```text
securecart-backend-service
```

as its backend destination.

The complete request path became:

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
Frontend NGINX Pod
  |
  | /api/*
  v
Backend ClusterIP Service
  |
  v
FastAPI Backend Pods

```

### End-to-End Validation

The complete application path was tested using:

```text
curl -i https://securecart.local/api/products
```

Result:

```text
HTTP/2 200
content-type: application/json
```

The response contained the SecureCart product catalog.

This proved that a request could travel successfully through:

```text
HTTPS
-> Ingress
-> Frontend Service
-> Frontend NGINX
-> Kubernetes DNS
-> Backend Service
-> FastAPI Pod
-> JSON response

```

while keeping the backend Service internal to the cluster.

### Engineering Decisions
- Used Python and FastAPI for the SecureCart backend.
- Used Pydantic models for API response structure and validation.
- Containerized the backend independently from the frontend.
- Tested containers locally before deploying them into Kubernetes.
- Used a ClusterIP Service so the backend remains internal to the cluster.
- Used Kubernetes DNS for frontend-to-backend service discovery.
- Used two backend replicas to demonstrate workload distribution and availability.
- Restricted backend ingress to frontend workloads using NetworkPolicy.
- Kept debugging utilities out of the backend image when existing Python functionality could perform the required test.
- Used the frontend NGINX container as a reverse proxy instead of exposing the backend directly through Ingress.
- Made the backend destination runtime-configurable rather than hardcoding environment-specific addresses into the frontend image.

### Lessons Learned
- A multi-tier application should separate frontend and backend responsibilities into independently deployable workloads.
- FastAPI automatically provides useful request validation and OpenAPI documentation.
- Pydantic provides explicit contracts for API data instead of relying on arbitrary dictionaries.
- HTTP status codes represent different failure layers: 404 can represent application logic while 422 can result from request validation before application logic executes.
- Containers do not need general-purpose troubleshooting utilities installed if existing application runtime tools can perform the required diagnostics.
- Kubernetes Services allow applications to communicate without knowing Pod IP addresses.
- EndpointSlices represent the backend endpoints available behind a Service.
- Multiple replicas can receive requests behind one stable Service identity.
- NetworkPolicy can enforce application-tier boundaries based on workload identity rather than IP addresses.
- Kubernetes DNS provides stable service discovery between application tiers.
- Browser-side JavaScript cannot directly resolve Kubernetes-only Service DNS names.
- A reverse proxy provides a clean boundary between external application routes and internal Kubernetes services.
- Runtime configuration allows the same container image to operate in multiple environments.
- Local Docker integration testing helps separate application problems from Kubernetes problems.
- End-to-end testing is necessary because successful individual component tests do not guarantee that the complete request path works.
- CNI behavior must be considered when a valid NetworkPolicy does not appear to take effect immediately in a local Kind environment.

Key Takeaways

This session transformed SecureCart from a containerized frontend into a functioning multi-tier application.

The architecture now separates external traffic, frontend presentation, backend application logic, service discovery, and network authorization:

```text

External Client
      |
    HTTPS
      |
      v
Ingress Controller
      |
      v
Frontend
      |
  NetworkPolicy
      |
      v
Backend Service
      |
      v
FastAPI Replicas

```

The backend remains inaccessible to arbitrary workloads while approved frontend workloads can communicate with it through a stable Kubernetes Service.

Most importantly, the same frontend and backend containers can be tested independently with Docker and then deployed into Kubernetes, keeping application behavior separate from orchestration.

### Next Session
- Update project architecture documentation and ADRs.
- Review the complete multi-tier Kubernetes configuration.
- Commit the backend and integration milestone.
- Create the next SecureCart release.
- Begin the next application-development milestone.


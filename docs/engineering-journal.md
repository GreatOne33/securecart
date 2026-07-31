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


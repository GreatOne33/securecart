# SecureCart Troubleshooting Guide

## Connection reset after recreating the Kind cluster

### Symptoms

    curl: (56) Recv failure: Connection reset by peer

### Root Cause

The NGINX Ingress Controller was scheduled onto the worker node while Kind host port mappings forwarded traffic into the control-plane node.

### Resolution

- Label the control-plane node.
- Configure the Ingress Controller with a matching `nodeSelector`.
- Restart the controller Deployment.

### Result

Ingress traffic was successfully routed through the control-plane node and SecureCart became reachable on ports 80 and 443.

---

## NetworkPolicy allow rule did not restore connectivity

### Symptoms

- The initial isolation policy blocked traffic correctly.
- Valid allow policies still timed out.
- Service and direct Pod-IP connections both failed.
- Pod and namespace labels matched the selectors.

### Investigation

Validated:

- The live NetworkPolicy YAML
- Frontend Pod labels
- Ingress Controller Pod labels
- The `ingress-nginx` namespace label
- Direct Pod-IP connectivity
- Namespace-only and port-only allow rules

### Resolution

Restarted the Kind networking DaemonSet:

```bash
kubectl rollout restart daemonset/kindnet -n kube-system

kubectl rollout status daemonset/kindnet \
  -n kube-system \
  --timeout=180s
```

### Result

After kindnet restarted, the namespace-scoped allow policy worked correctly:

- HTTPS traffic through ingress-nginx succeeded.
- Traffic from an unauthorized Pod in the default namespace remained blocked.

---

## NetworkPolicy state became inconsistent after Deployment rollout

### Symptoms

After replacing the frontend Pods during a rolling update:

- HTTPS through the Ingress Controller timed out.
- A temporary Pod in the default namespace could reach `securecart-service`.
- The live NetworkPolicy and Pod labels were still correct.

### Root Cause

The local Kind networking implementation did not reconcile NetworkPolicy state correctly for the newly created frontend Pod endpoints.

### Resolution

Restarted the kindnet DaemonSet:

```bash
kubectl rollout restart daemonset/kindnet -n kube-system

kubectl rollout status daemonset/kindnet \
  -n kube-system \
  --timeout=180s
```

### Result

After kindnet restarted:

- HTTPS through ingress-nginx returned HTTP/2 200.
- Unauthorized traffic from a Pod in the default namespace timed out.

---

## NetworkPolicy was not enforced after adding the backend policy

### Symptoms

After applying the backend NetworkPolicy:

```text
allow-frontend-to-backend
```

an unauthorized test Pod in the `default` namespace could still reach:

```text
securecart-backend-service:8000
```

even though the policy selected the backend Pods and allowed ingress only from frontend workloads.

The expected behavior was:

```text
Frontend Pods -> Backend :8000   ALLOWED
Other Pods    -> Backend :8000   DENIED
```

Instead, the unauthorized Pod continued to receive successful responses from the FastAPI backend.

### Investigation

Verified:

- The NetworkPolicy existed in the `default` namespace.
- The policy selected Pods with:

```text
app=securecart
component=backend
```

- Backend Pods had the expected labels.
- The ingress rule permitted only Pods with:

```text
app=securecart
component=frontend
```

- The rule permitted only TCP port 8000.
- The backend Service correctly selected the backend Pods.
- Backend EndpointSlices contained the expected Pod endpoints.

The Kubernetes resources were configured correctly, but the expected network isolation was not being enforced.

### Resolution

Restarted the Kind networking DaemonSet:

```bash
kubectl rollout restart daemonset/kindnet -n kube-system

kubectl rollout status daemonset/kindnet \
  -n kube-system \
  --timeout=180s
```

### Validation

Retested using an unauthorized Pod:

```bash
kubectl run backend-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -i \
  -- wget -T 5 -qO- \
  http://securecart-backend-service:8000/api/status
```

The request timed out as expected.

Then tested using a Pod carrying the frontend workload labels:

```bash
kubectl run frontend-network-test \
  --image=busybox:1.36 \
  --restart=Never \
  --labels="app=securecart,component=frontend" \
  --rm -i \
  -- wget -qO- \
  http://securecart-backend-service:8000/api/status
```

The request succeeded and returned the backend status response.

### Result

After restarting kindnet:

```text
Frontend workload -> Backend :8000   ALLOWED
Other workload    -> Backend :8000   DENIED
```

The behavior matched the intended least-privilege NetworkPolicy.

### Note

This was observed in the local Kind environment and should be treated as a local networking troubleshooting condition rather than a normal Kubernetes operational requirement.

A correctly functioning Kubernetes networking implementation should reconcile NetworkPolicy changes without requiring the networking DaemonSet to be restarted.

---

## Diagnostic tools were unavailable inside the backend container

### Symptoms

Attempting to test the FastAPI application from inside a backend Pod using `wget` failed:

```bash
kubectl exec <backend-pod> -- \
  wget -qO- http://localhost:8000/api/status
```

The container returned:

```text
exec: "wget": executable file not found in $PATH
```

### Root Cause

The SecureCart backend image is intentionally minimal and does not include `wget`.

The application itself was healthy. The failure was caused by the diagnostic command not being available inside the container.

### Resolution

Used Python's standard library instead:

```bash
kubectl exec <backend-pod> -- \
  python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8000/api/status').read().decode())"
```

### Result

The FastAPI endpoint returned successfully from inside the running container.

This confirmed that the backend application was listening on port 8000 and responding correctly.

### Lesson

Application containers do not need to contain general-purpose troubleshooting utilities.

When debugging minimal containers, use application-runtime capabilities when available or launch a dedicated temporary diagnostic Pod rather than adding unnecessary packages to the production image.

---

## Docker build context was incorrect when building the backend image

### Symptoms

Running:

```bash
docker build \
  -t securecart-backend:0.1.0 \
  app/backend
```

from inside:

```text
securecart/app/backend
```

failed with:

```text
ERROR: failed to build: unable to prepare context: path "app/backend" not found
```

### Root Cause

Docker build contexts are resolved relative to the current working directory.

Because the shell was already inside:

```text
securecart/app/backend
```

Docker attempted to locate:

```text
securecart/app/backend/app/backend
```

which did not exist.

### Resolution

When running the build from the backend directory, use the current directory as the build context:

```bash
docker build \
  -t securecart-backend:0.1.0 \
  .
```

Alternatively, return to the repository root:

```bash
cd ../..
```

and run:

```bash
docker build \
  -t securecart-backend:0.1.0 \
  app/backend
```

### Result

The backend image built successfully and was subsequently validated locally and loaded into the Kind cluster.

### Lesson

The final argument to `docker build` specifies the build context, not simply the location of the Dockerfile.

Always interpret the build-context path relative to the shell's current working directory.

---

## Backend Service connectivity test succeeded but did not always reach both replicas

### Symptoms

Repeated requests to:

```text
securecart-backend-service:8000
```

returned successful responses, but the same backend Pod sometimes handled several consecutive requests.

For example:

```text
securecart-backend-...-tb2zs
securecart-backend-...-tb2zs
securecart-backend-...-xr6hj
securecart-backend-...-tb2zs
```

### Explanation

A Kubernetes Service distributes connections across eligible endpoints, but it does not guarantee strict round-robin alternation between Pods.

Multiple consecutive requests may therefore reach the same backend replica.

### Validation

Repeated requests eventually returned responses containing both backend Pod names.

The backend `/api/status` endpoint exposes the Pod name through Kubernetes Downward API metadata, making it possible to observe which replica handled each request.

### Result

Both backend replicas successfully served traffic through the same ClusterIP Service.

This validated:

- Service label selection
- Endpoint discovery
- Kubernetes DNS
- Multi-replica backend availability
- Traffic distribution across backend Pods

---

## Frontend entered CrashLoopBackOff because the backend Service could not be resolved

### Symptoms

All SecureCart frontend Pods entered:

```text
CrashLoopBackOff
```

The previous container logs showed:
```text
host not found in upstream "securecart-backend-service"
```

NGINX exited with status code 1.

### Investigation

Verified:

- BACKEND_HOST was correctly set to securecart-backend-service
- BACKEND_PORT was correctly set to 8000
- The backend Service existed
- The backend Pods were Running and Ready
- Kubernetes DNS eventually resolved:

```text
securecart-backend-service.default.svc.cluster.local
```

to the expected ClusterIP

However, frontend-labeled workloads were unable to reach the backend Service even though the NetworkPolicy configuration and workload labels were correct.

### Root Cause

The local Kind networking state had not correctly reconciled the allowed frontend-to-backend network path.

Because frontend NGINX resolves the configured backend upstream when NGINX starts, the unavailable Service path caused NGINX startup to fail.

Kubernetes repeatedly restarted the frontend containers, resulting in CrashLoopBackOff.

### Resolution

Restarted the Kind networking DaemonSet:

```text
kubectl rollout restart daemonset/kindnet -n kube-system

kubectl rollout status daemonset/kindnet \
  -n kube-system \
  --timeout=180s
```

Then validated the authorized frontend path:

```text
kubectl run frontend-connectivity-test \
  --image=busybox:1.36 \
  --restart=Never \
  --labels="app=securecart,component=frontend" \
  --rm -i \
  -- wget -T 5 -qO- \
  http://securecart-backend-service:8000/api/status
```

After the network path recovered, restarted the frontend Deployment:
```text
kubectl rollout restart deployment/securecart-frontend

kubectl rollout status deployment/securecart-frontend

```

### Result

All three frontend Pods returned to:
```text
1/1 Running
```

and the full application path succeeded again:
```text
curl -i https://securecart.local/api/products
```

Result:
```text
HTTP/2 200
```

### Lesson

An application container can fail during startup even when its own configuration is correct if it depends on an upstream service that must resolve or become reachable during initialization.

When NGINX reports an unresolved upstream, validate both Kubernetes DNS and the permitted NetworkPolicy path before modifying the application configuration.

### FastAPI PostgreSQL connectivity stalled after backend rollout
Symptoms

After updating the backend to include PostgreSQL connectivity, a request to:
```text
https://securecart.local/api/db-status
```

did not return and had to be interrupted.

The backend Deployment itself rolled out successfully.

### Investigation

The PostgreSQL StatefulSet was healthy and:
```bash
kubectl exec securecart-postgres-0 -- \
  pg_isready \
  -U securecart_app \
  -d securecart
```

returned:
```text
/var/run/postgresql:5432 - accepting connections
```

The database Service and application configuration were present, but the newly deployed backend could not successfully complete the database connection path.

### Resolution

Restarted the Kind networking DaemonSet:
```bash
kubectl rollout restart daemonset/kindnet -n kube-system

kubectl rollout status daemonset/kindnet \
  -n kube-system \
  --timeout=180s
```

Then retested:
```bash
curl -i https://securecart.local/api/db-status
```

Result

The endpoint returned:
```text
HTTP/2 200
```

with:
```text
{
  "database": "PostgreSQL",
  "status": "connected",
  "test_query": 1
}
```

This confirmed successful communication between FastAPI and PostgreSQL.

### Lesson

A successful workload rollout does not guarantee that all application dependency paths are reachable.

Validate service-to-service connectivity independently when a new internal dependency is introduced.

This behavior was observed in the local Kind environment and is treated as a local networking reconciliation issue rather than an expected Kubernetes deployment requirement.

### PostgreSQL NetworkPolicy validation

#### Objective

Validate that PostgreSQL accepts connections only from explicitly authorized SecureCart database clients.

The database NetworkPolicy permits TCP port 5432 only from explicitly authorized SecureCart database clients.

Authorized workload identities are:

```text
app=securecart
component=backend
```

and:

```text
app=securecart
component=database-migration
```

### Unauthorized Pod Test

An unlabeled PostgreSQL client Pod was launched:
```bash
kubectl run postgres-test \
  --image=postgres:17-alpine \
  --restart=Never \
  --rm -i \
  -- pg_isready \
  -h securecart-postgres \
  -p 5432 \
  -t 5
```

Result:
```text
securecart-postgres:5432 - no response
```

### Frontend Identity Test

A PostgreSQL client carrying the frontend workload identity was launched:
```bash
kubectl run frontend-postgres-test \
  --image=postgres:17-alpine \
  --restart=Never \
  --labels="app=securecart,component=frontend" \
  --rm -i \
  -- pg_isready \
  -h securecart-postgres \
  -p 5432 \
  -t 5
```

Result:
```text
securecart-postgres:5432 - no response
```

### Backend Identity Test

A PostgreSQL client carrying the backend workload identity was launched:
```bash
kubectl run backend-postgres-test \
  --image=postgres:17-alpine \
  --restart=Never \
  --labels="app=securecart,component=backend" \
  --rm -i \
  -- pg_isready \
  -h securecart-postgres \
  -p 5432 \
  -t 5
```

Result:
```text
securecart-postgres:5432 - accepting connections
```

### Result

The database trust boundary behaved as designed:
```text
Backend workload  -> PostgreSQL :5432   ALLOWED
Frontend workload -> PostgreSQL :5432   DENIED
Other workload    -> PostgreSQL :5432   DENIED
```

The normal application path continued to work:
```bash
curl --max-time 10 -i \
  https://securecart.local/api/products
```

Result:
```text
HTTP/2 200
```

### Lesson

Network placement alone does not provide least privilege.

The database is internal to the Kubernetes cluster, but explicit NetworkPolicy rules are still required to prevent unauthorized workloads from reaching PostgreSQL.

---

## PostgreSQL failed to initialize when forced to run non-root

### Symptoms

PostgreSQL security hardening was tested by configuring the Pod to start directly as the PostgreSQL runtime identity:

```yaml
securityContext:
  runAsUser: 70
  runAsGroup: 70
  runAsNonRoot: true
  fsGroup: 70
```

A fresh PostgreSQL test Pod failed to start and entered:

```text
Error
CrashLoopBackOff
```

The container logs reported:

```text
chmod: /var/lib/postgresql/data: Operation not permitted
initdb: error: could not change permissions of directory "/var/lib/postgresql/data": Operation not permitted
```

### Investigation

The PostgreSQL image performs initialization operations against the database data directory before starting the long-running database server.

The test forced the entire container lifecycle to execute as UID/GID `70`.

Although UID `70` is the PostgreSQL runtime identity, the initialization process still required filesystem permission operations that were no longer permitted.

The existing PostgreSQL workload was inspected separately:

```bash
kubectl exec securecart-postgres-0 -- \
  sh -c 'grep -E "^(Uid|Gid):" /proc/1/status'
```

Result:

```text
Uid:    70    70    70    70
Gid:    70    70    70    70
```

This demonstrated that the running PostgreSQL server already operates as its dedicated PostgreSQL identity after successful initialization.

### Root Cause

Container startup identity and long-running process identity are not necessarily the same security requirement.

Forcing Kubernetes `runAsUser: 70` across the entire PostgreSQL container lifecycle prevented the image from performing required initialization operations on a fresh persistent volume.

### Resolution

The forced Pod-level non-root configuration was not applied to the production PostgreSQL StatefulSet.

The PostgreSQL image was allowed to preserve its required initialization behavior while retaining its normal runtime transition to the dedicated PostgreSQL user.

The application was then revalidated:

```bash
curl -i https://securecart.local/api/products

curl -i https://securecart.local/api/db-status
```

Both endpoints returned:

```text
HTTP/2 200
```

Existing database data was also verified directly through PostgreSQL.

### Result

SecureCart preserves PostgreSQL availability and persistent-volume initialization behavior while the long-running database process operates as UID/GID `70`.

The stricter non-root and read-only-root-filesystem controls remain applied to workloads where they are compatible:

```text
Frontend
Backend
Database Migration Job
```

### Lesson

Security controls should be validated against actual workload behavior rather than applied uniformly.

A security setting that is appropriate for a stateless application container may break a stateful database initialization lifecycle.

The goal is least privilege while preserving required application behavior.

---

## Frontend failed after moving NGINX to an unprivileged runtime

### Symptoms

During frontend hardening, the SecureCart frontend was moved from the standard NGINX image to an unprivileged NGINX runtime.

An early container test failed with:

```text
invalid port in upstream ":" in /tmp/securecart/nginx.conf
```

Another test could not resolve:

```text
host.docker.internal
```

The Kubernetes manifests also initially failed validation because fields were placed at incorrect YAML levels.

Example errors included:

```text
unknown field "spec.pports"
```

and:

```text
unknown field "spec.template.spec.containers[0].volumes"
```

### Investigation

The frontend startup process dynamically renders both application content and NGINX configuration using `envsubst`.

The generated NGINX configuration depends on:

```text
BACKEND_HOST
BACKEND_PORT
```

If those values are not available during template rendering, the generated upstream becomes invalid.

The move to an unprivileged NGINX image also changed the frontend container port from privileged port `80` to unprivileged port `8080`.

Kubernetes therefore required the frontend Service to expose:

```text
Service port: 80
Target port: 8080
```

The hardening changes also required writable runtime storage while keeping the container root filesystem read-only.

### Root Cause

Several application assumptions changed at the same time:

```text
NGINX runtime identity
Container listening port
Writable filesystem locations
Backend proxy configuration
Kubernetes Service target port
```

The initial configuration did not consistently reflect those changes across the Docker image, entrypoint, NGINX template, Deployment, and Service.

### Resolution

The frontend was configured to use the unprivileged NGINX image and run as UID/GID `101`.

The NGINX server was moved to port `8080`.

The frontend Service retained port `80` and forwards requests to container port `8080`.

Backend proxy configuration is supplied explicitly in Kubernetes:

```text
BACKEND_HOST=securecart-backend-service
BACKEND_PORT=8000
```

A writable `emptyDir` is mounted at:

```text
/tmp
```

while the remainder of the container root filesystem remains read-only.

The final runtime identity was verified:

```bash
kubectl exec "$POD" -- id
```

Result:

```text
uid=101(nginx) gid=101(nginx) groups=101(nginx)
```

Filesystem restrictions were also tested:

```bash
kubectl exec "$POD" -- \
  sh -c 'touch /etc/test-file'
```

Result:

```text
touch: /etc/test-file: Read-only file system
```

while:

```bash
kubectl exec "$POD" -- \
  sh -c 'touch /tmp/test-file'
```

succeeded.

### Result

The hardened frontend successfully serves the application and proxies API requests:

```bash
curl --max-time 10 -i https://securecart.local

curl --max-time 10 -i \
  https://securecart.local/api/products
```

Both application paths returned:

```text
HTTP/2 200
```

### Lesson

Container hardening can affect multiple layers of an application simultaneously.

Runtime user, listening ports, writable paths, template rendering, Services, probes, and proxy configuration should be treated as one deployment contract and validated together.

---

## Database migration Job initially failed to reach PostgreSQL

### Symptoms

After introducing the Kubernetes database migration Job, the workload could fail to reach PostgreSQL even though the backend application continued to access the database successfully.

The PostgreSQL NetworkPolicy originally permitted only workloads carrying:

```text
app=securecart
component=backend
```

The migration Job uses a separate workload identity:

```text
app=securecart
component=database-migration
```

### Investigation

The PostgreSQL NetworkPolicy was inspected:

```bash
kubectl describe networkpolicy \
  allow-backend-to-postgres
```

The database policy selects:

```text
app=securecart
component=database
```

and restricts inbound TCP `5432`.

Because the migration Job is intentionally not labeled as a backend workload, it did not automatically inherit backend database authorization.

### Root Cause

The migration Job introduced a new legitimate database client.

The existing NetworkPolicy correctly denied workloads that did not match the authorized backend identity.

This was expected least-privilege behavior, but the policy needed to evolve with the architecture.

### Resolution

The PostgreSQL NetworkPolicy was updated to explicitly authorize both application identities:

```text
app=securecart
component in (backend,database-migration)
```

The effective database access model became:

```text
Backend             -> PostgreSQL :5432   ALLOWED
Database Migration  -> PostgreSQL :5432   ALLOWED
Frontend            -> PostgreSQL :5432   DENIED
Other Workloads     -> PostgreSQL :5432   DENIED
```

The migration Job was recreated and tested:

```bash
kubectl delete job securecart-db-migration

kubectl apply \
  -f kubernetes/base/database-migration-job.yaml

kubectl wait \
  --for=condition=complete \
  job/securecart-db-migration \
  --timeout=120s

kubectl logs job/securecart-db-migration
```

Result:

```text
Skipping existing product: SecureCart T-Shirt
Skipping existing product: SecureCart Hoodie
Skipping existing product: SecureCart Sticker Pack
```

The Job completed successfully:

```text
STATUS       Complete
COMPLETIONS  1/1
```

### Local Kind Networking Note

During NetworkPolicy changes in the local Kind environment, connectivity did not always reconcile immediately.

Restarting Kind's networking DaemonSet restored the expected policy state:

```bash
kubectl rollout restart daemonset/kindnet \
  -n kube-system

kubectl rollout status daemonset/kindnet \
  -n kube-system \
  --timeout=180s
```

This is documented as a local Kind networking behavior observed during development, not as a required SecureCart deployment step.

### Result

The migration workload can now perform schema and seed operations while PostgreSQL remains isolated from unauthorized workloads.

### Lesson

Least-privilege NetworkPolicies must evolve when new legitimate workload identities are introduced.

A deployment Job should receive explicit access to its required dependency rather than being mislabeled as another application tier or broadening database access for the entire cluster.

---

---

## Frontend CrashLoopBackOff caused by backend DNS resolution during NGINX startup

### Symptoms

One SecureCart frontend Pod entered:

```text
CrashLoopBackOff
```

while the other frontend replicas remained healthy.

The frontend Deployment reported:

```text
2/3 Ready
```

The application remained partially available because the remaining frontend replicas continued serving traffic.

Previous container logs showed:

```text
host not found in upstream "securecart-backend-service"
```

NGINX exited with status code 1.

Startup probes then failed with:

```text
connect: connection refused
```

because NGINX never successfully started.

### Investigation

The affected frontend Pod and a healthy frontend Pod were both scheduled on the same Kubernetes worker node.

This reduced the likelihood that the issue was caused by a single unhealthy node.

The backend Service remained present and healthy.

After restarting the local Kind networking daemon and replacing the failed frontend Pod, the replacement Pod started successfully.

This indicated that the immediate failure was related to temporary DNS or networking availability during frontend container startup.

The frontend NGINX configuration used:

```text
securecart-backend-service:8000
```

directly as the proxy upstream.

NGINX attempted to resolve the backend Service name while loading its configuration.

If DNS resolution failed during this startup window, NGINX terminated instead of starting the frontend and allowing the dependency to recover later.

### Initial Runtime DNS Fix

The NGINX configuration was changed to use a runtime resolver discovered from:

```text
/etc/resolv.conf
```

and an NGINX variable-based upstream.

The generated configuration included:

```nginx
resolver <runtime-dns-server> valid=10s ipv6=off;
resolver_timeout 2s;

set $backend_upstream "<backend-host>:8000";

proxy_pass http://$backend_upstream;
```

Local Docker validation confirmed that the frontend could:

```text
Start before the backend existed
Serve static content with HTTP 200
Return HTTP 502 for unavailable backend requests
Remain running with RestartCount=0
Recover automatically after the backend later became available
```

### Kubernetes Short Service Name Issue

After deploying the first runtime DNS implementation to Kubernetes, the frontend Pods remained healthy but `/api/*` requests returned:

```text
HTTP 502
```

The frontend Pod resolver configuration showed:

```text
search default.svc.cluster.local svc.cluster.local cluster.local localdomain
nameserver 10.96.0.10
```

The backend Service and its endpoints were healthy.

The generated NGINX configuration still referenced the short Service name:

```text
securecart-backend-service
```

The runtime NGINX resolver did not use the Pod search-domain behavior in the same way as ordinary system name resolution.

### Resolution

The frontend Deployment was updated to expose the current Pod namespace through the Downward API:

```yaml
- name: POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
```

The backend runtime hostname was then defined as the fully qualified Kubernetes Service DNS name:

```text
securecart-backend-service.$(POD_NAMESPACE).svc.cluster.local
```

In the default namespace, this becomes:

```text
securecart-backend-service.default.svc.cluster.local
```

Frontend image `0.3.2` includes this runtime DNS behavior.

The generated NGINX configuration inside Kubernetes now contains:

```text
resolver 10.96.0.10 valid=10s ipv6=off
securecart-backend-service.default.svc.cluster.local:8000
```

### Validation

After deployment:

```text
Frontend replicas: 3/3 Ready
Backend replicas: 2/2 Ready
```

The frontend Pods reported zero restarts.

Application validation returned:

```text
/                  -> HTTP 200
/api/status        -> HTTP 200
/api/products      -> HTTP 200
/api/db-status     -> HTTP 200
```

The backend status endpoint also reported the correct deployed image version:

```text
0.4.1
```

### Lesson

A frontend process should not crash solely because a downstream Service name is temporarily unavailable during startup.

Runtime dependency resolution reduces unnecessary container restarts and allows transient dependency failures to remain isolated to the requests that require those dependencies.

When application-level DNS clients are used inside Kubernetes, validate their behavior with fully qualified Kubernetes Service names rather than assuming they consume Pod DNS search domains exactly like the system resolver.
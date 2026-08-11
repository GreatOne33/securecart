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
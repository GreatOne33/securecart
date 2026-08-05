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



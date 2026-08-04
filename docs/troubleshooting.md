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


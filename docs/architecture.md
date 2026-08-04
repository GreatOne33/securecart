# SecureCart Architecture

## HTTPS Request Flow

```text

Client
  │
  │ HTTPS
  ▼
NGINX Ingress Controller
TLS Termination
  │
  │ HTTP
  ▼
securecart-service
  │
  ▼
Healthy Frontend Pods

```

External client traffic is encrypted using HTTPS. The NGINX Ingress Controller terminates TLS and forwards HTTP traffic to the internal ClusterIP Service, which distributes requests across healthy frontend replicas.


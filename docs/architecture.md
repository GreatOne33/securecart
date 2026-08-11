# SecureCart Architecture

This document describes the current SecureCart application architecture, component responsibilities, request flows, network boundaries, and planned evolution.

SecureCart is currently a multi-tier containerized application running on a local Kubernetes cluster using Kind.

---

## Current Architecture

```text
                         External Client
                                |
                              HTTPS
                                |
                                v
                     NGINX Ingress Controller
                         TLS Termination
                                |
                              HTTP
                                |
                                v
                     securecart-service :80
                                |
                                v
                 +-----------------------------+
                 | SecureCart Frontend Pods    |
                 |                             |
                 | NGINX                       |
                 | Runtime Config Rendering    |
                 | /api/* Reverse Proxy        |
                 +-----------------------------+
                                |
                                | HTTP :8000
                                |
                                v
                securecart-backend-service :8000
                                |
                     +----------+----------+
                     |                     |
                     v                     v
              +-------------+       +-------------+
              |   FastAPI   |       |   FastAPI   |
              | Backend Pod |       | Backend Pod |
              +-------------+       +-------------+
```

The frontend and backend are independently containerized workloads.

The frontend is the externally reachable application tier. The backend remains internal to the Kubernetes cluster and is accessed through the frontend NGINX reverse proxy.

---

## Component Responsibilities

### NGINX Ingress Controller

The NGINX Ingress Controller provides the external entry point into SecureCart.

Responsibilities:

- Accept HTTPS traffic for `securecart.local`
- Terminate TLS
- Redirect HTTP traffic to HTTPS
- Route requests to `securecart-service`
- Provide the boundary between external traffic and the application

TLS currently uses a self-signed certificate for local development.

---

### Frontend Service

`securecart-service` is a Kubernetes ClusterIP Service that provides a stable network endpoint for the frontend Pods.

The Service selects workloads using:

```text
app=securecart
component=frontend
```

The Service distributes traffic across healthy frontend replicas.

---

### Frontend

The SecureCart frontend runs as a custom NGINX container.

The image contains:

- NGINX
- HTML template
- NGINX configuration template
- Container startup entrypoint
- Runtime configuration rendering

The container renders its application configuration during startup using environment variables supplied by Kubernetes.

This allows the same container image to operate in different environments without rebuilding the image.

Frontend Pods receive runtime configuration from Kubernetes ConfigMaps and Pod metadata through the Downward API.

The frontend has two primary responsibilities:

```text
/           -> Serve frontend content
/api/*      -> Proxy requests to the backend
```

API requests are forwarded to:

```text
securecart-backend-service:8000
```

---

### Backend Service

`securecart-backend-service` is an internal Kubernetes ClusterIP Service.

It provides a stable DNS name and virtual IP for the FastAPI backend while allowing backend Pods to be replaced or scaled independently.

The Service selects workloads using:

```text
app=securecart
component=backend
```

Applications communicate with the backend using Kubernetes service discovery rather than individual Pod IP addresses.

---

### Backend

The SecureCart backend is a Python application built with FastAPI.

The backend currently provides:

```text
GET /health
GET /api/status
GET /api/products
GET /api/products/{product_id}
```

Pydantic models define API response structures and provide an explicit application contract.

The backend currently uses in-memory product data while the persistent data layer is under development.

Multiple backend replicas run behind `securecart-backend-service`.

Backend Pods receive runtime configuration and Pod metadata from Kubernetes.

---

## HTTPS Request Flow

Requests for frontend content follow:

```text
Client
  |
  | HTTPS
  v
NGINX Ingress Controller
  |
  | TLS termination
  | HTTP
  v
securecart-service
  |
  v
Frontend Pod
  |
  v
NGINX
  |
  v
Frontend Content
```

External traffic remains encrypted until it reaches the Ingress Controller.

TLS terminates at the Ingress Controller, which forwards HTTP traffic to the internal frontend Service.

---

## API Request Flow

API requests use the same external application endpoint:

```text
https://securecart.local/api/*
```

The request path is:

```text
Client
  |
  | HTTPS
  v
NGINX Ingress Controller
  |
  | HTTP
  v
securecart-service :80
  |
  v
Frontend NGINX
  |
  | /api/*
  | HTTP :8000
  v
securecart-backend-service
  |
  v
FastAPI Backend Pod
```

The backend is not directly exposed through Kubernetes Ingress.

Frontend NGINX acts as the application reverse proxy and forwards API requests using Kubernetes DNS.

This provides a single external application origin while keeping backend implementation details internal to the cluster.

---

## Service Discovery

SecureCart uses Kubernetes Services and DNS for communication between application tiers.

The frontend does not communicate directly with backend Pod IP addresses.

Instead, it uses:

```text
securecart-backend-service:8000
```

Kubernetes resolves the Service name and forwards connections to eligible backend endpoints.

This allows backend Pods to be restarted, replaced, or scaled without requiring frontend configuration changes.

---

## Runtime Configuration

SecureCart separates container images from environment-specific runtime configuration.

The frontend container receives configuration from Kubernetes and renders its templates when the container starts.

Configuration sources include:

```text
Configuration sources include:

ConfigMap
   |
   +------> Application configuration
   |
   v
Frontend Container

Deployment Environment Variables
   |
   +------> Backend service location
   |
   v
Frontend Container

Downward API
   |
   +------> Pod metadata
   |
   v
Frontend / Backend

```

Examples include:

- Application name
- Environment
- Version
- Company
- Backend host
- Backend port
- Pod name

BACKEND_HOST and BACKEND_PORT are currently defined directly in the frontend Deployment, while general frontend configuration is provided through the ConfigMap.

This allows application images to remain portable while Kubernetes supplies environment-specific values.

---

## Health Management

### Frontend

The frontend uses HTTP-based Kubernetes probes against port 80:

- Startup probe
- Readiness probe
- Liveness probe

These probes determine when frontend Pods can receive traffic and when unhealthy containers should be restarted.

### Backend

The FastAPI backend provides a dedicated:

```text
/health
```

endpoint.

Kubernetes uses the health endpoint to determine backend application health.

The dedicated endpoint separates application health checking from normal API functionality.

As dependencies such as PostgreSQL are introduced, the backend health strategy will evolve so readiness can represent whether the application is capable of serving dependency-backed requests.

---

## Network Security Boundaries

SecureCart applies Kubernetes NetworkPolicies to both application tiers.

### Frontend Boundary

Frontend Pods accept TCP port 80 traffic only from the `ingress-nginx` namespace.

```text
ingress-nginx -> Frontend :80    ALLOWED

Other Pods    -> Frontend :80    DENIED
```

### Backend Boundary

Backend Pods accept TCP port 8000 traffic only from workloads carrying the SecureCart frontend identity:

```text
app=securecart
component=frontend
```

The intended boundary is:

```text
Frontend Pods -> Backend :8000   ALLOWED

Other Pods    -> Backend :8000   DENIED
```

Together, these policies establish the application communication path:

```text
External Client
      |
      v
Ingress Controller
      |
      | Allowed
      v
Frontend
      |
      | Allowed
      v
Backend

Unauthorized Pod
      |
      +------X------> Frontend
      |
      +------X------> Backend
```

This applies least-privilege network access between application tiers.

---

## Workload Identity

SecureCart uses Kubernetes labels to identify application workloads.

Frontend:

```text
app=securecart
component=frontend
```

Backend:

```text
app=securecart
component=backend
```

Services and NetworkPolicies use these identities rather than Pod names or Pod IP addresses.

This is important because Kubernetes Pods are ephemeral and may be recreated with different names and addresses.

---

## Scaling and Availability

The frontend and backend run as Kubernetes Deployments.

Deployments provide:

- Declarative replica management
- Pod replacement
- Self-healing
- Rolling updates
- Rollbacks

ClusterIP Services provide stable network endpoints in front of those changing Pod replicas.

The backend currently runs multiple replicas behind:

```text
securecart-backend-service
```

Requests can therefore be served by different backend Pods without clients needing to know individual Pod addresses.

---

## Current Trust Model

The current application architecture intentionally exposes only the frontend tier.

```text
Internet / Client
       |
       v
    Ingress
       |
       v
    Frontend
       |
       v
    Backend
```

Each application tier is granted only the network access required for its current responsibility.

The backend is not directly exposed to external clients.

Future components will follow the same approach rather than receiving broad network access by default.

---

## Planned Data Layer

The next architectural milestone introduces PostgreSQL and persistent storage.

The planned application flow is:

```text
External Client
      |
      v
Ingress Controller
      |
      v
Frontend
      |
      v
Backend
      |
      v
PostgreSQL
      |
      v
Persistent Storage
```

The backend will replace its current in-memory product catalog with database-backed data.

The database will not be externally exposed.

A dedicated NetworkPolicy will restrict database access to workloads that require it.

Persistent storage will be introduced independently from the lifecycle of individual database Pods.

This section represents planned architecture and is not yet implemented.

---

## Long-Term Architecture

SecureCart is designed to evolve from the current local Kind environment toward AWS.

Planned technologies include:

- Terraform
- Amazon ECR
- Amazon EKS
- AWS IAM
- AWS VPC networking
- AWS Load Balancer Controller
- AWS Certificate Manager
- Helm
- GitHub Actions
- Prometheus
- Grafana

The current architecture intentionally establishes application boundaries that can later be mapped to cloud infrastructure without redesigning the entire application.

The implementation of these components will be documented as later project phases are completed.

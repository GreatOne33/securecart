# SecureCart Design Decisions

This document records important architectural and engineering decisions made during SecureCart development.

---

## ADR-001: Health Probe Strategy

SecureCart uses HTTP-based startup, readiness, and liveness probes for the frontend NGINX container.

The probes currently check `/` on port 80 because the frontend does not yet expose dedicated health endpoints.

Readiness is used to control whether a Pod receives Service traffic. Liveness is used to restart an unhealthy frontend container. Startup protects initialization by preventing readiness and liveness checks from running until the application has successfully started.

A future backend API should expose dedicated endpoints such as:

- `/startup`
- `/ready`
- `/health`

These endpoints should evaluate application dependencies appropriately rather than relying only on the root application path.

--- 

## ADR-002: Resource Request Strategy

SecureCart uses Burstable Quality of Service by configuring requests lower than limits.

This approach reserves sufficient CPU and memory for scheduling while allowing temporary resource bursts during increased workload.

Current frontend allocation:

- CPU Request: 100m
- CPU Limit: 250m
- Memory Request: 128Mi
- Memory Limit: 256Mi

These values are intentionally conservative for the lightweight frontend and will be revisited after Metrics Server and application monitoring are introduced.

---

## ADR-003: Ingress and TLS Strategy

SecureCart uses the NGINX Ingress Controller for host-based HTTP and HTTPS routing.

Kind maps host ports 80 and 443 into the control-plane node. The Ingress Controller is scheduled onto that same node so incoming traffic reaches its host ports.

TLS terminates at the Ingress Controller. The controller forwards HTTP traffic internally to the ClusterIP Service.

A self-signed certificate is used for local development. Production deployments will use a trusted certificate authority through AWS Certificate Manager or cert-manager.
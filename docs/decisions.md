## Health Probe Strategy

SecureCart uses HTTP-based startup, readiness, and liveness probes for the frontend NGINX container.

The probes currently check `/` on port 80 because the frontend does not yet expose dedicated health endpoints.

Readiness is used to control whether a Pod receives Service traffic. Liveness is used to restart an unhealthy frontend container. Startup protects initialization by preventing readiness and liveness checks from running until the application has successfully started.

A future backend API should expose dedicated endpoints such as:

- `/startup`
- `/ready`
- `/health`

These endpoints should evaluate application dependencies appropriately rather than relying only on the root application path.
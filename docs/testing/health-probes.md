## Readiness Probe Test

### Break the application

```bash
kubectl exec <pod> -- \
  mv /usr/share/nginx/html/index.html \
     /usr/share/nginx/html/index.html.disabled
```

### Verify Pod status

```bash
kubectl get pods
```

### Verify Service endpoints

```bash
kubectl get endpointslice \
  -l kubernetes.io/service-name=securecart-service \
  -o wide
```

### Expected Result

- Pod remains Running
- Pod becomes NotReady
- Endpoint removed from Service
- Container is not restarted
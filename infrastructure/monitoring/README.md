# Loki + Promtail

## Prerequisites

- Kubernetes 1.21+
- Helm 3+

### Download and Deploy

```bash
helm repo add grafana https://grafana.github.io/helm-charts
```

```bash
helm repo update
```

### Deploy Loki

```bash
helm upgrade --install loki-stack grafana/loki-stack --version 2.9.11 -f loki.yaml -n monitoring
```

### Deploy Promtail

```bash
helm upgrade --install loki-promtail grafana/promtail --version 6.15.3 -f promtail.yaml -n monitoring
```

### Deploy Tempo
```bash
helm upgrade -f tempo-1.7.1.yaml --version 1.7.1 tempo -n istio-system grafana/tempo
kubectl apply -f zipkin-tempo-svc.yaml
```

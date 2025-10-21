# Kubernetes Deployment - E-Banking Observability Stack

Complete Kubernetes manifests for ODDO BHF e-Banking observability platform.

## 📦 Stack Components

### Infrastructure Layer
- **Vault** - Secrets management
- **Nginx** - Reverse proxy with SSL/TLS

### Data Sources Layer
- **SQL Server** - E-Banking transaction database
- **Prometheus** - Metrics collection
- **Elasticsearch** - Log storage
- **Jaeger** - Distributed tracing
- **Loki** - Log aggregation
- **PostgreSQL** - Grafana metadata storage
- **MinIO** - S3-compatible object storage

### Collectors Layer
- **Node Exporter** - System metrics
- **E-Banking Exporter** - Custom metrics exporter (C#)
- **Promtail** - Log collector
- **Telegraf** - Multi-purpose metrics collector
- **Pushgateway** - Batch job metrics

### Processing Layer
- **AlertManager** - Alert routing and grouping

### Visualization Layer
- **Grafana** - Observability dashboard platform

### E-Banking Services
- **Auth Service** - Authentication microservice
- **Transaction Service** - Transaction processing
- **KPI Service** - KPI tracking and reporting

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster 1.24+
- kubectl configured
- 16 CPU cores, 32GB RAM minimum
- StorageClass for persistent volumes
- Ingress controller (nginx/traefik)

### Deploy Complete Stack

```bash
# 1. Create namespace
kubectl apply -f 00-namespace.yaml

# 2. Create secrets
kubectl apply -f 01-secrets/

# 3. Create ConfigMaps
kubectl apply -f 02-configmaps/

# 4. Create persistent volumes
kubectl apply -f 03-storage/

# 5. Deploy databases and storage
kubectl apply -f 04-databases/

# 6. Deploy data sources
kubectl apply -f 05-data-sources/

# 7. Deploy collectors
kubectl apply -f 06-collectors/

# 8. Deploy processing layer
kubectl apply -f 07-processing/

# 9. Deploy Grafana
kubectl apply -f 08-grafana/

# 10. Deploy e-banking services
kubectl apply -f 09-ebanking-services/

# 11. Deploy ingress
kubectl apply -f 10-ingress/
```

### Or deploy everything at once:

```bash
./deploy.sh
```

## 📁 Directory Structure

```
k8s-stack/
├── 00-namespace.yaml
├── 01-secrets/
│   ├── vault-secrets.yaml
│   ├── database-secrets.yaml
│   └── grafana-secrets.yaml
├── 02-configmaps/
│   ├── prometheus-config.yaml
│   ├── loki-config.yaml
│   ├── alertmanager-config.yaml
│   ├── nginx-config.yaml
│   └── telegraf-config.yaml
├── 03-storage/
│   ├── storage-class.yaml
│   └── persistent-volumes.yaml
├── 04-databases/
│   ├── sql-server.yaml
│   ├── postgresql.yaml
│   ├── elasticsearch.yaml
│   └── minio.yaml
├── 05-data-sources/
│   ├── prometheus.yaml
│   ├── loki.yaml
│   └── jaeger.yaml
├── 06-collectors/
│   ├── node-exporter.yaml
│   ├── ebanking-exporter.yaml
│   ├── promtail.yaml
│   ├── telegraf.yaml
│   └── pushgateway.yaml
├── 07-processing/
│   └── alertmanager.yaml
├── 08-grafana/
│   └── grafana.yaml
├── 09-ebanking-services/
│   ├── auth-service.yaml
│   ├── transaction-service.yaml
│   └── kpi-service.yaml
├── 10-ingress/
│   └── ingress.yaml
└── deploy.sh
```

## 🔐 Security Features

- **NetworkPolicies** for pod-to-pod communication
- **RBAC** with least-privilege service accounts
- **Secrets** for sensitive credentials
- **SecurityContext** with non-root users
- **Pod Security Standards** enforced
- **TLS/SSL** for all external endpoints

## 📊 Resource Requirements

| Component | CPU Request | Memory Request | Storage |
|-----------|-------------|----------------|---------|
| SQL Server | 2 cores | 4Gi | 50Gi |
| Elasticsearch | 1 core | 2Gi | 30Gi |
| Prometheus | 1 core | 2Gi | 50Gi |
| Grafana | 500m | 1Gi | 10Gi |
| PostgreSQL | 500m | 1Gi | 10Gi |
| Loki | 500m | 1Gi | 20Gi |
| MinIO | 500m | 512Mi | 50Gi |
| **Total** | **~8 cores** | **~16Gi** | **~220Gi** |

## 🌐 Access Endpoints

After deployment:

- **Grafana**: https://grafana.oddo-bank.local
- **Prometheus**: https://prometheus.oddo-bank.local
- **AlertManager**: https://alertmanager.oddo-bank.local
- **Jaeger UI**: https://jaeger.oddo-bank.local
- **MinIO Console**: https://minio.oddo-bank.local

## 🔍 Monitoring & Health Checks

```bash
# Check all pods
kubectl get pods -n ebanking-observability

# Check services
kubectl get svc -n ebanking-observability

# Check ingress
kubectl get ingress -n ebanking-observability

# View logs
kubectl logs -n ebanking-observability deployment/grafana -f

# Port forward for local access
kubectl port-forward -n ebanking-observability svc/grafana 3000:3000
```

## 🛠️ Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n ebanking-observability
kubectl logs <pod-name> -n ebanking-observability --previous
```

### PVC pending
```bash
kubectl get pvc -n ebanking-observability
kubectl describe pvc <pvc-name> -n ebanking-observability
# Check storage class exists
kubectl get storageclass
```

### Service connectivity
```bash
kubectl exec -it deployment/grafana -n ebanking-observability -- /bin/sh
# Inside pod: test connectivity
wget -O- http://prometheus:9090/-/healthy
```

## 📝 Configuration

### Update Grafana admin password
```bash
kubectl edit secret grafana-admin-credentials -n ebanking-observability
# Update admin-password (base64 encoded)
```

### Update data source configs
```bash
kubectl edit configmap prometheus-config -n ebanking-observability
kubectl rollout restart deployment/prometheus -n ebanking-observability
```

## 🔄 Backup & Restore

### Backup Grafana dashboards
```bash
kubectl exec deployment/grafana -n ebanking-observability -- \
  tar czf /tmp/grafana-backup.tar.gz /var/lib/grafana
kubectl cp ebanking-observability/grafana-xxx:/tmp/grafana-backup.tar.gz ./grafana-backup.tar.gz
```

### Backup Prometheus data
```bash
kubectl exec statefulset/prometheus -n ebanking-observability -- \
  tar czf /tmp/prometheus-backup.tar.gz /prometheus
```

## 🚨 Alerts & Notifications

Alerts are pre-configured for:
- High transaction failure rate
- Slow API response times
- Database connection issues
- Pod crashes and restarts
- High resource usage

## 📈 Scaling

### Scale Grafana horizontally
```bash
kubectl scale deployment/grafana --replicas=3 -n ebanking-observability
```

### Scale e-banking services
```bash
kubectl scale deployment/transaction-service --replicas=5 -n ebanking-observability
```

## 🔧 Maintenance

### Update images
```bash
kubectl set image deployment/grafana grafana=grafana/grafana:10.3.0 -n ebanking-observability
```

### Rolling restart
```bash
kubectl rollout restart deployment/grafana -n ebanking-observability
```

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Grafana Kubernetes Guide](https://grafana.com/docs/grafana/latest/setup-grafana/installation/kubernetes/)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)

## 🤝 Support

For issues or questions:
- Internal Wiki: https://wiki.oddo-bank.local
- DevOps Team: devops@oddo-bank.local
- Slack: #observability-platform

# Kubernetes Deployment Guide - E-Banking Observability Stack

Complete deployment instructions for the ODDO BHF e-banking observability platform on Kubernetes.

## 📋 What Has Been Generated

### Core Files Created

1. ✅ **00-namespace.yaml** - Namespace configuration
2. ✅ **01-secrets/all-secrets.yaml** - All secrets (databases, Grafana, Vault, MinIO)
3. ✅ **03-storage/persistent-volumes.yaml** - 8 PVCs for all components
4. ✅ **04-databases/postgresql-complete.yaml** - PostgreSQL StatefulSet with init scripts
5. ✅ **05-data-sources/prometheus-complete.yaml** - Prometheus with RBAC and service discovery
6. ✅ **08-grafana/grafana-complete.yaml** - Production-ready Grafana with auto-scaling
7. ✅ **deploy.sh** - Automated deployment script
8. ✅ **README.md** - Complete documentation

### Components Deployed

| Component | Status | Description |
|-----------|--------|-------------|
| **Namespace** | ✅ Created | ebanking-observability |
| **Secrets** | ✅ Created | All credentials and tokens |
| **Storage** | ✅ Created | 220Gi total storage |
| **PostgreSQL** | ✅ Created | StatefulSet with HA |
| **Prometheus** | ✅ Created | With K8s service discovery |
| **Grafana** | ✅ Created | With datasource provisioning |
| **Deployment Script** | ✅ Created | Automated deployment |

## 🚀 Quick Start Deployment

### Method 1: Automated Deployment

```bash
cd k8s-stack
chmod +x deploy.sh
./deploy.sh
```

The script will:
1. Check prerequisites (kubectl, cluster access)
2. Create namespace
3. Deploy all components in order
4. Wait for services to be ready
5. Display access information

### Method 2: Manual Step-by-Step

```bash
# 1. Create namespace
kubectl apply -f 00-namespace.yaml

# 2. Create secrets
kubectl apply -f 01-secrets/all-secrets.yaml

# 3. Create storage
kubectl apply -f 03-storage/persistent-volumes.yaml

# Wait for PVCs to bind
kubectl get pvc -n ebanking-observability -w

# 4. Deploy PostgreSQL
kubectl apply -f 04-databases/postgresql-complete.yaml

# Wait for PostgreSQL
kubectl wait --for=condition=ready pod -l app=postgresql -n ebanking-observability --timeout=300s

# 5. Deploy Prometheus
kubectl apply -f 05-data-sources/prometheus-complete.yaml

# 6. Deploy Grafana
kubectl apply -f 08-grafana/grafana-complete.yaml

# Wait for Grafana
kubectl wait --for=condition=available deployment/grafana -n ebanking-observability --timeout=300s
```

## 🔍 Verification Steps

### 1. Check Namespace

```bash
kubectl get namespace ebanking-observability
```

**Expected Output:**
```
NAME                     STATUS   AGE
ebanking-observability   Active   1m
```

### 2. Check All Pods

```bash
kubectl get pods -n ebanking-observability
```

**Expected Output:**
```
NAME                          READY   STATUS    RESTARTS   AGE
postgresql-0                  1/1     Running   0          5m
prometheus-xxx                1/1     Running   0          4m
grafana-xxx                   1/1     Running   0          3m
```

### 3. Check Services

```bash
kubectl get svc -n ebanking-observability
```

**Expected Output:**
```
NAME         TYPE        CLUSTER-IP      PORT(S)    AGE
postgresql   ClusterIP   10.96.x.x       5432/TCP   5m
prometheus   ClusterIP   10.96.x.x       9090/TCP   4m
grafana      ClusterIP   10.96.x.x       3000/TCP   3m
```

### 4. Check PVC Status

```bash
kubectl get pvc -n ebanking-observability
```

**Expected Output:**
```
NAME                STATUS   VOLUME                                     CAPACITY
prometheus-data     Bound    pvc-xxxxx                                  50Gi
grafana-data        Bound    pvc-xxxxx                                  10Gi
postgresql-data     Bound    pvc-xxxxx                                  10Gi
```

## 🌐 Accessing Services

### Port Forwarding (for testing)

**Grafana:**
```bash
kubectl port-forward -n ebanking-observability svc/grafana 3000:3000
```
Then open: http://localhost:3000
- **Username:** admin
- **Password:** Grafana.OddoBhf@Secure123

**Prometheus:**
```bash
kubectl port-forward -n ebanking-observability svc/prometheus 9090:9090
```
Then open: http://localhost:9090

**PostgreSQL (database access):**
```bash
kubectl port-forward -n ebanking-observability svc/postgresql 5432:5432
```
Then connect with:
- **Host:** localhost
- **Port:** 5432
- **Database:** grafana_db
- **User:** grafana_admin
- **Password:** Grafana.OddoBhf@Secure123

### Production Access (with Ingress)

After configuring Ingress (see ingress configuration):
- **Grafana:** https://grafana.oddo-bank.local
- **Prometheus:** https://prometheus.oddo-bank.local

## 🔐 Security Features

### 1. Secrets Management

All sensitive data is stored in Kubernetes secrets:

```bash
# View secrets (values are base64 encoded)
kubectl get secrets -n ebanking-observability

# To update a secret:
kubectl edit secret grafana-admin-credentials -n ebanking-observability
```

### 2. RBAC Configuration

Prometheus has cluster-wide read permissions for service discovery:

```bash
# View Prometheus RBAC
kubectl get clusterrole prometheus
kubectl get clusterrolebinding prometheus
```

### 3. Network Policies

*Note: Network policies need to be created based on your security requirements.*

Example network policy to restrict access:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: grafana-network-policy
  namespace: ebanking-observability
spec:
  podSelector:
    matchLabels:
      app: grafana
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: nginx
    ports:
    - protocol: TCP
      port: 3000
```

## 📊 Monitoring the Stack

### View Logs

**Grafana logs:**
```bash
kubectl logs -f deployment/grafana -n ebanking-observability
```

**Prometheus logs:**
```bash
kubectl logs -f deployment/prometheus -n ebanking-observability
```

**PostgreSQL logs:**
```bash
kubectl logs -f statefulset/postgresql -n ebanking-observability
```

### Resource Usage

```bash
# CPU and Memory usage
kubectl top pods -n ebanking-observability

# Detailed pod info
kubectl describe pod <pod-name> -n ebanking-observability
```

### Events

```bash
# View recent events
kubectl get events -n ebanking-observability --sort-by='.lastTimestamp'
```

## 🛠️ Common Operations

### Scale Grafana

```bash
kubectl scale deployment/grafana --replicas=3 -n ebanking-observability
```

### Update Grafana Image

```bash
kubectl set image deployment/grafana grafana=grafana/grafana:10.3.0 -n ebanking-observability
```

### Restart a Service

```bash
kubectl rollout restart deployment/grafana -n ebanking-observability
```

### View Grafana Config

```bash
kubectl get configmap grafana-datasources -n ebanking-observability -o yaml
```

### Update Datasource Configuration

```bash
kubectl edit configmap grafana-datasources -n ebanking-observability
# Then restart Grafana
kubectl rollout restart deployment/grafana -n ebanking-observability
```

## 🐛 Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n ebanking-observability

# Check logs
kubectl logs <pod-name> -n ebanking-observability

# Check events
kubectl get events -n ebanking-observability | grep <pod-name>
```

### PVC Stuck in Pending

```bash
# Check PVC status
kubectl describe pvc <pvc-name> -n ebanking-observability

# Check available storage classes
kubectl get storageclass

# Check if volume is available
kubectl get pv
```

### Service Not Accessible

```bash
# Check service endpoints
kubectl get endpoints <service-name> -n ebanking-observability

# Check if pods are running
kubectl get pods -l app=<app-name> -n ebanking-observability

# Test connectivity from another pod
kubectl run test --rm -it --image=busybox -n ebanking-observability -- /bin/sh
# Then: wget -O- http://grafana:3000/api/health
```

### Grafana Can't Connect to Datasources

```bash
# Check if Prometheus is running
kubectl get pods -l app=prometheus -n ebanking-observability

# Check if PostgreSQL is running
kubectl get pods -l app=postgresql -n ebanking-observability

# Test connection from Grafana pod
kubectl exec -it deployment/grafana -n ebanking-observability -- /bin/sh
# Then: wget -O- http://prometheus:9090/-/healthy
```

## 🔄 Backup & Restore

### Backup Grafana Data

```bash
# Create backup
kubectl exec deployment/grafana -n ebanking-observability -- tar czf /tmp/grafana-backup.tar.gz /var/lib/grafana

# Copy backup to local
POD_NAME=$(kubectl get pod -l app=grafana -n ebanking-observability -o jsonpath='{.items[0].metadata.name}')
kubectl cp ebanking-observability/$POD_NAME:/tmp/grafana-backup.tar.gz ./grafana-backup-$(date +%Y%m%d).tar.gz
```

### Backup Prometheus Data

```bash
# Take snapshot
kubectl exec deployment/prometheus -n ebanking-observability -- \
  curl -XPOST http://localhost:9090/api/v1/admin/tsdb/snapshot
```

### Backup PostgreSQL

```bash
# Database dump
kubectl exec statefulset/postgresql -n ebanking-observability -- \
  pg_dump -U grafana_admin grafana_db > grafana_db_backup_$(date +%Y%m%d).sql
```

## 📈 Performance Tuning

### Grafana Performance

Edit Grafana deployment to increase resources:

```bash
kubectl edit deployment/grafana -n ebanking-observability
```

Update resources:
```yaml
resources:
  requests:
    cpu: 1000m
    memory: 2Gi
  limits:
    cpu: 2000m
    memory: 4Gi
```

### Prometheus Retention

Edit Prometheus deployment:

```bash
kubectl edit deployment/prometheus -n ebanking-observability
```

Update retention:
```yaml
args:
  - '--storage.tsdb.retention.time=90d'  # Increase to 90 days
```

## 🔒 Security Hardening

### 1. Update Secrets

```bash
# Generate new admin password
NEW_PASSWORD=$(openssl rand -base64 32)

# Update secret
kubectl create secret generic grafana-admin-credentials \
  --from-literal=admin-user=admin \
  --from-literal=admin-password=$NEW_PASSWORD \
  --from-literal=secret-key=$(openssl rand -base64 32) \
  --dry-run=client -o yaml | kubectl apply -f - -n ebanking-observability

# Restart Grafana
kubectl rollout restart deployment/grafana -n ebanking-observability
```

### 2. Enable Pod Security Policies

```bash
kubectl label namespace ebanking-observability \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```

## 📞 Support

For issues or questions:
- **Documentation:** This guide + README.md
- **Kubernetes Docs:** https://kubernetes.io/docs/
- **Grafana Docs:** https://grafana.com/docs/
- **Internal Support:** devops@oddo-bank.local

## ✅ Deployment Checklist

Before going to production:

- [ ] All pods are Running
- [ ] All PVCs are Bound
- [ ] Grafana UI accessible
- [ ] Prometheus scraping targets
- [ ] Datasources configured in Grafana
- [ ] Alerts configured
- [ ] Backup strategy in place
- [ ] Monitoring configured
- [ ] Security review completed
- [ ] Documentation updated
- [ ] Team trained on operations

---

**Deployment complete! Your e-banking observability stack is ready to use.**

For the complete course materials, see the parent directory workshops and training modules.

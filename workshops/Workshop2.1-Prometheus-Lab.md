# Workshop 2.1: Prometheus Deployment for API Gateway Monitoring

**Duration:** 120 minutes | **Level:** Intermediate

---

## Part 1: Deploy Sample Services (15 min)

### Step 1: Create API Services

Create `api-services.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: monitoring-ebanking
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: api-gateway
        image: quay.io/brancz/prometheus-example-app:v0.3.0
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  namespace: monitoring-ebanking
spec:
  ports:
  - port: 8080
  selector:
    app: api-gateway
```

Deploy:
```bash
kubectl apply -f api-services.yaml
kubectl get pods -l app=api-gateway
```

**📸 Screenshot: 2 API gateway pods running**

### Step 2: Verify Metrics Endpoint

```bash
kubectl port-forward deployment/api-gateway 8080:8080
curl http://localhost:8080/metrics
```

**📸 Screenshot: Prometheus metrics output**

**✅ Checkpoint:** Metrics endpoint accessible

---

## Part 2: Deploy Prometheus (30 min)

### Step 3: Create RBAC

Create `prometheus-rbac.yaml`:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: monitoring-ebanking
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring-ebanking
```

Apply:
```bash
kubectl apply -f prometheus-rbac.yaml
```

**📸 Screenshot: RBAC resources created**

### Step 4: Create Prometheus Config

Create `prometheus-config.yaml` with scrape configuration (see course materials).

Apply:
```bash
kubectl apply -f prometheus-config.yaml
```

**📸 Screenshot: ConfigMap created**

### Step 5: Deploy Prometheus

```bash
kubectl apply -f prometheus-deployment.yaml
kubectl get pods -l app=prometheus -w
```

**📸 Screenshot: Prometheus pod running**

### Step 6: Access Prometheus UI

```bash
kubectl port-forward svc/prometheus 9090:9090
```

Open: `http://localhost:9090`

**📸 Screenshot: Prometheus web UI home page**

**✅ Checkpoint:** Prometheus UI accessible

---

## Part 3: Verify Service Discovery (20 min)

### Step 7: Check Targets

In Prometheus UI:
1. Click "Status" → "Targets"

**📸 Screenshot: Targets page showing discovered pods**

### Step 8: Verify Metrics

In Prometheus query box, enter:
```promql
up{job="kubernetes-pods"}
```

Click "Execute"

**📸 Screenshot: Query results showing up=1 for API gateway pods**

**✅ Checkpoint:** API gateway pods discovered and metrics scraped

### Step 9: Test PromQL Query

Try:
```promql
rate(http_requests_total[5m])
```

**📸 Screenshot: Graph showing request rate over time**

---

## Part 4: Add Prometheus to Grafana (15 min)

### Step 10: Configure Data Source

In Grafana:
1. Configuration → Data sources → Add Prometheus
2. **URL:** `http://prometheus.monitoring-ebanking.svc.cluster.local:9090`
3. **Scrape interval:** `15s`

Click "Save & test"

**📸 Screenshot: Green "Data source is working" message**

**✅ Checkpoint:** Prometheus connected to Grafana

---

## Part 5: Create API Performance Dashboard (40 min)

### Step 11: Create Dashboard

Click + → Dashboard → Add visualization

### Step 12: Panel 1 - Request Rate

**Query (PromQL):**
```promql
sum(rate(http_requests_total[5m])) by (job)
```

**Settings:**
- Visualization: Time series
- Title: Request Rate by Service
- Unit: requests/sec
- Legend: Bottom

**📸 Screenshot: Request rate time series graph**

Click Apply

### Step 13: Panel 2 - Error Rate

Add new panel:
```promql
sum(rate(http_requests_total{status=~"5.."}[5m])) by (job) / 
sum(rate(http_requests_total[5m])) by (job) * 100
```

**Settings:**
- Visualization: Time series
- Title: Error Rate (%)
- Unit: Percent (0-100)

**📸 Screenshot: Error rate graph (should show 0 or low values)**

### Step 14: Panel 3 - Request Duration P95

```promql
histogram_quantile(0.95, 
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le, job)
) * 1000
```

**Settings:**
- Visualization: Time series
- Title: Request Duration P95
- Unit: milliseconds

**📸 Screenshot: Latency graph showing P95 line**

### Step 15: Panel 4 - Active Requests

```promql
sum(http_requests_active) by (job)
```

**Settings:**
- Visualization: Stat
- Title: Active Requests

**📸 Screenshot: Stat panel showing current active requests**

### Step 16: Save Dashboard

Save as "API Gateway Performance"

**📸 Screenshot: Complete dashboard with 4 panels**

**✅ Final Checkpoint:** Dashboard shows all metrics from Prometheus

---

## Workshop Complete! 🎉

You have successfully:
- ✅ Deployed sample services with Prometheus annotations
- ✅ Deployed Prometheus with RBAC
- ✅ Configured Kubernetes service discovery
- ✅ Connected Prometheus to Grafana
- ✅ Created API performance dashboard with PromQL queries

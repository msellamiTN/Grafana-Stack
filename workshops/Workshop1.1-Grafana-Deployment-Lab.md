# Workshop 1.1: Deploy Grafana Stack for Transaction Monitoring

**Duration:** 90 minutes | **Level:** Beginner

---

## Part 1: Setup Environment (15 min)

### Step 1: Verify Kubernetes Access

```bash
kubectl cluster-info
```

**📸 Screenshot: Cluster connection successful**

### Step 2: Create Namespace

```bash
kubectl create namespace monitoring-ebanking
kubectl config set-context --current --namespace=monitoring-ebanking
```

**✅ Checkpoint:** Verify namespace exists

---

## Part 2: Deploy Storage (10 min)

### Step 3: Create PVC

Create `grafana-pvc.yaml`:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-pvc
  namespace: monitoring-ebanking
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

Apply:
```bash
kubectl apply -f grafana-pvc.yaml
kubectl get pvc grafana-pvc
```

**📸 Screenshot: PVC status = Bound**

**✅ Checkpoint:** PVC must show STATUS = Bound

---

## Part 3: Deploy Grafana (20 min)

### Step 4: Create Secrets

```bash
kubectl create secret generic grafana-admin-credentials \
  --from-literal=admin-user='admin' \
  --from-literal=admin-password='OddoBH2024!Secure'
```

### Step 5: Deploy Grafana

Apply complete deployment from course materials:
```bash
kubectl apply -f grafana-deployment.yaml
```

Wait for pod:
```bash
kubectl get pods -l app=grafana -w
```

**📸 Screenshot: Pod STATUS = Running, READY = 1/1**

### Step 6: Access Grafana

```bash
kubectl port-forward svc/grafana 3000:80
```

Open browser: `http://localhost:3000`
- **Username:** admin
- **Password:** OddoBH2024!Secure

**📸 Screenshot: Grafana login page**

**📸 Screenshot: Grafana home dashboard after login**

**✅ Checkpoint:** Successfully logged into Grafana

---

## Part 4: Deploy PostgreSQL (15 min)

### Step 7: Deploy Database

```bash
kubectl apply -f postgres-transactions.yaml
kubectl wait --for=condition=ready pod -l app=postgres-transactions --timeout=120s
```

### Step 8: Verify Data

```bash
kubectl exec deployment/postgres-transactions -- \
  psql -U grafana_reader -d transactions_db -c \
  "SELECT COUNT(*) FROM transactions;"
```

**📸 Screenshot: Query shows 1000 transactions**

**✅ Checkpoint:** 1000 transactions in database

---

## Part 5: Configure Data Source (10 min)

### Step 9: Add PostgreSQL in Grafana

1. Click ⚙️ Configuration → Data sources
2. Click "Add data source"
3. Search and select "PostgreSQL"

**📸 Screenshot: Add data source page**

### Step 10: Configure Connection

**Settings:**
- Name: `TransactionDB`
- Host: `postgres-transactions.monitoring-ebanking.svc.cluster.local:5432`
- Database: `transactions_db`
- User: `grafana_reader`
- Password: `GrafanaRead123!`
- TLS/SSL Mode: `disable`

Click "Save & test"

**📸 Screenshot: Green "Database Connection OK" message**

**✅ Checkpoint:** Connection test successful

---

## Part 6: Create Dashboard (20 min)

### Step 11: Create Dashboard

Click + → Dashboard → Add visualization

**📸 Screenshot: New dashboard page**

### Step 12: Panel 1 - Total Transactions

**Query:**
```sql
SELECT COUNT(*) as "Total Transactions"
FROM transactions
WHERE created_at >= NOW() - INTERVAL '1 hour';
```

**Settings:**
- Visualization: Stat
- Title: Total Transactions (Last Hour)

Click "Apply"

**📸 Screenshot: Stat panel showing transaction count**

### Step 13: Panel 2 - Success Rate

Add new panel with query:
```sql
SELECT 
  ROUND((COUNT(*) FILTER (WHERE status = 'SUCCESS')::numeric / 
   NULLIF(COUNT(*), 0)) * 100, 2) as "Success Rate %"
FROM transactions
WHERE created_at >= NOW() - INTERVAL '1 hour';
```

**Settings:**
- Visualization: Gauge
- Unit: Percent (0-100)
- Thresholds: Red=0, Yellow=95, Green=98
- Title: Transaction Success Rate

**📸 Screenshot: Gauge showing success rate with green indicator**

### Step 14: Panel 3 - Processing Time

Query:
```sql
SELECT 
  DATE_TRUNC('minute', created_at) as time,
  AVG(processing_time_ms) as "Avg",
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY processing_time_ms) as "P95"
FROM transactions
WHERE created_at >= NOW() - INTERVAL '1 hour'
GROUP BY time ORDER BY time;
```

**Settings:**
- Visualization: Time series
- Unit: milliseconds
- Title: Processing Time

**📸 Screenshot: Time series graph with two lines**

### Step 15: Save Dashboard

1. Click Save dashboard (💾 icon)
2. Name: "E-Banking Transaction Monitoring"
3. Click Save

**📸 Screenshot: Complete dashboard with 3 panels**

**✅ Final Checkpoint:** Dashboard displays all panels with data

---

## Workshop Complete! 🎉

You have successfully:
- ✅ Deployed Grafana in Kubernetes
- ✅ Configured persistent storage
- ✅ Connected PostgreSQL data source
- ✅ Created transaction monitoring dashboard

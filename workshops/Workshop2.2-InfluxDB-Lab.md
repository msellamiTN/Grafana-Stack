# Workshop 2.2: InfluxDB Integration for Historical Transaction Analysis

**Duration:** 120 minutes | **Level:** Intermediate

---

## Part 1: Deploy InfluxDB 2.x (20 min)

### Step 1: Deploy InfluxDB

Apply InfluxDB deployment from course materials:
```bash
kubectl apply -f influxdb.yaml
kubectl get pods -l app=influxdb -w
```

**📸 Screenshot: InfluxDB pod running**

### Step 2: Access UI

```bash
kubectl port-forward svc/influxdb 8086:8086
```

Open: `http://localhost:8086`
Login: admin / influxdb2024!

**📸 Screenshot: InfluxDB 2.0 web UI**

**✅ Checkpoint:** InfluxDB accessible

---

## Part 2: Write Business Metrics (25 min)

### Step 3: Install Python Client

```bash
pip install influxdb-client
```

### Step 4: Run Data Script

Create and run `write_metrics.py` (see course materials)

```bash
python write_metrics.py
```

**📸 Screenshot: "Written 720 data points" message**

### Step 5: Verify Data

In InfluxDB UI → Data Explorer:
- Bucket: ebanking-metrics
- Measurement: daily_transactions

**📸 Screenshot: Data Explorer graph**

**✅ Checkpoint:** 30 days of data visible

---

## Part 3: Configure in Grafana (15 min)

### Step 6: Add Data Source

Configuration → Data sources → Add InfluxDB

**Settings:**
- Query Language: Flux
- URL: `http://influxdb.monitoring-ebanking.svc.cluster.local:8086`
- Organization: oddo-bank
- Token: oddo-influx-token-2024
- Default Bucket: ebanking-metrics

**📸 Screenshot: InfluxDB configuration**

Click "Save & test"

**📸 Screenshot: Green success message**

**✅ Checkpoint:** Connection successful

---

## Part 4: Create Dashboard (60 min)

### Step 7: Daily Transaction Trend

**Flux Query:**
```flux
from(bucket: "ebanking-metrics")
  |> range(start: -30d)
  |> filter(fn: (r) => r._measurement == "daily_transactions")
  |> filter(fn: (r) => r._field == "count")
  |> aggregateWindow(every: 1d, fn: sum)
```

**Settings:**
- Visualization: Time series
- Title: Daily Transaction Volume (30 Days)

**📸 Screenshot: 30-day trend graph**

### Step 8: Revenue Trend

**Query:**
```flux
from(bucket: "ebanking-metrics")
  |> range(start: -30d)
  |> filter(fn: (r) => r._field == "revenue")
  |> aggregateWindow(every: 1d, fn: sum)
```

**Settings:**
- Visualization: Time series
- Title: Daily Revenue Trend
- Unit: currency (EUR)

**📸 Screenshot: Revenue graph**

### Step 9: Weekly Summary

**Query:**
```flux
from(bucket: "ebanking-metrics")
  |> range(start: -14d)
  |> filter(fn: (r) => r._field == "count")
  |> aggregateWindow(every: 7d, fn: sum)
```

**Settings:**
- Visualization: Stat
- Title: Last 2 Weeks Volume

**📸 Screenshot: Stat with sparkline**

### Step 10: Save Dashboard

Save as "Business Metrics - Historical Analysis"

**📸 Screenshot: Complete dashboard**

**✅ Final Checkpoint:** All panels show historical data

---

## Workshop Complete! 🎉

You have successfully:
- ✅ Deployed InfluxDB 2.x
- ✅ Written time-series metrics
- ✅ Created Flux queries
- ✅ Built historical analysis dashboard

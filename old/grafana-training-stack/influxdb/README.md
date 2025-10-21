# InfluxDB - Time-Series Database

## Overview

InfluxDB 2.7 configured for time-series data storage with multiple buckets for different use cases in the training stack.

## Features

### **Multiple Buckets**
- **training** (30d retention) - Main bucket for training exercises
- **payments** (7d retention) - Payment API transaction data
- **metrics** (30d retention) - General application metrics
- **logs** (7d retention) - Log-based metrics

### **Auto-Initialization**
- Automatic bucket creation
- V1 authentication setup
- Multi-bucket access configuration
- Health check verification

### **Integration**
- Grafana datasource (auto-provisioned)
- Payment API (writes payment data)
- Custom applications (ready for integration)

## Bucket Details

### **1. training** (Default)
**Purpose**: Main bucket for training exercises  
**Retention**: 30 days (720 hours)  
**Use Cases**:
- Training exercises
- Sample data
- Practice queries
- Dashboard development

### **2. payments**
**Purpose**: Payment API transaction data  
**Retention**: 7 days (168 hours)  
**Use Cases**:
- Payment transaction tracking
- Revenue analysis
- Fraud detection metrics
- Business intelligence

**Data Written By**: Payment API service

### **3. metrics**
**Purpose**: General application metrics  
**Retention**: 30 days (720 hours)  
**Use Cases**:
- Custom application metrics
- Performance monitoring
- System health
- Business metrics

### **4. logs**
**Purpose**: Log-based metrics  
**Retention**: 7 days (168 hours)  
**Use Cases**:
- Log aggregation metrics
- Error rate tracking
- Event counting
- Log analysis

## Connection Details

### **From Grafana**
- **Datasource**: InfluxDB (auto-provisioned)
- **URL**: http://influxdb:8086
- **Organization**: data2ai
- **Default Bucket**: training
- **Token**: training-token-change-me

### **From Applications**
```javascript
const { InfluxDB, Point } = require('@influxdata/influxdb-client');

const influxDB = new InfluxDB({
  url: 'http://influxdb:8086',
  token: 'training-token-change-me'
});

const writeApi = influxDB.getWriteApi('data2ai', 'training');
```

### **From External Tools**
- **URL**: http://localhost:8086
- **Organization**: data2ai
- **Token**: training-token-change-me

## Flux Query Examples

### **1. Query Payment Data**
```flux
from(bucket: "payments")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "payment")
  |> filter(fn: (r) => r._field == "amount")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### **2. Calculate Success Rate**
```flux
from(bucket: "payments")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "payment")
  |> filter(fn: (r) => r._field == "amount")
  |> group(columns: ["status"])
  |> count()
```

### **3. Revenue by Currency**
```flux
from(bucket: "payments")
  |> range(start: -7d)
  |> filter(fn: (r) => r._measurement == "payment")
  |> filter(fn: (r) => r._field == "amount")
  |> filter(fn: (r) => r.status == "success")
  |> group(columns: ["currency"])
  |> sum()
```

### **4. Processing Time Percentiles**
```flux
from(bucket: "payments")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "payment")
  |> filter(fn: (r) => r._field == "processing_time")
  |> quantile(q: 0.95)
```

### **5. Training Bucket Query**
```flux
from(bucket: "training")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "example")
  |> yield(name: "results")
```

## Writing Data

### **Using Flux (CLI)**
```bash
# Write a single point
influx write \
  --bucket training \
  --org data2ai \
  --token training-token-change-me \
  --precision s \
  "measurement,tag1=value1 field1=1.0 $(date +%s)"
```

### **Using JavaScript**
```javascript
const point = new Point('measurement')
  .tag('tag1', 'value1')
  .floatField('field1', 1.0)
  .timestamp(new Date());

writeApi.writePoint(point);
await writeApi.flush();
```

### **Using Python**
```python
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS

client = InfluxDBClient(
    url="http://localhost:8086",
    token="training-token-change-me",
    org="data2ai"
)

write_api = client.write_api(write_options=SYNCHRONOUS)

point = Point("measurement") \
    .tag("tag1", "value1") \
    .field("field1", 1.0)

write_api.write(bucket="training", record=point)
```

## CLI Commands

### **List Buckets**
```bash
docker-compose exec influxdb influx bucket list \
  --org data2ai \
  --token training-token-change-me
```

### **Create New Bucket**
```bash
docker-compose exec influxdb influx bucket create \
  --name custom \
  --org data2ai \
  --retention 168h \
  --token training-token-change-me
```

### **Query Data**
```bash
docker-compose exec influxdb influx query \
  --org data2ai \
  --token training-token-change-me \
  'from(bucket: "training") |> range(start: -1h) |> limit(n: 10)'
```

### **Delete Bucket**
```bash
docker-compose exec influxdb influx bucket delete \
  --name custom \
  --org data2ai \
  --token training-token-change-me
```

## Training Use Cases

### **Module 2: Data Source Integration**

**Scenario**: Compare Prometheus vs InfluxDB

**Exercises**:
1. Query same metric from both sources
2. Compare query languages (PromQL vs Flux)
3. Analyze performance differences
4. Understand use case differences

**Example**:
```flux
// InfluxDB Flux
from(bucket: "payments")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "payment")
  |> mean()
```

```promql
// Prometheus PromQL
avg(payment_amount)
```

### **Module 3: Best Practices**

**Scenario**: Time-series data retention

**Exercises**:
1. Configure bucket retention policies
2. Understand data lifecycle
3. Optimize storage
4. Plan capacity

### **Module 5: Advanced Templating**

**Scenario**: Dynamic bucket selection

**Exercises**:
1. Create bucket variable
2. Dynamic queries based on bucket
3. Multi-bucket dashboards
4. Bucket-specific panels

## Monitoring

### **Check InfluxDB Health**
```bash
curl http://localhost:8086/health
```

### **View Metrics**
```bash
curl http://localhost:8086/metrics
```

### **Check Bucket Usage**
```bash
docker-compose exec influxdb influx bucket list \
  --org data2ai \
  --token training-token-change-me
```

## Troubleshooting

### **Container Won't Start**
```powershell
# Check logs
docker-compose logs influxdb

# Verify volume
docker volume inspect grafana-training-stack_influxdb_data
```

### **Can't Connect from Grafana**
```powershell
# Test connection
curl http://localhost:8086/health

# Verify token
docker-compose exec influxdb influx auth list \
  --org data2ai \
  --token training-token-change-me
```

### **Initialization Script Not Running**
```powershell
# Check if script is mounted
docker-compose exec influxdb ls -la /docker-entrypoint-initdb.d/

# Run manually
docker-compose exec influxdb sh /docker-entrypoint-initdb.d/init-influxdb.sh
```

### **Bucket Not Created**
```powershell
# List existing buckets
docker-compose exec influxdb influx bucket list \
  --org data2ai \
  --token training-token-change-me

# Create manually
docker-compose exec influxdb influx bucket create \
  --name payments \
  --org data2ai \
  --retention 168h \
  --token training-token-change-me
```

## Best Practices

### **Data Retention**
- ✅ Set appropriate retention periods
- ✅ Archive old data if needed
- ✅ Monitor disk usage
- ✅ Plan for growth

### **Query Optimization**
- ✅ Use time ranges
- ✅ Filter early in pipeline
- ✅ Limit result sets
- ✅ Use appropriate aggregations

### **Security**
- ✅ Change default token in production
- ✅ Use separate tokens per application
- ✅ Limit bucket access
- ✅ Enable TLS/SSL

### **Monitoring**
- ✅ Monitor disk usage
- ✅ Track query performance
- ✅ Set up alerts
- ✅ Regular backups

## Backup & Restore

### **Backup**
```bash
# Backup all data
docker-compose exec influxdb influx backup /tmp/backup \
  --org data2ai \
  --token training-token-change-me

# Copy to host
docker cp influxdb-training:/tmp/backup ./influxdb-backup
```

### **Restore**
```bash
# Copy backup to container
docker cp ./influxdb-backup influxdb-training:/tmp/backup

# Restore
docker-compose exec influxdb influx restore /tmp/backup \
  --org data2ai \
  --token training-token-change-me
```

## Architecture

```
┌─────────────────────────────────────┐
│         InfluxDB 2.7                │
│  ┌───────────────────────────────┐  │
│  │ Buckets:                      │  │
│  │  - training (30d)             │  │
│  │  - payments (7d)              │  │
│  │  - metrics (30d)              │  │
│  │  - logs (7d)                  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
         │                  │
         │ Flux Queries     │ Data Writes
         ▼                  ▼
┌──────────────┐   ┌──────────────┐
│   Grafana    │   │ Payment API  │
│  (Queries)   │   │  (Writes)    │
└──────────────┘   └──────────────┘
```

## Resources

### **Official Documentation**
- [InfluxDB 2.7 Docs](https://docs.influxdata.com/influxdb/v2.7/)
- [Flux Language](https://docs.influxdata.com/flux/v0.x/)
- [Client Libraries](https://docs.influxdata.com/influxdb/v2.7/api-guide/client-libraries/)

### **Training Materials**
- `training/module2/` - Data source integration
- `payment-api/README.md` - Payment API integration

## Version

- **InfluxDB**: 2.7
- **Organization**: data2ai
- **Buckets**: 4 (training, payments, metrics, logs)
- **Authentication**: Token-based + V1 compatibility

## License

Educational use - Data2AI Academy

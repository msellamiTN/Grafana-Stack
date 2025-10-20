# Complete Grafana Observability Stack Installation Workshop

## 📚 Workshop Overview

**Duration:** 2-3 hours  
**Level:** Intermediate  
**Prerequisites:** Docker, Docker Compose, Basic Linux/Windows CLI

This workshop will guide you through installing and configuring a complete observability stack using Docker Compose, including:
- Grafana (Visualization)
- Prometheus (Metrics)
- Loki (Logs)
- InfluxDB (Time Series)
- Alertmanager (Alerting)
- Payment API (Demo Application)
- And more!

---

## 🎯 Learning Objectives

By the end of this workshop, you will:
1. ✅ Understand the complete observability stack architecture
2. ✅ Install and configure all services using Docker Compose
3. ✅ Configure Prometheus for metrics collection
4. ✅ Set up Grafana dashboards
5. ✅ Configure Loki for log aggregation
6. ✅ Set up InfluxDB for time-series data
7. ✅ Configure alerting with Alertmanager
8. ✅ Monitor a demo payment API application

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Architecture Overview](#architecture-overview)
3. [Installation Steps](#installation-steps)
4. [Service Configuration](#service-configuration)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)
7. [Next Steps](#next-steps)

---

## 1. Prerequisites

### Required Software

**Docker Desktop**
- Windows: https://docs.docker.com/desktop/install/windows-install/
- Mac: https://docs.docker.com/desktop/install/mac-install/
- Linux: https://docs.docker.com/desktop/install/linux-install/

**Minimum System Requirements:**
- CPU: 4 cores
- RAM: 8 GB (16 GB recommended)
- Disk: 20 GB free space
- OS: Windows 10/11, macOS 10.15+, or Linux

### Verify Installation

```bash
# Check Docker version
docker --version
# Expected: Docker version 20.10.x or higher

# Check Docker Compose version
docker-compose --version
# Expected: Docker Compose version 2.x or higher

# Verify Docker is running
docker ps
# Should return empty list or running containers
```

---

## 2. Architecture Overview

### 🏗️ Stack Components

```
┌─────────────────────────────────────────────────────────────┐
│                     Grafana (Port 3000)                      │
│                    Visualization Layer                       │
└──────────────┬──────────────┬──────────────┬────────────────┘
               │              │              │
       ┌───────▼──────┐ ┌────▼─────┐ ┌──────▼──────┐
       │  Prometheus  │ │   Loki   │ │  InfluxDB   │
       │  (Port 9090) │ │(Port 3100│ │ (Port 8086) │
       │   Metrics    │ │   Logs   │ │ Time Series │
       └──────┬───────┘ └────┬─────┘ └──────┬──────┘
              │              │               │
    ┌─────────┴──────────────┴───────────────┴─────────┐
    │                                                    │
┌───▼────┐ ┌──────────┐ ┌──────────┐ ┌────────────┐   │
│Payment │ │  Node    │ │ eBanking │ │ Promtail   │   │
│  API   │ │ Exporter │ │ Exporter │ │(Log Agent) │   │
└────────┘ └──────────┘ └──────────┘ └────────────┘   │
                                                        │
┌───────────────────────────────────────────────────────┘
│  Supporting Services:
│  - Alertmanager (Port 9093) - Alert Management
│  - PostgreSQL (Port 5432) - Database
│  - MySQL (Port 3306) - Database
│  - MinIO (Port 9000/9001) - Object Storage
│  - Grafana MCP (Port 8081) - MCP Server
└────────────────────────────────────────────────────────
```

### Service Ports

| Service | Port | Purpose |
|---------|------|---------|
| Grafana | 3000 | Web UI |
| Prometheus | 9090 | Metrics & Web UI |
| Loki | 3100 | Log aggregation |
| InfluxDB | 8086 | Time series database |
| Alertmanager | 9093 | Alert management |
| Payment API | 8080 | Demo application |
| eBanking Exporter | 9201 | Custom metrics |
| MinIO | 9000, 9001 | Object storage |
| MySQL | 3306 | Database |
| PostgreSQL | 5432 | Database |
| Grafana MCP | 8081 | MCP Server |

---

## 3. Installation Steps

### Step 1: Navigate to Project Directory

```bash
cd "d:\Data2AI Academy\Grafana\observability-stack"
```

### Step 2: Review Environment Variables

Open and review the `.env` file:

```bash
# View the .env file
cat .env

# Or edit it
notepad .env  # Windows
nano .env     # Linux/Mac
```

**Important Variables to Review:**

```env
# InfluxDB Configuration
INFLUXDB_USER=admin
INFLUXDB_PASSWORD=InfluxSecure123!Change@Me  # ⚠️ CHANGE THIS
INFLUXDB_ORG=bhf-oddo
INFLUXDB_BUCKET=payments
INFLUXDB_TOKEN=my-super-secret-auth-token    # ⚠️ CHANGE THIS

# Grafana Configuration
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=GrafanaSecure123!Change@Me  # ⚠️ CHANGE THIS

# MySQL Configuration
MYSQL_ROOT_PASSWORD=MySQLRoot123!Change@Me   # ⚠️ CHANGE THIS

# MinIO Configuration
MINIO_ROOT_PASSWORD=MinioSecure123!Change@Me # ⚠️ CHANGE THIS
```

**🔒 Security Note:** Change all default passwords before deploying to production!

### Step 3: Create Required Directories

```bash
# Create directories for persistent data
mkdir -p prometheus/rules
mkdir -p grafana/provisioning/dashboards
mkdir -p grafana/provisioning/datasources
mkdir -p influxdb/{config,data,logs,backup,keys}
mkdir -p mysql/initdb.d
mkdir -p alertmanager
```

### Step 4: Verify Docker Compose File

```bash
# Validate the docker-compose.yml syntax
docker-compose config

# This should output the parsed configuration without errors
```

### Step 5: Pull Docker Images

```bash
# Pull all required images (this may take 10-15 minutes)
docker-compose pull

# Expected output: Pulling images for all services
```

### Step 6: Start the Stack

```bash
# Start all services in detached mode
docker-compose up -d

# Expected output:
# Creating network "observability-stack_observability" ... done
# Creating volume "observability-stack_prometheus_data" ... done
# Creating volume "observability-stack_grafana_data" ... done
# ... (more volumes)
# Creating prometheus ... done
# Creating loki ... done
# Creating influxdb ... done
# ... (more services)
```

### Step 7: Verify Services are Running

```bash
# Check all containers are running
docker-compose ps

# Expected output: All services should show "Up" status
```

**Expected Output:**
```
NAME                          STATUS              PORTS
alertmanager                  Up                  0.0.0.0:9093->9093/tcp
ebanking_metrics_exporter     Up                  0.0.0.0:9201->9200/tcp
grafana                       Up                  0.0.0.0:3000->3000/tcp
influxdb                      Up                  0.0.0.0:8086->8086/tcp
loki                          Up                  0.0.0.0:3100->3100/tcp
minio                         Up                  0.0.0.0:9000-9001->9000-9001/tcp
mysql                         Up                  0.0.0.0:3306->3306/tcp
node_exporter                 Up                  
payment-api                   Up (healthy)        0.0.0.0:8080->8080/tcp
postgres                      Up                  5432/tcp
prometheus                    Up                  0.0.0.0:9090->9090/tcp
promtail                      Up                  
```

### Step 8: Check Logs

```bash
# View logs for all services
docker-compose logs

# View logs for a specific service
docker-compose logs grafana
docker-compose logs prometheus
docker-compose logs payment-api

# Follow logs in real-time
docker-compose logs -f
```

---

## 4. Service Configuration

### 4.1 Grafana Configuration

**Access Grafana:**
- URL: http://localhost:3000
- Username: `admin`
- Password: `GrafanaSecure123!Change@Me` (from .env file)

**First Login Steps:**

1. Open browser and navigate to http://localhost:3000
2. Login with admin credentials
3. You'll be prompted to change password (recommended)
4. Explore the pre-configured dashboards in the "eBanking" folder

**Pre-configured Data Sources:**

Grafana should have these data sources automatically configured:
- Prometheus (http://prometheus:9090)
- Loki (http://loki:3100)
- InfluxDB (http://influxdb:8086)

**Verify Data Sources:**

1. Go to: Configuration → Data Sources
2. Check that all data sources show "Working" status
3. Click "Test" on each data source

### 4.2 Prometheus Configuration

**Access Prometheus:**
- URL: http://localhost:9090
- No authentication required

**Verify Targets:**

1. Navigate to: Status → Targets
2. Verify all targets are "UP":
   - prometheus (localhost:9090)
   - grafana (grafana:3000)
   - ebanking-exporter (ebanking_metrics_exporter:9200)
   - node-exporter (node-exporter:9100)
   - loki (loki:3100)
   - postgres (postgres:5432)
   - minio (minio:9000)
   - payment-api (payment-api:8080)

**Test a Query:**

1. Go to Graph tab
2. Enter query: `up`
3. Click "Execute"
4. Should see all services with value 1 (up)

**Sample Queries to Test:**

```promql
# Check all services are up
up

# CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Payment API request rate
rate(http_requests_total{job="payment-api"}[5m])
```

### 4.3 Loki Configuration

**Access Loki:**
- URL: http://localhost:3100
- API endpoint: http://localhost:3100/loki/api/v1/query

**Test Loki:**

```bash
# Query recent logs via API
curl -G -s "http://localhost:3100/loki/api/v1/query" --data-urlencode 'query={job="varlogs"}' | jq
```

**In Grafana:**

1. Go to Explore
2. Select "Loki" data source
3. Enter query: `{job="varlogs"}`
4. Click "Run query"
5. Should see log entries

### 4.4 InfluxDB Configuration

**Access InfluxDB:**
- URL: http://localhost:8086
- Username: `admin` (from .env)
- Password: `InfluxSecure123!Change@Me` (from .env)

**First Login Steps:**

1. Open http://localhost:8086
2. Login with credentials
3. Navigate to Data → Buckets
4. Verify "payments" bucket exists
5. Navigate to Data → Tokens
6. Verify your token is listed

**Test InfluxDB:**

```bash
# Query data via API
curl -X POST "http://localhost:8086/api/v2/query?org=bhf-oddo" \
  -H "Authorization: Token my-super-secret-auth-token" \
  -H "Content-Type: application/vnd.flux" \
  -d 'from(bucket: "payments") |> range(start: -1h) |> limit(n: 10)'
```

### 4.5 Payment API Configuration

**Access Payment API:**
- URL: http://localhost:8080
- Health Check: http://localhost:8080/health
- Metrics: http://localhost:8080/metrics

**Test Payment API:**

```bash
# Health check
curl http://localhost:8080/health

# Expected response:
# {"status":"healthy","timestamp":"2025-10-21T00:00:00.000Z"}

# Get metrics
curl http://localhost:8080/metrics

# Should return Prometheus-formatted metrics
```

**API Endpoints:**

- `GET /health` - Health check
- `GET /metrics` - Prometheus metrics
- `GET /api/payments` - List payments
- `POST /api/payments` - Create payment
- `GET /api/stats` - Payment statistics

### 4.6 Alertmanager Configuration

**Access Alertmanager:**
- URL: http://localhost:9093
- No authentication required

**Verify Configuration:**

1. Open http://localhost:9093
2. Check Status page
3. Verify configuration is loaded
4. No alerts should be firing initially

---

## 5. Verification

### 5.1 Service Health Checks

Run these commands to verify each service:

```bash
# Check all containers are healthy
docker-compose ps

# Check Grafana
curl -s http://localhost:3000/api/health | jq

# Check Prometheus
curl -s http://localhost:9090/-/healthy

# Check Loki
curl -s http://localhost:3100/ready

# Check InfluxDB
curl -s http://localhost:8086/health

# Check Payment API
curl -s http://localhost:8080/health | jq

# Check Alertmanager
curl -s http://localhost:9093/-/healthy
```

### 5.2 Data Flow Verification

**Test Metrics Flow:**

1. Open Grafana: http://localhost:3000
2. Go to Explore
3. Select "Prometheus" data source
4. Query: `up`
5. Verify all services show value 1

**Test Logs Flow:**

1. In Grafana Explore
2. Select "Loki" data source
3. Query: `{job="varlogs"}`
4. Verify logs are appearing

**Test Payment Data Flow:**

1. Generate some payment data:
```bash
curl -X POST http://localhost:8080/api/payments \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "currency": "USD", "method": "credit_card"}'
```

2. Check in InfluxDB:
   - Open http://localhost:8086
   - Go to Data Explorer
   - Select bucket: "payments"
   - Run query to see data

3. Check in Grafana:
   - Open Payments Dashboard
   - Verify new payment appears

### 5.3 Dashboard Verification

**Pre-configured Dashboards:**

1. Login to Grafana
2. Go to Dashboards → Browse
3. Open "eBanking" folder
4. Verify these dashboards exist:
   - eBanking Dashboard
   - Payments Dashboard
   - Production Dashboard (Fixed)
   - Production Dashboard (Full)

5. Open each dashboard and verify:
   - Panels are loading data
   - No errors displayed
   - Graphs show metrics

---

## 6. Troubleshooting

### Common Issues and Solutions

#### Issue 1: Services Not Starting

**Symptoms:**
- Containers exit immediately
- `docker-compose ps` shows "Exit 1" status

**Solutions:**

```bash
# Check logs for specific service
docker-compose logs [service-name]

# Common fixes:
# 1. Check port conflicts
netstat -ano | findstr :3000  # Windows
lsof -i :3000                 # Linux/Mac

# 2. Verify .env file exists
ls -la .env

# 3. Check Docker resources
docker system df
docker system prune  # Clean up if needed
```

#### Issue 2: Grafana Can't Connect to Data Sources

**Symptoms:**
- Data sources show "Error" status
- Dashboards show "No data"

**Solutions:**

```bash
# 1. Verify services are on same network
docker network inspect observability-stack_observability

# 2. Test connectivity from Grafana container
docker exec grafana ping prometheus
docker exec grafana ping loki
docker exec grafana ping influxdb

# 3. Check service URLs in Grafana
# Should use container names, not localhost:
# - http://prometheus:9090
# - http://loki:3100
# - http://influxdb:8086
```

#### Issue 3: Prometheus Targets Down

**Symptoms:**
- Targets show "DOWN" in Prometheus UI
- Metrics not collecting

**Solutions:**

```bash
# 1. Check Prometheus configuration
docker exec prometheus cat /etc/prometheus/prometheus.yml

# 2. Verify target services are running
docker-compose ps

# 3. Check network connectivity
docker exec prometheus wget -O- http://payment-api:8080/metrics

# 4. Restart Prometheus
docker-compose restart prometheus
```

#### Issue 4: InfluxDB Not Initialized

**Symptoms:**
- Can't login to InfluxDB
- Bucket doesn't exist

**Solutions:**

```bash
# 1. Check InfluxDB logs
docker-compose logs influxdb

# 2. Verify environment variables
docker exec influxdb env | grep INFLUX

# 3. Manually initialize if needed
docker exec -it influxdb influx setup \
  --username admin \
  --password InfluxSecure123!Change@Me \
  --org bhf-oddo \
  --bucket payments \
  --force
```

#### Issue 5: eBanking Exporter Failing

**Symptoms:**
- `exec ./ebanking-exporter: no such file or directory`
- Container keeps restarting

**Solutions:**

```bash
# 1. Rebuild the eBanking exporter
docker-compose build ebanking_metrics_exporter

# 2. If build fails, check .NET SDK is available
docker run --rm mcr.microsoft.com/dotnet/sdk:8.0 dotnet --version

# 3. Restart the service
docker-compose up -d ebanking_metrics_exporter

# 4. Check logs
docker-compose logs ebanking_metrics_exporter

# 5. If still failing, temporarily disable it
# Comment out the ebanking_metrics_exporter service in docker-compose.yml
```

#### Issue 6: Payment API Not Generating Data

**Symptoms:**
- No payment metrics in InfluxDB
- Empty dashboards

**Solutions:**

```bash
# 1. Check Payment API logs
docker-compose logs payment-api

# 2. Verify InfluxDB connection
docker exec payment-api env | grep INFLUX

# 3. Test API manually
curl -X POST http://localhost:8080/api/payments \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "currency": "USD"}'

# 4. Restart payment-api
docker-compose restart payment-api
```

#### Issue 6: High Resource Usage

**Symptoms:**
- Docker using too much CPU/Memory
- System slow

**Solutions:**

```bash
# 1. Check resource usage
docker stats

# 2. Limit resources in docker-compose.yml
# Add to each service:
# deploy:
#   resources:
#     limits:
#       cpus: '0.5'
#       memory: 512M

# 3. Stop unnecessary services
docker-compose stop mysql  # If not needed
docker-compose stop minio  # If not needed

# 4. Adjust Prometheus retention
# In prometheus command, change:
# --storage.tsdb.retention.time=7d  # Instead of 30d
```

### Getting Help

**View All Logs:**
```bash
docker-compose logs --tail=100
```

**Check Service Status:**
```bash
docker-compose ps
docker-compose top
```

**Restart Specific Service:**
```bash
docker-compose restart [service-name]
```

**Restart All Services:**
```bash
docker-compose restart
```

**Complete Reset:**
```bash
# Stop and remove everything
docker-compose down -v

# Start fresh
docker-compose up -d
```

---

## 7. Next Steps

### 7.1 Explore Dashboards

1. **eBanking Dashboard**
   - View eBanking metrics
   - Monitor transaction rates
   - Check system health

2. **Payments Dashboard**
   - Monitor payment API
   - View payment statistics
   - Track success rates

3. **Production Dashboard**
   - System metrics
   - Resource utilization
   - Service availability

### 7.2 Create Custom Dashboards

**Exercise: Create a System Monitoring Dashboard**

1. In Grafana, click "+" → "Dashboard"
2. Add Panel → Add Query
3. Select Prometheus data source
4. Add these panels:

**Panel 1: CPU Usage**
```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Panel 2: Memory Usage**
```promql
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100
```

**Panel 3: Disk Usage**
```promql
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100
```

**Panel 4: Network Traffic**
```promql
rate(node_network_receive_bytes_total[5m])
```

5. Save dashboard as "System Monitoring"

### 7.3 Configure Alerts

**Exercise: Create High CPU Alert**

1. In Grafana, go to Alerting → Alert rules
2. Click "New alert rule"
3. Configure:
   - Name: "High CPU Usage"
   - Query: CPU usage query from above
   - Condition: `WHEN last() OF query(A) IS ABOVE 80`
   - Evaluation: Every 1m for 5m
4. Save alert rule

### 7.4 Query Logs

**Exercise: Search Application Logs**

1. Go to Grafana Explore
2. Select Loki data source
3. Try these queries:

```logql
# All logs
{job="varlogs"}

# Error logs only
{job="varlogs"} |= "error"

# Payment API logs
{container="payment-api"}

# Logs in last hour
{job="varlogs"} [1h]

# Count errors
sum(count_over_time({job="varlogs"} |= "error" [1h]))
```

### 7.5 Work with InfluxDB

**Exercise: Query Payment Data**

1. Open InfluxDB UI: http://localhost:8086
2. Go to Data Explorer
3. Try these Flux queries:

```flux
// All payments in last hour
from(bucket: "payments")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "payment")

// Payment count by status
from(bucket: "payments")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "payment")
  |> group(columns: ["status"])
  |> count()

// Average payment amount
from(bucket: "payments")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_field"] == "amount")
  |> mean()
```

### 7.6 Advanced Topics

**Topics to Explore:**

1. **Service Discovery**
   - Configure Prometheus service discovery
   - Auto-discover new services

2. **Alert Routing**
   - Configure Alertmanager routes
   - Set up email/Slack notifications

3. **Data Retention**
   - Configure Prometheus retention policies
   - Set up InfluxDB downsampling

4. **High Availability**
   - Set up Prometheus HA
   - Configure Grafana HA

5. **Security**
   - Enable HTTPS
   - Configure authentication
   - Set up RBAC

---

## 8. Cleanup

### Stop Services

```bash
# Stop all services
docker-compose stop

# Stop specific service
docker-compose stop grafana
```

### Remove Services

```bash
# Stop and remove containers
docker-compose down

# Remove containers and volumes (⚠️ deletes all data)
docker-compose down -v

# Remove containers, volumes, and images
docker-compose down -v --rmi all
```

### Backup Data

```bash
# Backup volumes before cleanup
docker run --rm -v observability-stack_grafana_data:/data -v $(pwd):/backup alpine tar czf /backup/grafana-backup.tar.gz /data

docker run --rm -v observability-stack_prometheus_data:/data -v $(pwd):/backup alpine tar czf /backup/prometheus-backup.tar.gz /data

docker run --rm -v observability-stack_influxdb_data:/data -v $(pwd):/backup alpine tar czf /backup/influxdb-backup.tar.gz /data
```

---

## 9. Summary

### What You've Learned

✅ Installed complete observability stack with Docker Compose  
✅ Configured Grafana for visualization  
✅ Set up Prometheus for metrics collection  
✅ Configured Loki for log aggregation  
✅ Set up InfluxDB for time-series data  
✅ Configured Alertmanager for alerting  
✅ Deployed and monitored a demo application  
✅ Created dashboards and alerts  
✅ Queried metrics and logs  

### Key Takeaways

1. **Docker Compose** simplifies multi-container deployments
2. **Observability** requires metrics, logs, and traces
3. **Grafana** provides unified visualization
4. **Prometheus** is industry standard for metrics
5. **Loki** enables efficient log aggregation
6. **InfluxDB** excels at time-series data

### Resources

- **Grafana Docs:** https://grafana.com/docs/
- **Prometheus Docs:** https://prometheus.io/docs/
- **Loki Docs:** https://grafana.com/docs/loki/
- **InfluxDB Docs:** https://docs.influxdata.com/
- **Docker Compose Docs:** https://docs.docker.com/compose/

---

## 10. Appendix

### A. Complete Service List

| Service | Container | Image | Port | Purpose |
|---------|-----------|-------|------|---------|
| Grafana | grafana | grafana/grafana-oss:latest | 3000 | Visualization |
| Prometheus | prometheus | prom/prometheus:latest | 9090 | Metrics |
| Loki | loki | grafana/loki:latest | 3100 | Logs |
| Promtail | promtail | grafana/promtail:latest | - | Log collector |
| InfluxDB | influxdb | influxdb:2.7 | 8086 | Time series DB |
| Alertmanager | alertmanager | prom/alertmanager:latest | 9093 | Alerts |
| Node Exporter | node_exporter | prom/node-exporter:latest | - | System metrics |
| Payment API | payment-api | Custom build | 8080 | Demo app |
| eBanking Exporter | ebanking_metrics_exporter | Custom build | 9201 | Custom metrics |
| PostgreSQL | postgres | postgres:13-alpine | 5432 | Database |
| MySQL | mysql | mysql:8.0 | 3306 | Database |
| MinIO | minio | minio/minio:latest | 9000, 9001 | Object storage |
| Grafana MCP | grafana-mcp | mcp/grafana:latest | 8081 | MCP server |

### B. Environment Variables Reference

```env
# InfluxDB
INFLUXDB_USER=admin
INFLUXDB_PASSWORD=<password>
INFLUXDB_ORG=bhf-oddo
INFLUXDB_BUCKET=payments
INFLUXDB_TOKEN=<token>
INFLUXDB_RETENTION=1w

# Grafana
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=<password>
GF_SECURITY_SECRET_KEY=<secret>

# MySQL
MYSQL_ROOT_PASSWORD=<password>
MYSQL_DATABASE=observability
MYSQL_USER=appuser
MYSQL_PASSWORD=<password>

# MinIO
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=<password>

# Payment API
PAYMENT_API_PORT=8080
SIMULATION_RATE=10

# Grafana MCP
GRAFANA_SERVICE_ACCOUNT_TOKEN=<token>
```

### C. Useful Commands

```bash
# View all logs
docker-compose logs

# Follow logs
docker-compose logs -f

# View specific service logs
docker-compose logs grafana

# Check service status
docker-compose ps

# Restart service
docker-compose restart grafana

# Execute command in container
docker exec -it grafana bash

# View resource usage
docker stats

# Clean up
docker-compose down -v
```

---

**Workshop Complete! 🎉**

You now have a fully functional observability stack running with Docker Compose!

**Questions or Issues?**
- Check the Troubleshooting section
- Review service logs
- Consult official documentation

**Next Workshop:** Advanced Grafana Dashboards and Alerting

---

**Last Updated:** October 21, 2025  
**Version:** 1.0  
**Author:** Data2AI Academy

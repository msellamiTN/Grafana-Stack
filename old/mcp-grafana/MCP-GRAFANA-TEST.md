# Grafana MCP Test Guide

## 🎯 Overview

This guide helps you test and verify your Grafana MCP server configuration for the remote Grafana instance at `http://51.79.24.138:3000`.

## ✅ Pre-Test Checklist

Before testing, ensure:

- [ ] Docker Desktop is installed and running
- [ ] `mcp/grafana` Docker image is pulled
- [ ] Grafana service account token is obtained
- [ ] Token is configured in `settings.json` (line 22)
- [ ] Windsurf has been restarted

## 🧪 Test 1: Check MCP Server Configuration

**File:** `C:\Users\mokht\AppData\Roaming\Windsurf\User\settings.json`

**Expected Configuration:**
```json
{
  "mcp.servers": {
    "grafana-mcp": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-e", "GRAFANA_URL=http://51.79.24.138:3000",
        "-e", "GRAFANA_SERVICE_ACCOUNT_TOKEN",
        "mcp/grafana",
        "-t", "stdio"
      ],
      "env": {
        "GRAFANA_SERVICE_ACCOUNT_TOKEN": "glsa_xxxxx..."
      }
    }
  }
}
```

**✓ Pass:** Token is set and not "YOUR_SERVICE_ACCOUNT_TOKEN_HERE"  
**✗ Fail:** Token still shows placeholder value

---

## 🧪 Test 2: Verify Remote Grafana Access

**Test Connection:**
```powershell
Test-NetConnection -ComputerName 51.79.24.138 -Port 3000
```

**Expected Result:**
```
TcpTestSucceeded : True
```

**Alternative Test (Browser):**
- Open: http://51.79.24.138:3000
- Should see Grafana login page

**✓ Pass:** Connection successful  
**✗ Fail:** Connection refused or timeout

---

## 🧪 Test 3: Available Metrics Sources

Your remote Grafana instance has access to these data sources:

### 📊 Prometheus Metrics (Port 9090)
**Available Jobs:**
- `prometheus` - Prometheus self-monitoring
- `grafana` - Grafana metrics
- `ebanking-exporter` - eBanking custom metrics
- `node-exporter` - System metrics (CPU, memory, disk)
- `loki` - Loki log aggregation metrics
- `postgres` - PostgreSQL database metrics
- `minio` - MinIO object storage metrics
- `payment-api` - Payment API metrics

### 📝 Loki Logs (Port 3100)
- Application logs
- System logs
- Container logs

### 💾 InfluxDB Time Series (Port 8086)
- **Bucket:** `payments`
- **Organization:** `bhf-oddo`
- Payment transaction data
- Real-time payment metrics

---

## 🧪 Test 4: MCP Server Activation

Once Windsurf is restarted with proper configuration, test these commands:

### Basic Connectivity Tests

**Test 1: List Dashboards**
```
Ask Cascade: "List all Grafana dashboards"
```
**Expected:** List of available dashboards

**Test 2: Search Resources**
```
Ask Cascade: "Search for payment dashboards in Grafana"
```
**Expected:** Search results from Grafana

**Test 3: List Data Sources**
```
Ask Cascade: "Show me all Grafana data sources"
```
**Expected:** List including Prometheus, Loki, InfluxDB

---

## 🧪 Test 5: Query Prometheus Metrics

### System Metrics

**CPU Usage:**
```
Ask Cascade: "Query Prometheus for CPU usage across all nodes"
```
**Equivalent PromQL:**
```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Memory Usage:**
```
Ask Cascade: "Show memory usage from Prometheus"
```
**Equivalent PromQL:**
```promql
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100
```

### Payment API Metrics

**Request Rate:**
```
Ask Cascade: "Query payment API request rate"
```
**Equivalent PromQL:**
```promql
rate(http_requests_total{job="payment-api"}[5m])
```

**Response Time:**
```
Ask Cascade: "Show payment API response time"
```
**Equivalent PromQL:**
```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{job="payment-api"}[5m]))
```

### eBanking Metrics

**Transaction Count:**
```
Ask Cascade: "Query eBanking transaction count"
```
**Equivalent PromQL:**
```promql
rate(ebanking_transactions_total[5m])
```

---

## 🧪 Test 6: Query Loki Logs

**Recent Logs:**
```
Ask Cascade: "Show me recent logs from Loki"
```
**Equivalent LogQL:**
```logql
{job="varlogs"} |= "" | limit 100
```

**Error Logs:**
```
Ask Cascade: "Find error logs in the last hour"
```
**Equivalent LogQL:**
```logql
{job="varlogs"} |= "error" | __error__="" [1h]
```

**Payment API Logs:**
```
Ask Cascade: "Show payment API logs"
```
**Equivalent LogQL:**
```logql
{container="payment-api"} | limit 100
```

---

## 🧪 Test 7: Dashboard Operations

**Create Dashboard:**
```
Ask Cascade: "Create a new dashboard called 'Payment Monitoring'"
```

**Add Panel:**
```
Ask Cascade: "Add a panel showing payment API request rate to the dashboard"
```

**List Dashboards:**
```
Ask Cascade: "Show all dashboards with 'payment' in the name"
```

---

## 🧪 Test 8: Alert Configuration

**List Alerts:**
```
Ask Cascade: "Show me all alert rules in Grafana"
```

**Create Alert:**
```
Ask Cascade: "Create an alert for high CPU usage above 80%"
```

---

## 📊 Sample Queries to Test

Once MCP is active, try these natural language queries:

### Monitoring Queries
1. "What's the current CPU usage?"
2. "Show me memory usage trends"
3. "How many requests per second is the payment API handling?"
4. "What's the error rate for the payment API?"

### Log Queries
5. "Show me the last 50 log entries"
6. "Find all errors in the last hour"
7. "Show payment API logs from today"

### Dashboard Queries
8. "List all dashboards"
9. "Create a dashboard for system monitoring"
10. "Show me the payment dashboard"

### Data Source Queries
11. "What data sources are configured?"
12. "Test the Prometheus connection"
13. "Query InfluxDB for payment data"

---

## 🐛 Troubleshooting Test Failures

### MCP Server Not Found
**Symptom:** "server name grafana-mcp not found"

**Solutions:**
1. Verify token is set in settings.json
2. Restart Windsurf completely (close all windows)
3. Check Docker is running: `docker ps`
4. Pull image: `docker pull mcp/grafana`

### Authentication Failed
**Symptom:** "401 Unauthorized" or "403 Forbidden"

**Solutions:**
1. Regenerate service account token in Grafana
2. Verify token has correct permissions (Editor role minimum)
3. Update token in settings.json
4. Restart Windsurf

### Connection Refused
**Symptom:** "Connection refused" or "Cannot connect"

**Solutions:**
1. Test Grafana access: `Test-NetConnection 51.79.24.138 -Port 3000`
2. Verify Grafana is running on remote server
3. Check firewall rules
4. Confirm URL in settings: `http://51.79.24.138:3000`

### Docker Issues
**Symptom:** "Cannot connect to Docker daemon"

**Solutions:**
1. Start Docker Desktop
2. Verify Docker is running: `docker version`
3. Check Docker service status

---

## ✅ Success Criteria

Your Grafana MCP setup is working correctly if:

- [x] MCP server appears in Windsurf's MCP list
- [x] Can list Grafana dashboards
- [x] Can query Prometheus metrics
- [x] Can search Loki logs
- [x] Can create/modify dashboards
- [x] Can list data sources
- [x] No authentication errors

---

## 📝 Quick Test Commands

Copy and paste these into Cascade to test:

```
1. List all Grafana dashboards
2. Show me all data sources
3. Query Prometheus for CPU usage
4. Show recent Loki logs
5. Create a test dashboard
```

---

## 🎉 Next Steps After Successful Test

Once all tests pass:

1. **Explore Available Metrics**
   - Browse Prometheus metrics
   - Check InfluxDB payment data
   - Review Loki logs

2. **Create Dashboards**
   - Payment monitoring dashboard
   - System health dashboard
   - Application performance dashboard

3. **Set Up Alerts**
   - High CPU/memory alerts
   - Payment API error alerts
   - System availability alerts

4. **Integrate with Workflows**
   - Use natural language to query metrics
   - Generate reports
   - Troubleshoot issues

---

**Remote Grafana:** http://51.79.24.138:3000  
**Prometheus:** http://51.79.24.138:9090  
**Loki:** http://51.79.24.138:3100  
**InfluxDB:** http://51.79.24.138:8086  

**Last Updated:** October 20, 2025

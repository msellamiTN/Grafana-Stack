# Workshop 5.2: Payment Gateway Performance Dashboard with Advanced Templating

**Duration:** 120 minutes | **Level:** Advanced

---

## Part 1: Create Advanced Variables (25 min)

### Step 1: Create Dashboard

Create new dashboard: "Payment Gateway Performance"

### Step 2: Gateway Selection Variable

Dashboard settings → Variables → Add

**Query Variable:**
- **Name:** `gateway`
- **Type:** Query
- **Data source:** TransactionDB
- **Query:**
```sql
SELECT DISTINCT 
  COALESCE(payment_gateway, 'default-gateway') as gateway
FROM transactions
WHERE created_at >= NOW() - INTERVAL '30 days'
ORDER BY gateway;
```
- **Multi-value:** Yes
- **Include All:** Yes
- **Refresh:** On dashboard load

**📸 Screenshot: Gateway variable configuration**

### Step 3: Region Variable

Add variable:
- **Name:** `region`
- **Type:** Custom
- **Values:** `EU-West,EU-Central,US-East,US-West,APAC`
- **Multi-value:** Yes
- **Include All:** Yes
- **Custom all value:** `.*`

**📸 Screenshot: Region variable dropdown**

### Step 4: Payment Method Variable

Add variable:
- **Name:** `payment_method`
- **Type:** Query
- **Data source:** TransactionDB
- **Query:**
```sql
SELECT DISTINCT payment_method 
FROM transactions 
WHERE created_at >= NOW() - INTERVAL '7 days'
ORDER BY payment_method;
```
- **Multi-value:** Yes
- **Include All:** Yes

**📸 Screenshot: Payment method options**

### Step 5: Time Grouping Variable

Add variable:
- **Name:** `time_grouping`
- **Type:** Interval
- **Values:** `auto,30s,1m,5m,15m,30m,1h`
- **Auto min:** 30s
- **Auto step count:** 20

**📸 Screenshot: Interval variable**

### Step 6: SLA Target Constant

Add variable:
- **Name:** `sla_success_rate`
- **Type:** Constant
- **Value:** `99.5`
- **Hide:** Label

**📸 Screenshot: Variables list with 6 variables**

**✅ Checkpoint:** All variables created

---

## Part 2: Build Overview Panels (30 min)

### Step 7: Panel 1 - Total Transactions

**Query:**
```sql
SELECT 
  COUNT(*) as total_transactions,
  DATE_TRUNC('minute', created_at) as time
FROM transactions
WHERE created_at >= NOW() - INTERVAL '$__range_s seconds'
  AND payment_method = ANY(string_to_array('${payment_method:csv}', ','))
GROUP BY DATE_TRUNC('minute', created_at)
ORDER BY time;
```

**Transform:** Add transformation → Reduce
- Mode: Series to rows
- Calculations: Total

**Settings:**
- Visualization: Stat
- Graph mode: Area
- Color mode: Value
- Title: `Total Transactions - ${payment_method:text}`

**📸 Screenshot: Stat panel with sparkline showing total**

### Step 8: Panel 2 - Success Rate SLA

**Query:**
```sql
SELECT 
  ROUND(
    (COUNT(*) FILTER (WHERE status = 'SUCCESS')::numeric / 
     NULLIF(COUNT(*), 0)) * 100,
    3
  ) as success_rate_pct
FROM transactions
WHERE created_at >= NOW() - INTERVAL '5 minutes';
```

**Settings:**
- Visualization: Gauge
- Thresholds:
  - 0: Red
  - `${sla_success_rate} - 1`: Orange (98.5)
  - `${sla_success_rate}`: Green (99.5)
- Title: `Success Rate (Target: ${sla_success_rate}%)`
- Show threshold labels: Yes
- Show threshold markers: Yes

**📸 Screenshot: Gauge with SLA thresholds**

### Step 9: Panel 3 - P95 Latency

**Query:**
```sql
SELECT 
  DATE_TRUNC('$time_grouping', created_at) as time,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY processing_time_ms) as p95_latency
FROM transactions
WHERE created_at >= NOW() - INTERVAL '$__range_s seconds'
GROUP BY DATE_TRUNC('$time_grouping', created_at)
ORDER BY time;
```

**Settings:**
- Visualization: Stat
- Graph mode: Line
- Thresholds: 0, 1000, 2000 (ms)
- Color scheme: From thresholds
- Unit: milliseconds

**📸 Screenshot: Stat with trend line**

### Step 10: Panel 4 - Active Sessions

If using Prometheus:
```promql
sum(payment_gateway_active_sessions{method=~"${payment_method:regex}"}) by (method)
```

Or use sample query:
```sql
SELECT 
  payment_method,
  COUNT(*) as active_sessions
FROM transactions
WHERE created_at >= NOW() - INTERVAL '1 minute'
  AND status = 'PENDING'
GROUP BY payment_method;
```

**Settings:**
- Visualization: Time series
- Title: Active Payment Sessions

**📸 Screenshot: Overview row with 4 panels**

**✅ Checkpoint:** Overview panels complete

---

## Part 3: Performance Analysis Panels (35 min)

### Step 11: Throughput Timeline

**Query A - Successful:**
```sql
SELECT 
  DATE_TRUNC('$time_grouping', created_at) as time,
  COUNT(*) FILTER (WHERE status = 'SUCCESS') as "Successful Transactions"
FROM transactions
WHERE created_at >= NOW() - INTERVAL '$__range_s seconds'
GROUP BY DATE_TRUNC('$time_grouping', created_at)
ORDER BY time;
```

**Query B - Failed:**
```sql
SELECT 
  DATE_TRUNC('$time_grouping', created_at) as time,
  COUNT(*) FILTER (WHERE status = 'FAILED') as "Failed Transactions"
FROM transactions
WHERE created_at >= NOW() - INTERVAL '$__range_s seconds'
GROUP BY DATE_TRUNC('$time_grouping', created_at)
ORDER BY time;
```

**Settings:**
- Visualization: Time series
- Stack series: Normal
- Title: Transaction Throughput
- Legend: Bottom (table mode)

**📸 Screenshot: Stacked time series**

### Step 12: Add Annotations

Dashboard settings → Annotations → Add annotation query

**Annotation:**
- **Name:** Deployments
- **Data source:** TransactionDB
- **Enable:** ✓
- **Query:**
```sql
SELECT
  EXTRACT(EPOCH FROM deploy_time) * 1000 as time,
  service_name as text,
  'deployment' as tags
FROM deployment_events
WHERE deploy_time >= NOW() - INTERVAL '$__range_s seconds';
```

**📸 Screenshot: Annotation configuration**

### Step 13: Error Distribution

**Query:**
```sql
SELECT 
  CASE 
    WHEN status = 'FAILED' AND processing_time_ms > 5000 THEN 'Timeout'
    WHEN status = 'FAILED' AND processing_time_ms < 100 THEN 'Validation Error'
    WHEN status = 'FAILED' THEN 'Processing Error'
    WHEN status = 'PENDING' THEN 'Pending'
    ELSE 'Unknown'
  END as error_type,
  COUNT(*) as count
FROM transactions
WHERE status != 'SUCCESS'
  AND created_at >= NOW() - INTERVAL '1 hour'
  AND payment_method = ANY(string_to_array('${payment_method:csv}', ','))
GROUP BY error_type
ORDER BY count DESC;
```

**Settings:**
- Visualization: Pie chart
- Pie type: Donut
- Legend: Right (values + percentage)
- Title: Error Distribution

**📸 Screenshot: Donut chart with error types**

### Step 14: Latency Heatmap

**Query:**
```sql
SELECT 
  DATE_TRUNC('$time_grouping', created_at) as time,
  WIDTH_BUCKET(processing_time_ms, 0, 10000, 20) * 500 as latency_bucket,
  COUNT(*) as count
FROM transactions
WHERE created_at >= NOW() - INTERVAL '$__range_s seconds'
GROUP BY time, latency_bucket
ORDER BY time, latency_bucket;
```

**Settings:**
- Visualization: Heatmap
- Color scheme: Spectral
- Y-axis: Latency buckets (ms)
- Calculate: Count
- Title: Processing Time Distribution

**📸 Screenshot: Heatmap showing latency buckets over time**

**✅ Checkpoint:** Performance panels complete

---

## Part 4: Optimize Dashboard (20 min)

### Step 15: Enable Query Caching

For each panel:
1. Edit panel → Query options
2. **Cache timeout:** 300 (5 minutes)
3. **Max data points:** 500

**📸 Screenshot: Query options with caching**

### Step 16: Set Panel Priorities

Dashboard settings → Panel options
- Critical panels (Overview): Load first
- Detail panels: Normal priority

**📸 Screenshot: Panel loading priorities**

### Step 17: Test Performance

1. Open browser Developer Tools (F12)
2. Network tab → Reload dashboard
3. Note load time
4. Check for query result caching

**📸 Screenshot: Network tab showing load time < 3 seconds**

### Step 18: Add Time Range Limits

For expensive queries, add limits:
```sql
SELECT * FROM transactions
WHERE created_at >= NOW() - INTERVAL '$__range_s seconds'
  AND created_at <= NOW()  -- Explicit upper bound
LIMIT 1000;  -- Protect against huge result sets
```

**📸 Screenshot: Query with limits**

**✅ Checkpoint:** Dashboard loads in < 3 seconds

---

## Part 5: Create Template Library (10 min)

### Step 19: Export Variable Configuration

1. Dashboard settings → JSON Model
2. Copy `templating` section
3. Save to file: `payment-gateway-variables.json`

**JSON snippet:**
```json
{
  "templating": {
    "list": [
      {
        "name": "payment_method",
        "type": "query",
        "datasource": "TransactionDB",
        "query": "SELECT DISTINCT payment_method FROM transactions",
        "multi": true,
        "includeAll": true
      },
      {
        "name": "time_grouping",
        "type": "interval",
        "auto": true,
        "auto_count": 20,
        "auto_min": "30s"
      }
    ]
  }
}
```

**📸 Screenshot: Exported variable template**

### Step 20: Import into New Dashboard

To reuse variables:
1. Create new dashboard
2. Settings → JSON Model
3. Replace `templating` section
4. Save

**📸 Screenshot: Variables imported into new dashboard**

### Step 21: Save Dashboard

Save as "Payment Gateway Performance"

**📸 Screenshot: Complete dashboard with all panels**

**✅ Final Checkpoint:** Production-ready dashboard complete

---

## Workshop Complete! 🎉

You have successfully:
- ✅ Created 6 advanced variables including chained dependencies
- ✅ Built overview panels with SLA monitoring
- ✅ Created performance analysis visualizations
- ✅ Added deployment annotations
- ✅ Optimized query performance with caching
- ✅ Exported reusable variable templates
- ✅ Built production-grade payment gateway dashboard

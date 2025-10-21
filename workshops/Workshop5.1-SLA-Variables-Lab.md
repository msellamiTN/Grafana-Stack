# Workshop 5.1: Dynamic SLA Dashboard with Query Variables

**Duration:** 90 minutes | **Level:** Advanced

---

## Part 1: Create Base Variables (20 min)

### Step 1: Create New Dashboard

1. Click + → Dashboard
2. Dashboard settings (⚙️) → Variables → Add variable

**📸 Screenshot: Variables configuration page**

### Step 2: Create Interval Variable

**Variable settings:**
- **Name:** `interval`
- **Type:** Interval
- **Label:** Aggregation Interval
- **Values:** `auto,1m,5m,15m,1h,6h,1d`
- **Auto Option:** Enabled
- **Auto step count:** 30
- **Auto min interval:** 1m

Click "Add"

**📸 Screenshot: Interval variable configuration**

### Step 3: Create Service Variable

Add new variable:
- **Name:** `service`
- **Type:** Query
- **Label:** Service
- **Data source:** Prometheus
- **Query:** `label_values(up, job)`
- **Sort:** Alphabetical (asc)
- **Multi-value:** Enabled
- **Include All option:** Enabled
- **Custom all value:** `.*`

**📸 Screenshot: Query variable with service list**

### Step 4: Create Status Filter

Add variable:
- **Name:** `status`
- **Type:** Custom
- **Label:** Status Filter
- **Values:** `SUCCESS,FAILED,PENDING`
- **Multi-value:** Enabled
- **Include All option:** Enabled

**📸 Screenshot: Custom variable dropdown**

### Step 5: Create SLA Threshold (Constant)

Add variable:
- **Name:** `sla_threshold`
- **Type:** Constant
- **Value:** `95`
- **Hide:** Variable

**📸 Screenshot: Variables list showing 4 variables**

**✅ Checkpoint:** All variables created

---

## Part 2: Create Variable-Driven Panels (40 min)

### Step 6: Panel 1 - Service Availability

**Query (PostgreSQL):**
```sql
SELECT 
  ROUND(
    (COUNT(*) FILTER (WHERE status IN ($status))::numeric / 
     NULLIF(COUNT(*), 0)) * 100,
    2
  ) as availability
FROM transactions
WHERE created_at >= NOW() - INTERVAL '$__range_s seconds'
  AND status = ANY(string_to_array('$status', ','));
```

**Settings:**
- Visualization: Gauge
- Title: `Availability - ${service:text}`
- Thresholds:
  - Base: 0 (Red)
  - `${sla_threshold}` (Yellow) - Type: 95
  - `${sla_threshold} + 3` (Green) - Type: 98
- Unit: Percent (0-100)

**📸 Screenshot: Gauge using variable in thresholds**

### Step 7: Panel 2 - Request Rate by Service

**Query (Prometheus):**
```promql
sum(rate(http_requests_total{job=~"$service"}[$interval])) by (job)
```

**Settings:**
- Visualization: Time series
- Title: `Request Rate - ${service:text}`
- Legend: `{{job}}`
- Unit: requests/sec

**📸 Screenshot: Time series with dynamic aggregation interval**

### Step 8: Panel 3 - Error Rate Comparison

**Query:**
```sql
SELECT 
  CASE 
    WHEN status = 'SUCCESS' THEN 'Success'
    WHEN status = 'FAILED' THEN 'Failed'
    ELSE 'Pending'
  END as status_label,
  COUNT(*) as count
FROM transactions
WHERE created_at >= NOW() - INTERVAL '$__range_s seconds'
  AND status = ANY(string_to_array('$status', ','))
GROUP BY status_label
ORDER BY count DESC;
```

**Settings:**
- Visualization: Bar gauge
- Title: `Status Distribution - Filtered by ${status:text}`

**📸 Screenshot: Bar gauge filtered by status variable**

### Step 9: Panel 4 - Latency Percentiles

**Query:**
```sql
SELECT 
  DATE_TRUNC('$interval', created_at) as time,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY processing_time_ms) as "P50",
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY processing_time_ms) as "P95",
  PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY processing_time_ms) as "P99"
FROM transactions
WHERE created_at >= NOW() - INTERVAL '$__range_s seconds'
  AND status = ANY(string_to_array('$status', ','))
GROUP BY DATE_TRUNC('$interval', created_at)
ORDER BY time;
```

**Settings:**
- Visualization: Time series
- Title: `Latency Percentiles (aggregated by ${interval})`
- Unit: milliseconds

**📸 Screenshot: Time series with variable in title and query**

### Step 10: Test Variables

1. Change interval dropdown → See aggregation change
2. Select specific service → Panels filter
3. Change status filter → Data updates

**📸 Screenshot: Dashboard with variable dropdowns at top**

**✅ Checkpoint:** Variables control all panels

---

## Part 3: Implement Variable Chaining (20 min)

### Step 11: Create Account ID Variable

Dashboard settings → Variables → Add

- **Name:** `account_id`
- **Type:** Query
- **Label:** Account ID
- **Data source:** TransactionDB
- **Query:**
```sql
SELECT DISTINCT account_id 
FROM transactions 
WHERE created_at >= NOW() - INTERVAL '7 days'
  AND status = ANY(string_to_array('$status', ','))
ORDER BY account_id
LIMIT 100;
```
- **Multi-value:** Enabled
- **Include All:** Enabled

**📸 Screenshot: Account variable depends on status**

### Step 12: Create Merchant Variable

Add variable:
- **Name:** `merchant`
- **Type:** Query
- **Data source:** TransactionDB
- **Query:**
```sql
SELECT DISTINCT merchant_id 
FROM transactions 
WHERE account_id = ANY(string_to_array('$account_id', ','))
  AND created_at >= NOW() - INTERVAL '7 days'
ORDER BY merchant_id;
```
- **Multi-value:** Enabled
- **Include All:** Enabled

**📸 Screenshot: Merchant variable depends on account_id**

### Step 13: Test Variable Chain

1. Select specific status → Account list updates
2. Select specific account → Merchant list filters
3. Select "All" → All options available

**📸 Screenshot: Variable chain in action**

**✅ Checkpoint:** Variable chaining works

---

## Part 4: Add Drill-Down Links (10 min)

### Step 14: Create Transaction Details Dashboard

Create new dashboard: "Transaction Details"

Add text box variable:
- **Name:** `tx_id`
- **Type:** Textbox
- **Label:** Transaction ID

Add table panel showing single transaction:
```sql
SELECT * FROM transactions WHERE transaction_id = $tx_id;
```

Save dashboard (note UID)

**📸 Screenshot: Transaction detail dashboard**

### Step 15: Add Link in SLA Dashboard

Back in SLA dashboard, add panel showing transaction list:
```sql
SELECT 
  transaction_id,
  account_id,
  amount,
  status,
  created_at
FROM transactions
WHERE created_at >= NOW() - INTERVAL '1 hour'
ORDER BY created_at DESC
LIMIT 50;
```

Add data link:
1. Edit panel → Field → Data links
2. **Title:** View Details
3. **URL:** `/d/TRANSACTION_DETAILS_UID?var-tx_id=${__data.fields.transaction_id}`
4. **Open in new tab:** Yes

**📸 Screenshot: Data link configuration**

### Step 16: Test Drill-Down

Click on transaction row → Opens detail dashboard with tx_id populated

**📸 Screenshot: Detail page with auto-populated transaction ID**

**✅ Final Checkpoint:** Drill-down navigation works

---

## Workshop Complete! 🎉

You have successfully:
- ✅ Created multiple variable types
- ✅ Built variable-driven panels
- ✅ Implemented variable chaining
- ✅ Added drill-down navigation
- ✅ Created dynamic SLA dashboard

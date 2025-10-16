# Workshop 3.2: Multi-Database Observability for Customer Journey Analytics

**Duration:** 120 minutes | **Level:** Advanced

---

## Part 1: Deploy MySQL Customer Database (25 min)

### Step 1: Deploy MySQL

Apply MySQL deployment from course materials:
```bash
kubectl apply -f mysql-customers.yaml
kubectl get pods -l app=mysql-customers -w
```

**📸 Screenshot: MySQL pod running**

### Step 2: Verify Customer Data

```bash
kubectl exec deployment/mysql-customers -- \
  mysql -ugrafana_reader -pGrafanaRead123! -e \
  "SELECT COUNT(*) FROM customer_db.customers;"
```

**📸 Screenshot: 1000 customers in database**

**✅ Checkpoint:** MySQL deployed with customer data

---

## Part 2: Add MySQL Data Source (10 min)

### Step 3: Configure MySQL in Grafana

Configuration → Data sources → Add MySQL

**Settings:**
- Host: `mysql-customers.monitoring-ebanking.svc.cluster.local:3306`
- Database: customer_db
- User: grafana_reader
- Password: GrafanaRead123!

Click "Save & test"

**📸 Screenshot: Green "Database Connection OK"**

**✅ Checkpoint:** MySQL connected

---

## Part 3: Create Customer Journey Dashboard (60 min)

### Step 4: Panel 1 - Active Customers by Segment

**Data Source:** MySQL

**Query:**
```sql
SELECT 
  customer_segment as segment,
  COUNT(*) as customer_count
FROM customers
WHERE is_active = TRUE
GROUP BY customer_segment;
```

**Settings:**
- Visualization: Pie chart
- Title: Active Customers by Segment

**📸 Screenshot: Pie chart with premium/standard/basic segments**

### Step 5: Panel 2 - Customer Transaction History

**Query A - Transaction Count (PostgreSQL - TransactionDB):**
```sql
SELECT 
  t.account_id,
  COUNT(*) as transaction_count,
  SUM(t.amount) as total_amount
FROM transactions t
WHERE t.created_at >= NOW() - INTERVAL '30 days'
GROUP BY t.account_id
ORDER BY COUNT(*) DESC
LIMIT 100;
```

**Query B - Customer Details (MySQL - customer_db):**
```sql
SELECT 
  account_id,
  CONCAT(first_name, ' ', last_name) as customer_name,
  customer_segment,
  email
FROM customers
WHERE is_active = TRUE;
```

**Transform:** Add transformation → **Outer join**
- Join by field: account_id

**📸 Screenshot: Transform configuration with join settings**

**Settings:**
- Visualization: Table
- Title: Top Customers by Transaction Volume

**📸 Screenshot: Table showing joined data from both databases**

### Step 6: Panel 3 - Session Analytics

**Data Source:** MySQL

**Query:**
```sql
SELECT 
  UNIX_TIMESTAMP(DATE(session_start)) * 1000 as time,
  COUNT(*) as "Total Sessions",
  AVG(pages_viewed) as "Avg Pages",
  AVG(actions_taken) as "Avg Actions"
FROM customer_sessions
WHERE session_start >= NOW() - INTERVAL 7 DAY
GROUP BY DATE(session_start)
ORDER BY session_start;
```

**Settings:**
- Visualization: Time series
- Title: Customer Engagement - Last 7 Days

**📸 Screenshot: Multi-line time series with sessions and engagement metrics**

### Step 7: Panel 4 - Customer Engagement Score

**Query A - Transaction Metrics (PostgreSQL):**
```sql
SELECT 
  account_id,
  COUNT(*) as tx_count,
  AVG(CASE WHEN status = 'SUCCESS' THEN 100 ELSE 0 END) as success_rate
FROM transactions
WHERE created_at >= NOW() - INTERVAL '90 days'
GROUP BY account_id
LIMIT 100;
```

**Query B - Session Metrics (MySQL):**
```sql
SELECT 
  c.account_id,
  COUNT(cs.session_id) as session_count,
  AVG(cs.pages_viewed) as avg_engagement
FROM customers c
LEFT JOIN customer_sessions cs ON c.customer_id = cs.customer_id
WHERE cs.session_start >= NOW() - INTERVAL 90 DAY
GROUP BY c.account_id
LIMIT 100;
```

**Transform:** Add transformation → **Join**
- Join field: account_id
- Then add **Add field from calculation**:
```
Customer Score = (tx_count * 0.4) + (success_rate * 0.3) + (session_count * 0.3)
```

**📸 Screenshot: Transformation pipeline showing join and calculation**

**Settings:**
- Visualization: Bar gauge
- Title: Top 10 Customers by Engagement Score
- Sort: By customer_score descending
- Max items: 10

**📸 Screenshot: Bar gauge showing customer scores**

### Step 8: Save Dashboard

Save as "Customer Journey Analytics"

**📸 Screenshot: Complete dashboard with 4 panels showing cross-database data**

---

## Part 4: Query Optimization (25 min)

### Step 9: Add Indexes

**PostgreSQL:**
```bash
kubectl exec deployment/postgres-transactions -- \
  psql -U grafana_reader -d transactions_db -c \
  "CREATE INDEX idx_transactions_account_created 
   ON transactions(account_id, created_at);"
```

**MySQL:**
```bash
kubectl exec deployment/mysql-customers -- \
  mysql -ugrafana_reader -pGrafanaRead123! customer_db -e \
  "CREATE INDEX idx_sessions_customer_start 
   ON customer_sessions(customer_id, session_start);"
```

**📸 Screenshot: Indexes created successfully**

### Step 10: Enable Query Caching

For each panel:
1. Edit panel → Query options
2. **Cache timeout:** 300 (5 minutes)
3. **Max data points:** 1000

**📸 Screenshot: Query options with caching enabled**

### Step 11: Test Performance

1. Open dashboard
2. Note load time (should be < 5 seconds)
3. Refresh dashboard
4. Second load should be faster (cached)

**📸 Screenshot: Browser developer tools showing cached responses**

### Step 12: Measure Query Time

In panel inspector:
1. Edit panel → Inspect → Stats
2. Note **Query execution time**

**📸 Screenshot: Query stats showing execution time < 500ms**

**✅ Final Checkpoint:** Dashboard loads in <5 seconds

---

## Workshop Complete! 🎉

You have successfully:
- ✅ Deployed MySQL with customer data
- ✅ Created cross-database joins in Grafana
- ✅ Built customer journey analytics dashboard
- ✅ Applied query optimization techniques
- ✅ Implemented performance improvements

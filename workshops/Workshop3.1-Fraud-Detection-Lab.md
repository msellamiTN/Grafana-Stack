# Workshop 3.1: Fraud Detection Dashboard with Exemplars

**Duration:** 90 minutes | **Level:** Advanced

---

## Part 1: Create Fraud Score Table (15 min)

### Step 1: Add Fraud Scores

```bash
kubectl exec deployment/postgres-transactions -- \
  psql -U grafana_reader -d transactions_db << 'EOF'
CREATE TABLE fraud_scores (
  score_id SERIAL PRIMARY KEY,
  transaction_id INTEGER REFERENCES transactions(transaction_id),
  risk_score DECIMAL(5,2),
  risk_factors TEXT[],
  is_flagged BOOLEAN,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO fraud_scores (transaction_id, risk_score, risk_factors, is_flagged)
SELECT 
  transaction_id,
  CASE 
    WHEN amount > 5000 THEN random() * 40 + 60
    WHEN processing_time_ms > 4000 THEN random() * 30 + 50
    ELSE random() * 30
  END as risk_score,
  ARRAY[
    CASE WHEN amount > 5000 THEN 'high_amount' END,
    CASE WHEN processing_time_ms > 4000 THEN 'slow_processing' END
  ]::TEXT[] as risk_factors,
  CASE 
    WHEN amount > 8000 OR processing_time_ms > 4500 THEN TRUE
    ELSE FALSE
  END as is_flagged
FROM transactions;

CREATE INDEX idx_fraud_flagged ON fraud_scores(is_flagged, created_at);
EOF
```

**📸 Screenshot: Table created successfully**

### Step 2: Verify Data

```bash
kubectl exec deployment/postgres-transactions -- \
  psql -U grafana_reader -d transactions_db -c \
  "SELECT COUNT(*) as total, COUNT(*) FILTER (WHERE is_flagged) as flagged FROM fraud_scores;"
```

**📸 Screenshot: Query showing total and flagged counts**

**✅ Checkpoint:** Fraud scores populated

---

## Part 2: Build Fraud Dashboard (45 min)

### Step 3: Create Dashboard

Create new dashboard: "Fraud Detection & Risk Analysis"

### Step 4: Panel 1 - Fraud Detection Rate

**Query:**
```sql
SELECT 
  ROUND((COUNT(*) FILTER (WHERE fs.is_flagged = TRUE)::numeric / 
   NULLIF(COUNT(*), 0)) * 100, 2) as fraud_rate
FROM transactions t
INNER JOIN fraud_scores fs ON t.transaction_id = fs.transaction_id
WHERE t.created_at >= NOW() - INTERVAL '1 hour';
```

**Settings:**
- Visualization: Stat
- Title: Fraud Detection Rate (%)
- Unit: Percent
- Thresholds: Green<2, Yellow 2-5, Red>5

**📸 Screenshot: Stat showing fraud rate with color coding**

### Step 5: Panel 2 - High-Risk Transactions

**Query:**
```sql
SELECT 
  t.transaction_id as "Transaction ID",
  t.account_id as "Account",
  t.amount as "Amount",
  fs.risk_score as "Risk Score",
  fs.risk_factors as "Risk Factors",
  t.created_at as "Time"
FROM transactions t
INNER JOIN fraud_scores fs ON t.transaction_id = fs.transaction_id
WHERE fs.is_flagged = TRUE
  AND t.created_at >= NOW() - INTERVAL '6 hours'
ORDER BY fs.risk_score DESC
LIMIT 20;
```

**Settings:**
- Visualization: Table
- Title: Flagged High-Risk Transactions
- Column overrides: Color risk_score (Red>80, Yellow>60)

**📸 Screenshot: Table showing flagged transactions with color-coded risk scores**

### Step 6: Panel 3 - Risk Distribution

**Query:**
```sql
SELECT 
  WIDTH_BUCKET(fs.risk_score, 0, 100, 10) * 10 as risk_bucket,
  COUNT(*) as transaction_count
FROM fraud_scores fs
INNER JOIN transactions t ON fs.transaction_id = t.transaction_id
WHERE t.created_at >= NOW() - INTERVAL '24 hours'
GROUP BY risk_bucket
ORDER BY risk_bucket;
```

**Settings:**
- Visualization: Bar chart
- Title: Risk Score Distribution

**📸 Screenshot: Histogram showing risk score buckets**

### Step 7: Panel 4 - Fraud by Payment Method

**Query:**
```sql
SELECT 
  t.payment_method as "Method",
  COUNT(*) as "Flagged Count"
FROM transactions t
INNER JOIN fraud_scores fs ON t.transaction_id = fs.transaction_id
WHERE fs.is_flagged = TRUE
  AND t.created_at >= NOW() - INTERVAL '24 hours'
GROUP BY t.payment_method
ORDER BY COUNT(*) DESC;
```

**Settings:**
- Visualization: Pie chart
- Title: Fraud Distribution by Payment Method

**📸 Screenshot: Pie chart with payment method breakdown**

### Step 8: Panel 5 - Fraud Timeline

**Query:**
```sql
SELECT 
  DATE_TRUNC('hour', t.created_at) as time,
  COUNT(*) as "Total",
  COUNT(*) FILTER (WHERE fs.is_flagged = TRUE) as "Flagged",
  AVG(fs.risk_score) as "Avg Risk"
FROM transactions t
INNER JOIN fraud_scores fs ON t.transaction_id = fs.transaction_id
WHERE t.created_at >= NOW() - INTERVAL '24 hours'
GROUP BY time
ORDER BY time;
```

**Settings:**
- Visualization: Time series
- Title: Fraud Detection Timeline

**📸 Screenshot: Multi-line time series showing trends**

### Step 9: Save Dashboard

**📸 Screenshot: Complete fraud detection dashboard**

---

## Part 3: Add Drill-Down Links (15 min)

### Step 10: Configure Data Links

In "High-Risk Transactions" table panel:
1. Edit panel → Field → Data links
2. Add link:
   - **Title:** View Details
   - **URL:** `/d/transaction-details?var-tx_id=${__data.fields["Transaction ID"]}`
   - Open in new tab: Yes

**📸 Screenshot: Data link configuration**

### Step 11: Test Link

Click on a transaction row

**📸 Screenshot: Link navigates to detail page**

**✅ Checkpoint:** Drill-down functional

---

## Part 4: Create Fraud Alert (15 min)

### Step 12: Add Alert Rule

Alerting → Alert rules → New

**Name:** High Fraud Detection Rate

**Query:**
```sql
SELECT 
  (COUNT(*) FILTER (WHERE fs.is_flagged = TRUE)::numeric / 
   NULLIF(COUNT(*), 0)) * 100 as fraud_rate
FROM transactions t
INNER JOIN fraud_scores fs ON t.transaction_id = fs.transaction_id
WHERE t.created_at >= NOW() - INTERVAL '10 minutes';
```

**Condition:** fraud_rate > 5

**Labels:**
```
severity = critical
team = fraud-detection
alert_type = security
```

**📸 Screenshot: Alert rule configuration**

Save rule.

**✅ Final Checkpoint:** Fraud monitoring complete

---

## Workshop Complete! 🎉

You have successfully:
- ✅ Created fraud scoring system
- ✅ Built comprehensive fraud detection dashboard
- ✅ Added drill-down navigation
- ✅ Configured fraud rate alerting

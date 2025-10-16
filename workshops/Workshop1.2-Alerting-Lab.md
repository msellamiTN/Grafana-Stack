# Workshop 1.2: Alerting for Transaction Failures

**Duration:** 90 minutes | **Level:** Beginner

---

## Part 1: Configure Notification Channel (20 min)

### Step 1: Access Alerting Menu

In Grafana:
1. Click 🔔 Alerting in left sidebar
2. Click "Contact points"

**📸 Screenshot: Alerting menu showing Contact points page**

### Step 2: Add Slack Contact Point

1. Click "Add contact point"
2. Fill in:
   - **Name:** `ebanking-alerts-slack`
   - **Integration:** Select "Slack"
   - **Webhook URL:** `https://hooks.slack.com/services/YOUR/WEBHOOK/URL`

**📸 Screenshot: Contact point form with Slack integration**

### Step 3: Configure Message Template

In the "Optional Slack settings" section, add message:
```
⚠️ *{{ .GroupLabels.alertname }}*

*Summary:* {{ .Annotations.summary }}
*Details:* {{ .Annotations.description }}

*Severity:* {{ .CommonLabels.severity }}
```

**📸 Screenshot: Message template editor**

### Step 4: Test Notification

1. Click "Test" button
2. Verify message appears in Slack

**📸 Screenshot: Test notification in Slack channel**

**✅ Checkpoint:** Test notification received successfully

Click "Save contact point"

---

## Part 2: Configure Notification Policy (15 min)

### Step 5: Set Up Routing

1. Navigate to Alerting → Notification policies
2. Click "Edit" on default policy

**📸 Screenshot: Notification policies page**

### Step 6: Configure Policy

Set:
- **Contact point:** ebanking-alerts-slack
- **Group by:** alertname, severity
- **Timing:**
  - Group wait: 30s
  - Group interval: 5m
  - Repeat interval: 4h

**📸 Screenshot: Notification policy settings**

Click "Save policy"

**✅ Checkpoint:** Policy configured with correct timings

---

## Part 3: Create High Failure Rate Alert (25 min)

### Step 7: Create Alert Rule

1. Navigate to Alerting → Alert rules
2. Click "New alert rule"

**📸 Screenshot: New alert rule page**

### Step 8: Define Query

**Section 1: Define query and condition**

Name: `High Transaction Failure Rate`

**Query A:**
- Data source: TransactionDB
- Query:
```sql
SELECT 
  ROUND((COUNT(*) FILTER (WHERE status = 'FAILED')::numeric / 
   NULLIF(COUNT(*), 0)) * 100, 2) as failure_rate
FROM transactions
WHERE created_at >= NOW() - INTERVAL '5 minutes';
```

**📸 Screenshot: Query editor with failure rate query**

### Step 9: Set Threshold

**Expression B:**
- Operation: Threshold
- Input: A
- Condition: IS ABOVE 5

**📸 Screenshot: Expression builder with threshold condition**

### Step 10: Configure Evaluation

**Section 2: Set evaluation behavior**
- Folder: Create new "E-Banking Alerts"
- Evaluation group: "Transactions" (create new)
- Evaluation interval: 1m
- Pending period: 5m

**📸 Screenshot: Evaluation settings section**

### Step 11: Add Labels

**Section 3: Add labels**
```
severity = critical
team = payments
service = transaction-processor
```

**📸 Screenshot: Labels section with three labels**

### Step 12: Add Annotations

**Section 4: Annotations**
- **summary:** `Transaction failure rate exceeds 5%`
- **description:** `Current failure rate: {{ $values.A.Value }}%. Investigate immediately.`
- **runbook_url:** `https://wiki.oddo-bank.local/runbooks/high-failure-rate`

**📸 Screenshot: Annotations section filled**

Click "Save rule and exit"

**✅ Checkpoint:** Alert rule appears in alert rules list

---

## Part 4: Create Slow Processing Alert (20 min)

### Step 13: Add Second Alert

1. Alerting → Alert rules → New alert rule

Name: `Slow Transaction Processing`

**Query A:**
```sql
SELECT AVG(processing_time_ms) as avg_processing_time
FROM transactions
WHERE created_at >= NOW() - INTERVAL '5 minutes';
```

**Expression B:**
- Condition: IS ABOVE 3000

**📸 Screenshot: Second alert rule configuration**

### Step 14: Configure Labels

```
severity = warning
team = payments
service = transaction-processor
```

**Annotations:**
- **summary:** `Transaction processing time degraded`
- **description:** `Average: {{ $values.A.Value }}ms (expected < 3000ms)`

Save rule.

**✅ Checkpoint:** Two alert rules exist

**📸 Screenshot: Alert rules list showing both rules**

---

## Part 5: Test Alert Firing (30 min)

### Step 15: Generate Failed Transactions

```bash
kubectl exec deployment/postgres-transactions -- \
  psql -U grafana_reader -d transactions_db -c "
INSERT INTO transactions (account_id, transaction_type, amount, status, processing_time_ms)
SELECT 
  'ACC' || LPAD((random() * 10000)::int::text, 5, '0'),
  'DEBIT', (random() * 1000)::decimal(15,2), 'FAILED',
  (random() * 8000 + 4000)::int
FROM generate_series(1, 200);"
```

**📸 Screenshot: Terminal showing INSERT command executed**

### Step 16: Monitor Alert State

1. Navigate to Alerting → Alert rules
2. Refresh page every 30 seconds
3. Watch for state changes:
   - Normal → Pending (after 1 min)
   - Pending → Firing (after 6 min total)

**📸 Screenshot: Alert status showing "Pending"**

**📸 Screenshot: Alert status showing "Firing"**

### Step 17: Verify Notification

Check Slack channel for alert

**📸 Screenshot: Alert notification in Slack with all details**

**✅ Checkpoint:** Alert fired and notification received

---

## Part 6: Create Silence Rule (15 min)

### Step 18: Add Silence

1. Navigate to Alerting → Silences
2. Click "Add silence"

**📸 Screenshot: Add silence form**

### Step 19: Configure Silence

- **Duration:** 2 hours
- **Matchers:**
  - service = transaction-processor
- **Comment:** `Planned maintenance - processor upgrade`

**📸 Screenshot: Silence configuration with matcher**

Click "Create"

### Step 20: Verify Silence

1. Check alert still shows "Firing"
2. Verify notifications stop

**📸 Screenshot: Active silences list**

**✅ Checkpoint:** Silence active, no new notifications

---

## Part 7: View Alert History (5 min)

### Step 21: Check State History

1. Click on "High Transaction Failure Rate" rule
2. Click "See alert state history"

**📸 Screenshot: Alert state history timeline showing transitions**

**✅ Final Checkpoint:** Can view complete alert lifecycle

---

## Workshop Complete! 🎉

You have successfully:
- ✅ Configured Slack notifications
- ✅ Set up notification policies
- ✅ Created two alert rules
- ✅ Tested alert firing
- ✅ Created silence rules
- ✅ Reviewed alert history

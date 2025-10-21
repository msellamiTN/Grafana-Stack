# Workshop 4.1: Multi-Tenant Setup for Payment & Retail Banking Teams

**Duration:** 90 minutes | **Level:** Advanced

---

## Part 1: Create Teams (15 min)

### Step 1: Create Payments Team

In Grafana:
1. Configuration (⚙️) → Teams → New team
2. **Name:** `Payments Team`
3. **Email:** `payments-team@oddo-bank.local`
4. Click "Create"

**📸 Screenshot: Payments Team created**

### Step 2: Add Team Members

1. In Payments Team page, click "Add member"
2. Add users (create if needed):
   - alice.payment@oddo-bank.local (Editor)
   - bob.payment@oddo-bank.local (Editor)

**📸 Screenshot: Team members list**

### Step 3: Create Retail Banking Team

Repeat steps:
- **Name:** `Retail Banking Team`
- **Email:** `retail-team@oddo-bank.local`
- **Members:**
  - charlie.retail@oddo-bank.local (Editor)
  - diana.retail@oddo-bank.local (Viewer)

**📸 Screenshot: Retail team created with members**

### Step 4: Create DevOps Team

- **Name:** `DevOps Team`
- **Members:**
  - admin@oddo-bank.local (Admin)

**📸 Screenshot: Three teams in teams list**

**✅ Checkpoint:** 3 teams created with members

---

## Part 2: Create Folder Structure (20 min)

### Step 5: Create Payment Services Folder

1. Dashboards → New folder
2. **Name:** `Payment Services`
3. Click "Create"

**📸 Screenshot: Payment Services folder created**

### Step 6: Set Folder Permissions

1. Click folder → Permissions tab
2. **Remove:** Everyone with Editor Role
3. **Add:**
   - Team: Payments Team → Editor
   - Team: DevOps Team → Admin
   - Team: Retail Banking Team → Viewer
4. Click "Save"

**📸 Screenshot: Folder permissions showing team access**

### Step 7: Create Retail Banking Folder

Create folder: `Retail Banking`

**Permissions:**
- Retail Banking Team → Editor
- DevOps Team → Admin
- (Payments Team has no access)

**📸 Screenshot: Retail folder with permissions**

### Step 8: Create Shared Folder

Create folder: `Shared Observability`

**Permissions:**
- Payments Team → Viewer
- Retail Banking Team → Viewer
- DevOps Team → Editor

**📸 Screenshot: Three folders in dashboards view**

**✅ Checkpoint:** 3 folders with different permission levels

---

## Part 3: Move Dashboards to Folders (15 min)

### Step 9: Organize Dashboards

Move existing dashboards:

1. **E-Banking Transaction Monitoring** → Payment Services
   - Dashboard → Settings → General
   - Folder: Payment Services
   - Save

2. **API Gateway Performance** → Shared Observability

3. **Fraud Detection** → Payment Services

4. **Customer Journey Analytics** → Retail Banking

**📸 Screenshot: Dashboards organized in folders**

**✅ Checkpoint:** All dashboards in appropriate folders

---

## Part 4: Configure Data Source Permissions (20 min)

### Step 10: Enable Data Source Permissions

1. Configuration → Data sources → TransactionDB
2. Click "Permissions" tab
3. **Enable:** Yes

**📸 Screenshot: Data source permissions page**

### Step 11: Set TransactionDB Permissions

**Add permissions:**
- Team: Payments Team → Query
- Team: DevOps Team → Query + Admin

**Remove:** Everyone (if present)

**📸 Screenshot: TransactionDB permissions set**

### Step 12: Set Other Data Source Permissions

**Prometheus:**
- All teams → Query

**MySQL (customer_db):**
- Retail Banking Team → Query
- DevOps Team → Query + Admin

**InfluxDB:**
- DevOps Team → Query + Admin

**📸 Screenshot: Data source permissions summary**

**✅ Checkpoint:** Data sources restricted by team

---

## Part 5: Test Permissions (10 min)

### Step 13: Test as Payment User

1. Logout from admin account
2. Login as: alice.payment@oddo-bank.local
3. Navigate to Dashboards

**Expected:**
- ✅ Can see Payment Services folder (Editor)
- ✅ Can see Shared Observability folder (Viewer)
- ❌ Cannot see Retail Banking folder

**📸 Screenshot: Payment user's dashboard view**

### Step 14: Test Dashboard Edit

1. Open dashboard in Payment Services folder
2. Try to edit → Should succeed
3. Try to edit dashboard in Shared Observability → Should fail (Viewer only)

**📸 Screenshot: Edit permissions working correctly**

### Step 15: Test Data Source Access

1. Create new dashboard panel
2. Check available data sources:
   - ✅ TransactionDB visible
   - ✅ Prometheus visible
   - ❌ MySQL customer_db NOT visible

**📸 Screenshot: Data source dropdown filtered by permissions**

**✅ Checkpoint:** Permissions enforced correctly

---

## Part 6: Create Service Accounts (10 min)

### Step 16: Create CI/CD Service Account

Login as admin again.

1. Configuration → Service accounts → Add service account
2. **Name:** `cicd-pipeline`
3. **Role:** Editor
4. Click "Create"

**📸 Screenshot: Service account created**

### Step 17: Generate Token

1. Click service account
2. "Add service account token"
3. **Name:** `dashboard-provisioning-token`
4. **Expiration:** 1 year
5. Click "Generate"
6. **Copy token** (starts with glsa_)

**📸 Screenshot: Token generated (partially visible)**

### Step 18: Test Token

```bash
export GRAFANA_TOKEN="glsa_YOUR_TOKEN_HERE"

curl -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
  http://localhost:3000/api/dashboards/uid/YOUR_DASHBOARD_UID
```

**📸 Screenshot: API response showing dashboard JSON**

**✅ Final Checkpoint:** Service account API access works

---

## Workshop Complete! 🎉

You have successfully:
- ✅ Created teams with members
- ✅ Organized dashboards in folders
- ✅ Configured folder permissions
- ✅ Restricted data source access
- ✅ Tested multi-tenant separation
- ✅ Created service accounts for automation

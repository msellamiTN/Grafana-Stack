# Workshop 4.2: Dashboard Provisioning with GitOps

**Duration:** 90 minutes | **Level:** Advanced

---

## Part 1: Export Dashboards (20 min)

### Step 1: Get Dashboard UID

In Grafana:
1. Open "E-Banking Transaction Monitoring" dashboard
2. Settings (⚙️) → General
3. Note the **UID** (e.g., transaction-monitoring)

**📸 Screenshot: Dashboard settings showing UID**

### Step 2: Export via API

```bash
export GRAFANA_URL="http://localhost:3000"
export GRAFANA_TOKEN="YOUR_SERVICE_ACCOUNT_TOKEN"
export DASHBOARD_UID="transaction-monitoring"

curl -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
  "${GRAFANA_URL}/api/dashboards/uid/${DASHBOARD_UID}" | \
  jq '.dashboard' > transaction-monitoring.json
```

**📸 Screenshot: Dashboard JSON exported**

### Step 3: Clean JSON

Edit `transaction-monitoring.json`:
- Remove or set `"id": null`
- Set `"version": 0`
- Keep `uid`, `title`, `panels`, etc.

**📸 Screenshot: Cleaned JSON file**

### Step 4: Create Directory Structure

```bash
mkdir -p grafana-dashboards/{payments,retail,shared}
mv transaction-monitoring.json grafana-dashboards/payments/
```

**📸 Screenshot: Directory structure created**

### Step 5: Export All Dashboards

Repeat for other dashboards:
- fraud-detection.json → payments/
- customer-journey.json → retail/
- api-gateway.json → shared/

**✅ Checkpoint:** All dashboards exported as JSON

---

## Part 2: Create Provisioning Configuration (25 min)

### Step 6: Create Provisioning YAML

Create `provisioning-config.yaml`:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-provisioning
  namespace: monitoring-ebanking
data:
  dashboards.yaml: |
    apiVersion: 1
    providers:
      - name: 'Payment Services'
        orgId: 1
        folder: 'Payment Services'
        type: file
        disableDeletion: false
        updateIntervalSeconds: 30
        allowUiUpdates: true
        options:
          path: /etc/grafana/provisioning/dashboards/payments
      
      - name: 'Retail Banking'
        orgId: 1
        folder: 'Retail Banking'
        type: file
        disableDeletion: false
        updateIntervalSeconds: 30
        allowUiUpdates: true
        options:
          path: /etc/grafana/provisioning/dashboards/retail
      
      - name: 'Shared Observability'
        orgId: 1
        folder: 'Shared Observability'
        type: file
        disableDeletion: false
        updateIntervalSeconds: 30
        allowUiUpdates: false
        options:
          path: /etc/grafana/provisioning/dashboards/shared
```

**📸 Screenshot: Provisioning YAML file**

### Step 7: Create Dashboard ConfigMaps

```bash
kubectl create configmap grafana-dashboards-payments \
  --from-file=grafana-dashboards/payments/ \
  -n monitoring-ebanking

kubectl create configmap grafana-dashboards-retail \
  --from-file=grafana-dashboards/retail/ \
  -n monitoring-ebanking

kubectl create configmap grafana-dashboards-shared \
  --from-file=grafana-dashboards/shared/ \
  -n monitoring-ebanking

kubectl apply -f provisioning-config.yaml
```

**📸 Screenshot: ConfigMaps created**

### Step 8: Verify ConfigMaps

```bash
kubectl get configmaps -n monitoring-ebanking | grep dashboard
```

**📸 Screenshot: 4 dashboard ConfigMaps listed**

**✅ Checkpoint:** ConfigMaps created successfully

---

## Part 3: Update Grafana Deployment (20 min)

### Step 9: Add Volume Mounts

Edit Grafana deployment to add:

**volumes:**
```yaml
- name: dashboard-provisioning
  configMap:
    name: grafana-dashboard-provisioning
- name: dashboards-payments
  configMap:
    name: grafana-dashboards-payments
- name: dashboards-retail
  configMap:
    name: grafana-dashboards-retail
- name: dashboards-shared
  configMap:
    name: grafana-dashboards-shared
```

**volumeMounts:**
```yaml
- name: dashboard-provisioning
  mountPath: /etc/grafana/provisioning/dashboards/dashboards.yaml
  subPath: dashboards.yaml
- name: dashboards-payments
  mountPath: /etc/grafana/provisioning/dashboards/payments
- name: dashboards-retail
  mountPath: /etc/grafana/provisioning/dashboards/retail
- name: dashboards-shared
  mountPath: /etc/grafana/provisioning/dashboards/shared
```

**📸 Screenshot: Deployment YAML with new volumes**

### Step 10: Apply Changes

```bash
kubectl apply -f grafana-deployment.yaml
kubectl rollout status deployment/grafana -n monitoring-ebanking
```

**📸 Screenshot: Deployment updated**

### Step 11: Verify Provisioning

In Grafana UI:
1. Navigate to Dashboards
2. Check folders for dashboards
3. Look for "(provisioned)" label on dashboards

**📸 Screenshot: Dashboard with "(provisioned)" label**

**✅ Checkpoint:** Dashboards auto-provisioned

---

## Part 4: Set Up GitOps Workflow (25 min)

### Step 12: Initialize Git Repository

```bash
cd grafana-dashboards
git init
git add .
git commit -m "Initial dashboard commit"
```

**📸 Screenshot: Git repository initialized**

### Step 13: Create CI/CD Pipeline

Create `.gitlab-ci.yml`:
```yaml
stages:
  - validate
  - deploy

validate-dashboards:
  stage: validate
  image: stedolan/jq
  script:
    - |
      for file in dashboards/**/*.json; do
        echo "Validating $file"
        jq empty "$file" || exit 1
      done
  only:
    - merge_requests
    - main

deploy-to-kubernetes:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl delete configmap grafana-dashboards-payments -n monitoring-ebanking --ignore-not-found
    - kubectl create configmap grafana-dashboards-payments --from-file=dashboards/payments/ -n monitoring-ebanking
    
    - kubectl delete configmap grafana-dashboards-retail -n monitoring-ebanking --ignore-not-found
    - kubectl create configmap grafana-dashboards-retail --from-file=dashboards/retail/ -n monitoring-ebanking
    
    - kubectl delete configmap grafana-dashboards-shared -n monitoring-ebanking --ignore-not-found
    - kubectl create configmap grafana-dashboards-shared --from-file=dashboards/shared/ -n monitoring-ebanking
    
    - kubectl rollout restart deployment/grafana -n monitoring-ebanking
  only:
    - main
```

**📸 Screenshot: CI/CD pipeline file**

### Step 14: Create Deployment Script

Create `scripts/deploy-dashboards.sh`:
```bash
#!/bin/bash
set -e

NAMESPACE="monitoring-ebanking"

echo "Deploying dashboard ConfigMaps..."

kubectl create configmap grafana-dashboards-payments \
  --from-file=dashboards/payments/ \
  --dry-run=client -o yaml | kubectl apply -n $NAMESPACE -f -

kubectl create configmap grafana-dashboards-retail \
  --from-file=dashboards/retail/ \
  --dry-run=client -o yaml | kubectl apply -n $NAMESPACE -f -

kubectl create configmap grafana-dashboards-shared \
  --from-file=dashboards/shared/ \
  --dry-run=client -o yaml | kubectl apply -n $NAMESPACE -f -

echo "Restarting Grafana..."
kubectl rollout restart deployment/grafana -n $NAMESPACE
kubectl rollout status deployment/grafana -n $NAMESPACE

echo "✅ Dashboards deployed successfully"
```

Make executable:
```bash
chmod +x scripts/deploy-dashboards.sh
```

**📸 Screenshot: Deployment script**

### Step 15: Test Automated Deployment

1. Make change to a dashboard JSON
2. Commit and push:
```bash
git add payments/transaction-monitoring.json
git commit -m "Update transaction dashboard"
git push origin main
```

3. Watch CI/CD pipeline run (or run script manually)

```bash
./scripts/deploy-dashboards.sh
```

**📸 Screenshot: Script running**

### Step 16: Verify Dashboard Update

In Grafana:
1. Wait 30 seconds (updateIntervalSeconds)
2. Refresh dashboard
3. Verify changes applied

**📸 Screenshot: Updated dashboard in Grafana**

**✅ Final Checkpoint:** GitOps workflow functional

---

## Workshop Complete! 🎉

You have successfully:
- ✅ Exported dashboards to JSON
- ✅ Created provisioning ConfigMaps
- ✅ Updated Grafana deployment
- ✅ Verified auto-provisioning
- ✅ Set up GitOps workflow
- ✅ Automated dashboard deployment

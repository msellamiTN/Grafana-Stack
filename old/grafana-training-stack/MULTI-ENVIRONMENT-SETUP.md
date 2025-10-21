# 🌍 Multi-Environment Simulation Setup

## Overview

This guide shows how to run multiple eBanking exporters simultaneously, each simulating a different environment (Production, Staging, Development, Training) for comprehensive multi-environment monitoring training.

---

## 🎯 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Prometheus                            │
│              (Scrapes all environments)                  │
└─────────────────────────────────────────────────────────┘
         │              │              │              │
         ▼              ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Production   │ │   Staging    │ │ Development  │ │   Training   │
│  Port 9201   │ │  Port 9202   │ │  Port 9203   │ │  Port 9200   │
│ environment= │ │ environment= │ │ environment= │ │ environment= │
│ "production" │ │  "staging"   │ │"development" │ │  "training"  │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
```

---

## 🚀 Quick Start

### **Option 1: Run All Environments (Recommended for Training)**

```bash
cd "d:\Data2AI Academy\Grafana\grafana-training-stack"

# Start main stack first
docker-compose up -d

# Start multi-environment exporters
docker-compose -f docker-compose.multi-env.yml up -d

# Verify all environments are running
docker-compose -f docker-compose.multi-env.yml ps
```

### **Option 2: Run Single Environment**

```bash
# Start only production environment
docker-compose -f docker-compose.multi-env.yml up -d ebanking-exporter-production

# Start only staging environment
docker-compose -f docker-compose.multi-env.yml up -d ebanking-exporter-staging
```

---

## 📊 Environment Details

### **1. Production Environment**

| Property | Value |
|----------|-------|
| **Port** | 9201 |
| **Container** | ebanking-exporter-production |
| **Environment** | production |
| **Cluster** | production-cluster |
| **Metrics URL** | http://localhost:9201/metrics |

**Characteristics**:
- Highest transaction volume
- Strictest SLAs
- Critical alerts
- 24/7 monitoring

**Query Example**:
```promql
ebanking_transactions_processed_total{environment="production"}
```

### **2. Staging Environment**

| Property | Value |
|----------|-------|
| **Port** | 9202 |
| **Container** | ebanking-exporter-staging |
| **Environment** | staging |
| **Cluster** | staging-cluster |
| **Metrics URL** | http://localhost:9202/metrics |

**Characteristics**:
- Pre-production testing
- Similar to production load
- Escalated alerts
- Performance testing

**Query Example**:
```promql
ebanking_transactions_processed_total{environment="staging"}
```

### **3. Development Environment**

| Property | Value |
|----------|-------|
| **Port** | 9203 |
| **Container** | ebanking-exporter-development |
| **Environment** | development |
| **Cluster** | development-cluster |
| **Metrics URL** | http://localhost:9203/metrics |

**Characteristics**:
- Active development
- Lower transaction volume
- Team notifications
- Feature testing

**Query Example**:
```promql
ebanking_transactions_processed_total{environment="development"}
```

### **4. Training Environment**

| Property | Value |
|----------|-------|
| **Port** | 9200 |
| **Container** | ebanking-exporter-training |
| **Environment** | training |
| **Cluster** | training-cluster |
| **Metrics URL** | http://localhost:9200/metrics |

**Characteristics**:
- Training/demo purposes
- Consistent data
- Low priority alerts
- Learning environment

**Query Example**:
```promql
ebanking_transactions_processed_total{environment="training"}
```

---

## 📈 Prometheus Queries

### **View All Environments**

```promql
# All transactions across all environments
ebanking_transactions_processed_total

# Group by environment
sum by (environment) (ebanking_transactions_processed_total)

# Transaction rate per environment
sum by (environment) (rate(ebanking_transactions_processed_total[5m]))
```

### **Compare Environments**

```promql
# Compare production vs staging
ebanking_active_sessions{environment=~"production|staging"}

# Error rate comparison
sum by (environment) (rate(ebanking_api_errors_total[5m]))

# Top environment by transaction volume
topk(1, sum by (environment) (rate(ebanking_transactions_processed_total[5m])))
```

### **Environment-Specific Queries**

```promql
# Production only
ebanking_transactions_processed_total{environment="production"}

# Non-production environments
ebanking_transactions_processed_total{environment!="production"}

# Development and staging
ebanking_transactions_processed_total{environment=~"development|staging"}
```

---

## 🎨 Grafana Dashboard Setup

### **1. Create Multi-Environment Dashboard**

**Dashboard Variables**:

```json
{
  "name": "environment",
  "type": "query",
  "query": "label_values(ebanking_transactions_processed_total, environment)",
  "multi": true,
  "includeAll": true,
  "current": {
    "text": "All",
    "value": "$__all"
  }
}
```

**Panel Query**:
```promql
sum by (environment) (rate(ebanking_transactions_processed_total{environment=~"$environment"}[5m]))
```

### **2. Environment Comparison Dashboard**

**Panels**:
1. **Transaction Volume by Environment** (Time Series)
   ```promql
   sum by (environment) (rate(ebanking_transactions_processed_total[5m]))
   ```

2. **Error Rate by Environment** (Bar Chart)
   ```promql
   sum by (environment) (rate(ebanking_api_errors_total[5m]))
   ```

3. **Active Sessions by Environment** (Gauge)
   ```promql
   ebanking_active_sessions
   ```

4. **Environment Health** (Stat)
   ```promql
   up{job="ebanking"}
   ```

---

## 🔔 Alert Rules

### **Environment-Specific Alerts**

```yaml
groups:
  - name: ebanking_multi_env_alerts
    rules:
      # Production - Critical alerts
      - alert: ProductionHighErrorRate
        expr: |
          (
            sum(rate(ebanking_api_errors_total{environment="production",severity="high"}[5m]))
            /
            sum(rate(ebanking_api_requests_total{environment="production"}[5m]))
          ) > 0.01
        for: 2m
        labels:
          severity: critical
          environment: production
        annotations:
          summary: "CRITICAL: High error rate in PRODUCTION"
          description: "Production error rate is {{ $value | humanizePercentage }}"
      
      # Staging - Warning alerts
      - alert: StagingHighErrorRate
        expr: |
          (
            sum(rate(ebanking_api_errors_total{environment="staging",severity="high"}[5m]))
            /
            sum(rate(ebanking_api_requests_total{environment="staging"}[5m]))
          ) > 0.05
        for: 5m
        labels:
          severity: warning
          environment: staging
        annotations:
          summary: "Warning: High error rate in STAGING"
          description: "Staging error rate is {{ $value | humanizePercentage }}"
      
      # Development - Info alerts
      - alert: DevelopmentHighErrorRate
        expr: |
          (
            sum(rate(ebanking_api_errors_total{environment="development",severity="high"}[5m]))
            /
            sum(rate(ebanking_api_requests_total{environment="development"}[5m]))
          ) > 0.10
        for: 10m
        labels:
          severity: info
          environment: development
        annotations:
          summary: "Info: High error rate in DEVELOPMENT"
          description: "Development error rate is {{ $value | humanizePercentage }}"
      
      # Cross-environment comparison
      - alert: EnvironmentDivergence
        expr: |
          abs(
            sum by (environment) (rate(ebanking_transactions_processed_total{environment="production"}[5m]))
            -
            sum by (environment) (rate(ebanking_transactions_processed_total{environment="staging"}[5m]))
          ) > 100
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Production and Staging metrics diverging"
          description: "Transaction rate difference: {{ $value }}"
```

---

## 🔧 Management Commands

### **Start/Stop Environments**

```bash
# Start all environments
docker-compose -f docker-compose.multi-env.yml up -d

# Stop all environments
docker-compose -f docker-compose.multi-env.yml down

# Restart specific environment
docker-compose -f docker-compose.multi-env.yml restart ebanking-exporter-production

# View logs for specific environment
docker-compose -f docker-compose.multi-env.yml logs -f ebanking-exporter-production
```

### **Check Status**

```bash
# Check all environment containers
docker-compose -f docker-compose.multi-env.yml ps

# Check metrics from each environment
curl http://localhost:9200/metrics | grep environment  # Training
curl http://localhost:9201/metrics | grep environment  # Production
curl http://localhost:9202/metrics | grep environment  # Staging
curl http://localhost:9203/metrics | grep environment  # Development
```

### **Resource Usage**

```bash
# Check resource usage per environment
docker stats ebanking-exporter-production ebanking-exporter-staging ebanking-exporter-development ebanking-exporter-training
```

---

## 🎓 Training Scenarios

### **Scenario 1: Environment Comparison**

**Objective**: Compare metrics across environments

**Steps**:
1. Start all environments
2. Create dashboard with environment variable
3. Compare transaction rates
4. Identify differences

**Queries**:
```promql
# Transaction rate by environment
sum by (environment) (rate(ebanking_transactions_processed_total[5m]))

# Error rate comparison
sum by (environment) (rate(ebanking_api_errors_total[5m])) 
/ 
sum by (environment) (rate(ebanking_api_requests_total[5m]))
```

### **Scenario 2: Production vs Staging**

**Objective**: Validate staging matches production

**Steps**:
1. Monitor production metrics
2. Compare with staging
3. Identify discrepancies
4. Set up divergence alerts

**Queries**:
```promql
# Production transactions
sum(rate(ebanking_transactions_processed_total{environment="production"}[5m]))

# Staging transactions
sum(rate(ebanking_transactions_processed_total{environment="staging"}[5m]))

# Difference
abs(
  sum(rate(ebanking_transactions_processed_total{environment="production"}[5m]))
  -
  sum(rate(ebanking_transactions_processed_total{environment="staging"}[5m]))
)
```

### **Scenario 3: Dynamic Alert Routing**

**Objective**: Configure environment-specific alert routing

**Steps**:
1. Create alert rules for each environment
2. Configure Alertmanager routes
3. Test alerts per environment
4. Verify routing

**Alertmanager Config**:
```yaml
route:
  receiver: 'default'
  routes:
    - match:
        environment: production
      receiver: 'pagerduty-critical'
    - match:
        environment: staging
      receiver: 'slack-ops'
    - match:
        environment: development
      receiver: 'slack-dev'
    - match:
        environment: training
      receiver: 'email-training'
```

### **Scenario 4: Environment Promotion**

**Objective**: Simulate promoting code through environments

**Steps**:
1. Monitor development metrics
2. Promote to staging
3. Compare staging vs development
4. Validate before production
5. Monitor production deployment

---

## 📊 Expected Metrics

### **Per Environment**

Each environment exposes:
- **15+ metric types** with environment label
- **Transaction metrics** (volume, amount, status)
- **Session metrics** (active, duration)
- **API metrics** (requests, latency, errors)
- **Business metrics** (revenue, satisfaction)

### **Total Metrics**

With 4 environments running:
- **60+ unique metric series**
- **4x data points** for comparison
- **Cross-environment analysis** capabilities

---

## 🔍 Troubleshooting

### **Environment Not Starting**

```bash
# Check logs
docker-compose -f docker-compose.multi-env.yml logs ebanking-exporter-production

# Verify port not in use
netstat -ano | findstr :9201

# Rebuild if needed
docker-compose -f docker-compose.multi-env.yml build ebanking-exporter-production
docker-compose -f docker-compose.multi-env.yml up -d ebanking-exporter-production
```

### **Metrics Not Showing**

```bash
# Test metrics endpoint
curl http://localhost:9201/metrics

# Check Prometheus targets
# Go to http://localhost:9090/targets

# Verify environment label
curl http://localhost:9201/metrics | grep 'environment="production"'
```

### **High Resource Usage**

```bash
# Stop non-essential environments
docker-compose -f docker-compose.multi-env.yml stop ebanking-exporter-development

# Or run only specific environments
docker-compose -f docker-compose.multi-env.yml up -d ebanking-exporter-production ebanking-exporter-staging
```

---

## 💡 Best Practices

### **1. Resource Management**
- Run only needed environments
- Monitor resource usage
- Scale based on requirements

### **2. Alert Configuration**
- Different thresholds per environment
- Environment-specific routing
- Escalation policies

### **3. Dashboard Organization**
- Separate dashboards per environment
- Comparison dashboards
- Environment selector variables

### **4. Monitoring Strategy**
- Production: Real-time, critical alerts
- Staging: Pre-production validation
- Development: Team notifications
- Training: Learning and demos

---

## 🎉 Summary

### **What You Get**

✅ **4 Environments** running simultaneously  
✅ **Production** simulation (Port 9201)  
✅ **Staging** simulation (Port 9202)  
✅ **Development** simulation (Port 9203)  
✅ **Training** environment (Port 9200)  
✅ **Multi-environment** Prometheus scraping  
✅ **Environment-specific** alert routing  
✅ **Cross-environment** comparison capabilities  

### **Training Value**

⭐ **Real-world** multi-environment setup  
⭐ **Production-like** monitoring scenarios  
⭐ **Alert routing** best practices  
⭐ **Environment promotion** workflows  
⭐ **Comparison** and validation techniques  

---

**Status**: ✅ **READY FOR MULTI-ENVIRONMENT TRAINING**  
**Environments**: 4 (Production, Staging, Development, Training)  
**Total Ports**: 9200-9203  

---

**Created by**: Data2AI Academy  
**Date**: October 21, 2024  
**License**: Educational Use

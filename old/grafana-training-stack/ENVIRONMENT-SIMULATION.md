# 🎭 Environment-Specific Simulation

## Overview

The eBanking exporter now simulates realistic, environment-specific behavior for Production, Staging, Development, and Training environments with different characteristics, volumes, and error rates.

---

## 🌍 Environment Profiles

### **Production Environment** 🏭

**Characteristics**:
- **Volume**: 5x multiplier (highest)
- **Success Rate**: 97% (strictest SLAs)
- **Error Rate**: 1% (lowest)
- **Fraud Rate**: 0.5% (lowest)
- **Revenue**: $250,000/day
- **Sessions**: 500 base (peak: 1,500)
- **Customer Satisfaction**: 92-98%

**Behavior**:
- High transaction volume
- Very low error rates
- Fewer critical errors (2% of errors)
- More critical fraud alerts (15% of alerts)
- Highest customer satisfaction
- Strict performance requirements

**Use Case**: Production monitoring, SLA tracking, critical alerting

---

### **Staging Environment** 🧪

**Characteristics**:
- **Volume**: 3x multiplier (medium-high)
- **Success Rate**: 94% (pre-production)
- **Error Rate**: 3% (slightly elevated)
- **Fraud Rate**: 1% (medium)
- **Revenue**: $150,000/day
- **Sessions**: 300 base (peak: 900)
- **Customer Satisfaction**: 88-96%

**Behavior**:
- Medium-high transaction volume
- Slightly higher error rates for testing
- Moderate critical errors (5% of errors)
- Balanced fraud alert severity
- Similar to production but with testing scenarios
- Pre-production validation

**Use Case**: Pre-production testing, deployment validation, performance testing

---

### **Development Environment** 💻

**Characteristics**:
- **Volume**: 1.5x multiplier (low)
- **Success Rate**: 88% (active development)
- **Error Rate**: 8% (highest - testing)
- **Fraud Rate**: 2% (highest - testing)
- **Revenue**: $75,000/day
- **Sessions**: 150 base (peak: 450)
- **Customer Satisfaction**: 80-92%

**Behavior**:
- Low transaction volume
- High error rates (active development/testing)
- More critical errors (10% of errors)
- More error scenarios for debugging
- Lower customer satisfaction (testing phase)
- Feature testing and debugging

**Use Case**: Development testing, debugging, feature validation

---

### **Training Environment** 🎓

**Characteristics**:
- **Volume**: 2x multiplier (balanced)
- **Success Rate**: 90% (balanced)
- **Error Rate**: 5% (balanced)
- **Fraud Rate**: 1.5% (balanced)
- **Revenue**: $100,000/day
- **Sessions**: 200 base (peak: 600)
- **Customer Satisfaction**: 85-95%

**Behavior**:
- Balanced transaction volume
- Moderate error rates
- Balanced error severity
- Consistent for learning
- Representative of real-world scenarios
- Educational purposes

**Use Case**: Training, demonstrations, learning scenarios

---

## 📊 Comparison Table

| Metric | Production | Staging | Development | Training |
|--------|-----------|---------|-------------|----------|
| **Transaction Volume** | 5x (Highest) | 3x (High) | 1.5x (Low) | 2x (Medium) |
| **Success Rate** | 97% | 94% | 88% | 90% |
| **Error Rate** | 1% | 3% | 8% | 5% |
| **Fraud Rate** | 0.5% | 1% | 2% | 1.5% |
| **Critical Errors** | 2% | 5% | 10% | 5% |
| **Critical Fraud** | 15% | 5% | 5% | 5% |
| **Daily Revenue** | $250K | $150K | $75K | $100K |
| **Base Sessions** | 500 | 300 | 150 | 200 |
| **Peak Sessions** | 1,500 | 900 | 450 | 600 |
| **Satisfaction** | 92-98% | 88-96% | 80-92% | 85-95% |

---

## 🎯 Query Examples

### **Compare Transaction Volumes**

```promql
# Transaction rate by environment
sum by (environment) (rate(ebanking_transactions_processed_total[5m]))

# Expected results (approximate):
# production: ~25 tps (5x multiplier)
# staging: ~15 tps (3x multiplier)
# development: ~7.5 tps (1.5x multiplier)
# training: ~10 tps (2x multiplier)
```

### **Compare Error Rates**

```promql
# Error rate by environment
sum by (environment) (rate(ebanking_api_errors_total[5m]))
/ 
sum by (environment) (rate(ebanking_api_requests_total[5m]))

# Expected results:
# production: ~1%
# staging: ~3%
# development: ~8%
# training: ~5%
```

### **Compare Success Rates**

```promql
# Success rate by environment
sum by (environment) (rate(ebanking_transactions_processed_total{status="success"}[5m]))
/
sum by (environment) (rate(ebanking_transactions_processed_total[5m]))

# Expected results:
# production: ~97%
# staging: ~94%
# development: ~88%
# training: ~90%
```

### **Compare Revenue**

```promql
# Daily revenue by environment
ebanking_daily_revenue_eur

# Expected results (approximate):
# production: ~$250,000
# staging: ~$150,000
# development: ~$75,000
# training: ~$100,000
```

### **Compare Customer Satisfaction**

```promql
# Customer satisfaction by environment
ebanking_customer_satisfaction_score

# Expected results:
# production: 92-98
# staging: 88-96
# development: 80-92
# training: 85-95
```

---

## 🔔 Environment-Specific Alerts

### **Production Alerts** (Critical)

```yaml
- alert: ProductionHighErrorRate
  expr: |
    (
      sum(rate(ebanking_api_errors_total{environment="production"}[5m]))
      /
      sum(rate(ebanking_api_requests_total{environment="production"}[5m]))
    ) > 0.02  # Alert if > 2% (double the normal 1%)
  for: 2m
  labels:
    severity: critical
    environment: production
  annotations:
    summary: "CRITICAL: Production error rate exceeded"
    description: "Production error rate is {{ $value | humanizePercentage }}"

- alert: ProductionLowSuccessRate
  expr: |
    (
      sum(rate(ebanking_transactions_processed_total{environment="production",status="success"}[5m]))
      /
      sum(rate(ebanking_transactions_processed_total{environment="production"}[5m]))
    ) < 0.95  # Alert if < 95% (below normal 97%)
  for: 5m
  labels:
    severity: critical
    environment: production
```

### **Staging Alerts** (Warning)

```yaml
- alert: StagingHighErrorRate
  expr: |
    (
      sum(rate(ebanking_api_errors_total{environment="staging"}[5m]))
      /
      sum(rate(ebanking_api_requests_total{environment="staging"}[5m]))
    ) > 0.05  # Alert if > 5% (above normal 3%)
  for: 5m
  labels:
    severity: warning
    environment: staging
```

### **Development Alerts** (Info)

```yaml
- alert: DevelopmentVeryHighErrorRate
  expr: |
    (
      sum(rate(ebanking_api_errors_total{environment="development"}[5m]))
      /
      sum(rate(ebanking_api_requests_total{environment="development"}[5m]))
    ) > 0.15  # Alert if > 15% (above normal 8%)
  for: 10m
  labels:
    severity: info
    environment: development
```

---

## 🎓 Training Scenarios

### **Scenario 1: Identify Production Issues**

**Objective**: Detect when production deviates from normal

**Steps**:
1. Observe normal production metrics (97% success, 1% errors)
2. Simulate an issue (if error rate > 2%)
3. Create alert for production degradation
4. Validate alert fires correctly

**Query**:
```promql
# Production success rate
sum(rate(ebanking_transactions_processed_total{environment="production",status="success"}[5m]))
/
sum(rate(ebanking_transactions_processed_total{environment="production"}[5m]))
```

### **Scenario 2: Staging vs Production Comparison**

**Objective**: Validate staging matches production behavior

**Steps**:
1. Compare transaction rates
2. Compare error rates
3. Identify discrepancies
4. Set acceptable deviation thresholds

**Query**:
```promql
# Compare transaction rates
sum by (environment) (rate(ebanking_transactions_processed_total{environment=~"production|staging"}[5m]))

# Calculate difference
abs(
  sum(rate(ebanking_transactions_processed_total{environment="production"}[5m]))
  -
  sum(rate(ebanking_transactions_processed_total{environment="staging"}[5m]))
)
```

### **Scenario 3: Development Testing Validation**

**Objective**: Monitor development environment during testing

**Steps**:
1. Observe higher error rates (8%)
2. Validate error types and severity
3. Ensure errors are expected (testing)
4. Track error resolution

**Query**:
```promql
# Development error breakdown
sum by (error_type, severity) (rate(ebanking_api_errors_total{environment="development"}[5m]))
```

### **Scenario 4: Environment Promotion**

**Objective**: Track metrics through environment promotion

**Steps**:
1. Monitor development metrics
2. Promote to staging
3. Compare staging vs development
4. Validate improvements
5. Promote to production
6. Monitor production metrics

**Queries**:
```promql
# Development metrics
sum(rate(ebanking_transactions_processed_total{environment="development"}[5m]))

# After promotion to staging
sum(rate(ebanking_transactions_processed_total{environment="staging"}[5m]))

# After promotion to production
sum(rate(ebanking_transactions_processed_total{environment="production"}[5m]))
```

---

## 📈 Expected Behavior

### **Transaction Volume Over Time**

```
Production:   ████████████████████████████████████ (5x)
Staging:      ████████████████████ (3x)
Training:     █████████████ (2x)
Development:  ████████ (1.5x)
```

### **Error Rate Distribution**

```
Development:  ████████ (8%)
Training:     █████ (5%)
Staging:      ███ (3%)
Production:   █ (1%)
```

### **Success Rate**

```
Production:   ████████████████████████████████████████ (97%)
Staging:      ██████████████████████████████████████ (94%)
Training:     ████████████████████████████████████ (90%)
Development:  ██████████████████████████████████ (88%)
```

---

## 🔍 Validation

### **Check Environment Configuration**

```bash
# Production
curl http://localhost:9201/metrics | grep 'environment="production"'

# Staging
curl http://localhost:9202/metrics | grep 'environment="staging"'

# Development
curl http://localhost:9203/metrics | grep 'environment="development"'

# Training
curl http://localhost:9200/metrics | grep 'environment="training"'
```

### **Verify Transaction Rates**

```promql
# Should show different rates per environment
sum by (environment) (rate(ebanking_transactions_processed_total[1m]))
```

### **Verify Error Rates**

```promql
# Should show: production < staging < training < development
sum by (environment) (rate(ebanking_api_errors_total[1m]))
```

---

## 💡 Best Practices

### **1. Alert Thresholds**
- Set environment-specific thresholds
- Production: Strict (low tolerance)
- Staging: Moderate (testing tolerance)
- Development: Relaxed (high tolerance)

### **2. Monitoring Strategy**
- Production: Real-time, 24/7
- Staging: Business hours, pre-deployment
- Development: On-demand, during testing
- Training: Educational, consistent

### **3. Dashboard Organization**
- Separate dashboards per environment
- Comparison dashboards for validation
- Environment selector for flexibility

### **4. Resource Allocation**
- Production: Highest priority
- Staging: Medium priority
- Development: Low priority
- Training: Consistent for learning

---

## 🎉 Summary

### **What You Get**

✅ **4 Distinct Environments** with unique characteristics  
✅ **Realistic Behavior** matching real-world scenarios  
✅ **Volume Differences** (1.5x to 5x multipliers)  
✅ **Error Rate Variations** (1% to 8%)  
✅ **Success Rate Differences** (88% to 97%)  
✅ **Revenue Variations** ($75K to $250K)  
✅ **Customer Satisfaction Ranges** (80-98%)  
✅ **Environment-Specific Alerts** with appropriate thresholds  

### **Training Value**

⭐ **Real-world** environment differences  
⭐ **Production-like** monitoring scenarios  
⭐ **Comparison** techniques  
⭐ **Alert tuning** best practices  
⭐ **Environment promotion** workflows  

---

**Status**: ✅ **ENVIRONMENT SIMULATION COMPLETE**  
**Environments**: 4 with distinct behaviors  
**Realism**: ⭐⭐⭐⭐⭐  

---

**Created by**: Data2AI Academy  
**Date**: October 21, 2024  
**License**: Educational Use

# eBanking Metrics Exporter

## Overview

A Prometheus metrics exporter that simulates realistic eBanking application metrics for training purposes.

## Features

### **Transaction Metrics**
- Transaction processing (transfer, payment, withdrawal, deposit, bill payment)
- Transaction amounts and distributions
- Multi-channel support (web, mobile, ATM, branch)
- Success/failure tracking

### **Session Metrics**
- Active user sessions
- Session duration tracking
- Time-of-day variations

### **Account Metrics**
- Account balances by currency and type
- Active account counts
- Multi-currency support (EUR, USD, GBP, CHF)

### **API Performance**
- Request duration by endpoint
- HTTP status code tracking
- Method-based metrics (GET, POST, PUT, DELETE)

### **Authentication**
- Login attempt tracking
- Failed login reasons
- Multi-factor authentication methods

### **Error & Fraud Detection**
- API error tracking by type and severity
- Fraud alert simulation
- Real-time anomaly detection

### **Database Metrics**
- Connection pool monitoring
- Query duration tracking
- Multi-pool support

### **Business Metrics**
- Daily revenue tracking
- Customer satisfaction scores

## Metrics Exposed

All metrics are available at `http://localhost:9200/metrics`

### **Key Metrics**

```promql
# Transactions
ebanking_transactions_processed_total{transaction_type, status, channel}
ebanking_transaction_amount_eur{transaction_type}

# Sessions
ebanking_active_sessions
ebanking_session_duration_seconds

# Accounts
ebanking_account_balance_total{currency, account_type}
ebanking_active_accounts_total{account_type}

# API Performance
ebanking_request_duration_seconds{endpoint, method}
ebanking_api_requests_total{endpoint, method, status_code}

# Authentication
ebanking_login_attempts_total{status, method}
ebanking_failed_login_attempts_total{reason}

# Errors & Fraud
ebanking_api_errors_total{error_type, severity}
ebanking_fraud_alerts_total{alert_type, severity}

# Database
ebanking_database_connections{pool}
ebanking_database_query_duration_seconds{query_type}

# Business
ebanking_daily_revenue_eur
ebanking_customer_satisfaction_score
```

## Usage

### **Standalone**

```bash
# Install dependencies
pip install -r requirements.txt

# Run exporter
python main.py
```

### **Docker**

```bash
# Build image
docker build -t ebanking-exporter .

# Run container
docker run -p 9200:9200 ebanking-exporter
```

### **Docker Compose** (Included in stack)

```bash
docker-compose up -d ebanking-exporter
```

## Example Queries

### **Transaction Rate**

```promql
# Transactions per second
rate(ebanking_transactions_processed_total[5m])

# Success rate
sum(rate(ebanking_transactions_processed_total{status="success"}[5m]))
/ sum(rate(ebanking_transactions_processed_total[5m]))
```

### **API Performance**

```promql
# 95th percentile response time
histogram_quantile(0.95, 
  rate(ebanking_request_duration_seconds_bucket[5m])
)

# Error rate
sum(rate(ebanking_api_requests_total{status_code=~"5.."}[5m]))
/ sum(rate(ebanking_api_requests_total[5m]))
```

### **Fraud Detection**

```promql
# Fraud alerts per minute
rate(ebanking_fraud_alerts_total[1m]) * 60

# Critical fraud alerts
ebanking_fraud_alerts_total{severity="critical"}
```

## Training Use Cases

### **Module 2: Data Source Integration**
- Learn PromQL queries
- Understand metric types (Counter, Gauge, Histogram)
- Practice label filtering

### **Module 3: Best Practices**
- Dashboard design with real metrics
- Alert rule creation
- Performance optimization

### **Module 5: Advanced Templating**
- Dynamic dashboards with variables
- Multi-dimensional data exploration
- Business intelligence dashboards

## Configuration

The exporter simulates realistic patterns:
- **Success Rate**: 90% (configurable via weights)
- **Peak Hours**: Simulated time-of-day variations
- **Error Rate**: 3% API errors, 1% fraud alerts
- **Update Frequency**: 0.5-2 seconds per iteration

## Architecture

```
┌─────────────────────────────────────┐
│   eBanking Metrics Exporter         │
│   (Python + prometheus_client)      │
└─────────────────────────────────────┘
                 │
                 │ HTTP :9200/metrics
                 ▼
┌─────────────────────────────────────┐
│         Prometheus                   │
│      (Scrapes every 15s)            │
└─────────────────────────────────────┘
                 │
                 │ PromQL Queries
                 ▼
┌─────────────────────────────────────┐
│           Grafana                    │
│    (Visualizes metrics)             │
└─────────────────────────────────────┘
```

## Development

### **Adding New Metrics**

```python
# Define metric
new_metric = Counter(
    'ebanking_new_metric_total',
    'Description of new metric',
    ['label1', 'label2']
)

# Update in simulation loop
new_metric.labels(label1='value1', label2='value2').inc()
```

### **Adjusting Simulation**

Edit `simulate_realistic_metrics()` function to:
- Change transaction types
- Adjust success/failure rates
- Modify time-of-day patterns
- Add new business logic

## Troubleshooting

### **Metrics not appearing**

```bash
# Check if exporter is running
curl http://localhost:9200/metrics

# Check Prometheus targets
# Go to: http://localhost:9090/targets
```

### **High resource usage**

Adjust sleep time in `main.py`:
```python
time.sleep(random.uniform(1.0, 3.0))  # Slower updates
```

## License

Educational use - Data2AI Academy

## Version

1.0.0 - Training Version

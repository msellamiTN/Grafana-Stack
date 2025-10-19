# Lab 2: e-Banking Transaction Monitoring

## Objective
Monitor and analyze transaction metrics in real-time using Grafana and Prometheus.

## Prerequisites
- Completed Lab 1: e-Banking Monitoring Setup
- All services running from Lab 1

## Tasks

### 1. Explore Available Metrics

1. Access Prometheus at http://localhost:9090
2. Try these queries:
   ```
   # Transaction rate (per second)
   rate(ebanking_transactions_total[5m])
   
   # Error rate
   rate(ebanking_errors_total[5m])
   
   # Average transaction amount
   rate(ebanking_transaction_amount_sum[5m]) / rate(ebanking_transaction_amount_count[5m])
   ```

### 2. Create a Transaction Dashboard

1. In Grafana, create a new dashboard named "e-Banking Transactions"
2. Add these panels:

   **Panel 1: Transaction Rate**
   - Query: `rate(ebanking_transactions_total[5m])`
   - Visualization: Time series
   - Unit: ops/sec
   
   **Panel 2: Error Rate**
   - Query: `sum by (type) (rate(ebanking_errors_total[5m]))`
   - Visualization: Time series
   - Use color thresholds
   
   **Panel 3: Transaction Amounts**
   - Query: `histogram_quantile(0.95, sum(rate(ebanking_transaction_duration_seconds_bucket[5m])) by (le))`
   - Visualization: Stat
   - Unit: seconds

### 3. Set Up Alerts

1. Create an alert for high error rate:
   ```
   sum(rate(ebanking_errors_total[5m])) / sum(rate(ebanking_transactions_total[5m])) > 0.05
   ```
2. Set severity to "critical"
3. Add notification channel

## Exercises

1. Create a panel showing transaction amount distribution
2. Add a panel for transaction success rate
3. Create an alert for transaction timeouts

## Verification

1. Your dashboard should show real-time transaction data
2. Alerts should trigger based on defined conditions
3. All panels should have proper units and legends

## Troubleshooting

- If data looks incorrect:
  - Check if the ebanking-exporter is running
  - Verify metric names in Prometheus
  - Check for label mismatches in queries

## Next Steps
Proceed to [Lab 3: Log Analysis](./lab3-log-analysis/README.md)

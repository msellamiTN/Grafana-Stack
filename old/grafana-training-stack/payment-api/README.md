# Payment API Mock - Training Version

## Overview

A realistic Payment API mock service that simulates payment processing with Prometheus metrics and InfluxDB integration for training purposes.

## Features

### **Payment Processing**
- RESTful API for payment operations
- Realistic processing simulation (50-800ms)
- 3% failure rate (configurable)
- Multi-currency support (USD, EUR, GBP)
- Customer ID tracking

### **Metrics Export** (Prometheus)
- Payment request counters
- Payment amount histograms
- Processing duration tracking
- Active payment gauge
- Daily revenue tracking
- Failure rate monitoring

### **Data Storage** (InfluxDB)
- Time-series payment data
- Transaction history
- Performance metrics
- Revenue tracking

### **Simulation**
- Automatic traffic generation
- Configurable transaction rate
- Realistic payment patterns
- Multi-currency transactions

## API Endpoints

### **Health Check**
```bash
GET /health
```

Response:
```json
{
  "status": "UP",
  "service": "payment-api",
  "version": "1.0.0",
  "timestamp": "2024-10-21T12:00:00.000Z"
}
```

### **Metrics** (Prometheus)
```bash
GET /metrics
```

### **Process Payment**
```bash
POST /api/payments
Content-Type: application/json

{
  "amount": 100.50,
  "currency": "USD",
  "customerId": "cust_12345",
  "type": "standard"
}
```

Response (Success):
```json
{
  "success": true,
  "paymentId": "pay_abc123xyz",
  "amount": 100.50,
  "currency": "USD",
  "timestamp": "2024-10-21T12:00:00.000Z",
  "processingTime": 0.234,
  "customerId": "cust_12345"
}
```

Response (Failure):
```json
{
  "success": false,
  "error": "Payment processing failed",
  "paymentId": "pay_abc123xyz",
  "amount": 100.50,
  "currency": "USD",
  "timestamp": "2024-10-21T12:00:00.000Z"
}
```

### **Get Payment Stats**
```bash
GET /api/payments/stats
```

Response:
```json
{
  "revenue": {
    "USD": 12345.67,
    "EUR": 8901.23,
    "GBP": 4567.89
  },
  "timestamp": "2024-10-21T12:00:00.000Z"
}
```

### **Get Payment by ID**
```bash
GET /api/payments/:id
```

## Prometheus Metrics

### **Counters**
```promql
# Total payment requests
payment_requests_total{method, status, type, currency}

# Example queries:
# Success rate
sum(rate(payment_requests_total{status="200"}[5m]))
/ sum(rate(payment_requests_total[5m]))

# Requests by currency
sum by (currency) (rate(payment_requests_total[5m]))
```

### **Histograms**
```promql
# Payment amounts
payment_amount{currency, status}

# Processing duration
payment_duration_seconds{status}

# Example queries:
# 95th percentile processing time
histogram_quantile(0.95, rate(payment_duration_seconds_bucket[5m]))

# Average payment amount
rate(payment_amount_sum[5m]) / rate(payment_amount_count[5m])
```

### **Gauges**
```promql
# Active payments being processed
active_payments

# Daily revenue by currency
payment_daily_revenue{currency}

# Failure rate
payment_failure_rate
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | 8080 | API server port |
| `SIMULATION_RATE` | 5 | Transactions per second |
| `INFLUXDB_URL` | http://influxdb:8086 | InfluxDB URL |
| `INFLUXDB_TOKEN` | training-token-change-me | InfluxDB auth token |
| `INFLUXDB_ORG` | data2ai | InfluxDB organization |
| `INFLUXDB_BUCKET` | training | InfluxDB bucket |
| `NODE_ENV` | production | Environment mode |
| `ENABLE_SIMULATION` | true | Enable auto traffic |

## Usage

### **Standalone**

```bash
# Install dependencies
npm install

# Start server
npm start

# Development mode
npm run dev
```

### **Docker**

```bash
# Build image
docker build -t payment-api .

# Run container
docker run -p 8080:8080 \
  -e SIMULATION_RATE=10 \
  -e INFLUXDB_URL=http://influxdb:8086 \
  payment-api
```

### **Docker Compose** (Included in stack)

```bash
docker-compose up -d payment-api
```

## Training Use Cases

### **Module 2: Data Source Integration**
- Query payment metrics from Prometheus
- Visualize payment data from InfluxDB
- Compare metrics vs time-series data

### **Module 3: Best Practices**
- Monitor API performance
- Track payment success rates
- Alert on high failure rates
- Revenue monitoring dashboards

### **Module 5: Advanced Templating**
- Multi-currency dashboards
- Customer segmentation
- Payment type analysis
- Dynamic filtering

## Example Dashboards

### **Payment Overview**
- Total payments processed
- Success/failure rate
- Revenue by currency
- Active payments gauge

### **Performance Monitoring**
- Request rate
- Processing time (p50, p95, p99)
- Error rate
- Throughput

### **Business Intelligence**
- Daily revenue trends
- Currency distribution
- Payment type breakdown
- Customer activity

## Integration with Stack

### **Prometheus Scraping**
Already configured in `prometheus/prometheus.yml`:
```yaml
- job_name: 'payment-api'
  static_configs:
    - targets: ['payment-api:8080']
```

### **InfluxDB Storage**
Automatically writes to InfluxDB `training` bucket with tags:
- `status` (success/failed)
- `currency` (USD/EUR/GBP)
- `customer_id`
- `payment_type`

### **Grafana Visualization**
Create dashboards using:
- **Prometheus datasource** for metrics
- **InfluxDB datasource** for time-series data

## Testing

### **Manual Testing**

```bash
# Process a payment
curl -X POST http://localhost:8080/api/payments \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "currency": "USD", "customerId": "test_001"}'

# Check metrics
curl http://localhost:8080/metrics

# Get stats
curl http://localhost:8080/api/payments/stats
```

### **Automated Simulation (Shell Script)**

The training stack includes a powerful Bash simulation script with multiple traffic patterns.

#### **Make Script Executable**

```bash
chmod +x simulate.sh
```

#### **Basic Usage**

```bash
# Default: 100 requests, normal mode
./simulate.sh

# Custom number of requests
./simulate.sh 500

# Different simulation modes
./simulate.sh 200 burst      # High-speed sequential
./simulate.sh 300 peak       # High concurrent traffic
./simulate.sh 500 stress     # Maximum load
./simulate.sh 200 realistic  # Variable traffic patterns

# Custom concurrency
./simulate.sh 1000 peak 10
```

#### **Simulation Modes**

| Mode | Description | Delay | Use Case |
|------|-------------|-------|----------|
| **normal** | Standard traffic | 1-3s | Regular operations |
| **burst** | High-speed sequential | 0.1s | Traffic spikes |
| **peak** | High concurrent | 0.5s | Peak hours |
| **stress** | Maximum load | 0.01s | Load testing |
| **realistic** | Variable patterns | 0.5-5s | Real-world simulation ⭐ |

#### **Features**

✅ **Realistic Data Generation**:
- Weighted currency distribution (EUR 50%, USD 25%, GBP 15%, CHF 7%, JPY 3%)
- Amount distribution (80% small $10-200, 15% medium $200-1000, 5% large $1000-6000)
- Returning customer simulation (20% repeat customers from pool of 100)
- Multiple payment types (70% standard, 20% express, 10% recurring)

✅ **Comprehensive Statistics**:
- Success/failure rates
- Total transaction amount
- Throughput (requests/second)
- Duration tracking

✅ **Colored Output**:
- Green for successful payments
- Red for failures
- Blue for informational messages
- Yellow for warnings
- Cyan for concurrent batches

#### **Example Output**

```
========================================
🚀 Payment API Simulation
========================================
API URL:          http://localhost:8080
Requests:         100
Mode:             realistic
Max Concurrent:   5
========================================

🔍 Checking API health...
✓ API is healthy

🌍 Running REALISTIC mode (variable traffic patterns)

[1] ✓ Payment pay_abc123xyz | 125.50 EUR | Customer: cust_00042 | 0.234s
[2] ✓ Payment pay_def456uvw | 89.99 USD | Customer: cust_01234 | 0.189s
[Concurrent batch]
[3] ✓ Payment pay_ghi789rst | 450.00 GBP | Customer: cust_00015 | 0.312s
[4] ✓ Payment pay_jkl012mno | 1250.00 USD | Customer: cust_02456 | 0.287s
[5] ✓ Payment pay_pqr345stu | 75.50 EUR | Customer: cust_00089 | 0.198s
...

========================================
📊 Simulation Statistics
========================================
Mode:             realistic
Duration:         125s
Total Requests:   100
Successful:       97
Failed:           3
Success Rate:     97.00%
Total Amount:     $12345.67
Throughput:       0.80 req/s
========================================

✅ Simulation completed!

Usage: ./simulate.sh [num_requests] [mode] [max_concurrent]
Modes: normal, burst, peak, stress, realistic
Example: ./simulate.sh 500 peak 10
```

#### **Advanced Examples**

```bash
# Stress test with high concurrency
./simulate.sh 5000 stress 20

# Realistic day simulation (1000 transactions)
./simulate.sh 1000 realistic 5

# Peak hour simulation
./simulate.sh 2000 peak 15

# Quick burst test
./simulate.sh 100 burst

# Custom API URL
API_URL=http://payment-api:8080 ./simulate.sh 500 realistic
```

#### **Environment Variables**

```bash
# Override API URL
export API_URL=http://localhost:8080

# Run simulation
./simulate.sh 200 realistic
```

### **Load Testing (Alternative)**

```bash
# Using Apache Bench
ab -n 1000 -c 10 -p payment.json -T application/json \
  http://localhost:8080/api/payments
```

## Troubleshooting

### **Service not starting**
```bash
# Check logs
docker-compose logs payment-api

# Verify InfluxDB connection
curl http://localhost:8086/health
```

### **No metrics appearing**
```bash
# Check Prometheus targets
# Go to: http://localhost:9090/targets

# Verify metrics endpoint
curl http://localhost:8080/metrics
```

### **InfluxDB write errors**
```bash
# Check InfluxDB token
docker-compose exec payment-api env | grep INFLUXDB

# Verify bucket exists
# Go to: http://localhost:8086
```

## Architecture

```
┌─────────────────────────────────────┐
│      Payment API Mock               │
│      (Node.js + Express)            │
└─────────────────────────────────────┘
         │                  │
         │ Metrics          │ Data
         ▼                  ▼
┌──────────────┐   ┌──────────────┐
│  Prometheus  │   │   InfluxDB   │
│  (Scrapes)   │   │  (Stores)    │
└──────────────┘   └──────────────┘
         │                  │
         └────────┬─────────┘
                  ▼
         ┌──────────────┐
         │   Grafana    │
         │ (Visualizes) │
         └──────────────┘
```

## License

Educational use - Data2AI Academy

## Version

1.0.0 - Training Version

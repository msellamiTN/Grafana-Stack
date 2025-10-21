# Lab 1: e-Banking Monitoring Setup

## Objective
Set up monitoring for the e-Banking application using the existing observability stack.

## Prerequisites
- Docker and Docker Compose
- Access to the observability-stack repository

## Tasks

### 1. Start the e-Banking Stack

```bash
cd d:\\Data2AI Academy\\Grafana\\observability-stack
docker-compose up -d
```

### 2. Verify Services

Check all services are running:

```bash
docker-compose ps
```

### 3. Access Key Components

1. **Grafana**
   - URL: http://localhost:3000
   - Credentials: admin/GrafanaSecure123!Change@Me

2. **Prometheus**
   - URL: http://localhost:9090
   - Check targets at: http://localhost:9090/targets

3. **e-Banking Exporter**
   - Metrics endpoint: http://localhost:9201/metrics

### 4. Configure Data Sources

In Grafana:
1. Go to Configuration > Data Sources
2. Verify these data sources exist:
   - Prometheus (http://prometheus:9090)
   - Loki (http://loki:3100)
   - InfluxDB (http://influxdb:8086)

## Verification

1. In Grafana, create a new dashboard
2. Add a panel with query:
   ```
   rate(ebanking_transactions_total[5m])
   ```
3. You should see transaction rate data

## Exercises

1. Create a panel showing successful vs failed transactions
2. Add a panel for average transaction amount
3. Create a row showing system metrics (CPU, memory, disk)

## Troubleshooting

- If no data appears:
  - Check if the ebanking-exporter is running
  - Verify Prometheus is scraping the exporter
  - Check logs: `docker-compose logs -f ebanking-exporter`

## Next Steps
Proceed to [Lab 2: Transaction Monitoring](./lab2-transaction-monitoring/README.md)

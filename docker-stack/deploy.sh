# Create required directories
mkdir -p prometheus/rules
mkdir -p alertmanager/{templates}
mkdir -p loki
mkdir -p promtail
mkdir -p telegraf
mkdir -p grafana/{provisioning/{dashboards,datasources,alerting},custom-dashboards}
mkdir -p postgresql
mkdir -p nginx/{ssl,conf.d}
mkdir -p vault/{config,data}
mkdir -p mssql/{data,scripts,backup}
mkdir -p ebanking-exporter
mkdir -p auth-service
mkdir -p transaction-service
mkdir -p kpi-service

# Start the stack
docker-compose up -d

# Check logs
docker-compose logs -f grafana
docker-compose logs -f prometheus
docker-compose logs -f elasticsearch

# Access services
# Grafana: https://localhost:3000 (admin/Grafana.OddoBhf@Secure123)
# Prometheus: http://localhost:9090
# Jaeger: http://localhost:16686
# Elasticsearch: http://localhost:9200
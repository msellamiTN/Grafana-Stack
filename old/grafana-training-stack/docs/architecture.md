# 🏗️ Architecture Overview - Grafana Training Stack

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Grafana Training Stack                       │
│                        Data2AI Academy                           │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    Presentation Layer                             │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Grafana OSS (Port 3000)                     │   │
│  │  • Dashboards & Visualizations                          │   │
│  │  • User Management & RBAC                               │   │
│  │  • Alerting & Notifications                             │   │
│  │  • Data Source Management                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                     Data Layer                                    │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Prometheus  │  │     Loki     │  │    Tempo     │          │
│  │   (Metrics)  │  │    (Logs)    │  │   (Traces)   │          │
│  │  Port: 9090  │  │  Port: 3100  │  │  Port: 3200  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐                             │
│  │   InfluxDB   │  │  PostgreSQL  │                             │
│  │ (Time-Series)│  │  (Backend)   │                             │
│  │  Port: 8086  │  │  Port: 5432  │                             │
│  └──────────────┘  └──────────────┘                             │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                   Collection Layer                                │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │     Node     │  │   cAdvisor   │  │   Promtail   │          │
│  │   Exporter   │  │ (Containers) │  │    (Logs)    │          │
│  │  Port: 9100  │  │  Port: 8080  │  │  Port: 9080  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                   Support Services                                │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐                             │
│  │ Alertmanager │  │    Redis     │                             │
│  │   (Alerts)   │  │   (Cache)    │                             │
│  │  Port: 9093  │  │  Port: 6379  │                             │
│  └──────────────┘  └──────────────┘                             │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Component Details

### **1. Grafana OSS**

**Purpose**: Visualization and dashboard platform

**Key Features**:
- Multi-data source support
- Rich visualization library
- Alerting and notifications
- User management and RBAC
- Dashboard provisioning
- Plugin ecosystem

**Configuration**:
- Backend: PostgreSQL
- Session storage: Redis
- Provisioning: Auto-configured
- Authentication: Local (extensible to LDAP/OAuth)

**Ports**:
- 3000: HTTP interface

---

### **2. Prometheus**

**Purpose**: Metrics collection and storage

**Key Features**:
- Pull-based metrics collection
- PromQL query language
- Time-series database
- Service discovery
- Alert rule evaluation

**Scrape Targets**:
- Prometheus itself
- Grafana
- Node Exporter
- cAdvisor
- Alertmanager
- Loki
- Tempo

**Ports**:
- 9090: HTTP API and UI

**Retention**: 30 days (configurable)

---

### **3. Loki**

**Purpose**: Log aggregation and querying

**Key Features**:
- LogQL query language
- Label-based indexing
- Cost-effective log storage
- Integration with Promtail
- Grafana native integration

**Storage**: Local filesystem (BoltDB + filesystem)

**Ports**:
- 3100: HTTP API

**Retention**: 31 days (744 hours)

---

### **4. Tempo**

**Purpose**: Distributed tracing

**Key Features**:
- OTLP, Jaeger, Zipkin support
- Trace-to-metrics correlation
- Trace-to-logs correlation
- Service graph generation
- Span metrics

**Protocols**:
- OTLP (gRPC: 4317, HTTP: 4318)
- Jaeger
- Zipkin
- OpenCensus

**Ports**:
- 3200: HTTP API
- 4317: OTLP gRPC
- 4318: OTLP HTTP

**Retention**: 30 days (720 hours)

---

### **5. InfluxDB**

**Purpose**: Time-series database

**Key Features**:
- Flux query language
- High write throughput
- Downsampling and retention policies
- Built-in UI
- Native Grafana support

**Ports**:
- 8086: HTTP API and UI

**Organization**: data2ai
**Bucket**: training
**Retention**: 30 days

---

### **6. PostgreSQL**

**Purpose**: Grafana backend database

**Key Features**:
- Stores dashboards
- User management
- Permissions and settings
- Annotations
- Alerts

**Database**: grafana
**Version**: 15

**Ports**:
- 5432: PostgreSQL protocol

---

### **7. Redis**

**Purpose**: Session storage and caching

**Key Features**:
- Fast in-memory storage
- Session persistence
- Cache layer
- Pub/sub capabilities

**Ports**:
- 6379: Redis protocol

---

### **8. Alertmanager**

**Purpose**: Alert management and routing

**Key Features**:
- Alert deduplication
- Grouping and routing
- Silencing
- Inhibition rules
- Multiple notification channels

**Ports**:
- 9093: HTTP API and UI

---

### **9. Node Exporter**

**Purpose**: System metrics collection

**Metrics**:
- CPU usage
- Memory usage
- Disk I/O
- Network statistics
- Filesystem metrics

**Ports**:
- 9100: Metrics endpoint

---

### **10. cAdvisor**

**Purpose**: Container metrics collection

**Metrics**:
- Container CPU usage
- Container memory usage
- Container network I/O
- Container filesystem usage

**Ports**:
- 8080: HTTP UI and metrics

---

### **11. Promtail**

**Purpose**: Log collection for Loki

**Sources**:
- Docker container logs
- System logs (/var/log)
- Application logs

**Ports**:
- 9080: HTTP API

---

## Data Flow

### **Metrics Flow**

```
System/Containers
      ↓
Node Exporter / cAdvisor
      ↓
Prometheus (scrape)
      ↓
Grafana (query via PromQL)
      ↓
Dashboard Visualization
```

### **Logs Flow**

```
Containers / System
      ↓
Promtail (collect)
      ↓
Loki (ingest & index)
      ↓
Grafana (query via LogQL)
      ↓
Log Panel Visualization
```

### **Traces Flow**

```
Application (instrumented)
      ↓
OTLP / Jaeger / Zipkin
      ↓
Tempo (ingest)
      ↓
Grafana (query)
      ↓
Trace Visualization
```

### **Alerts Flow**

```
Prometheus (evaluate rules)
      ↓
Alertmanager (route & deduplicate)
      ↓
Notification Channels
  ├─ Email
  ├─ Slack
  ├─ Webhook
  └─ PagerDuty
```

---

## Network Architecture

### **Docker Network**

- **Name**: `monitoring`
- **Driver**: bridge
- **Subnet**: 172.20.0.0/16

### **Service Communication**

All services communicate within the `monitoring` network:
- Internal DNS resolution
- No external network access required (except for alerts)
- Isolated from host network

### **Port Exposure**

Only essential ports are exposed to the host:
- 3000 (Grafana)
- 9090 (Prometheus)
- 3100 (Loki)
- 3200 (Tempo)
- 8086 (InfluxDB)
- 9093 (Alertmanager)
- 8080 (cAdvisor)

---

## Storage Architecture

### **Docker Volumes**

All persistent data stored in named volumes:

| Volume | Purpose | Size (typical) |
|--------|---------|----------------|
| grafana_data | Dashboards, users, settings | 1-2 GB |
| prometheus_data | Metrics time-series | 5-10 GB |
| loki_data | Log data | 3-5 GB |
| tempo_data | Trace data | 2-4 GB |
| influxdb_data | Time-series data | 2-3 GB |
| postgres_data | Grafana backend | 500 MB |
| redis_data | Session data | 100 MB |
| alertmanager_data | Alert state | 50 MB |

**Total**: ~15-25 GB (depends on usage)

---

## Security Architecture

### **Authentication**

- **Grafana**: Local authentication (default)
  - Extensible to LDAP, OAuth, SAML
  - Strong password policy
  - Session timeout

### **Authorization**

- **RBAC**: Role-based access control
  - Admin, Editor, Viewer roles
  - Organization-level permissions
  - Dashboard-level permissions

### **Network Security**

- **Internal Network**: Isolated Docker network
- **Minimal Exposure**: Only necessary ports exposed
- **TLS Ready**: Can enable HTTPS with certificates

### **Data Security**

- **Secrets**: Environment variables (not in code)
- **Passwords**: Hashed and salted
- **Database**: Encrypted at rest (optional)

---

## Scalability Considerations

### **Current Setup**

- **Type**: Single-node, all-in-one
- **Purpose**: Training and development
- **Capacity**: ~10-20 users, moderate load

### **Production Scaling**

For production, consider:

1. **Horizontal Scaling**:
   - Multiple Prometheus instances
   - Loki distributed mode
   - Tempo distributed mode
   - Grafana clustering

2. **External Storage**:
   - S3 for Loki/Tempo
   - Remote storage for Prometheus
   - Managed PostgreSQL

3. **Load Balancing**:
   - Nginx/HAProxy for Grafana
   - Service mesh for internal communication

4. **High Availability**:
   - Multiple replicas
   - Failover mechanisms
   - Backup and disaster recovery

---

## Monitoring the Monitoring Stack

### **Self-Monitoring**

The stack monitors itself:
- Prometheus scrapes all services
- Grafana dashboards for stack health
- Alerts for service failures
- Logs aggregated in Loki

### **Health Checks**

All services have health checks:
- HTTP endpoints
- Docker health checks
- Automatic restart on failure

---

## Best Practices Implemented

✅ **Configuration as Code**: All configs in version control
✅ **Auto-Provisioning**: Dashboards and data sources
✅ **Health Checks**: All services monitored
✅ **Logging**: Centralized log aggregation
✅ **Alerting**: Proactive issue detection
✅ **Security**: Secrets in environment variables
✅ **Documentation**: Comprehensive guides
✅ **Modularity**: Easy to add/remove components

---

## Training Integration

### **Module Alignment**

- **Module 1**: Grafana fundamentals → Use Grafana UI
- **Module 2**: Data sources → Prometheus, Loki, Tempo, InfluxDB
- **Module 3**: Best practices → Pre-configured examples
- **Module 4**: Organization → Multi-org setup ready
- **Module 5**: Advanced → Template variables, complex queries

### **Hands-On Learning**

- Real metrics from running services
- Live logs from containers
- Actual traces (when instrumented)
- Production-like environment

---

**Version**: 1.0.0  
**Last Updated**: October 2024  
**Maintained by**: Data2AI Academy

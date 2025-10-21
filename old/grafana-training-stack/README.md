# 🎓 Grafana Training Stack - Production-Ready Observability Platform

## 📚 Overview

This is a **production-ready Grafana observability stack** designed specifically for **Data2AI Academy training courses**. It follows industry best practices and provides hands-on learning experiences for DevOps engineers and SREs.

### **Target Audience**
- DevOps Engineers
- Site Reliability Engineers (SREs)
- Platform Engineers
- System Administrators

### **Course Duration**
16-20 hours across 5 comprehensive modules

---

## 🏗️ Stack Architecture

### **Core Components**

| Component | Version | Purpose | Port |
|-----------|---------|---------|------|
| **Grafana OSS** | Latest | Visualization & Dashboards | 3000 |
| **Prometheus** | Latest | Metrics Collection | 9090 |
| **Loki** | Latest | Log Aggregation | 3100 |
| **Tempo** | Latest | Distributed Tracing | 3200 |
| **InfluxDB** | 2.7 | Time-Series Database | 8086 |
| **PostgreSQL** | 15 | Grafana Backend | 5432 |
| **Redis** | 7-alpine | Caching Layer | 6379 |
| **Node Exporter** | Latest | System Metrics | 9100 |
| **cAdvisor** | Latest | Container Metrics | 8080 |
| **Alertmanager** | Latest | Alert Management | 9093 |

### **Training Modules**

1. **Module 1: Grafana Fundamentals** (4 hours)
   - Dashboard creation
   - Panel types and visualizations
   - Data source configuration

2. **Module 2: Data Source Integration** (4 hours)
   - Prometheus integration
   - InfluxDB queries
   - Loki log queries

3. **Module 3: Best Practices** (3 hours)
   - Dashboard design patterns
   - Performance optimization
   - Security hardening

4. **Module 4: Organization Management** (3 hours)
   - Multi-tenancy
   - User management
   - RBAC configuration

5. **Module 5: Advanced Templating** (4 hours)
   - Variables and filters
   - Dynamic dashboards
   - Advanced queries

---

## 🚀 Quick Start

### **Prerequisites**

- Docker Desktop 24.0+ or Docker Engine 24.0+
- Docker Compose v2.20+
- 8GB RAM minimum (16GB recommended)
- 20GB free disk space

### **1. Clone and Setup**

```bash
cd "d:\Data2AI Academy\Grafana\grafana-training-stack"

# Copy environment template
cp .env.example .env

# Edit passwords (optional - defaults provided)
notepad .env
```

### **2. Start the Stack**

```bash
# Start all services
docker-compose up -d

# Check service health
docker-compose ps

# View logs
docker-compose logs -f grafana
```

### **3. Access Services**

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **Grafana** | http://localhost:3000 | admin / admin123 |
| **Prometheus** | http://localhost:9090 | - |
| **Alertmanager** | http://localhost:9093 | - |
| **InfluxDB** | http://localhost:8086 | admin / admin123 |

### **4. Initial Setup**

1. **Login to Grafana**: http://localhost:3000
2. **Change default password** (prompted on first login)
3. **Verify data sources** (auto-provisioned):
   - Prometheus
   - Loki
   - Tempo
   - InfluxDB
4. **Import training dashboards** from `grafana/dashboards/`

---

## 📁 Directory Structure

```
grafana-training-stack/
├── docker-compose.yml              # Main stack definition
├── .env.example                    # Environment variables template
├── .gitignore                      # Git ignore rules
├── README.md                       # This file
│
├── grafana/                        # Grafana configuration
│   ├── grafana.ini                 # Grafana settings
│   ├── provisioning/               # Auto-provisioning
│   │   ├── datasources/            # Data source configs
│   │   ├── dashboards/             # Dashboard configs
│   │   ├── alerting/               # Alert rules
│   │   └── plugins/                # Plugin configs
│   └── dashboards/                 # Dashboard JSON files
│       ├── module1/                # Module 1 dashboards
│       ├── module2/                # Module 2 dashboards
│       ├── module3/                # Module 3 dashboards
│       ├── module4/                # Module 4 dashboards
│       └── module5/                # Module 5 dashboards
│
├── prometheus/                     # Prometheus configuration
│   ├── prometheus.yml              # Main config
│   ├── rules/                      # Alert rules
│   └── targets/                    # Service discovery
│
├── loki/                          # Loki configuration
│   └── loki-config.yaml           # Loki settings
│
├── tempo/                         # Tempo configuration
│   └── tempo-config.yaml          # Tempo settings
│
├── influxdb/                      # InfluxDB configuration
│   └── init-scripts/              # Initialization scripts
│
├── alertmanager/                  # Alertmanager configuration
│   └── alertmanager.yml           # Alert routing
│
├── training/                      # Training materials
│   ├── module1/                   # Module 1 exercises
│   ├── module2/                   # Module 2 exercises
│   ├── module3/                   # Module 3 exercises
│   ├── module4/                   # Module 4 exercises
│   ├── module5/                   # Module 5 exercises
│   └── solutions/                 # Exercise solutions
│
├── docs/                          # Documentation
│   ├── architecture.md            # Architecture overview
│   ├── best-practices.md          # Best practices guide
│   ├── troubleshooting.md         # Troubleshooting guide
│   └── api-reference.md           # API documentation
│
└── scripts/                       # Utility scripts
    ├── backup.sh                  # Backup script
    ├── restore.sh                 # Restore script
    └── reset.sh                   # Reset environment
```

---

## 🎯 Training Modules

### **Module 1: Grafana Fundamentals**

**Learning Objectives:**
- Understand Grafana architecture
- Create and customize dashboards
- Master panel types and visualizations
- Configure data sources

**Workshops:**
1. **Workshop 1.1**: Building Your First Dashboard
2. **Workshop 1.2**: Advanced Panel Configurations

**Duration**: 4 hours

### **Module 2: Data Source Integration**

**Learning Objectives:**
- Integrate Prometheus for metrics
- Query InfluxDB time-series data
- Aggregate logs with Loki
- Implement distributed tracing with Tempo

**Workshops:**
1. **Workshop 2.1**: Prometheus Metrics and PromQL
2. **Workshop 2.2**: InfluxDB Flux Queries
3. **Workshop 2.3**: Loki LogQL Fundamentals

**Duration**: 4 hours

### **Module 3: Best Practices**

**Learning Objectives:**
- Design effective dashboards
- Optimize query performance
- Implement security best practices
- Configure high availability

**Workshops:**
1. **Workshop 3.1**: Dashboard Design Patterns
2. **Workshop 3.2**: Security Hardening

**Duration**: 3 hours

### **Module 4: Organization Management**

**Learning Objectives:**
- Manage multiple organizations
- Configure user roles and permissions
- Implement RBAC
- Set up team collaboration

**Workshops:**
1. **Workshop 4.1**: Multi-Tenancy Setup
2. **Workshop 4.2**: Advanced RBAC Configuration

**Duration**: 3 hours

### **Module 5: Advanced Templating**

**Learning Objectives:**
- Create dynamic dashboards
- Master template variables
- Implement advanced queries
- Build reusable dashboard templates

**Workshops:**
1. **Workshop 5.1**: Dynamic Dashboard Creation
2. **Workshop 5.2**: Advanced Variable Chaining

**Duration**: 4 hours

---

## 🔐 Security Best Practices

### **Implemented Security Features**

✅ **Authentication & Authorization**
- Strong default passwords (change on first login)
- RBAC enabled
- Anonymous access disabled
- Session timeout configured

✅ **Network Security**
- Internal Docker network isolation
- Minimal port exposure
- TLS/SSL ready (certificates not included)

✅ **Data Protection**
- Secrets in environment variables
- .env file gitignored
- Database encryption at rest
- Secure password storage

✅ **Monitoring & Auditing**
- Audit logging enabled
- Failed login tracking
- API access logging

### **Production Checklist**

Before deploying to production:

- [ ] Change all default passwords
- [ ] Enable TLS/SSL certificates
- [ ] Configure external authentication (LDAP/OAuth)
- [ ] Set up backup strategy
- [ ] Enable monitoring and alerting
- [ ] Review and harden firewall rules
- [ ] Configure log retention policies
- [ ] Set up disaster recovery plan

---

## 📊 Pre-configured Dashboards

### **System Monitoring**
- **Node Exporter Dashboard**: System metrics (CPU, Memory, Disk, Network)
- **Container Metrics**: Docker container monitoring
- **Grafana Internal**: Grafana performance metrics

### **Application Monitoring**
- **E-Banking Application**: Financial transaction monitoring
- **API Performance**: REST API metrics
- **Database Performance**: PostgreSQL/InfluxDB metrics

### **Training Dashboards**
- **Module 1**: Basic dashboard examples
- **Module 2**: Data source integration examples
- **Module 3**: Best practices examples
- **Module 4**: Multi-org dashboard examples
- **Module 5**: Advanced templating examples

---

## 🛠️ Management Commands

### **Start/Stop Services**

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart grafana

# View logs
docker-compose logs -f [service-name]
```

### **Backup & Restore**

```bash
# Backup Grafana data
./scripts/backup.sh

# Restore from backup
./scripts/restore.sh backup-20241021.tar.gz

# Reset to clean state
./scripts/reset.sh
```

### **Health Checks**

```bash
# Check all services
docker-compose ps

# Check Grafana health
curl http://localhost:3000/api/health

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets
```

---

## 🐛 Troubleshooting

### **Common Issues**

#### **1. Grafana won't start**
```bash
# Check logs
docker-compose logs grafana

# Verify permissions
ls -la grafana/

# Reset Grafana
docker-compose down
docker volume rm grafana-training-stack_grafana_data
docker-compose up -d grafana
```

#### **2. Data source connection failed**
```bash
# Test network connectivity
docker-compose exec grafana ping prometheus

# Verify service is running
docker-compose ps prometheus

# Check data source configuration
cat grafana/provisioning/datasources/prometheus.yml
```

#### **3. Dashboard not loading**
```bash
# Verify dashboard file exists
ls grafana/dashboards/

# Check provisioning logs
docker-compose logs grafana | grep provisioning

# Re-provision dashboards
docker-compose restart grafana
```

See `docs/troubleshooting.md` for detailed troubleshooting guide.

---

## 📚 Additional Resources

### **Documentation**
- [Grafana Official Docs](https://grafana.com/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [InfluxDB Documentation](https://docs.influxdata.com/)

### **Training Materials**
- Course slides: `training/slides/`
- Hands-on exercises: `training/module*/`
- Solutions: `training/solutions/`
- Cheat sheets: `docs/cheatsheets/`

### **Community**
- [Grafana Community Forums](https://community.grafana.com/)
- [Grafana Slack](https://grafana.slack.com/)
- [GitHub Issues](https://github.com/grafana/grafana/issues)

---

## 🤝 Support

For training-related questions:
- **Email**: training@data2ai.academy
- **Slack**: #grafana-training
- **Office Hours**: Monday-Friday, 9AM-5PM UTC

For technical issues:
- Check `docs/troubleshooting.md`
- Review logs: `docker-compose logs`
- Open an issue in the repository

---

## 📝 License

This training stack is provided for educational purposes as part of Data2AI Academy courses.

---

## ✅ Getting Started Checklist

- [ ] Prerequisites installed (Docker, Docker Compose)
- [ ] Repository cloned
- [ ] Environment variables configured (.env)
- [ ] Stack started (`docker-compose up -d`)
- [ ] Grafana accessible (http://localhost:3000)
- [ ] Default password changed
- [ ] Data sources verified
- [ ] Training dashboards imported
- [ ] Ready to start Module 1!

---

**Version**: 1.0.0  
**Last Updated**: October 2024  
**Maintained by**: Data2AI Academy

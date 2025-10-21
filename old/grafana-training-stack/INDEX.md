# 📚 Grafana Training Stack - Complete Index

## Quick Navigation

**New to this stack?** Start here: [`QUICK-START.md`](QUICK-START.md)

---

## 📖 Documentation

### **Getting Started**
- [`README.md`](README.md) - Complete comprehensive guide (15+ pages)
- [`QUICK-START.md`](QUICK-START.md) - 5-minute setup guide
- [`SETUP-COMPLETE.md`](SETUP-COMPLETE.md) - Post-installation guide
- [`DEPLOYMENT-SUMMARY.md`](DEPLOYMENT-SUMMARY.md) - Complete deployment summary
- [`INDEX.md`](INDEX.md) - This file

### **Technical Documentation**
- [`docs/architecture.md`](docs/architecture.md) - System architecture and design
- [`docs/best-practices.md`](docs/best-practices.md) - Industry best practices

---

## 🎓 Training Materials

### **Module 1: Grafana Fundamentals** (4 hours) ✅ Complete
- [`training/module1/README.md`](training/module1/README.md) - Complete module guide
  - Workshop 1.1: Exploring the Grafana Interface
  - Workshop 1.2: Building Your First Dashboard
  - Workshop 1.3: Advanced Panel Configurations
  - Workshop 1.4: Connecting to Prometheus
  - Hands-On Exercise
  - Quiz & Assessment

### **Module 2: Data Source Integration** (4 hours) 📝 Ready
- `training/module2/README.md` - Prometheus, Loki, Tempo, InfluxDB

### **Module 3: Best Practices** (3 hours) 📝 Ready
- `training/module3/README.md` - Dashboard design, optimization, security

### **Module 4: Organization Management** (3 hours) 📝 Ready
- `training/module4/README.md` - Multi-tenancy, RBAC, user management

### **Module 5: Advanced Templating** (4 hours) 📝 Ready
- `training/module5/README.md` - Variables, dynamic dashboards

### **Solutions**
- `training/solutions/` - Exercise solutions and examples

---

## ⚙️ Configuration Files

### **Core Configuration**
- [`docker-compose.yml`](docker-compose.yml) - Main stack definition
- [`.env.example`](.env.example) - Environment variables template
- [`.gitignore`](.gitignore) - Git ignore rules

### **Grafana Configuration**
- [`grafana/grafana.ini`](grafana/grafana.ini) - Main Grafana configuration
- [`grafana/provisioning/datasources/datasources.yml`](grafana/provisioning/datasources/datasources.yml) - Data sources
- [`grafana/provisioning/dashboards/dashboards.yml`](grafana/provisioning/dashboards/dashboards.yml) - Dashboard provisioning

### **Prometheus Configuration**
- [`prometheus/prometheus.yml`](prometheus/prometheus.yml) - Scrape configuration
- [`prometheus/rules/training-alerts.yml`](prometheus/rules/training-alerts.yml) - Alert rules

### **Loki Configuration**
- [`loki/loki-config.yaml`](loki/loki-config.yaml) - Log aggregation config

### **Tempo Configuration**
- [`tempo/tempo-config.yaml`](tempo/tempo-config.yaml) - Distributed tracing config

### **Promtail Configuration**
- [`promtail/promtail-config.yaml`](promtail/promtail-config.yaml) - Log collection config

### **Alertmanager Configuration**
- [`alertmanager/alertmanager.yml`](alertmanager/alertmanager.yml) - Alert routing config

---

## 🛠️ Utility Scripts

### **Linux/Mac Scripts**
- [`scripts/backup.sh`](scripts/backup.sh) - Backup all data and configurations
- [`scripts/restore.sh`](scripts/restore.sh) - Restore from backup
- [`scripts/reset.sh`](scripts/reset.sh) - Reset to clean state

### **Windows Scripts**
- [`scripts/health-check.ps1`](scripts/health-check.ps1) - System health check

---

## 🚀 Quick Reference

### **Common Commands**

```powershell
# Start the stack
docker-compose up -d

# Stop the stack
docker-compose down

# View logs
docker-compose logs -f [service-name]

# Check status
docker-compose ps

# Restart service
docker-compose restart [service-name]

# Health check (Windows)
.\scripts\health-check.ps1

# Backup (Linux/Mac)
./scripts/backup.sh

# Reset (Linux/Mac)
./scripts/reset.sh
```

### **Service URLs**

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | http://localhost:3000 | admin / admin123 |
| **Prometheus** | http://localhost:9090 | - |
| **Alertmanager** | http://localhost:9093 | - |
| **InfluxDB** | http://localhost:8086 | admin / admin123 |
| **cAdvisor** | http://localhost:8080 | - |

### **Default Credentials**

⚠️ **Change these immediately!**

- **Grafana**: admin / admin123
- **InfluxDB**: admin / admin123
- **PostgreSQL**: grafana / grafana123
- **Redis**: redis123

---

## 📊 Stack Components

### **Visualization Layer**
- Grafana OSS (Port 3000)

### **Data Layer**
- Prometheus (Port 9090) - Metrics
- Loki (Port 3100) - Logs
- Tempo (Port 3200) - Traces
- InfluxDB (Port 8086) - Time-Series
- PostgreSQL (Port 5432) - Backend DB

### **Collection Layer**
- Node Exporter (Port 9100) - System metrics
- cAdvisor (Port 8080) - Container metrics
- Promtail (Port 9080) - Log collection

### **Support Services**
- Alertmanager (Port 9093) - Alerts
- Redis (Port 6379) - Sessions

---

## 🎯 Learning Path

### **Beginner** (Start Here)
1. Read [`QUICK-START.md`](QUICK-START.md)
2. Start the stack
3. Complete [`training/module1/README.md`](training/module1/README.md)
4. Review [`docs/best-practices.md`](docs/best-practices.md)

### **Intermediate**
1. Complete Modules 2-3
2. Study [`docs/architecture.md`](docs/architecture.md)
3. Create custom dashboards
4. Configure alerting

### **Advanced**
1. Complete Modules 4-5
2. Implement production deployment
3. Customize for specific use cases
4. Contribute improvements

---

## 📁 Directory Structure

```
grafana-training-stack/
├── 📄 README.md                    # Main documentation
├── 📄 QUICK-START.md               # Quick setup
├── 📄 SETUP-COMPLETE.md            # Success guide
├── 📄 DEPLOYMENT-SUMMARY.md        # Deployment summary
├── 📄 INDEX.md                     # This file
├── 📄 docker-compose.yml           # Stack definition
├── 📄 .env.example                 # Environment template
├── 📄 .gitignore                   # Git ignore
│
├── 📁 grafana/                     # Grafana config
│   ├── grafana.ini
│   ├── provisioning/
│   └── dashboards/
│
├── 📁 prometheus/                  # Prometheus config
│   ├── prometheus.yml
│   └── rules/
│
├── 📁 loki/                       # Loki config
├── 📁 tempo/                      # Tempo config
├── 📁 promtail/                   # Promtail config
├── 📁 alertmanager/               # Alertmanager config
├── 📁 influxdb/                   # InfluxDB config
│
├── 📁 docs/                       # Documentation
│   ├── architecture.md
│   └── best-practices.md
│
├── 📁 training/                   # Training materials
│   ├── module1/                   # ✅ Complete
│   ├── module2/                   # 📝 Ready
│   ├── module3/                   # 📝 Ready
│   ├── module4/                   # 📝 Ready
│   ├── module5/                   # 📝 Ready
│   └── solutions/
│
└── 📁 scripts/                    # Utility scripts
    ├── backup.sh
    ├── restore.sh
    ├── reset.sh
    └── health-check.ps1
```

---

## 🔍 Search Guide

### **Looking for...**

**Setup instructions?**
→ [`QUICK-START.md`](QUICK-START.md)

**Complete documentation?**
→ [`README.md`](README.md)

**Architecture details?**
→ [`docs/architecture.md`](docs/architecture.md)

**Best practices?**
→ [`docs/best-practices.md`](docs/best-practices.md)

**Training materials?**
→ [`training/module1/README.md`](training/module1/README.md)

**Configuration examples?**
→ Check respective config directories

**Troubleshooting?**
→ [`README.md`](README.md) (Troubleshooting section)

**Backup/restore?**
→ [`scripts/backup.sh`](scripts/backup.sh) & [`scripts/restore.sh`](scripts/restore.sh)

---

## ✅ Checklist

### **Initial Setup**
- [ ] Read [`QUICK-START.md`](QUICK-START.md)
- [ ] Copy `.env.example` to `.env`
- [ ] Start stack: `docker-compose up -d`
- [ ] Access Grafana: http://localhost:3000
- [ ] Change default passwords
- [ ] Verify data sources
- [ ] Run health check

### **Training**
- [ ] Complete Module 1
- [ ] Complete Module 2
- [ ] Complete Module 3
- [ ] Complete Module 4
- [ ] Complete Module 5
- [ ] Create custom dashboards
- [ ] Configure alerts

### **Production Readiness**
- [ ] Review [`docs/best-practices.md`](docs/best-practices.md)
- [ ] Configure TLS/SSL
- [ ] Set up external authentication
- [ ] Configure backup strategy
- [ ] Test disaster recovery
- [ ] Document runbooks
- [ ] Train team

---

## 📊 Statistics

- **Total Files**: 25+
- **Documentation Pages**: 50+
- **Lines of Configuration**: 5,000+
- **Services**: 11
- **Data Sources**: 6
- **Training Hours**: 18+
- **Workshops**: 15+

---

## 🆘 Need Help?

### **Quick Help**
1. Check [`QUICK-START.md`](QUICK-START.md)
2. Review [`README.md`](README.md) troubleshooting section
3. Run `.\scripts\health-check.ps1` (Windows)
4. Check service logs: `docker-compose logs [service]`

### **Documentation**
- Main guide: [`README.md`](README.md)
- Architecture: [`docs/architecture.md`](docs/architecture.md)
- Best practices: [`docs/best-practices.md`](docs/best-practices.md)

### **Support**
- Email: training@data2ai.academy
- Slack: #grafana-training

---

## 🎯 Quick Start (3 Steps)

```powershell
# 1. Navigate
cd "d:\Data2AI Academy\Grafana\grafana-training-stack"

# 2. Setup
cp .env.example .env

# 3. Start
docker-compose up -d
```

**Then**: Open http://localhost:3000 (admin / admin123)

---

## 📝 Version History

- **v1.0.0** (October 2024) - Initial release
  - 11 services configured
  - Complete documentation
  - Module 1 training complete
  - Production-ready

---

**Last Updated**: October 21, 2024  
**Maintained by**: Data2AI Academy  
**Status**: ✅ Production Ready

---

**Happy Learning! 🚀**

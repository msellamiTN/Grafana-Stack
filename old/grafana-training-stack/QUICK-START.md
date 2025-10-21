# 🚀 Quick Start Guide - Grafana Training Stack

## ⚡ 5-Minute Setup

### **Step 1: Prerequisites Check**

```powershell
# Check Docker
docker --version
# Required: Docker 24.0+

# Check Docker Compose
docker-compose --version
# Required: v2.20+
```

### **Step 2: Setup Environment**

```powershell
# Navigate to stack directory
cd "d:\Data2AI Academy\Grafana\grafana-training-stack"

# Copy environment file
cp .env.example .env

# (Optional) Edit passwords
notepad .env
```

### **Step 3: Start the Stack**

```powershell
# Start all services
docker-compose up -d

# Wait for services to be healthy (30-60 seconds)
docker-compose ps
```

### **Step 4: Access Grafana**

1. Open browser: **http://localhost:3000**
2. Login:
   - **Username**: `admin`
   - **Password**: `admin123`
3. Change password when prompted

### **Step 5: Verify Setup**

✅ **Check Data Sources** (should be auto-configured):
- Go to **Configuration** → **Data Sources**
- Verify: Prometheus, Loki, Tempo, InfluxDB, PostgreSQL

✅ **Check Dashboards**:
- Go to **Dashboards** → **Browse**
- Look for folders: System, Training/Module 1-5

✅ **Test Prometheus**:
- Open: **http://localhost:9090**
- Run query: `up`
- Should see all services

---

## 📊 What's Running?

| Service | URL | Purpose |
|---------|-----|---------|
| **Grafana** | http://localhost:3000 | Dashboards & Visualization |
| **Prometheus** | http://localhost:9090 | Metrics Collection |
| **Alertmanager** | http://localhost:9093 | Alert Management |
| **InfluxDB** | http://localhost:8086 | Time-Series Database |
| **cAdvisor** | http://localhost:8080 | Container Metrics |

---

## 🎓 Start Training

### **Module 1: Grafana Fundamentals** (4 hours)

```powershell
# Navigate to training materials
cd training/module1

# Read the workshop guide
cat workshop-1.1-first-dashboard.md

# Open Grafana and follow along
start http://localhost:3000
```

**Learning Path:**
1. Workshop 1.1: Building Your First Dashboard
2. Workshop 1.2: Advanced Panel Configurations
3. Hands-on Exercise: Create a System Monitoring Dashboard
4. Quiz & Assessment

---

## 🛠️ Common Commands

### **Service Management**

```powershell
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart a specific service
docker-compose restart grafana

# View logs
docker-compose logs -f grafana

# Check service health
docker-compose ps
```

### **Data Management**

```powershell
# Backup Grafana data
docker-compose exec grafana grafana-cli admin reset-admin-password newpassword

# Reset to clean state
docker-compose down -v
docker-compose up -d
```

### **Troubleshooting**

```powershell
# Check if services are running
docker-compose ps

# View service logs
docker-compose logs [service-name]

# Restart a problematic service
docker-compose restart [service-name]

# Check network connectivity
docker-compose exec grafana ping prometheus
```

---

## 📚 Training Resources

### **Documentation**
- `README.md` - Complete documentation
- `docs/architecture.md` - System architecture
- `docs/best-practices.md` - Best practices guide
- `docs/troubleshooting.md` - Troubleshooting guide

### **Training Materials**
- `training/module1/` - Module 1 exercises
- `training/module2/` - Module 2 exercises
- `training/module3/` - Module 3 exercises
- `training/module4/` - Module 4 exercises
- `training/module5/` - Module 5 exercises
- `training/solutions/` - Exercise solutions

### **Dashboards**
- `grafana/dashboards/system/` - System monitoring dashboards
- `grafana/dashboards/module1/` - Module 1 example dashboards
- `grafana/dashboards/module2/` - Module 2 example dashboards
- And so on...

---

## ⚠️ Important Notes

### **Default Credentials**
- **Grafana**: admin / admin123
- **InfluxDB**: admin / admin123
- **PostgreSQL**: grafana / grafana123

**⚠️ Change these in production!**

### **Ports Used**
- 3000 - Grafana
- 9090 - Prometheus
- 3100 - Loki
- 3200 - Tempo
- 8086 - InfluxDB
- 9093 - Alertmanager
- 8080 - cAdvisor
- 5432 - PostgreSQL
- 6379 - Redis

### **Data Persistence**
All data is stored in Docker volumes:
- `grafana_data` - Grafana dashboards, users, settings
- `prometheus_data` - Prometheus metrics
- `loki_data` - Loki logs
- `tempo_data` - Tempo traces
- `influxdb_data` - InfluxDB time-series data
- `postgres_data` - PostgreSQL database

---

## 🆘 Need Help?

### **Common Issues**

**1. Port already in use**
```powershell
# Check what's using the port
netstat -ano | findstr :3000

# Stop the process or change port in .env
```

**2. Services won't start**
```powershell
# Check logs
docker-compose logs [service-name]

# Restart Docker Desktop
# Then: docker-compose up -d
```

**3. Can't access Grafana**
```powershell
# Verify service is running
docker-compose ps grafana

# Check if port is accessible
curl http://localhost:3000/api/health
```

### **Get Support**
- Check `docs/troubleshooting.md`
- Review logs: `docker-compose logs`
- Email: training@data2ai.academy
- Slack: #grafana-training

---

## ✅ Next Steps

1. ✅ Stack is running
2. ✅ Grafana is accessible
3. ✅ Data sources are configured
4. 🎓 **Start Module 1**: `training/module1/README.md`
5. 📖 Read best practices: `docs/best-practices.md`
6. 🔧 Customize your environment

---

**Happy Learning! 🎉**

**Data2AI Academy**  
*Empowering DevOps Engineers & SREs*

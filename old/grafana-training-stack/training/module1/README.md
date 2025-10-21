# 📚 Module 1: Grafana Fundamentals

## Overview

**Duration**: 4 hours  
**Level**: Beginner  
**Prerequisites**: Basic understanding of monitoring concepts

---

## 🎯 Learning Objectives

By the end of this module, you will be able to:

✅ Navigate the Grafana interface confidently  
✅ Create and customize dashboards  
✅ Understand different panel types and their use cases  
✅ Configure data sources  
✅ Apply basic queries to visualize data  
✅ Share and export dashboards  

---

## 📖 Module Structure

### **Part 1: Grafana Interface** (45 minutes)

**Topics Covered:**
- Grafana UI overview
- Navigation and menus
- User preferences
- Keyboard shortcuts

**Workshop 1.1**: Exploring the Grafana Interface

### **Part 2: Dashboard Basics** (60 minutes)

**Topics Covered:**
- Dashboard creation
- Panel types overview
- Time ranges and refresh intervals
- Dashboard settings

**Workshop 1.2**: Building Your First Dashboard

### **Part 3: Panel Configuration** (90 minutes)

**Topics Covered:**
- Graph panels
- Stat panels
- Table panels
- Gauge and bar gauge
- Panel options and overrides

**Workshop 1.3**: Advanced Panel Configurations

### **Part 4: Data Source Integration** (45 minutes)

**Topics Covered:**
- Adding data sources
- Testing connections
- Query basics
- Data source permissions

**Workshop 1.4**: Connecting to Prometheus

---

## 🛠️ Workshops

### **Workshop 1.1: Exploring the Grafana Interface**

**Objective**: Familiarize yourself with the Grafana UI

**Steps:**

1. **Login to Grafana**
   ```
   URL: http://localhost:3000
   Username: admin
   Password: admin123
   ```

2. **Explore the Home Dashboard**
   - Locate the main menu (left sidebar)
   - Find the search bar
   - Identify the user menu (bottom left)

3. **Navigate Through Menus**
   - **Dashboards**: Browse existing dashboards
   - **Explore**: Query data sources directly
   - **Alerting**: View alert rules
   - **Configuration**: Access settings

4. **Customize Your Profile**
   - Click user icon → Preferences
   - Change theme (Light/Dark)
   - Set timezone
   - Configure home dashboard

**Expected Outcome**: Comfortable navigating Grafana interface

---

### **Workshop 1.2: Building Your First Dashboard**

**Objective**: Create a system monitoring dashboard from scratch

**Scenario**: Monitor the training stack's health

**Steps:**

1. **Create New Dashboard**
   - Click **+** → **Dashboard**
   - Click **Add new panel**

2. **Add CPU Usage Panel**
   - **Data Source**: Prometheus
   - **Query**: 
     ```promql
     100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
     ```
   - **Panel Title**: "CPU Usage (%)"
   - **Visualization**: Time series
   - **Unit**: Percent (0-100)
   - Click **Apply**

3. **Add Memory Usage Panel**
   - Click **Add panel**
   - **Query**:
     ```promql
     (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
     ```
   - **Panel Title**: "Memory Usage (%)"
   - **Visualization**: Gauge
   - **Thresholds**: 
     - Green: 0-70
     - Yellow: 70-85
     - Red: 85-100
   - Click **Apply**

4. **Add Disk Usage Panel**
   - Click **Add panel**
   - **Query**:
     ```promql
     (node_filesystem_avail_bytes{fstype!="tmpfs"} / node_filesystem_size_bytes{fstype!="tmpfs"}) * 100
     ```
   - **Panel Title**: "Disk Space Available (%)"
   - **Visualization**: Bar gauge
   - Click **Apply**

5. **Add Service Status Panel**
   - Click **Add panel**
   - **Query**:
     ```promql
     up
     ```
   - **Panel Title**: "Service Status"
   - **Visualization**: Stat
   - **Value mappings**:
     - 1 → "UP" (Green)
     - 0 → "DOWN" (Red)
   - Click **Apply**

6. **Organize Dashboard**
   - Drag panels to arrange layout
   - Resize panels as needed
   - Recommended layout: 2x2 grid

7. **Configure Dashboard Settings**
   - Click **Dashboard settings** (gear icon)
   - **General**:
     - Name: "System Monitoring"
     - Description: "Training Stack Health Dashboard"
     - Tags: "training", "system", "module1"
   - **Time options**:
     - Timezone: Browser time
     - Auto-refresh: 30s
     - Time range: Last 1 hour
   - Click **Save**

8. **Save Dashboard**
   - Click **Save dashboard** (disk icon)
   - Name: "System Monitoring - Module 1"
   - Folder: "Training/Module 1"
   - Click **Save**

**Expected Outcome**: A functional 4-panel system monitoring dashboard

**Screenshot Checkpoint**: Your dashboard should show:
- ✅ CPU usage trending over time
- ✅ Memory usage as a gauge
- ✅ Disk space as bar gauge
- ✅ Service status indicators

---

### **Workshop 1.3: Advanced Panel Configurations**

**Objective**: Master panel customization and styling

**Steps:**

1. **Create a New Dashboard**
   - Name: "Advanced Panels - Module 1"

2. **Time Series with Multiple Queries**
   - Add panel
   - **Query A** (CPU):
     ```promql
     100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
     ```
   - **Query B** (Memory):
     ```promql
     (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
     ```
   - **Panel Title**: "CPU vs Memory Usage"
   - **Legend**: Show as table, to the right
   - **Tooltip**: All series
   - **Graph styles**: Lines + Points
   - **Thresholds**: Add threshold at 80% (red line)

3. **Stat Panel with Sparkline**
   - Add panel
   - **Query**:
     ```promql
     count(up == 1)
     ```
   - **Panel Title**: "Services Running"
   - **Visualization**: Stat
   - **Graph mode**: Area
   - **Color mode**: Background gradient
   - **Text size**: Auto

4. **Table Panel with Transformations**
   - Add panel
   - **Query**:
     ```promql
     up
     ```
   - **Panel Title**: "Service Status Table"
   - **Visualization**: Table
   - **Transform**: Organize fields
     - Rename: `job` → "Service"
     - Rename: `Value` → "Status"
   - **Value mappings**:
     - 1 → "✅ Running"
     - 0 → "❌ Down"
   - **Column styles**: 
     - Status: Cell display mode = Color background

5. **Heatmap Panel**
   - Add panel
   - **Query**:
     ```promql
     rate(prometheus_http_request_duration_seconds_bucket[5m])
     ```
   - **Panel Title**: "Request Duration Heatmap"
   - **Visualization**: Heatmap
   - **Color scheme**: Spectral

6. **Save Dashboard**

**Expected Outcome**: Understanding of advanced panel configurations

---

### **Workshop 1.4: Connecting to Prometheus**

**Objective**: Understand data source configuration

**Note**: Data sources are already provisioned in this training stack, but this workshop teaches you how to do it manually.

**Steps:**

1. **View Existing Data Sources**
   - Go to **Configuration** → **Data Sources**
   - Click on **Prometheus**
   - Review configuration:
     - URL: `http://prometheus:9090`
     - Access: Server (proxy)
     - Scrape interval: 15s

2. **Test Data Source**
   - Scroll down
   - Click **Save & Test**
   - Should see: "Data source is working"

3. **Explore Prometheus Metrics**
   - Go to **Explore** (compass icon)
   - Select **Prometheus** data source
   - **Metrics browser**: Click to see available metrics
   - Try queries:
     ```promql
     # All metrics
     up
     
     # CPU metrics
     node_cpu_seconds_total
     
     # Memory metrics
     node_memory_MemTotal_bytes
     
     # Prometheus metrics
     prometheus_tsdb_head_samples
     ```

4. **Understanding PromQL Basics**
   - **Instant vector**: `up`
   - **Range vector**: `up[5m]`
   - **Rate**: `rate(node_cpu_seconds_total[5m])`
   - **Aggregation**: `sum(up) by (job)`
   - **Arithmetic**: `(1 - x) * 100`

**Expected Outcome**: Comfortable querying Prometheus

---

## 📝 Hands-On Exercise

### **Exercise 1: Create a Custom Dashboard**

**Scenario**: Create a dashboard to monitor the Grafana service itself

**Requirements**:

1. **Dashboard Name**: "Grafana Self-Monitoring"
2. **Panels to Create**:
   - HTTP Request Rate (time series)
   - Active Users (stat)
   - Dashboard Count (stat)
   - Response Time (gauge)
   - Request Status Codes (pie chart)

3. **Queries** (use Prometheus):
   ```promql
   # Request rate
   rate(grafana_http_request_duration_seconds_count[5m])
   
   # Active users
   grafana_stat_active_users
   
   # Dashboard count
   grafana_stat_totals_dashboard
   
   # Response time (p95)
   histogram_quantile(0.95, rate(grafana_http_request_duration_seconds_bucket[5m]))
   
   # Status codes
   sum by (status_code) (rate(grafana_http_request_duration_seconds_count[5m]))
   ```

4. **Dashboard Features**:
   - Auto-refresh: 30s
   - Time range: Last 6 hours
   - At least 5 panels
   - Organized layout
   - Meaningful titles and descriptions

**Validation**:
- [ ] Dashboard created and saved
- [ ] All 5 panels working
- [ ] Queries returning data
- [ ] Dashboard auto-refreshing
- [ ] Proper panel arrangement

---

## 🧪 Quiz

Test your knowledge:

1. **What is the default refresh interval for Grafana dashboards?**
   - a) 5 seconds
   - b) 30 seconds
   - c) No auto-refresh
   - d) 1 minute

2. **Which panel type is best for showing a single numeric value?**
   - a) Graph
   - b) Stat
   - c) Table
   - d) Heatmap

3. **What does the "up" metric in Prometheus indicate?**
   - a) System uptime
   - b) Service availability (1=up, 0=down)
   - c) CPU usage
   - d) Memory usage

4. **How do you add a new panel to a dashboard?**
   - a) Click the + icon in the top menu
   - b) Click "Add panel" button
   - c) Right-click on dashboard
   - d) Use keyboard shortcut Ctrl+N

5. **What is PromQL?**
   - a) A programming language
   - b) Prometheus Query Language
   - c) A database
   - d) A visualization type

**Answers**: 1-c, 2-b, 3-b, 4-b, 5-b

---

## 📚 Additional Resources

### **Documentation**
- [Grafana Panels](https://grafana.com/docs/grafana/latest/panels/)
- [Prometheus Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [PromQL Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)

### **Video Tutorials**
- Grafana Getting Started (15 min)
- Creating Your First Dashboard (20 min)
- Panel Types Overview (25 min)

### **Practice Datasets**
- TestData data source (built-in)
- Prometheus metrics from training stack
- Sample dashboards in `grafana/dashboards/module1/`

---

## ✅ Module Completion Checklist

- [ ] Completed Workshop 1.1: Interface Exploration
- [ ] Completed Workshop 1.2: First Dashboard
- [ ] Completed Workshop 1.3: Advanced Panels
- [ ] Completed Workshop 1.4: Prometheus Connection
- [ ] Completed Hands-On Exercise
- [ ] Passed Quiz (4/5 correct)
- [ ] Created at least 2 custom dashboards
- [ ] Comfortable with basic PromQL queries

---

## 🎓 Next Steps

**Congratulations!** You've completed Module 1.

**Next Module**: [Module 2 - Data Source Integration](../module2/README.md)

**Topics Preview**:
- Advanced Prometheus queries
- Loki log queries (LogQL)
- InfluxDB Flux queries
- Tempo trace queries
- Multi-data source dashboards

---

**Module 1 Complete! 🎉**

**Estimated Time**: 4 hours  
**Difficulty**: ⭐⭐☆☆☆  
**Hands-On**: 80%

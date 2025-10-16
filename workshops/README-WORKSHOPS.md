# Grafana Workshops - Hands-On Lab Guide

**Complete workshop collection for all 5 modules**

---

## 📚 Workshop Overview

This directory contains 10 hands-on workshop labs with detailed step-by-step instructions and screenshot descriptions.

### Workshop Structure

Each workshop includes:
- ✅ **Step-by-step instructions** with exact commands
- ✅ **Screenshot descriptions** (marked with 📸) showing expected UI
- ✅ **Validation checkpoints** (marked with ✅) for progress verification
- ✅ **Duration estimates** for time planning
- ✅ **Difficulty levels** (Beginner/Intermediate/Advanced)
- ✅ **Code samples** (YAML, SQL, PromQL, Flux)
- ✅ **Troubleshooting tips** where needed

---

## 🎯 Module 1: Grafana Fundamentals (3-4 hours)

### Workshop 1.1: Deploy Grafana Stack for Transaction Monitoring
**File:** `Workshop1.1-Grafana-Deployment-Lab.md`  
**Duration:** 90 minutes | **Level:** Beginner

**What you'll build:**
- Grafana deployment in Kubernetes with persistent storage
- PostgreSQL database with 1000 sample transactions
- 6-panel transaction monitoring dashboard
- Data source configuration

**Key Skills:**
- Kubernetes deployments, services, PVCs
- Grafana data source configuration
- Dashboard creation with Stat, Gauge, Time series panels
- SQL queries for transaction analysis

**Screenshots:** 15+ annotated screenshots covering:
- Kubernetes resource creation
- Grafana UI login and navigation
- Data source configuration
- Panel creation and configuration
- Complete dashboard view

---

### Workshop 1.2: Alerting for Transaction Failures
**File:** `Workshop1.2-Alerting-Lab.md`  
**Duration:** 90 minutes | **Level:** Beginner

**What you'll build:**
- Slack notification channel
- Notification routing policies
- 2 alert rules (failure rate, slow processing)
- Alert testing and validation
- Silence rules for maintenance

**Key Skills:**
- Unified alerting configuration
- Contact points and notification policies
- Alert rule creation with thresholds
- Alert testing and state management
- Silence configuration

**Screenshots:** 12+ screenshots covering:
- Contact point configuration
- Alert rule creation
- Alert state transitions (Normal → Pending → Firing)
- Slack notifications
- Silence management

---

## 🔗 Module 2: Data Source Integration (4-5 hours)

### Workshop 2.1: Prometheus Deployment for API Gateway Monitoring
**File:** `Workshop2.1-Prometheus-Lab.md`  
**Duration:** 120 minutes | **Level:** Intermediate

**What you'll build:**
- Prometheus with Kubernetes service discovery
- RBAC configuration for service discovery
- Sample API services with metrics endpoints
- 4-panel API performance dashboard

**Key Skills:**
- Prometheus deployment and configuration
- Kubernetes RBAC for service accounts
- Service discovery annotations
- PromQL query language
- RED metrics (Rate, Errors, Duration)

**Screenshots:** 10+ screenshots covering:
- Prometheus targets page
- Service discovery verification
- PromQL query results
- Time series visualizations
- Multi-panel dashboard

---

### Workshop 2.2: InfluxDB Integration for Historical Transaction Analysis
**File:** `Workshop2.2-InfluxDB-Lab.md`  
**Duration:** 120 minutes | **Level:** Intermediate

**What you'll build:**
- InfluxDB 2.x deployment
- Python script for time-series data ingestion
- 30 days of business metrics
- Historical analysis dashboard with Flux queries

**Key Skills:**
- InfluxDB 2.x setup and configuration
- Time-series data modeling
- Flux query language
- Long-term trend analysis
- Data aggregation windows

**Screenshots:** 8+ screenshots covering:
- InfluxDB UI and Data Explorer
- Data ingestion verification
- Flux query editor
- 30-day trend visualizations
- Heatmap and aggregation panels

---

## 🎨 Module 3: Best Practices & Observability (3-4 hours)

### Workshop 3.1: Fraud Detection Dashboard with Exemplars
**File:** `Workshop3.1-Fraud-Detection-Lab.md`  
**Duration:** 90 minutes | **Level:** Advanced

**What you'll build:**
- Fraud scoring table with risk factors
- 5-panel fraud detection dashboard
- Risk score distribution analysis
- Drill-down links to transaction details
- Fraud rate alerting

**Key Skills:**
- Complex SQL joins across tables
- Risk scoring algorithms
- Table visualizations with color coding
- Drill-down navigation
- Security monitoring dashboards

**Screenshots:** 10+ screenshots covering:
- Fraud score data verification
- Multi-type visualizations (stat, table, pie, histogram)
- Drill-down link configuration
- Alert configuration for fraud detection

---

### Workshop 3.2: Multi-Database Observability for Customer Journey Analytics
**File:** `Workshop3.2-Multi-Database-Lab.md`  
**Duration:** 120 minutes | **Level:** Advanced

**What you'll build:**
- MySQL customer database deployment
- Cross-database joins (PostgreSQL + MySQL)
- Customer journey analytics dashboard
- Query optimization with indexes
- Performance-tuned dashboard

**Key Skills:**
- Multi-database deployments
- Cross-source data joining in Grafana
- Transform operations (joins, calculations)
- Database indexing
- Query performance optimization
- Dashboard caching strategies

**Screenshots:** 12+ screenshots covering:
- MySQL deployment and verification
- Transform configuration (joins)
- Combined data visualizations
- Performance metrics (query execution time)
- Optimized dashboard loading

---

## 🔐 Module 4: Organization & Dashboard Management (3-4 hours)

### Workshop 4.1: Multi-Tenant Setup for Payment & Retail Banking Teams
**File:** `Workshop4.1-RBAC-MultiTenant-Lab.md`  
**Duration:** 90 minutes | **Level:** Advanced

**What you'll build:**
- 3 teams (Payments, Retail Banking, DevOps)
- Folder structure with permissions
- Data source access control
- Service accounts for automation
- Permission testing

**Key Skills:**
- Team creation and member management
- Folder-based RBAC
- Data source permissions
- Service account tokens
- Multi-tenant architecture

**Screenshots:** 13+ screenshots covering:
- Team creation and member assignment
- Folder permissions configuration
- Permission testing from different user accounts
- Data source dropdown filtering
- Service account token generation

---

### Workshop 4.2: Dashboard Provisioning with GitOps
**File:** `Workshop4.2-Dashboard-Provisioning-Lab.md`  
**Duration:** 90 minutes | **Level:** Advanced

**What you'll build:**
- Dashboard JSON exports
- ConfigMap-based provisioning
- Updated Grafana deployment with auto-provisioning
- Git repository with CI/CD pipeline
- Automated deployment workflow

**Key Skills:**
- Dashboard export and JSON manipulation
- Kubernetes ConfigMaps for configuration
- Volume mounting in deployments
- Git version control
- CI/CD pipeline creation
- Automated dashboard updates

**Screenshots:** 14+ screenshots covering:
- Dashboard export process
- ConfigMap creation
- Deployment volume configuration
- Provisioned dashboard labels
- Git repository structure
- CI/CD pipeline execution

---

## 🚀 Module 5: Advanced Templating & Optimization (3-4 hours)

### Workshop 5.1: Dynamic SLA Dashboard with Query Variables
**File:** `Workshop5.1-SLA-Variables-Lab.md`  
**Duration:** 90 minutes | **Level:** Advanced

**What you'll build:**
- 6 dashboard variables (interval, query, custom, constant)
- Variable chaining and dependencies
- Variable-driven panels
- Drill-down navigation between dashboards
- Dynamic SLA monitoring dashboard

**Key Skills:**
- All variable types (interval, query, custom, constant, textbox)
- Variable syntax in queries ($variable, ${variable})
- Multi-value variables
- Variable chaining
- Dashboard linking with parameters
- Dynamic thresholds using variables

**Screenshots:** 11+ screenshots covering:
- Variable configuration for each type
- Variable dropdowns in dashboard
- Variable chaining demonstration
- Dynamic panel updates
- Drill-down link navigation

---

### Workshop 5.2: Payment Gateway Performance Dashboard with Advanced Templating
**File:** `Workshop5.2-Payment-Gateway-Lab.md`  
**Duration:** 120 minutes | **Level:** Advanced

**What you'll build:**
- Production-grade payment gateway dashboard
- 6 advanced variables with dependencies
- 7 performance panels (overview + analysis)
- Deployment annotations
- Optimized queries with caching
- Reusable variable templates

**Key Skills:**
- Complex variable configurations
- Query optimization (caching, limits)
- Dashboard annotations
- Heatmap visualizations
- Panel loading priorities
- Template library creation
- Production-ready dashboard design

**Screenshots:** 15+ screenshots covering:
- Advanced variable setup
- Overview panels with SLA monitoring
- Stacked time series
- Annotation configuration
- Heatmap visualization
- Query performance metrics
- Complete production dashboard

---

## 📸 Screenshot Guidelines

All workshops use **screenshot placeholders** marked with 📸 emoji. Each placeholder includes:

1. **Context:** Where in the UI this screenshot appears
2. **Content:** What should be visible in the screenshot
3. **Purpose:** What the screenshot validates

**Example:**
```
📸 Screenshot: Grafana login page
[Screenshot showing:
- Grafana logo at top
- "Welcome to Grafana" heading
- Email or username field
- Password field
- "Log in" button
- Dark theme interface
]
```

### Creating Actual Screenshots

When conducting workshops:
1. Follow each step exactly as written
2. Capture screenshots at each 📸 marker
3. Replace placeholder descriptions with actual images
4. Annotate screenshots with red arrows/boxes for clarity
5. Save as PNG or JPEG with descriptive filenames

**Recommended naming:**
- `module1-workshop1-step3-pvc-bound.png`
- `module2-workshop1-step7-prometheus-targets.png`

---

## ✅ Validation Checkpoints

Each workshop includes **validation checkpoints** marked with ✅. These are critical verification points where participants must confirm success before proceeding.

**Checkpoint Types:**

1. **Resource Status:** Kubernetes pods running, services created
2. **Connectivity:** Database connections, API responses
3. **Data Verification:** Query results, record counts
4. **UI Confirmation:** Dashboard displays, alert states
5. **Functional Testing:** Links work, variables update panels

**Example:**
```
✅ Checkpoint 3: Grafana pod must be "Running" with READY status "1/1"
```

If checkpoint fails, workshop includes troubleshooting steps.

---

## 🎓 Workshop Delivery Tips

### For Instructors

**Preparation:**
1. Complete each workshop yourself before class
2. Capture all screenshots with annotations
3. Test in same environment students will use
4. Prepare backup plans for common issues
5. Have troubleshooting guide handy

**During Workshop:**
1. Demonstrate first 2-3 steps
2. Let students work independently with checkpoints
3. Monitor progress using checkpoints as milestones
4. Address common issues for entire group
5. Encourage peer helping

**Timing:**
- Beginner workshops: Add 15-20 min buffer
- Advanced workshops: Add 20-30 min buffer
- Include 10 min break for 90+ min workshops

### For Self-Paced Learning

**Success Tips:**
1. Follow steps exactly as written
2. Don't skip validation checkpoints
3. If stuck, check troubleshooting guide
4. Take your own screenshots for notes
5. Experiment after completing workshop

**Common Issues:**
- PVC stays Pending: Check storage class
- Pod CrashLoopBackOff: Check logs with kubectl logs
- Connection failures: Verify service names and ports
- Query errors: Check data source permissions

---

## 📂 Workshop Files Quick Reference

| Workshop | File | Duration | Level | Key Technologies |
|----------|------|----------|-------|------------------|
| **1.1** | Workshop1.1-Grafana-Deployment-Lab.md | 90 min | Beginner | Kubernetes, Grafana, PostgreSQL |
| **1.2** | Workshop1.2-Alerting-Lab.md | 90 min | Beginner | Grafana Alerting, Slack |
| **2.1** | Workshop2.1-Prometheus-Lab.md | 120 min | Intermediate | Prometheus, PromQL, RBAC |
| **2.2** | Workshop2.2-InfluxDB-Lab.md | 120 min | Intermediate | InfluxDB, Flux, Python |
| **3.1** | Workshop3.1-Fraud-Detection-Lab.md | 90 min | Advanced | SQL Joins, Drill-downs |
| **3.2** | Workshop3.2-Multi-Database-Lab.md | 120 min | Advanced | PostgreSQL, MySQL, Transforms |
| **4.1** | Workshop4.1-RBAC-MultiTenant-Lab.md | 90 min | Advanced | Teams, Folders, Permissions |
| **4.2** | Workshop4.2-Dashboard-Provisioning-Lab.md | 90 min | Advanced | ConfigMaps, GitOps, CI/CD |
| **5.1** | Workshop5.1-SLA-Variables-Lab.md | 90 min | Advanced | Variables, Chaining, Links |
| **5.2** | Workshop5.2-Payment-Gateway-Lab.md | 120 min | Advanced | Optimization, Annotations |

---

## 🛠️ Required Tools & Access

**Software:**
- kubectl CLI (configured with cluster access)
- Web browser (Chrome/Firefox recommended)
- Code editor (VS Code recommended)
- Git client
- Python 3.x (for Workshop 2.2)
- Terminal/Shell access

**Kubernetes Cluster:**
- Minimum: 8 CPU, 16GB RAM
- Storage class available
- LoadBalancer or port-forward capability
- Internet access for pulling images

**Grafana Access:**
- Admin credentials
- Ability to create users/teams (Module 4)
- Service account permissions (Module 4)

**External Services (Optional):**
- Slack workspace with webhook (for real notifications)
- Alternative: Use webhook.site for testing

---

## 📝 Workshop Completion Tracking

Use this checklist to track progress:

### Module 1
- [ ] Workshop 1.1: Grafana Deployment (90 min)
- [ ] Workshop 1.2: Alerting Configuration (90 min)

### Module 2
- [ ] Workshop 2.1: Prometheus Integration (120 min)
- [ ] Workshop 2.2: InfluxDB Integration (120 min)

### Module 3
- [ ] Workshop 3.1: Fraud Detection (90 min)
- [ ] Workshop 3.2: Multi-Database Analytics (120 min)

### Module 4
- [ ] Workshop 4.1: RBAC & Multi-Tenancy (90 min)
- [ ] Workshop 4.2: Dashboard Provisioning (90 min)

### Module 5
- [ ] Workshop 5.1: SLA Dashboard with Variables (90 min)
- [ ] Workshop 5.2: Payment Gateway Dashboard (120 min)

**Total Time:** ~17 hours of hands-on practice

---

## 🎉 Workshop Series Complete!

After completing all 10 workshops, you will have:

✅ Built 15+ production-grade dashboards  
✅ Deployed complete Grafana observability stack  
✅ Mastered 4 data sources (PostgreSQL, MySQL, Prometheus, InfluxDB)  
✅ Created 20+ alert rules  
✅ Implemented RBAC with multi-tenancy  
✅ Set up GitOps dashboard provisioning  
✅ Optimized dashboard performance  
✅ Gained practical e-banking monitoring experience

**Next Steps:**
- Take the course assessment (see 06-Assessment-Rubric.md)
- Apply skills to your organization's use cases
- Explore Grafana Enterprise features
- Join Grafana community forums

---

**Questions or Issues?**  
Refer to: `../troubleshooting-guide.md`

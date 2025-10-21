# MS SQL Server - E-Banking Fraud Detection Database

## Overview

A production-like MS SQL Server database for e-banking fraud detection and financial observability training. Includes realistic schema, sample data, and fraud detection scenarios.

## Features

### **Database Schema**
- **Clients** (1,000 records) - Customer profiles with risk scoring
- **Merchants** (50 records) - Merchant profiles across categories
- **FieldAgents** (20 records) - Regional agent network
- **Transactions** (100+ records) - Multi-channel transaction data
- **FraudAlerts** (10+ records) - Real-time fraud detection alerts
- **AccountBalances** (1,000 records) - Account balance tracking
- **SystemMetrics** (240 records) - Performance monitoring data
- **AuditLog** - Comprehensive audit trail

### **Business Context**
- **Institution Type**: Medium-sized Financial Institution
- **Active Clients**: 1,000 (training-optimized)
- **Merchants**: 50 across 12 categories
- **Field Agents**: 20 regional agents
- **Transaction Types**: Transfer, Payment, Withdrawal, Deposit, Purchase
- **Channels**: Mobile, Web, ATM, POS, Agent

### **Fraud Detection**
- **Risk Scoring**: 0-100 scale for clients and transactions
- **Alert Types**: Velocity, Location, Amount, Pattern, Device
- **Severity Levels**: Low, Medium, High, Critical
- **Real-time Monitoring**: Transaction flagging and alerts

## Database Tables

### **1. Clients**
```sql
SELECT TOP 10 
    ClientCode, FirstName, LastName, AccountType, 
    RiskScore, AccountStatus, KYCStatus
FROM Clients
ORDER BY RiskScore DESC;
```

**Key Fields**:
- `RiskScore` - Fraud risk (0-100)
- `AccountType` - Individual, Business, Premium
- `KYCStatus` - Verified, Pending, Failed

### **2. Transactions**
```sql
SELECT TOP 10 
    TransactionCode, TransactionType, Amount, Currency,
    Status, Channel, FraudScore, IsFraudulent
FROM Transactions
ORDER BY TransactionDate DESC;
```

**Key Fields**:
- `FraudScore` - Transaction fraud risk (0-100)
- `IsFraudulent` - Boolean flag
- `Channel` - Mobile, Web, ATM, POS, Agent
- `Status` - Completed, Failed, Flagged, Pending

### **3. FraudAlerts**
```sql
SELECT 
    AlertType, Severity, AlertMessage, RiskScore, Status
FROM FraudAlerts
WHERE Status = 'Open'
ORDER BY DetectedAt DESC;
```

**Alert Types**:
- **Velocity** - Multiple transactions in short time
- **Location** - Impossible travel patterns
- **Amount** - Unusual transaction amounts
- **Pattern** - Suspicious behavior patterns
- **Device** - Unknown or suspicious devices

### **4. Merchants**
```sql
SELECT 
    MerchantCode, MerchantName, Category, RiskLevel
FROM Merchants
WHERE IsActive = 1;
```

**Categories**: Retail, Food & Beverage, Travel, Entertainment, Healthcare, Education, Utilities, Telecom, E-commerce, Gas Station, Pharmacy, Supermarket

## Connection Details

### **From Grafana**
- **Datasource**: MSSQL-EBanking (auto-provisioned)
- **Host**: mssql:1433
- **Database**: EBankingDB
- **User**: sa
- **Password**: EBanking@Secure123!

### **From External Tools**
- **Host**: localhost:1433
- **Database**: EBankingDB
- **User**: sa
- **Password**: EBanking@Secure123!

## Example Queries for Grafana

### **1. Transaction Volume by Type**
```sql
SELECT 
    TransactionType,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalAmount
FROM Transactions
WHERE TransactionDate >= DATEADD(hour, -24, GETDATE())
GROUP BY TransactionType
ORDER BY TransactionCount DESC;
```

### **2. Fraud Detection Rate**
```sql
SELECT 
    CAST(TransactionDate AS DATE) as Date,
    COUNT(*) as TotalTransactions,
    SUM(CASE WHEN IsFraudulent = 1 THEN 1 ELSE 0 END) as FraudulentCount,
    CAST(SUM(CASE WHEN IsFraudulent = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as FraudRate
FROM Transactions
WHERE TransactionDate >= DATEADD(day, -7, GETDATE())
GROUP BY CAST(TransactionDate AS DATE)
ORDER BY Date;
```

### **3. High-Risk Clients**
```sql
SELECT TOP 10
    c.ClientCode,
    c.FirstName + ' ' + c.LastName as ClientName,
    c.RiskScore,
    COUNT(t.TransactionID) as TransactionCount,
    SUM(CASE WHEN t.IsFraudulent = 1 THEN 1 ELSE 0 END) as FraudulentTransactions
FROM Clients c
LEFT JOIN Transactions t ON c.ClientID = t.ClientID
WHERE c.RiskScore > 50
GROUP BY c.ClientCode, c.FirstName, c.LastName, c.RiskScore
ORDER BY c.RiskScore DESC;
```

### **4. Open Fraud Alerts by Severity**
```sql
SELECT 
    Severity,
    COUNT(*) as AlertCount,
    AVG(RiskScore) as AvgRiskScore
FROM FraudAlerts
WHERE Status = 'Open'
GROUP BY Severity
ORDER BY 
    CASE Severity
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
    END;
```

### **5. Transaction Success Rate by Channel**
```sql
SELECT 
    Channel,
    COUNT(*) as TotalTransactions,
    SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as SuccessfulTransactions,
    CAST(SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as SuccessRate
FROM Transactions
WHERE TransactionDate >= DATEADD(hour, -24, GETDATE())
GROUP BY Channel
ORDER BY TotalTransactions DESC;
```

### **6. System Performance Metrics**
```sql
SELECT 
    MetricName,
    AVG(MetricValue) as AvgValue,
    MIN(MetricValue) as MinValue,
    MAX(MetricValue) as MaxValue,
    MetricUnit
FROM SystemMetrics
WHERE Timestamp >= DATEADD(hour, -1, GETDATE())
GROUP BY MetricName, MetricUnit
ORDER BY MetricName;
```

## Training Use Cases

### **Module 2: Data Source Integration**

**Scenario**: Query relational database from Grafana

**Exercises**:
1. Connect to MS SQL Server datasource
2. Write SQL queries for dashboards
3. Create time-series visualizations
4. Join multiple tables for insights

### **Module 3: Best Practices**

**Scenario**: Fraud detection monitoring dashboard

**Exercises**:
1. Create fraud alert dashboard
2. Set up high-risk transaction alerts
3. Monitor fraud detection rates
4. Track system performance

### **Module 4: Organization Management**

**Scenario**: Multi-team fraud monitoring

**Exercises**:
1. Create team-specific dashboards
2. Set up role-based access
3. Configure alert routing by team
4. Implement audit logging

### **Module 5: Advanced Templating**

**Scenario**: Dynamic fraud analysis dashboard

**Exercises**:
1. Add client selector variable
2. Implement merchant category filter
3. Create time range selector
4. Build drill-down capabilities

## Dashboard Ideas

### **1. Fraud Detection Overview**
- Total transactions (24h)
- Fraud detection rate
- Open alerts by severity
- High-risk clients list
- Transaction heatmap

### **2. Transaction Monitoring**
- Transaction volume by type
- Success rate by channel
- Average transaction amount
- Processing time trends
- Geographic distribution

### **3. Client Risk Analysis**
- Risk score distribution
- High-risk client list
- Client transaction patterns
- KYC status overview
- Account status breakdown

### **4. Merchant Analytics**
- Transaction volume by merchant
- Merchant risk levels
- Category performance
- Top merchants by revenue
- Merchant fraud rates

### **5. System Performance**
- Transaction throughput
- API response times
- Error rates
- System availability
- Database performance

## Maintenance

### **Reset Database**
```sql
-- Drop and recreate database
USE master;
DROP DATABASE IF EXISTS EBankingDB;
GO

-- Then restart container to re-initialize
```

### **Add More Sample Data**
```sql
-- Add more transactions
EXEC sp_GenerateTransactions @Count = 1000;

-- Add more clients
EXEC sp_GenerateClients @Count = 5000;
```

### **Check Database Size**
```sql
SELECT 
    name AS DatabaseName,
    size * 8 / 1024 AS SizeMB
FROM sys.master_files
WHERE database_id = DB_ID('EBankingDB');
```

### **View Table Statistics**
```sql
SELECT 
    t.name AS TableName,
    p.rows AS RowCount,
    SUM(a.total_pages) * 8 / 1024 AS TotalSpaceMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0
GROUP BY t.name, p.rows
ORDER BY TotalSpaceMB DESC;
```

## Security Best Practices

### **Production Deployment**
1. ✅ Change default SA password
2. ✅ Create dedicated application user
3. ✅ Enable TLS/SSL encryption
4. ✅ Implement row-level security
5. ✅ Enable audit logging
6. ✅ Regular backup schedule
7. ✅ Network isolation
8. ✅ Least privilege access

### **Training Environment**
- ⚠️ Default password for ease of use
- ⚠️ SA account enabled
- ⚠️ Encryption disabled
- ✅ Isolated Docker network
- ✅ No external exposure (by default)

## Troubleshooting

### **Container Won't Start**
```powershell
# Check logs
docker-compose logs mssql

# Verify password complexity
# Must contain: uppercase, lowercase, digit, special char
# Minimum 8 characters
```

### **Can't Connect from Grafana**
```powershell
# Test connection
docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd `
  -S localhost -U sa -P 'EBanking@Secure123!' `
  -Q "SELECT @@VERSION"

# Check if database exists
docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd `
  -S localhost -U sa -P 'EBanking@Secure123!' `
  -Q "SELECT name FROM sys.databases"
```

### **Initialize Database Manually**
```powershell
# Run init scripts
docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd `
  -S localhost -U sa -P 'EBanking@Secure123!' `
  -i /docker-entrypoint-initdb.d/01-create-database.sql

docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd `
  -S localhost -U sa -P 'EBanking@Secure123!' `
  -i /docker-entrypoint-initdb.d/02-seed-data.sql
```

## Architecture

```
┌─────────────────────────────────────┐
│     MS SQL Server 2022              │
│     (EBankingDB)                    │
│  - Clients (1,000)                  │
│  - Transactions (100+)              │
│  - Fraud Alerts (10+)               │
│  - Merchants (50)                   │
└─────────────────────────────────────┘
                 │
                 │ SQL Queries
                 ▼
┌─────────────────────────────────────┐
│           Grafana                    │
│  - MSSQL-EBanking datasource        │
│  - Fraud detection dashboards       │
│  - Transaction monitoring           │
└─────────────────────────────────────┘
```

## Version

- **MS SQL Server**: 2022 (Developer Edition)
- **Database**: EBankingDB
- **Collation**: SQL_Latin1_General_CP1_CI_AS
- **Compatibility Level**: 160

## License

Educational use - Data2AI Academy

## Support

For issues or questions:
- Check logs: `docker-compose logs mssql`
- Review documentation: `mssql/README.md`
- Contact: training@data2ai.academy

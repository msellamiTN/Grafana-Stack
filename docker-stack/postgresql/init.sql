-- Create Grafana database
CREATE DATABASE grafana_db OWNER grafana_admin;

-- Create E-Banking databases
CREATE DATABASE EBankingAuth OWNER sa;
CREATE DATABASE EBankingTransactions OWNER sa;
CREATE DATABASE EBankingKPI OWNER sa;
CREATE DATABASE EBankingODDO OWNER sa;

-- Connect to grafana_db
\c grafana_db

-- Create tables for dashboard metadata
CREATE TABLE IF NOT EXISTS dashboard_metadata (
    id SERIAL PRIMARY KEY,
    dashboard_uid VARCHAR(255) UNIQUE,
    service_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS kpi_definitions (
    id SERIAL PRIMARY KEY,
    kpi_name VARCHAR(255) NOT NULL,
    description TEXT,
    metric_type VARCHAR(50),
    threshold_warning FLOAT,
    threshold_critical FLOAT,
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert KPI Definitions
INSERT INTO kpi_definitions (kpi_name, description, metric_type, threshold_warning, threshold_critical) VALUES
('TransactionVolume', 'Total number of transactions processed', 'counter', 1000, 500),
('SuccessRate', 'Percentage of successful transactions', 'gauge', 0.95, 0.90),
('AverageResponseTime', 'Average API response time in milliseconds', 'histogram', 1000, 2000),
('ErrorRate', 'Percentage of failed transactions', 'gauge', 0.05, 0.10),
('UserEngagement', 'Active users in the system', 'gauge', 100, 50),
('SystemUptime', 'System availability percentage', 'gauge', 0.99, 0.95),
('DataProcessingDelay', 'Average data processing delay', 'histogram', 5000, 10000);

-- Create audit log table
CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(255),
    action VARCHAR(500),
    status VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);

-- Create indexes
CREATE INDEX idx_dashboard_service ON dashboard_metadata(service_name);
CREATE INDEX idx_kpi_enabled ON kpi_definitions(enabled);
CREATE INDEX idx_audit_service ON audit_logs(service_name);
CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp);

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE grafana_db TO grafana_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO grafana_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO grafana_admin;

-- Connect to EBankingODDO
\c EBankingODDO

-- Create main tables for E-Banking
CREATE TABLE IF NOT EXISTS Users (
    UserId BIGINT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(100) NOT NULL UNIQUE,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    FullName NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    LastLoginAt DATETIME
);

CREATE TABLE IF NOT EXISTS Transactions (
    TransactionId BIGINT PRIMARY KEY IDENTITY(1,1),
    UserId BIGINT FOREIGN KEY REFERENCES Users(UserId),
    Amount DECIMAL(18,2),
    TransactionType NVARCHAR(50),
    Status NVARCHAR(50),
    Description NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    ResponseTimeMs INT
);

CREATE TABLE IF NOT EXISTS KPIMetrics (
    MetricId BIGINT PRIMARY KEY IDENTITY(1,1),
    MetricName NVARCHAR(100),
    MetricValue DECIMAL(18,4),
    Timestamp DATETIME DEFAULT GETDATE(),
    Service NVARCHAR(100),
    Environment NVARCHAR(50)
);

CREATE TABLE IF NOT EXISTS ErrorLogs (
    ErrorId BIGINT PRIMARY KEY IDENTITY(1,1),
    Service NVARCHAR(100),
    ErrorMessage NVARCHAR(MAX),
    StackTrace NVARCHAR(MAX),
    Severity NVARCHAR(20),
    Timestamp DATETIME DEFAULT GETDATE()
);

-- Create indexes
CREATE INDEX idx_transaction_user ON Transactions(UserId);
CREATE INDEX idx_transaction_status ON Transactions(Status);
CREATE INDEX idx_transaction_created ON Transactions(CreatedAt);
CREATE INDEX idx_kpi_timestamp ON KPIMetrics(Timestamp);
CREATE INDEX idx_kpi_service ON KPIMetrics(Service);
CREATE INDEX idx_error_service ON ErrorLogs(Service);
CREATE INDEX idx_error_timestamp ON ErrorLogs(Timestamp);
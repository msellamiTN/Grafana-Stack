-- =============================================
-- Sample Data Generation for E-Banking System
-- Data2AI Academy - Training Version
-- =============================================
-- Optimized for training: 1,000 clients, 50 merchants, 20 agents
-- =============================================

USE EBankingDB;
GO

PRINT '========================================';
PRINT 'Starting data seeding...';
PRINT '========================================';
GO

-- =============================================
-- Seed Merchants (50 merchants)
-- =============================================
PRINT 'Seeding Merchants...';
GO

DECLARE @MerchantCounter INT = 1;
DECLARE @Categories TABLE (Category NVARCHAR(100));
INSERT INTO @Categories VALUES 
    ('Retail'), ('Food & Beverage'), ('Travel'), ('Entertainment'), 
    ('Healthcare'), ('Education'), ('Utilities'), ('Telecom'),
    ('E-commerce'), ('Gas Station'), ('Pharmacy'), ('Supermarket');

WHILE @MerchantCounter <= 50
BEGIN
    DECLARE @Category NVARCHAR(100);
    DECLARE @RiskLevel NVARCHAR(20);
    
    SELECT TOP 1 @Category = Category FROM @Categories ORDER BY NEWID();
    
    SET @RiskLevel = CASE 
        WHEN @MerchantCounter % 10 = 0 THEN 'High'
        WHEN @MerchantCounter % 5 = 0 THEN 'Medium'
        ELSE 'Low'
    END;
    
    INSERT INTO Merchants (MerchantCode, MerchantName, Category, Country, City, RiskLevel, IsActive)
    VALUES (
        CONCAT('MER', RIGHT('00000' + CAST(@MerchantCounter AS VARCHAR), 5)),
        CONCAT(@Category, ' Store #', @MerchantCounter),
        @Category,
        'Tunisia',
        CASE (@MerchantCounter % 5)
            WHEN 0 THEN 'Tunis'
            WHEN 1 THEN 'Sfax'
            WHEN 2 THEN 'Sousse'
            WHEN 3 THEN 'Bizerte'
            ELSE 'Gabes'
        END,
        @RiskLevel,
        1
    );
    
    SET @MerchantCounter = @MerchantCounter + 1;
END

PRINT '✓ Merchants seeded: 50';
GO

-- =============================================
-- Seed Field Agents (20 agents)
-- =============================================
PRINT 'Seeding Field Agents...';
GO

DECLARE @AgentCounter INT = 1;
DECLARE @FirstNames TABLE (Name NVARCHAR(100));
DECLARE @LastNames TABLE (Name NVARCHAR(100));

INSERT INTO @FirstNames VALUES ('Mohamed'), ('Ahmed'), ('Fatima'), ('Aisha'), ('Ali'), ('Sara'), ('Youssef'), ('Leila'), ('Omar'), ('Nour');
INSERT INTO @LastNames VALUES ('Ben Ali'), ('Trabelsi'), ('Jebali'), ('Hamdi'), ('Karoui'), ('Mejri'), ('Gharbi'), ('Sassi'), ('Cherni'), ('Bouazizi');

WHILE @AgentCounter <= 20
BEGIN
    DECLARE @FirstName NVARCHAR(100);
    DECLARE @LastName NVARCHAR(100);
    
    SELECT TOP 1 @FirstName = Name FROM @FirstNames ORDER BY NEWID();
    SELECT TOP 1 @LastName = Name FROM @LastNames ORDER BY NEWID();
    
    INSERT INTO FieldAgents (AgentCode, FirstName, LastName, Email, PhoneNumber, Region, IsActive)
    VALUES (
        CONCAT('AGT', RIGHT('00000' + CAST(@AgentCounter AS VARCHAR), 5)),
        @FirstName,
        @LastName,
        CONCAT(LOWER(@FirstName), '.', LOWER(@LastName), '@ebanking.tn'),
        CONCAT('+216', RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR), 8)),
        CASE (@AgentCounter % 5)
            WHEN 0 THEN 'North'
            WHEN 1 THEN 'South'
            WHEN 2 THEN 'Center'
            WHEN 3 THEN 'East'
            ELSE 'West'
        END,
        1
    );
    
    SET @AgentCounter = @AgentCounter + 1;
END

PRINT '✓ Field Agents seeded: 20';
GO

-- =============================================
-- Seed Clients (1,000 clients for training)
-- =============================================
PRINT 'Seeding Clients (this may take a moment)...';
GO

DECLARE @ClientCounter INT = 1;
DECLARE @ClientFirstNames TABLE (Name NVARCHAR(100));
DECLARE @ClientLastNames TABLE (Name NVARCHAR(100));

INSERT INTO @ClientFirstNames VALUES 
    ('Mohamed'), ('Ahmed'), ('Fatima'), ('Aisha'), ('Ali'), ('Sara'), ('Youssef'), ('Leila'), ('Omar'), ('Nour'),
    ('Karim'), ('Salma'), ('Hassan'), ('Amina'), ('Tarek'), ('Hana'), ('Rami'), ('Dina'), ('Sami'), ('Mona');

INSERT INTO @ClientLastNames VALUES 
    ('Ben Ali'), ('Trabelsi'), ('Jebali'), ('Hamdi'), ('Karoui'), ('Mejri'), ('Gharbi'), ('Sassi'), ('Cherni'), ('Bouazizi'),
    ('Mansour'), ('Khalil'), ('Nasri'), ('Fakhri'), ('Zouari'), ('Abidi'), ('Dridi'), ('Khelifi'), ('Slimani'), ('Toumi');

WHILE @ClientCounter <= 1000
BEGIN
    DECLARE @ClientFirstName NVARCHAR(100);
    DECLARE @ClientLastName NVARCHAR(100);
    DECLARE @AccountType NVARCHAR(50);
    DECLARE @RiskScore DECIMAL(5,2);
    
    SELECT TOP 1 @ClientFirstName = Name FROM @ClientFirstNames ORDER BY NEWID();
    SELECT TOP 1 @ClientLastName = Name FROM @ClientLastNames ORDER BY NEWID();
    
    -- Account type distribution: 70% Individual, 20% Business, 10% Premium
    SET @AccountType = CASE 
        WHEN @ClientCounter % 10 = 0 THEN 'Premium'
        WHEN @ClientCounter % 5 = 0 THEN 'Business'
        ELSE 'Individual'
    END;
    
    -- Risk score: Most clients low risk, some medium, few high
    SET @RiskScore = CASE 
        WHEN @ClientCounter % 50 = 0 THEN CAST((RAND() * 30 + 70) AS DECIMAL(5,2)) -- High risk (70-100)
        WHEN @ClientCounter % 10 = 0 THEN CAST((RAND() * 30 + 40) AS DECIMAL(5,2)) -- Medium risk (40-70)
        ELSE CAST((RAND() * 40) AS DECIMAL(5,2)) -- Low risk (0-40)
    END;
    
    INSERT INTO Clients (ClientCode, FirstName, LastName, Email, PhoneNumber, AccountType, AccountStatus, RiskScore, KYCStatus, Country, City)
    VALUES (
        CONCAT('CLI', RIGHT('00000' + CAST(@ClientCounter AS VARCHAR), 5)),
        @ClientFirstName,
        @ClientLastName,
        CONCAT(LOWER(@ClientFirstName), '.', LOWER(@ClientLastName), @ClientCounter, '@email.tn'),
        CONCAT('+216', RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR), 8)),
        @AccountType,
        CASE WHEN @ClientCounter % 100 = 0 THEN 'Suspended' ELSE 'Active' END,
        @RiskScore,
        CASE WHEN @ClientCounter % 50 = 0 THEN 'Pending' ELSE 'Verified' END,
        'Tunisia',
        CASE (@ClientCounter % 5)
            WHEN 0 THEN 'Tunis'
            WHEN 1 THEN 'Sfax'
            WHEN 2 THEN 'Sousse'
            WHEN 3 THEN 'Bizerte'
            ELSE 'Gabes'
        END
    );
    
    SET @ClientCounter = @ClientCounter + 1;
END

PRINT '✓ Clients seeded: 1,000';
GO

-- =============================================
-- Seed Account Balances
-- =============================================
PRINT 'Seeding Account Balances...';
GO

INSERT INTO AccountBalances (ClientID, AccountNumber, AccountType, Balance, AvailableBalance, Currency)
SELECT 
    ClientID,
    CONCAT('ACC', RIGHT('0000000000' + CAST(ClientID AS VARCHAR), 10)),
    CASE 
        WHEN AccountType = 'Premium' THEN 'Investment'
        WHEN AccountType = 'Business' THEN 'Checking'
        ELSE 'Savings'
    END,
    CAST((RAND(CHECKSUM(NEWID())) * 50000 + 1000) AS DECIMAL(18,2)), -- Balance: 1,000 - 51,000 TND
    CAST((RAND(CHECKSUM(NEWID())) * 50000 + 1000) AS DECIMAL(18,2)), -- Available balance
    'TND'
FROM Clients;

PRINT '✓ Account Balances seeded: 1,000';
GO

-- =============================================
-- Seed Sample Transactions (100 recent transactions)
-- =============================================
PRINT 'Seeding Sample Transactions...';
GO

DECLARE @TransCounter INT = 1;
DECLARE @TransTypes TABLE (TransType NVARCHAR(50));
DECLARE @Channels TABLE (Channel NVARCHAR(50));
DECLARE @Statuses TABLE (Status NVARCHAR(20));

INSERT INTO @TransTypes VALUES ('Transfer'), ('Payment'), ('Withdrawal'), ('Deposit'), ('Purchase');
INSERT INTO @Channels VALUES ('Mobile'), ('Web'), ('ATM'), ('POS'), ('Agent');
INSERT INTO @Statuses VALUES ('Completed'), ('Completed'), ('Completed'), ('Completed'), ('Failed'); -- 80% success rate

WHILE @TransCounter <= 100
BEGIN
    DECLARE @ClientID INT;
    DECLARE @MerchantID INT;
    DECLARE @TransType NVARCHAR(50);
    DECLARE @Channel NVARCHAR(50);
    DECLARE @Status NVARCHAR(20);
    DECLARE @Amount DECIMAL(18,2);
    DECLARE @FraudScore DECIMAL(5,2);
    
    SELECT TOP 1 @ClientID = ClientID FROM Clients ORDER BY NEWID();
    SELECT TOP 1 @MerchantID = MerchantID FROM Merchants ORDER BY NEWID();
    SELECT TOP 1 @TransType = TransType FROM @TransTypes ORDER BY NEWID();
    SELECT TOP 1 @Channel = Channel FROM @Channels ORDER BY NEWID();
    SELECT TOP 1 @Status = Status FROM @Statuses ORDER BY NEWID();
    
    SET @Amount = CAST((RAND() * 2000 + 10) AS DECIMAL(18,2)); -- 10 - 2,010 TND
    SET @FraudScore = CAST((RAND() * 100) AS DECIMAL(5,2));
    
    INSERT INTO Transactions (
        TransactionCode, ClientID, MerchantID, TransactionType, Amount, Currency, 
        Status, Channel, FraudScore, IsFraudulent, ProcessingTime, TransactionDate
    )
    VALUES (
        CONCAT('TXN', RIGHT('000000000000' + CAST(@TransCounter AS VARCHAR), 12)),
        @ClientID,
        CASE WHEN @TransType IN ('Payment', 'Purchase') THEN @MerchantID ELSE NULL END,
        @TransType,
        @Amount,
        'TND',
        @Status,
        @Channel,
        @FraudScore,
        CASE WHEN @FraudScore > 80 THEN 1 ELSE 0 END,
        CAST((RAND() * 500 + 50) AS INT), -- 50-550ms
        DATEADD(MINUTE, -@TransCounter * 5, GETDATE()) -- Spread over last 8 hours
    );
    
    SET @TransCounter = @TransCounter + 1;
END

PRINT '✓ Sample Transactions seeded: 100';
GO

-- =============================================
-- Seed Sample Fraud Alerts (10 alerts)
-- =============================================
PRINT 'Seeding Sample Fraud Alerts...';
GO

DECLARE @AlertCounter INT = 1;
DECLARE @AlertTypes TABLE (AlertType NVARCHAR(100));
DECLARE @Severities TABLE (Severity NVARCHAR(20));

INSERT INTO @AlertTypes VALUES ('Velocity'), ('Location'), ('Amount'), ('Pattern'), ('Device');
INSERT INTO @Severities VALUES ('Low'), ('Medium'), ('High'), ('Critical');

WHILE @AlertCounter <= 10
BEGIN
    DECLARE @TransID BIGINT;
    DECLARE @AlertClientID INT;
    DECLARE @AlertType NVARCHAR(100);
    DECLARE @Severity NVARCHAR(20);
    
    SELECT TOP 1 @TransID = TransactionID, @AlertClientID = ClientID 
    FROM Transactions 
    WHERE IsFraudulent = 1 OR FraudScore > 70
    ORDER BY NEWID();
    
    SELECT TOP 1 @AlertType = AlertType FROM @AlertTypes ORDER BY NEWID();
    SELECT TOP 1 @Severity = Severity FROM @Severities ORDER BY NEWID();
    
    IF @TransID IS NOT NULL
    BEGIN
        INSERT INTO FraudAlerts (TransactionID, ClientID, AlertType, Severity, AlertMessage, RiskScore, Status)
        VALUES (
            @TransID,
            @AlertClientID,
            @AlertType,
            @Severity,
            CONCAT('Suspicious ', @AlertType, ' pattern detected'),
            CAST((RAND() * 30 + 70) AS DECIMAL(5,2)),
            CASE WHEN @AlertCounter % 3 = 0 THEN 'Resolved' ELSE 'Open' END
        );
    END
    
    SET @AlertCounter = @AlertCounter + 1;
END

PRINT '✓ Sample Fraud Alerts seeded: 10';
GO

-- =============================================
-- Seed System Metrics (last hour)
-- =============================================
PRINT 'Seeding System Metrics...';
GO

DECLARE @MetricCounter INT = 1;
WHILE @MetricCounter <= 60 -- One per minute for last hour
BEGIN
    INSERT INTO SystemMetrics (MetricName, MetricValue, MetricUnit, Category, Timestamp)
    VALUES 
        ('TransactionThroughput', CAST((RAND() * 100 + 50) AS DECIMAL(18,4)), 'tps', 'Throughput', DATEADD(MINUTE, -@MetricCounter, GETDATE())),
        ('APIResponseTime', CAST((RAND() * 200 + 50) AS DECIMAL(18,4)), 'ms', 'Performance', DATEADD(MINUTE, -@MetricCounter, GETDATE())),
        ('ErrorRate', CAST((RAND() * 5) AS DECIMAL(18,4)), 'percent', 'Error', DATEADD(MINUTE, -@MetricCounter, GETDATE())),
        ('SystemAvailability', CAST((RAND() * 1 + 99) AS DECIMAL(18,4)), 'percent', 'Availability', DATEADD(MINUTE, -@MetricCounter, GETDATE()));
    
    SET @MetricCounter = @MetricCounter + 1;
END

PRINT '✓ System Metrics seeded: 240 records';
GO

PRINT '========================================';
PRINT '✓ Data seeding completed successfully!';
PRINT '========================================';
PRINT '';
PRINT 'Summary:';
PRINT '  - Merchants: 50';
PRINT '  - Field Agents: 20';
PRINT '  - Clients: 1,000';
PRINT '  - Account Balances: 1,000';
PRINT '  - Transactions: 100';
PRINT '  - Fraud Alerts: 10';
PRINT '  - System Metrics: 240';
PRINT '';
PRINT 'Database ready for training!';
GO

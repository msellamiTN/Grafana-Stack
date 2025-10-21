# ============================================
# Grafana Training Stack - Health Check Script
# Data2AI Academy - Windows PowerShell Version
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Grafana Training Stack - Health Check" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check Docker
Write-Host "1. Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "   ✓ Docker installed: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Docker not found or not running" -ForegroundColor Red
    exit 1
}

# Check Docker Compose
Write-Host ""
Write-Host "2. Checking Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version
    Write-Host "   ✓ Docker Compose installed: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Docker Compose not found" -ForegroundColor Red
    exit 1
}

# Check if services are running
Write-Host ""
Write-Host "3. Checking service status..." -ForegroundColor Yellow
$services = docker-compose ps --format json | ConvertFrom-Json

if ($services.Count -eq 0) {
    Write-Host "   ✗ No services running" -ForegroundColor Red
    Write-Host "   Run: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

$healthyCount = 0
$unhealthyCount = 0

foreach ($service in $services) {
    $name = $service.Service
    $status = $service.State
    
    if ($status -eq "running") {
        Write-Host "   ✓ $name - Running" -ForegroundColor Green
        $healthyCount++
    } else {
        Write-Host "   ✗ $name - $status" -ForegroundColor Red
        $unhealthyCount++
    }
}

# Check service endpoints
Write-Host ""
Write-Host "4. Checking service endpoints..." -ForegroundColor Yellow

$endpoints = @(
    @{Name="Grafana"; URL="http://localhost:3000/api/health"},
    @{Name="Prometheus"; URL="http://localhost:9090/-/healthy"},
    @{Name="Alertmanager"; URL="http://localhost:9093/-/healthy"},
    @{Name="InfluxDB"; URL="http://localhost:8086/health"}
)

foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-WebRequest -Uri $endpoint.URL -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✓ $($endpoint.Name) - Accessible" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ $($endpoint.Name) - Status: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ✗ $($endpoint.Name) - Not accessible" -ForegroundColor Red
    }
}

# Check data sources (if Grafana is accessible)
Write-Host ""
Write-Host "5. Checking Grafana data sources..." -ForegroundColor Yellow
try {
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:admin123"))
    $headers = @{
        "Authorization" = "Basic $auth"
    }
    
    $datasources = Invoke-RestMethod -Uri "http://localhost:3000/api/datasources" -Headers $headers
    
    foreach ($ds in $datasources) {
        Write-Host "   ✓ $($ds.name) ($($ds.type))" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠ Unable to check data sources (Grafana may not be ready)" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Health Check Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Services Running: $healthyCount" -ForegroundColor Green
if ($unhealthyCount -gt 0) {
    Write-Host "Services Down: $unhealthyCount" -ForegroundColor Red
}
Write-Host ""

if ($unhealthyCount -eq 0) {
    Write-Host "✓ All systems operational!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access Grafana: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "Username: admin" -ForegroundColor Gray
    Write-Host "Password: admin123" -ForegroundColor Gray
} else {
    Write-Host "⚠ Some services need attention" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Try:" -ForegroundColor Cyan
    Write-Host "  docker-compose restart" -ForegroundColor White
    Write-Host "  docker-compose logs [service-name]" -ForegroundColor White
}

Write-Host ""

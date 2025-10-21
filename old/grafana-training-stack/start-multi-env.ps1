# ============================================
# Start Multi-Environment Grafana Training Stack
# Data2AI Academy
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Multi-Environment Training Stack" -ForegroundColor Cyan
Write-Host "Data2AI Academy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Start main stack
Write-Host "Starting main observability stack..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Main stack started" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to start main stack" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Start multi-environment exporters
Write-Host "Starting multi-environment eBanking exporters..." -ForegroundColor Yellow
docker-compose -f docker-compose.multi-env.yml up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Multi-environment exporters started" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to start multi-environment exporters" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ All services started successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Display environment information
Write-Host "Environment Endpoints:" -ForegroundColor Cyan
Write-Host "  Production:   http://localhost:9201/metrics" -ForegroundColor White
Write-Host "  Staging:      http://localhost:9202/metrics" -ForegroundColor White
Write-Host "  Development:  http://localhost:9203/metrics" -ForegroundColor White
Write-Host "  Training:     http://localhost:9200/metrics" -ForegroundColor White
Write-Host ""

Write-Host "Main Services:" -ForegroundColor Cyan
Write-Host "  Grafana:      http://localhost:3000 (admin / admin123)" -ForegroundColor White
Write-Host "  Prometheus:   http://localhost:9090" -ForegroundColor White
Write-Host "  Alertmanager: http://localhost:9093" -ForegroundColor White
Write-Host ""

# Wait for services to be healthy
Write-Host "Waiting for services to be healthy (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check service status
Write-Host ""
Write-Host "Checking service status..." -ForegroundColor Yellow
Write-Host ""

$services = @(
    @{Name="Production"; Port=9201},
    @{Name="Staging"; Port=9202},
    @{Name="Development"; Port=9203},
    @{Name="Training"; Port=9200}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($service.Port)/metrics" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ $($service.Name) environment is healthy" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ✗ $($service.Name) environment is not responding" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Open Grafana: http://localhost:3000" -ForegroundColor White
Write-Host "2. Login with: admin / admin123" -ForegroundColor White
Write-Host "3. Check Prometheus targets: http://localhost:9090/targets" -ForegroundColor White
Write-Host "4. Query metrics by environment:" -ForegroundColor White
Write-Host "   ebanking_transactions_processed_total{environment=\"production\"}" -ForegroundColor Gray
Write-Host ""
Write-Host "To stop all services:" -ForegroundColor Yellow
Write-Host "  docker-compose down" -ForegroundColor Gray
Write-Host "  docker-compose -f docker-compose.multi-env.yml down" -ForegroundColor Gray
Write-Host ""
Write-Host "For more information, see MULTI-ENVIRONMENT-SETUP.md" -ForegroundColor Cyan
Write-Host ""

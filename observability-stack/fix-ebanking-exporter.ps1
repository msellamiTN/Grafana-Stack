# Fix eBanking Exporter Build Issue
# This script rebuilds the eBanking exporter container

Write-Host "=== Fixing eBanking Exporter ===" -ForegroundColor Cyan
Write-Host ""

# Stop the failing container
Write-Host "1. Stopping ebanking_metrics_exporter..." -ForegroundColor Yellow
docker-compose stop ebanking_metrics_exporter
Write-Host "   ✓ Stopped" -ForegroundColor Green
Write-Host ""

# Remove the container
Write-Host "2. Removing old container..." -ForegroundColor Yellow
docker-compose rm -f ebanking_metrics_exporter
Write-Host "   ✓ Removed" -ForegroundColor Green
Write-Host ""

# Rebuild the image
Write-Host "3. Rebuilding eBanking exporter image..." -ForegroundColor Yellow
Write-Host "   This may take a few minutes..." -ForegroundColor Gray
docker-compose build --no-cache ebanking_metrics_exporter

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Build successful" -ForegroundColor Green
} else {
    Write-Host "   ✗ Build failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check if .NET SDK 8.0 is available:" -ForegroundColor White
    Write-Host "   docker run --rm mcr.microsoft.com/dotnet/sdk:8.0 dotnet --version" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Check Docker has internet access to pull images" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Try building manually:" -ForegroundColor White
    Write-Host "   cd ebanking-exporter" -ForegroundColor Gray
    Write-Host "   docker build -t ebanking-exporter ." -ForegroundColor Gray
    exit 1
}
Write-Host ""

# Start the container
Write-Host "4. Starting ebanking_metrics_exporter..." -ForegroundColor Yellow
docker-compose up -d ebanking_metrics_exporter
Write-Host "   ✓ Started" -ForegroundColor Green
Write-Host ""

# Wait a few seconds
Write-Host "5. Waiting for container to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
Write-Host "   ✓ Done" -ForegroundColor Green
Write-Host ""

# Check status
Write-Host "6. Checking container status..." -ForegroundColor Yellow
$status = docker-compose ps ebanking_metrics_exporter
Write-Host $status
Write-Host ""

# Check logs
Write-Host "7. Recent logs:" -ForegroundColor Yellow
docker-compose logs --tail=20 ebanking_metrics_exporter
Write-Host ""

# Test endpoint
Write-Host "8. Testing metrics endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9201/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✓ eBanking exporter is healthy!" -ForegroundColor Green
        Write-Host "   Metrics available at: http://localhost:9201/metrics" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   ⚠ Health check failed - container may still be starting" -ForegroundColor Yellow
    Write-Host "   Wait a few more seconds and try: curl http://localhost:9201/health" -ForegroundColor Gray
}
Write-Host ""

Write-Host "=== Fix Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Verify in Prometheus: http://localhost:9090/targets" -ForegroundColor Gray
Write-Host "2. Check metrics: http://localhost:9201/metrics" -ForegroundColor Gray
Write-Host "3. View in Grafana dashboards" -ForegroundColor Gray
Write-Host ""

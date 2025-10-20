# Grafana MCP Connection Test Script
# This script tests the Grafana MCP server configuration

Write-Host "=== Grafana MCP Connection Test ===" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "1. Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "   ✓ Docker is installed: $dockerVersion" -ForegroundColor Green
    
    $dockerRunning = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Docker is running" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ✗ Docker is not installed or not in PATH" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Check if mcp/grafana image exists
Write-Host "2. Checking Grafana MCP Docker image..." -ForegroundColor Yellow
$imageExists = docker images mcp/grafana --format "{{.Repository}}" 2>&1
if ($imageExists -match "mcp/grafana") {
    Write-Host "   ✓ mcp/grafana image is available" -ForegroundColor Green
} else {
    Write-Host "   ✗ mcp/grafana image not found. Pulling..." -ForegroundColor Yellow
    docker pull mcp/grafana
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Successfully pulled mcp/grafana image" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Failed to pull mcp/grafana image" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# Check Grafana server accessibility
Write-Host "3. Checking Grafana server accessibility..." -ForegroundColor Yellow
try {
    $response = Test-NetConnection -ComputerName 51.79.24.138 -Port 3000 -WarningAction SilentlyContinue
    if ($response.TcpTestSucceeded) {
        Write-Host "   ✓ Grafana server is accessible at http://51.79.24.138:3000" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Cannot connect to Grafana server at http://51.79.24.138:3000" -ForegroundColor Red
        Write-Host "   Please check if the server is running and accessible." -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ✗ Error testing connection: $_" -ForegroundColor Red
}
Write-Host ""

# Check environment variable
Write-Host "4. Checking GRAFANA_SERVICE_ACCOUNT_TOKEN..." -ForegroundColor Yellow
$token = $env:GRAFANA_SERVICE_ACCOUNT_TOKEN
if ($token) {
    $maskedToken = $token.Substring(0, [Math]::Min(10, $token.Length)) + "..."
    Write-Host "   ✓ Token is set: $maskedToken" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Token not set in environment variable" -ForegroundColor Yellow
    Write-Host "   Check if it's configured in Windsurf settings.json" -ForegroundColor Yellow
}
Write-Host ""

# Check Windsurf settings
Write-Host "5. Checking Windsurf settings..." -ForegroundColor Yellow
$settingsPath = "$env:APPDATA\Windsurf\User\settings.json"
if (Test-Path $settingsPath) {
    Write-Host "   ✓ Settings file found: $settingsPath" -ForegroundColor Green
    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if ($settings.'mcp.servers'.'grafana-mcp') {
            Write-Host "   ✓ grafana-mcp server is configured" -ForegroundColor Green
            $mcpConfig = $settings.'mcp.servers'.'grafana-mcp'
            
            if ($mcpConfig.command -eq "docker") {
                Write-Host "   ✓ Using Docker command" -ForegroundColor Green
            }
            
            if ($mcpConfig.env.GRAFANA_SERVICE_ACCOUNT_TOKEN) {
                if ($mcpConfig.env.GRAFANA_SERVICE_ACCOUNT_TOKEN -eq "YOUR_SERVICE_ACCOUNT_TOKEN_HERE") {
                    Write-Host "   ⚠ Service account token needs to be updated in settings.json" -ForegroundColor Yellow
                } else {
                    Write-Host "   ✓ Service account token is configured in settings" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "   ✗ grafana-mcp server not found in settings" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ✗ Error reading settings: $_" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ Settings file not found" -ForegroundColor Red
}
Write-Host ""

# Test Docker run command
Write-Host "6. Testing MCP server startup (dry run)..." -ForegroundColor Yellow
Write-Host "   Command that will be executed by Windsurf:" -ForegroundColor Cyan
Write-Host "   docker run --rm -i -e GRAFANA_URL=http://51.79.24.138:3000 -e GRAFANA_SERVICE_ACCOUNT_TOKEN mcp/grafana -t stdio" -ForegroundColor Gray
Write-Host ""

Write-Host "=== Test Summary ===" -ForegroundColor Cyan
Write-Host "If all checks passed, restart Windsurf to activate the MCP server." -ForegroundColor Green
Write-Host "If any checks failed, follow the instructions in WINDSURF-MCP-SETUP.md" -ForegroundColor Yellow
Write-Host ""

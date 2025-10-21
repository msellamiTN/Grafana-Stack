# Grafana MCP Integration with Windsurf - Setup Guide

## ✅ Configuration Added

The official Grafana MCP server (from https://github.com/grafana/mcp-grafana) has been configured in your Windsurf settings at:
`C:\Users\mokht\AppData\Roaming\Windsurf\User\settings.json`

## 🔧 Setup Steps

### 1. Install Docker

Ensure Docker Desktop is installed and running on your system.
- Download from: https://www.docker.com/products/docker-desktop

### 2. Pull the Grafana MCP Docker Image

```powershell
docker pull mcp/grafana
```

### 3. Get Your Grafana Service Account Token

1. Log in to your Grafana instance at: `http://51.79.24.138:3000`
2. Navigate to: **Administration** → **Service Accounts**
3. Create a new service account with appropriate permissions:
   - **Viewer** role minimum (for read operations)
   - **Editor** role (for dashboard/alert modifications)
   - **Admin** role (for full access including datasource management)
4. Generate a service account token and copy it

### 4. Configure the Service Account Token

**Option A: Update Windsurf settings.json directly (Recommended)**

Edit `C:\Users\mokht\AppData\Roaming\Windsurf\User\settings.json` and replace:
```json
"GRAFANA_SERVICE_ACCOUNT_TOKEN": "YOUR_SERVICE_ACCOUNT_TOKEN_HERE"
```
with your actual token.

**Option B: Set as System Environment Variable**

```powershell
# Run PowerShell as Administrator
[System.Environment]::SetEnvironmentVariable('GRAFANA_SERVICE_ACCOUNT_TOKEN', 'your-token-here', 'User')
```

### 5. Restart Windsurf

After configuring the token, restart Windsurf completely to load the new MCP configuration.

## 📋 MCP Configuration Details

**Server Name:** `grafana-mcp`  
**Docker Image:** `mcp/grafana` (official from GitHub)  
**Grafana URL:** `http://51.79.24.138:3000`  
**Transport Mode:** `stdio` (direct integration with Windsurf)  
**Authentication:** Service Account Token (via environment variable)

**Available Tools:**
- 🔍 **Search** - Search Grafana resources
- 📊 **Datasource** - Manage data sources
- 📈 **Dashboard** - Create and manage dashboards
- 🚨 **Alerting** - Configure alert rules
- 📉 **Prometheus** - Query Prometheus metrics
- 📝 **Loki** - Query and analyze logs
- 🔥 **Pyroscope** - Profile application performance
- 🎯 **Sift** - Investigate issues
- 📞 **OnCall** - Manage on-call schedules
- 🔧 **Admin** - Administrative operations
- 🧭 **Navigation** - Navigate Grafana UI

## 🧪 Testing the Connection

Once configured, you can test the MCP connection by:

1. Opening Windsurf
2. Accessing the MCP panel (if available)
3. Verifying that `grafana-mcp` appears in the list of available servers
4. Testing a simple query or operation

## 🔒 Security Notes

- Never commit your service account token to version control
- Use environment variables to store sensitive credentials
- Rotate tokens periodically
- Grant minimum required permissions to service accounts

## 📚 Available Operations

With this MCP integration, you can:
- Query Prometheus metrics directly from Windsurf
- Search and analyze Loki logs
- Create and update Grafana dashboards
- Manage data sources
- Configure alerting rules
- Search across all Grafana resources

## 🐛 Troubleshooting

### Run the Test Script
```powershell
.\test-mcp-connection.ps1
```
This will check all prerequisites and configuration.

### MCP Server Not Appearing
- Verify Docker is running: `docker ps`
- Check if the image is available: `docker images mcp/grafana`
- Verify token is configured in `settings.json`
- Restart Windsurf completely
- Check Windsurf logs for MCP-related errors

### Docker Errors
- Ensure Docker Desktop is running
- Pull the image manually: `docker pull mcp/grafana`
- Test Docker connectivity: `docker run --rm hello-world`

### Connection Errors
- Verify Grafana server is accessible: `Test-NetConnection -ComputerName 51.79.24.138 -Port 3000`
- Check if Grafana is running on the remote server
- Verify firewall settings allow connections to port 3000

### Authentication Errors
- Regenerate the service account token in Grafana
- Verify token permissions (minimum: Viewer role)
- Update the token in `settings.json` at line 22
- Ensure no extra spaces or quotes in the token value

### Common Issues
1. **"Cannot connect to Docker daemon"** - Start Docker Desktop
2. **"Image not found"** - Run `docker pull mcp/grafana`
3. **"401 Unauthorized"** - Token is invalid or expired, regenerate it
4. **"Connection refused"** - Grafana server is not accessible

## 📞 Support

For issues specific to:
- **Grafana MCP**: Check the server logs at `http://51.79.24.138:8081`
- **Windsurf Integration**: Review Windsurf documentation
- **Service Account**: Verify in Grafana Administration panel

---

**Last Updated:** October 20, 2025  
**Configuration File:** `C:\Users\mokht\AppData\Roaming\Windsurf\User\settings.json`

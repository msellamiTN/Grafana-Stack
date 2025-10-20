# Grafana MCP - Remote Server Quick Start

## 🎯 Overview

Your Windsurf is configured to use the official Grafana MCP server with your **remote Grafana instance** at `http://51.79.24.138:3000`.

## ✅ Current Configuration

**Windsurf Settings Location:**  
`C:\Users\mokht\AppData\Roaming\Windsurf\User\settings.json`

**Configuration:**
```json
{
  "mcp.servers": {
    "grafana-mcp": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-e", "GRAFANA_URL=http://51.79.24.138:3000",
        "-e", "GRAFANA_SERVICE_ACCOUNT_TOKEN",
        "mcp/grafana",
        "-t", "stdio"
      ],
      "env": {
        "GRAFANA_SERVICE_ACCOUNT_TOKEN": "YOUR_SERVICE_ACCOUNT_TOKEN_HERE"
      }
    }
  }
}
```

## 🚀 Quick Setup (3 Steps)

### Step 1: Get Service Account Token from Remote Grafana

1. Open your browser and go to: **http://51.79.24.138:3000**
2. Login with your credentials
3. Navigate to: **☰ Menu** → **Administration** → **Service Accounts**
4. Click **"Add service account"**
5. Set name: `windsurf-mcp` (or any name you prefer)
6. Set role: **Editor** (recommended) or **Viewer** (read-only)
7. Click **"Create"**
8. Click **"Add service account token"**
9. Set name: `windsurf-token`
10. Click **"Generate token"**
11. **Copy the token immediately** (you won't see it again!)

### Step 2: Update Token in Windsurf Settings

1. Open: `C:\Users\mokht\AppData\Roaming\Windsurf\User\settings.json`
2. Find line 22: `"GRAFANA_SERVICE_ACCOUNT_TOKEN": "YOUR_SERVICE_ACCOUNT_TOKEN_HERE"`
3. Replace `YOUR_SERVICE_ACCOUNT_TOKEN_HERE` with your actual token
4. Save the file

**Example:**
```json
"GRAFANA_SERVICE_ACCOUNT_TOKEN": "glsa_abc123xyz789..."
```

### Step 3: Restart Windsurf

1. Close Windsurf completely
2. Reopen Windsurf
3. The MCP server will automatically start when needed

## 🧪 Testing the Connection

Once Windsurf restarts, you can test the MCP connection by asking Cascade:

- "List all Grafana dashboards"
- "Query Prometheus metrics"
- "Show me Loki logs"
- "Create a new dashboard"

## 📋 What You Can Do

With the Grafana MCP server, you can:

### 📊 Dashboards
- List all dashboards
- Create new dashboards
- Update existing dashboards
- Delete dashboards
- Search dashboards by name/tag

### 📈 Data Sources
- List all data sources
- Query Prometheus metrics
- Query Loki logs
- Query InfluxDB data

### 🚨 Alerting
- List alert rules
- Create new alert rules
- Update alert rules
- Test alert rules

### 🔍 Search & Navigation
- Search across all Grafana resources
- Navigate to specific dashboards
- Find data sources

### 🔧 Administration
- Manage service accounts
- Configure settings
- View system status

## 🐛 Troubleshooting

### "MCP server not found"
- Ensure Docker Desktop is running on your local machine
- Pull the image: `docker pull mcp/grafana`
- Restart Windsurf

### "401 Unauthorized" or "403 Forbidden"
- Your service account token is invalid or expired
- Generate a new token from Grafana (Step 1)
- Update settings.json (Step 2)
- Restart Windsurf (Step 3)

### "Connection refused" or "Cannot connect to Grafana"
- Verify the remote server is accessible from your network
- Test in browser: http://51.79.24.138:3000
- Check if firewall is blocking port 3000

### "Docker not found"
- Install Docker Desktop: https://www.docker.com/products/docker-desktop
- Ensure Docker is running
- Add Docker to your PATH

## 🔒 Security Notes

- **Never commit** your service account token to Git
- The token is stored locally in your Windsurf settings
- Rotate tokens periodically for security
- Use minimum required permissions (Viewer for read-only, Editor for modifications)

## 📚 Additional Resources

- **Official Grafana MCP**: https://github.com/grafana/mcp-grafana
- **MCP Protocol**: https://modelcontextprotocol.io/
- **Grafana Docs**: https://grafana.com/docs/

## 🎉 You're All Set!

After completing the 3 steps above and restarting Windsurf, you can start using natural language to interact with your remote Grafana instance through Cascade!

---

**Remote Grafana Server:** http://51.79.24.138:3000  
**Configuration File:** `C:\Users\mokht\AppData\Roaming\Windsurf\User\settings.json`  
**Last Updated:** October 20, 2025

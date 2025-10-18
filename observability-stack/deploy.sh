#!/bin/bash
# Deploy script for Grafana Observability Stack

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting deployment of Grafana Observability Stack...${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Docker is running
docker_running() {
    docker info > /dev/null 2>&1
    return $?
}

# Check if Docker is running
if ! docker_running; then
    echo -e "${RED}❌ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Check if we should use docker compose or docker-compose
if command_exists docker-compose; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo -e "${RED}❌ Neither 'docker compose' nor 'docker-compose' is available. Please install Docker Compose.${NC}"
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    echo -e "${GREEN}🔧 Loading environment variables from .env file...${NC}"
    # Handle the case where .env file has comments or spaces
    export $(grep -v '^#' .env | xargs) > /dev/null 2>&1
else
    echo -e "${YELLOW}⚠️  No .env file found. Creating from .env.example...${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${YELLOW}ℹ️  Please update the .env file with your configuration and run the script again.${NC}"
    else
        echo -e "${RED}❌ Error: .env.example file not found. Please create a .env file.${NC}"
    fi
    exit 1
fi

# Create necessary directories with proper permissions
echo -e "${GREEN}📂 Creating required directories...${NC}"
sudo mkdir -p grafana/{data,provisioning/datasources,provisioning/dashboards,config}
sudo mkdir -p prometheus/rules alertmanager

# Set ownership to current user
echo -e "${GREEN}🔒 Setting permissions...${NC}"
sudo chown -R $USER:$USER .
sudo chmod -R 775 grafana/

# Create default Grafana configuration if not exists
if [ ! -f grafana/config/grafana.ini ]; then
    echo -e "${GREEN}📝 Creating default Grafana configuration...${NC}"
    sudo tee grafana/config/grafana.ini > /dev/null << 'EOL'
[server]
root_url = %(protocol)s://%(domain)s:%(http_port)s/
serve_from_sub_path = false

[database]
type = sqlite3
path = /var/lib/grafana/grafana.db

[security]
admin_user = ${GRAFANA_ADMIN_USER:-admin}
admin_password = ${GRAFANA_ADMIN_PASSWORD:-GrafanaSecure123!Change@Me}
secret_key = ${GRAFANA_SECRET_KEY:-GrafanaSecret123!Change@Me}
disable_initial_admin_creation = false
allow_embedding = true
cookie_secure = false
cookie_samesite = lax

[auth.anonymous]
enabled = false

[auth]
disable_login_form = false
disable_signout_menu = false

[users]
allow_sign_up = false
auto_assign_org = true
auto_assign_org_role = Editor
EOL
fi

# Create default datasource configuration
echo -e "${GREEN}📝 Configuring data sources...${NC}"
sudo tee grafana/provisioning/datasources/datasources.yaml > /dev/null << 'EOL'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      httpMethod: POST
      timeInterval: 15s

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    jsonData:
      maxLines: 1000
EOL

# Stop and remove existing containers
echo -e "${GREEN}🛑 Stopping any running containers...${NC}"
$DOCKER_COMPOSE_CMD down --remove-orphans

# Start the stack
echo -e "${GREEN}🚀 Starting containers with $DOCKER_COMPOSE_CMD...${NC}"
$DOCKER_COMPOSE_CMD up -d --build

# Wait for services to be ready
echo -e "${GREEN}⏳ Waiting for services to be ready (30 seconds)...${NC}"
sleep 30

# Check if Grafana is running
GRAFANA_HEALTH=$($DOCKER_COMPOSE_CMD ps -q grafana 2>/dev/null)
if [ -z "$GRAFANA_HEALTH" ]; then
    echo -e "${RED}❌ Grafana container is not running. Please check the logs with: $DOCKER_COMPOSE_CMD logs grafana${NC}"
    exit 1
fi

# Reset admin password
echo -e "${GREEN}🔄 Resetting admin password...${NC}"
$DOCKER_COMPOSE_CMD exec -T grafana grafana-cli admin reset-admin-password "${GRAFANA_ADMIN_PASSWORD:-GrafanaSecure123!Change@Me}" || echo -e "${YELLOW}⚠️  Could not reset admin password. It might already be set.${NC}"

# Show deployment info
echo -e "\n${GREEN}✅ Deployment completed successfully!${NC}\n"

echo -e "${GREEN}📊 Access the following services:${NC}"
echo -e "- Grafana:      http://localhost:3000"
echo -e "  Username: admin"
echo -e "  Password: ${GRAFANA_ADMIN_PASSWORD:-GrafanaSecure123!Change@Me}\n"
echo -e "- Prometheus:   http://localhost:9090"
echo -e "- Alertmanager: http://localhost:9093"
echo -e "- Loki:         http://localhost:3100\n"
echo -e "📝 To view logs, run: $DOCKER_COMPOSE_CMD logs -f"
echo -e "🛑 To stop all services: $DOCKER_COMPOSE_CMD down\n"
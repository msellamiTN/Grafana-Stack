#!/bin/bash
# Deploy script for Grafana Observability Stack

echo "🚀 Starting deployment of Grafana Observability Stack..."

# Load environment variables
if [ -f .env ]; then
    echo "🔧 Loading environment variables from .env file..."
    export $(grep -v '^#' .env | xargs)
else
    echo "⚠️  No .env file found. Creating from .env.example..."
    cp .env.example .env
    echo "ℹ️  Please update the .env file with your configuration and run the script again."
    exit 1
fi

# Create necessary directories
echo "📂 Creating required directories..."
mkdir -p grafana/{data,provisioning/datasources,provisioning/dashboards,config}
mkdir -p prometheus/rules

# Set proper permissions
echo "🔒 Setting permissions..."
sudo chown -R 472:472 grafana/
sudo chmod -R 775 grafana/

# Create default Grafana configuration if not exists
if [ ! -f grafana/config/grafana.ini ]; then
    echo "📝 Creating default Grafana configuration..."
    cat > grafana/config/grafana.ini << 'EOL'
[server]
root_url = %(protocol)s://%(domain)s:%(http_port)s/
serve_from_sub_path = false

[database]
type = sqlite3
path = /var/lib/grafana/grafana.db

[security]
admin_user = admin
admin_password = ${GRAFANA_ADMIN_PASSWORD}
secret_key = ${GRAFANA_SECRET_KEY}
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
cat > grafana/provisioning/datasources/datasources.yaml << 'EOL'
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

echo "🚀 Starting containers with Docker Compose..."
docker-compose down

echo "🔧 Building and starting containers in the background..."
docker-compose up -d --build

echo "⏳ Waiting for services to be ready (30 seconds)..."
sleep 30

# Check if Grafana is running
GRAFANA_HEALTH=$(docker-compose ps -q grafana)
if [ -z "$GRAFANA_HEALTH" ]; then
    echo "❌ Grafana container is not running. Please check the logs with: docker-compose logs grafana"
    exit 1
fi

echo "🔄 Resetting admin password..."
docker-compose exec -T grafana grafana-cli admin reset-admin-password "${GRAFANA_ADMIN_PASSWORD:-GrafanaSecure123!Change@Me}" || echo "⚠️  Could not reset admin password. It might already be set."

echo "
✅ Deployment completed successfully!

📊 Access the following services:
- Grafana:      http://localhost:3000
  Username: admin
  Password: ${GRAFANA_ADMIN_PASSWORD:-GrafanaSecure123!Change@Me}

- Prometheus:   http://localhost:9090
- Alertmanager: http://localhost:9093
- Loki:         http://localhost:3100

📝 To view logs, run: docker-compose logs -f
"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Docker is running
docker_running() {
    docker info > /dev/null 2>&1
    return $?
}

# Function to deploy with Docker Compose
deploy_docker() {
    echo -e "${GREEN}Starting Docker Compose deployment...${NC}"
    
    # Check for port conflicts
    if command_exists lsof; then
        if lsof -i :${EBANKING_METRICS_PORT:-9201} | grep LISTEN; then
            echo -e "${RED}Error: Port ${EBANKING_METRICS_PORT:-9201} is already in use${NC}"
            exit 1
        fi
    fi
    
    docker-compose pull
    docker-compose up -d --build
    
    echo -e "\n${GREEN}Deployment complete!${NC}"
    echo -e "Access Grafana at: http://localhost:${GRAFANA_PORT:-3000}"
}

# Function to deploy to Kubernetes
deploy_kubernetes() {
    echo -e "${GREEN}Starting Kubernetes deployment...${NC}"
    
    # Check kubectl is installed
    if ! command_exists kubectl; then
        echo -e "${RED}Error: kubectl is not installed${NC}"
        exit 1
    fi
    
    # Create namespace if it doesn't exist
    kubectl create namespace ebanking-observability --dry-run=client -o yaml | kubectl apply -f -
    
    # Create secrets from .env
    kubectl create secret generic observability-secrets \
        --from-env-file=.env \
        -n ebanking-observability \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # Apply all Kubernetes manifests
    if [ -d "k8s" ]; then
        kubectl apply -f k8s/
    else
        echo -e "${YELLOW}Warning: k8s/ directory not found. No Kubernetes resources will be deployed.${NC}"
    fi
    
    echo -e "\n${GREEN}Kubernetes deployment initiated!${NC}"
    echo -e "To access Grafana, run: kubectl port-forward svc/grafana 3000:3000 -n ebanking-observability"
}

# Main deployment function
deploy() {
    if ! docker_running; then
        echo -e "${RED}Error: Docker is not running. Please start Docker and try again.${NC}"
        exit 1
    fi
    
    case "$1" in
        docker)
            deploy_docker
            ;;
        k8s|kubernetes)
            deploy_kubernetes
            ;;
        all)
            deploy_docker
            deploy_kubernetes
            ;;
        *)
            echo "Usage: $0 {docker|k8s|kubernetes|all}"
            echo "  docker:     Deploy using Docker Compose"
            echo "  k8s:        Deploy to Kubernetes"
            echo "  all:        Deploy to both Docker and Kubernetes"
            exit 1
            ;;
    esac
}

# Show welcome message
echo -e "${GREEN}ODDO BHF Observability Stack Deployment${NC}"
echo -e "======================================\n"

# Start deployment
deploy "$1"

#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Warning: .env file not found. Creating from .env.example${NC}"
    cp .env.example .env
    echo -e "${YELLOW}Please edit .env with your configuration before continuing${NC}
"
    exit 1
fi

# Load environment variables
export $(grep -v '^#' .env | xargs)

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Docker is running
docker_running() {
    docker info > /dev/null 2>&1
    return $?
}

# Function to deploy with Docker Compomake -j$(nproc)se
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

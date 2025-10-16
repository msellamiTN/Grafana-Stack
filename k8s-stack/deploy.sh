#!/bin/bash

# E-Banking Observability Stack Deployment Script
# ODDO BHF Kubernetes Deployment

set -e

NAMESPACE="ebanking-observability"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Deploying E-Banking Observability Stack to Kubernetes"
echo "=================================================="

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check prerequisites
echo ""
echo "Checking prerequisites..."

if ! command -v kubectl &> /dev/null; then
    print_error "kubectl not found. Please install kubectl."
    exit 1
fi
print_status "kubectl found"

if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Check your kubeconfig."
    exit 1
fi
print_status "Kubernetes cluster accessible"

echo ""
echo "=================================================="
echo "Deployment Steps:"
echo "1. Create namespace"
echo "2. Create secrets"
echo "3. Create configmaps"
echo "4. Create persistent volumes"
echo "5. Deploy databases"
echo "6. Deploy data sources"
echo "7. Deploy collectors"
echo "8. Deploy processing layer"
echo "9. Deploy Grafana"
echo "10. Deploy e-banking services"
echo "11. Deploy ingress"
echo "=================================================="
echo ""

read -p "Continue with deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Deployment cancelled"
    exit 0
fi

# Step 1: Create Namespace
echo ""
echo "Step 1/11: Creating namespace..."
kubectl apply -f 00-namespace.yaml
print_status "Namespace created: $NAMESPACE"

# Step 2: Create Secrets
echo ""
echo "Step 2/11: Creating secrets..."
kubectl apply -f 01-secrets/
print_status "Secrets created"

# Step 3: Create ConfigMaps
echo ""
echo "Step 3/11: Creating configmaps..."
if [ -d "02-configmaps" ]; then
    kubectl apply -f 02-configmaps/
    print_status "ConfigMaps created"
else
    print_warning "ConfigMaps directory not found, skipping..."
fi

# Step 4: Create Storage
echo ""
echo "Step 4/11: Creating persistent volumes..."
kubectl apply -f 03-storage/
print_status "PVCs created"

# Wait for PVCs to be bound
echo "Waiting for PVCs to be bound..."
kubectl wait --for=condition=bound pvc --all -n $NAMESPACE --timeout=120s || print_warning "Some PVCs may not be bound yet"

# Step 5: Deploy Databases
echo ""
echo "Step 5/11: Deploying databases..."
if [ -d "04-databases" ]; then
    kubectl apply -f 04-databases/
    print_status "Databases deployed"
    
    echo "Waiting for databases to be ready..."
    sleep 10
else
    print_warning "Databases directory not found, skipping..."
fi

# Step 6: Deploy Data Sources
echo ""
echo "Step 6/11: Deploying data sources..."
if [ -d "05-data-sources" ]; then
    kubectl apply -f 05-data-sources/
    print_status "Data sources deployed"
    
    echo "Waiting for data sources to be ready..."
    sleep 10
else
    print_warning "Data sources directory not found, skipping..."
fi

# Step 7: Deploy Collectors
echo ""
echo "Step 7/11: Deploying collectors..."
if [ -d "06-collectors" ]; then
    kubectl apply -f 06-collectors/
    print_status "Collectors deployed"
else
    print_warning "Collectors directory not found, skipping..."
fi

# Step 8: Deploy Processing Layer
echo ""
echo "Step 8/11: Deploying processing layer..."
if [ -d "07-processing" ]; then
    kubectl apply -f 07-processing/
    print_status "Processing layer deployed"
else
    print_warning "Processing directory not found, skipping..."
fi

# Step 9: Deploy Grafana
echo ""
echo "Step 9/11: Deploying Grafana..."
kubectl apply -f 08-grafana/
print_status "Grafana deployed"

echo "Waiting for Grafana to be ready..."
kubectl wait --for=condition=available deployment/grafana -n $NAMESPACE --timeout=300s || print_warning "Grafana may not be ready yet"

# Step 10: Deploy E-Banking Services
echo ""
echo "Step 10/11: Deploying e-banking services..."
if [ -d "09-ebanking-services" ]; then
    kubectl apply -f 09-ebanking-services/
    print_status "E-banking services deployed"
else
    print_warning "E-banking services directory not found, skipping..."
fi

# Step 11: Deploy Ingress
echo ""
echo "Step 11/11: Deploying ingress..."
if [ -d "10-ingress" ]; then
    kubectl apply -f 10-ingress/
    print_status "Ingress deployed"
else
    print_warning "Ingress directory not found, skipping..."
fi

# Display deployment status
echo ""
echo "=================================================="
echo "Deployment Summary"
echo "=================================================="
echo ""

echo "Checking pod status..."
kubectl get pods -n $NAMESPACE

echo ""
echo "Checking services..."
kubectl get svc -n $NAMESPACE

echo ""
echo "=================================================="
echo "Access Information:"
echo "=================================================="
echo ""
echo "Grafana:"
echo "  - Port Forward: kubectl port-forward -n $NAMESPACE svc/grafana 3000:3000"
echo "  - URL: http://localhost:3000"
echo "  - Username: admin"
echo "  - Password: (stored in secret grafana-admin-credentials)"
echo ""
echo "Prometheus:"
echo "  - Port Forward: kubectl port-forward -n $NAMESPACE svc/prometheus 9090:9090"
echo "  - URL: http://localhost:9090"
echo ""
echo "=================================================="
echo ""

print_status "Deployment complete!"

echo ""
echo "Next steps:"
echo "1. Wait for all pods to be Running: kubectl get pods -n $NAMESPACE -w"
echo "2. Access Grafana: kubectl port-forward -n $NAMESPACE svc/grafana 3000:3000"
echo "3. Configure data sources in Grafana UI"
echo "4. Import dashboards"
echo ""
echo "For troubleshooting:"
echo "  kubectl logs -n $NAMESPACE <pod-name>"
echo "  kubectl describe pod -n $NAMESPACE <pod-name>"
echo ""

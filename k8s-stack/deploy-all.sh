#!/bin/bash
set -e

# Apply namespace first
kubectl apply -f 00-namespace.yaml

# Apply storage class
kubectl apply -f 03-storage/storage-class.yaml

# Create secrets (make sure to replace with your actual secrets)
kubectl apply -f 01-secrets/all-secrets.yaml

# Apply network policies
kubectl apply -f 10-network-policies/

# Apply databases
kubectl apply -f 04-databases/

# Wait for databases to be ready
kubectl wait --for=condition=ready pod -l app=postgresql -n ebanking-observability --timeout=300s

# Apply data sources
kubectl apply -f 05-data-sources/

# Apply processing layer
kubectl apply -f 06-processing/

# Apply collectors
kubectl apply -f 07-collectors/

# Apply Grafana
kubectl apply -f 08-grafana/

# Apply e-banking services
kubectl apply -f 09-ebanking-services/

echo "Deployment completed successfully!"
echo "Grafana will be available at: http://localhost:3000"
kubectl port-forward svc/grafana -n ebanking-observability 3000:3000

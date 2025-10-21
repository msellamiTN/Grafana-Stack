#!/bin/sh
set -e

# =============================================
# InfluxDB Initialization Script
# Data2AI Academy - Training Stack
# =============================================

# Wait for InfluxDB to be ready
echo "========================================="
echo "⏳ Waiting for InfluxDB to start..."
echo "========================================="

MAX_RETRIES=30
RETRY_COUNT=0

until curl -s http://localhost:8086/health | grep '"status":"pass"' > /dev/null; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "❌ InfluxDB failed to start after $MAX_RETRIES attempts"
    exit 1
  fi
  echo "Waiting for InfluxDB to be ready... (attempt $RETRY_COUNT/$MAX_RETRIES)"
  sleep 5
done

echo "✅ InfluxDB is ready!"
echo ""

# Ensure all required env vars are set
: "${INFLUXDB_ORG:?Environment variable INFLUXDB_ORG not set}"
: "${INFLUXDB_TOKEN:?Environment variable INFLUXDB_TOKEN not set}"
: "${INFLUXDB_USER:?Environment variable INFLUXDB_USER not set}"
: "${INFLUXDB_PASSWORD:?Environment variable INFLUXDB_PASSWORD not set}"

echo "========================================="
echo "📊 InfluxDB Configuration"
echo "========================================="
echo "Organization: $INFLUXDB_ORG"
echo "User: $INFLUXDB_USER"
echo ""

# =============================================
# Create Buckets
# =============================================

echo "========================================="
echo "🪣 Creating Buckets..."
echo "========================================="

# Training bucket (main bucket for training exercises)
if influx bucket list --org "$INFLUXDB_ORG" --token "$INFLUXDB_TOKEN" | grep -q "training"; then
  echo "✓ Bucket 'training' already exists."
else
  echo "Creating bucket 'training' (retention: 30d)..."
  influx bucket create \
    --name training \
    --org "$INFLUXDB_ORG" \
    --retention 720h \
    --token "$INFLUXDB_TOKEN"
  echo "✓ Bucket 'training' created."
fi

# Payments bucket (for Payment API data)
if influx bucket list --org "$INFLUXDB_ORG" --token "$INFLUXDB_TOKEN" | grep -q "payments"; then
  echo "✓ Bucket 'payments' already exists."
else
  echo "Creating bucket 'payments' (retention: 7d)..."
  influx bucket create \
    --name payments \
    --org "$INFLUXDB_ORG" \
    --retention 168h \
    --token "$INFLUXDB_TOKEN"
  echo "✓ Bucket 'payments' created."
fi

# Metrics bucket (for general application metrics)
if influx bucket list --org "$INFLUXDB_ORG" --token "$INFLUXDB_TOKEN" | grep -q "metrics"; then
  echo "✓ Bucket 'metrics' already exists."
else
  echo "Creating bucket 'metrics' (retention: 30d)..."
  influx bucket create \
    --name metrics \
    --org "$INFLUXDB_ORG" \
    --retention 720h \
    --token "$INFLUXDB_TOKEN"
  echo "✓ Bucket 'metrics' created."
fi

# Logs bucket (for log-based metrics)
if influx bucket list --org "$INFLUXDB_ORG" --token "$INFLUXDB_TOKEN" | grep -q "logs"; then
  echo "✓ Bucket 'logs' already exists."
else
  echo "Creating bucket 'logs' (retention: 7d)..."
  influx bucket create \
    --name logs \
    --org "$INFLUXDB_ORG" \
    --retention 168h \
    --token "$INFLUXDB_TOKEN"
  echo "✓ Bucket 'logs' created."
fi

echo ""

# =============================================
# Create V1 Authentication (for compatibility)
# =============================================

echo "========================================="
echo "🔐 Creating V1 Authentication..."
echo "========================================="

# Get bucket IDs dynamically
TRAINING_BUCKET_ID=$(influx bucket list --org "$INFLUXDB_ORG" --token "$INFLUXDB_TOKEN" | awk '/training/ {print $1}' | head -n 1)
PAYMENTS_BUCKET_ID=$(influx bucket list --org "$INFLUXDB_ORG" --token "$INFLUXDB_TOKEN" | awk '/payments/ {print $1}' | head -n 1)
METRICS_BUCKET_ID=$(influx bucket list --org "$INFLUXDB_ORG" --token "$INFLUXDB_TOKEN" | awk '/metrics/ {print $1}' | head -n 1)
LOGS_BUCKET_ID=$(influx bucket list --org "$INFLUXDB_ORG" --token "$INFLUXDB_TOKEN" | awk '/logs/ {print $1}' | head -n 1)

# Check if v1 auth already exists
if influx v1 auth list --org "$INFLUXDB_ORG" --token "$INFLUXDB_TOKEN" | grep -q "$INFLUXDB_USER"; then
  echo "✓ V1 auth for user '$INFLUXDB_USER' already exists."
else
  echo "Creating V1 auth for user '$INFLUXDB_USER'..."
  influx v1 auth create \
    --org "$INFLUXDB_ORG" \
    --username "$INFLUXDB_USER" \
    --password "$INFLUXDB_PASSWORD" \
    --read-bucket "$TRAINING_BUCKET_ID" \
    --write-bucket "$TRAINING_BUCKET_ID" \
    --read-bucket "$PAYMENTS_BUCKET_ID" \
    --write-bucket "$PAYMENTS_BUCKET_ID" \
    --read-bucket "$METRICS_BUCKET_ID" \
    --write-bucket "$METRICS_BUCKET_ID" \
    --read-bucket "$LOGS_BUCKET_ID" \
    --write-bucket "$LOGS_BUCKET_ID" \
    --token "$INFLUXDB_TOKEN"
  echo "✓ V1 auth created for user '$INFLUXDB_USER'."
fi

echo ""

# =============================================
# Summary
# =============================================

echo "========================================="
echo "✅ InfluxDB Initialization Complete!"
echo "========================================="
echo ""
echo "📊 Buckets Created:"
echo "  - training (30d retention)"
echo "  - payments (7d retention)"
echo "  - metrics (30d retention)"
echo "  - logs (7d retention)"
echo ""
echo "🔐 Authentication:"
echo "  - V1 Auth: $INFLUXDB_USER (read/write all buckets)"
echo "  - Token: $INFLUXDB_TOKEN"
echo ""
echo "🌐 Access:"
echo "  - URL: http://localhost:8086"
echo "  - Organization: $INFLUXDB_ORG"
echo ""
echo "========================================="
echo "🎓 Ready for Training!"
echo "========================================="

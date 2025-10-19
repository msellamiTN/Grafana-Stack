#!/bin/sh

# Wait for InfluxDB to be ready
until curl -s -o /dev/null http://influxdb:8086/health; do
  echo "Waiting for InfluxDB to be ready..."
  sleep 5
done

# Create the bucket if it doesn't exist
influx bucket create \
  --name payments \
  --org ${INFLUXDB_ORG} \
  --retention 1w \
  --token ${INFLUXDB_TOKEN} || echo "Bucket may already exist"

echo "InfluxDB initialization complete"

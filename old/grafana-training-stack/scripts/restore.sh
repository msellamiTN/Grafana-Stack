#!/bin/bash
# ============================================
# Grafana Training Stack - Restore Script
# Data2AI Academy
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backup file provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No backup file specified${NC}"
    echo "Usage: $0 <backup-file.tar.gz>"
    echo ""
    echo "Available backups:"
    ls -lh backups/grafana-stack-backup-*.tar.gz 2>/dev/null || echo "  No backups found"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "${BACKUP_FILE}" ]; then
    echo -e "${RED}Error: Backup file not found: ${BACKUP_FILE}${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Grafana Training Stack - Restore${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Backup file: ${BACKUP_FILE}${NC}"
echo ""

# Warning
echo -e "${RED}WARNING: This will replace all current data!${NC}"
echo -e "${RED}Make sure you have a backup of the current state.${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no) " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Restore cancelled."
    exit 1
fi

# Stop services
echo -e "${YELLOW}1. Stopping services...${NC}"
docker-compose down
echo -e "${GREEN}   ✓ Services stopped${NC}"

# Extract backup
TEMP_DIR=$(mktemp -d)
echo -e "${YELLOW}2. Extracting backup...${NC}"
tar xzf "${BACKUP_FILE}" -C "${TEMP_DIR}"
echo -e "${GREEN}   ✓ Backup extracted${NC}"

# Start services
echo -e "${YELLOW}3. Starting services...${NC}"
docker-compose up -d
sleep 10
echo -e "${GREEN}   ✓ Services started${NC}"

# Restore Grafana data
echo -e "${YELLOW}4. Restoring Grafana data...${NC}"
docker-compose exec -T grafana sh -c "rm -rf /var/lib/grafana/*"
cat "${TEMP_DIR}"/grafana-data-*.tar.gz | docker-compose exec -T grafana tar xzf - -C /
echo -e "${GREEN}   ✓ Grafana data restored${NC}"

# Restore Prometheus data
echo -e "${YELLOW}5. Restoring Prometheus data...${NC}"
docker-compose exec -T prometheus sh -c "rm -rf /prometheus/*"
cat "${TEMP_DIR}"/prometheus-data-*.tar.gz | docker-compose exec -T prometheus tar xzf - -C /
echo -e "${GREEN}   ✓ Prometheus data restored${NC}"

# Restore Loki data
echo -e "${YELLOW}6. Restoring Loki data...${NC}"
docker-compose exec -T loki sh -c "rm -rf /loki/*"
cat "${TEMP_DIR}"/loki-data-*.tar.gz | docker-compose exec -T loki tar xzf - -C /
echo -e "${GREEN}   ✓ Loki data restored${NC}"

# Restore PostgreSQL database
echo -e "${YELLOW}7. Restoring PostgreSQL database...${NC}"
cat "${TEMP_DIR}"/postgres-*.sql | docker-compose exec -T postgres psql -U grafana grafana
echo -e "${GREEN}   ✓ PostgreSQL database restored${NC}"

# Restore InfluxDB data
echo -e "${YELLOW}8. Restoring InfluxDB data...${NC}"
cat "${TEMP_DIR}"/influxdb-data-*.tar.gz | docker-compose exec -T influxdb tar xzf - -C /tmp/
docker-compose exec -T influxdb influx restore /tmp/influx-backup
echo -e "${GREEN}   ✓ InfluxDB data restored${NC}"

# Cleanup
rm -rf "${TEMP_DIR}"

# Restart services
echo -e "${YELLOW}9. Restarting services...${NC}"
docker-compose restart
sleep 15
echo -e "${GREEN}   ✓ Services restarted${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Restore Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Grafana should be available at: ${GREEN}http://localhost:3000${NC}"
echo ""

#!/bin/bash
# ============================================
# Grafana Training Stack - Backup Script
# Data2AI Academy
# ============================================

set -e

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="grafana-stack-backup-${TIMESTAMP}.tar.gz"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Grafana Training Stack - Backup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Create backup directory
mkdir -p "${BACKUP_DIR}"

echo -e "${YELLOW}Starting backup...${NC}"
echo ""

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${RED}Warning: Some services may not be running${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Backup Grafana data
echo -e "${YELLOW}1. Backing up Grafana data...${NC}"
docker-compose exec -T grafana tar czf - /var/lib/grafana > "${BACKUP_DIR}/grafana-data-${TIMESTAMP}.tar.gz"
echo -e "${GREEN}   ✓ Grafana data backed up${NC}"

# Backup Prometheus data
echo -e "${YELLOW}2. Backing up Prometheus data...${NC}"
docker-compose exec -T prometheus tar czf - /prometheus > "${BACKUP_DIR}/prometheus-data-${TIMESTAMP}.tar.gz"
echo -e "${GREEN}   ✓ Prometheus data backed up${NC}"

# Backup Loki data
echo -e "${YELLOW}3. Backing up Loki data...${NC}"
docker-compose exec -T loki tar czf - /loki > "${BACKUP_DIR}/loki-data-${TIMESTAMP}.tar.gz"
echo -e "${GREEN}   ✓ Loki data backed up${NC}"

# Backup PostgreSQL database
echo -e "${YELLOW}4. Backing up PostgreSQL database...${NC}"
docker-compose exec -T postgres pg_dump -U grafana grafana > "${BACKUP_DIR}/postgres-${TIMESTAMP}.sql"
echo -e "${GREEN}   ✓ PostgreSQL database backed up${NC}"

# Backup InfluxDB data
echo -e "${YELLOW}5. Backing up InfluxDB data...${NC}"
docker-compose exec -T influxdb influx backup /tmp/influx-backup
docker-compose exec -T influxdb tar czf - /tmp/influx-backup > "${BACKUP_DIR}/influxdb-data-${TIMESTAMP}.tar.gz"
echo -e "${GREEN}   ✓ InfluxDB data backed up${NC}"

# Backup configuration files
echo -e "${YELLOW}6. Backing up configuration files...${NC}"
tar czf "${BACKUP_DIR}/configs-${TIMESTAMP}.tar.gz" \
    grafana/ \
    prometheus/ \
    loki/ \
    tempo/ \
    alertmanager/ \
    promtail/ \
    docker-compose.yml \
    .env 2>/dev/null || tar czf "${BACKUP_DIR}/configs-${TIMESTAMP}.tar.gz" \
    grafana/ \
    prometheus/ \
    loki/ \
    tempo/ \
    alertmanager/ \
    promtail/ \
    docker-compose.yml
echo -e "${GREEN}   ✓ Configuration files backed up${NC}"

# Create combined backup
echo ""
echo -e "${YELLOW}7. Creating combined backup archive...${NC}"
cd "${BACKUP_DIR}"
tar czf "${BACKUP_FILE}" \
    grafana-data-${TIMESTAMP}.tar.gz \
    prometheus-data-${TIMESTAMP}.tar.gz \
    loki-data-${TIMESTAMP}.tar.gz \
    postgres-${TIMESTAMP}.sql \
    influxdb-data-${TIMESTAMP}.tar.gz \
    configs-${TIMESTAMP}.tar.gz

# Cleanup individual backups
rm -f grafana-data-${TIMESTAMP}.tar.gz \
      prometheus-data-${TIMESTAMP}.tar.gz \
      loki-data-${TIMESTAMP}.tar.gz \
      postgres-${TIMESTAMP}.sql \
      influxdb-data-${TIMESTAMP}.tar.gz \
      configs-${TIMESTAMP}.tar.gz

cd ..

echo -e "${GREEN}   ✓ Combined backup created${NC}"
echo ""

# Display backup info
BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Backup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Backup file: ${GREEN}${BACKUP_DIR}/${BACKUP_FILE}${NC}"
echo -e "Backup size: ${GREEN}${BACKUP_SIZE}${NC}"
echo -e "Timestamp: ${GREEN}${TIMESTAMP}${NC}"
echo ""

# Cleanup old backups (keep last 7 days)
echo -e "${YELLOW}Cleaning up old backups (keeping last 7 days)...${NC}"
find "${BACKUP_DIR}" -name "grafana-stack-backup-*.tar.gz" -mtime +7 -delete
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""

echo -e "${GREEN}To restore this backup, run:${NC}"
echo -e "  ./scripts/restore.sh ${BACKUP_DIR}/${BACKUP_FILE}"
echo ""

#!/bin/bash
# ============================================
# Grafana Training Stack - Reset Script
# Data2AI Academy
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Grafana Training Stack - Reset${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Warning
echo -e "${RED}WARNING: This will delete ALL data and reset to clean state!${NC}"
echo -e "${RED}All dashboards, users, and metrics will be lost.${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no) " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Reset cancelled."
    exit 1
fi

# Confirm again
echo -e "${YELLOW}Last chance! Type 'RESET' to confirm:${NC}"
read -r CONFIRM
if [ "$CONFIRM" != "RESET" ]; then
    echo "Reset cancelled."
    exit 1
fi

echo ""
echo -e "${YELLOW}Starting reset process...${NC}"
echo ""

# Stop all services
echo -e "${YELLOW}1. Stopping all services...${NC}"
docker-compose down
echo -e "${GREEN}   ✓ Services stopped${NC}"

# Remove all volumes
echo -e "${YELLOW}2. Removing all volumes...${NC}"
docker-compose down -v
echo -e "${GREEN}   ✓ Volumes removed${NC}"

# Remove any orphaned containers
echo -e "${YELLOW}3. Cleaning up orphaned containers...${NC}"
docker-compose down --remove-orphans
echo -e "${GREEN}   ✓ Cleanup complete${NC}"

# Start services fresh
echo -e "${YELLOW}4. Starting services with fresh data...${NC}"
docker-compose up -d
echo -e "${GREEN}   ✓ Services starting...${NC}"

# Wait for services to be healthy
echo ""
echo -e "${YELLOW}5. Waiting for services to be healthy (60 seconds)...${NC}"
sleep 60

# Check service status
echo ""
echo -e "${YELLOW}6. Checking service status...${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Reset Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Stack has been reset to clean state."
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Access Grafana: http://localhost:3000"
echo "2. Login with: admin / admin123"
echo "3. Change default password"
echo "4. Data sources are auto-configured"
echo "5. Start training from Module 1"
echo ""

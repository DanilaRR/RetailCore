#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Webstore - Docker Compose Launcher${NC}"
echo -e "${BLUE}========================================${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed.${NC}"
    echo "Install Docker: https://www.docker.com"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}Docker Compose is not available.${NC}"
    echo "Install Docker Compose: https://docs.docker.com/compose/install"
    exit 1
fi

echo -e "${GREEN}Docker and Docker Compose are available.${NC}"
echo ""

echo -e "${YELLOW}Choose an action:${NC}"
echo "1) Start application (docker compose up -d)"
echo "2) Stop application (docker compose down)"
echo "3) Restart application"
echo "4) Show logs"
echo "5) Rebuild images"
echo "6) Remove containers and database volume"
echo "7) Show status"
echo "8) Exit"
echo ""

read -p "Enter a number (1-8): " choice

case $choice in
    1)
        echo -e "${BLUE}Starting containers...${NC}"
        docker compose up -d
        sleep 3
        echo -e "${GREEN}Containers started.${NC}"
        echo "Frontend:   http://localhost:5173"
        echo "Items API:  http://localhost:8081/api/items"
        echo "Auth API:   http://localhost:8082/api/auth/login"
        echo "PostgreSQL: localhost:5432"
        docker compose ps
        ;;
    2)
        echo -e "${BLUE}Stopping containers...${NC}"
        docker compose down
        ;;
    3)
        echo -e "${BLUE}Restarting application...${NC}"
        docker compose down
        docker compose up -d
        docker compose ps
        ;;
    4)
        docker compose logs -f
        ;;
    5)
        echo -e "${BLUE}Rebuilding images...${NC}"
        docker compose build --no-cache
        ;;
    6)
        echo -e "${RED}This removes containers, volumes, and database data.${NC}"
        read -p "Continue? (y/N): " confirm
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            docker compose down -v
        else
            echo "Canceled."
        fi
        ;;
    7)
        docker compose ps
        ;;
    8)
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice.${NC}"
        exit 1
        ;;
esac

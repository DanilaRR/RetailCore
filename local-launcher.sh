#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Webstore - Local Launcher${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

check_requirements() {
    local missing=0

    echo -e "${YELLOW}Checking required tools...${NC}"

    if ! command -v java &> /dev/null; then
        echo -e "${RED}Java is not installed.${NC}"
        missing=1
    else
        echo -e "${GREEN}Java found.${NC}"
    fi

    if ! command -v node &> /dev/null; then
        echo -e "${RED}Node.js is not installed.${NC}"
        missing=1
    else
        echo -e "${GREEN}Node.js found.${NC}"
    fi

    if ! command -v npm &> /dev/null; then
        echo -e "${RED}npm is not installed.${NC}"
        missing=1
    else
        echo -e "${GREEN}npm found.${NC}"
    fi

    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}Docker is not available. It is required for the local PostgreSQL helper.${NC}"
    else
        echo -e "${GREEN}Docker found.${NC}"
    fi

    if [ $missing -eq 1 ]; then
        echo ""
        echo -e "${RED}Install the missing tools and try again.${NC}"
        exit 1
    fi

    echo ""
}

start_postgres() {
    echo -e "${BLUE}Starting PostgreSQL...${NC}"

    if docker ps --format '{{.Names}}' | grep -q "^webstore-postgres$"; then
        echo -e "${YELLOW}PostgreSQL is already running.${NC}"
        return 0
    fi

    docker rm webstore-postgres 2>/dev/null || true

    docker run --name webstore-postgres \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=admin \
        -e POSTGRES_DB=site \
        -p 5432:5432 \
        -d postgres:15-alpine

    echo -e "${YELLOW}Waiting for PostgreSQL...${NC}"
    sleep 5

    if docker exec webstore-postgres pg_isready -U postgres > /dev/null 2>&1; then
        echo -e "${GREEN}PostgreSQL is ready.${NC}"
    else
        echo -e "${RED}PostgreSQL is not ready.${NC}"
        exit 1
    fi
}

check_requirements

echo -e "${YELLOW}Choose a launch option:${NC}"
echo "1) Start PostgreSQL only"
echo "2) Start frontend only"
echo "3) Start Security Service"
echo "4) Start Item Service"
echo "5) Show local development commands"
echo "6) Exit"
echo ""

read -p "Enter a number (1-6): " choice

case $choice in
    1)
        start_postgres
        ;;
    2)
        cd "$ROOT_DIR/frontend" || exit 1
        npm install
        npm run dev
        ;;
    3)
        start_postgres
        cd "$ROOT_DIR" || exit 1
        ./mvnw -f backend/pom.xml -pl security-service spring-boot:run
        ;;
    4)
        start_postgres
        cd "$ROOT_DIR" || exit 1
        ./mvnw -f backend/pom.xml -pl item-service spring-boot:run
        ;;
    5)
        echo "Terminal 1: make db-start"
        echo "Terminal 2: make security-dev"
        echo "Terminal 3: make items-dev"
        echo "Terminal 4: make frontend-dev"
        echo "Open http://localhost:5173 after the frontend starts."
        ;;
    6)
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice.${NC}"
        exit 1
        ;;
esac

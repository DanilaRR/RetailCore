#!/bin/bash

# Цвета
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🚀 Webstore - Локальный запуск${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Проверка требуемых инструментов
check_requirements() {
    local missing=0

    echo -e "${YELLOW}Проверка требуемых инструментов...${NC}"

    if ! command -v java &> /dev/null; then
        echo -e "${RED}❌ Java не установлена${NC}"
        missing=1
    else
        echo -e "${GREEN}✅ Java${NC}"
    fi

    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js не установлен${NC}"
        missing=1
    else
        echo -e "${GREEN}✅ Node.js${NC}"
    fi

    if ! command -v npm &> /dev/null; then
        echo -e "${RED}❌ npm не установлен${NC}"
        missing=1
    else
        echo -e "${GREEN}✅ npm${NC}"
    fi

    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}⚠️  Docker не найден (нужен для PostgreSQL)${NC}"
    else
        echo -e "${GREEN}✅ Docker${NC}"
    fi

    if [ $missing -eq 1 ]; then
        echo ""
        echo -e "${RED}Пожалуйста установите отсутствующие инструменты${NC}"
        exit 1
    fi

    echo ""
}

# Запуск PostgreSQL в Docker
start_postgres() {
    echo -e "${BLUE}🐘 Запуск PostgreSQL...${NC}"

    # Проверим, не запущен ли уже
    if docker ps | grep -q "webstore-postgres"; then
        echo -e "${YELLOW}⚠️  PostgreSQL уже запущен${NC}"
        return 0
    fi

    # Удалим старый контейнер если есть
    docker rm webstore-postgres 2>/dev/null

    # Запустим новый
    docker run --name webstore-postgres \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=admin \
        -e POSTGRES_DB=site \
        -p 5432:5432 \
        -d postgres:15-alpine

    # Ждем готовности БД
    echo -e "${YELLOW}⏳ Ожидание готовности БД...${NC}"
    sleep 5

    if docker exec webstore-postgres pg_isready -U postgres > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PostgreSQL готова${NC}"
    else
        echo -e "${RED}❌ PostgreSQL не готова${NC}"
        exit 1
    fi
}

check_requirements

echo -e "${YELLOW}Выберите вариант запуска:${NC}"
echo "1) 📦 Запустить Backend (оба сервиса в одном процессе)"
echo "2) 🎨 Запустить только Frontend"
echo "3) 🔐 Запустить Security Service (Terminal 1)"
echo "4) 📦 Запустить Item Service (Terminal 2)"
echo "5) ⚡ Запустить всё (требует 3 терминала)"
echo "6) ❌ Выход"
echo ""

read -p "Введите номер (1-6): " choice

case $choice in
    1)
        echo ""
        start_postgres
        echo ""
        echo -e "${BLUE}🔨 Сборка Backend...${NC}"
        cd backend
        ./mvnw clean install -DskipTests
        echo ""
        echo -e "${BLUE}▶️  Запуск Backend сервисов...${NC}"
        ./mvnw spring-boot:run
        ;;
    2)
        echo ""
        echo -e "${BLUE}📦 Установка npm зависимостей...${NC}"
        cd frontend
        npm install
        echo ""
        echo -e "${BLUE}▶️  Запуск Frontend (Ctrl+C для выхода)...${NC}"
        npm run dev
        ;;
    3)
        echo ""
        start_postgres
        echo ""
        echo -e "${BLUE}🔐 Запуск Security Service на порту 8082...${NC}"
        echo -e "${YELLOW}Рекомендация: откройте новый терминал для Item Service${NC}"
        echo ""
        cd backend/security-service
        ../../mvnw spring-boot:run
        ;;
    4)
        echo ""
        start_postgres
        echo ""
        echo -e "${BLUE}📦 Запуск Item Service на порту 8081...${NC}"
        echo -e "${YELLOW}Рекомендация: откройте новый терминал для Security Service${NC}"
        echo ""
        cd backend/item-service
        ../../mvnw spring-boot:run
        ;;
    5)
        echo ""
        start_postgres
        echo ""
        echo -e "${GREEN}✅ PostgreSQL запущена${NC}"
        echo ""
        echo -e "${YELLOW}Откройте 3 новых терминала и запустите:${NC}"
        echo ""
        echo -e "${BLUE}Terminal 1 - Security Service:${NC}"
        echo "cd backend/security-service && ../../mvnw spring-boot:run"
        echo ""
        echo -e "${BLUE}Terminal 2 - Item Service:${NC}"
        echo "cd backend/item-service && ../../mvnw spring-boot:run"
        echo ""
        echo -e "${BLUE}Terminal 3 - Frontend:${NC}"
        echo "cd frontend && npm install && npm run dev"
        echo ""
        echo "После запуска откройте в браузере: http://localhost:5173"
        ;;
    6)
        echo "Выход"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Неверный выбор${NC}"
        exit 1
        ;;
esac


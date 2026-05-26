#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🚀 Webstore - Docker Compose Launcher${NC}"
echo -e "${BLUE}========================================${NC}"

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker не установлен!${NC}"
    echo "Установите Docker: https://www.docker.com"
    exit 1
fi

# Проверка Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose не установлен!${NC}"
    echo "Установите Docker Compose: https://docs.docker.com/compose/install"
    exit 1
fi

echo -e "${GREEN}✅ Docker и Docker Compose найдены${NC}"
echo ""

# Опции
echo -e "${YELLOW}Выберите действие:${NC}"
echo "1) 🚀 Запустить приложение (docker-compose up -d)"
echo "2) 🛑 Остановить приложение (docker-compose down)"
echo "3) 🔄 Перезапустить приложение"
echo "4) 📋 Показать логи (Ctrl+C для выхода)"
echo "5) 🔨 Пересобрать образы"
echo "6) 🧹 Удалить контейнеры и данные"
echo "7) 📊 Проверить статус"
echo "8) ❌ Выход"
echo ""

read -p "Введите номер (1-8): " choice

case $choice in
    1)
        echo -e "${BLUE}🚀 Запуск контейнеров...${NC}"
        docker-compose up -d
        sleep 3
        echo ""
        echo -e "${GREEN}✅ Контейнеры запущены!${NC}"
        echo ""
        echo -e "${BLUE}📍 Доступные сервисы:${NC}"
        echo "🌐 Frontend:       http://localhost:5173"
        echo "📦 Items API:      http://localhost:8081/api/items"
        echo "🔐 Auth API:       http://localhost:8082/api/auth/login"
        echo "🐘 PostgreSQL:     localhost:5432"
        echo ""
        docker-compose ps
        ;;
    2)
        echo -e "${BLUE}🛑 Остановка контейнеров...${NC}"
        docker-compose down
        echo -e "${GREEN}✅ Контейнеры остановлены${NC}"
        ;;
    3)
        echo -e "${BLUE}🔄 Перезапуск приложения...${NC}"
        docker-compose down
        sleep 2
        docker-compose up -d
        sleep 3
        echo -e "${GREEN}✅ Приложение перезапущено!${NC}"
        docker-compose ps
        ;;
    4)
        echo -e "${BLUE}📋 Выводятся логи (нажмите Ctrl+C для выхода)${NC}"
        echo ""
        docker-compose logs -f
        ;;
    5)
        echo -e "${BLUE}🔨 Пересборка образов...${NC}"
        docker-compose build --no-cache
        echo -e "${GREEN}✅ Образы пересобраны${NC}"
        ;;
    6)
        echo -e "${RED}⚠️  Это удалит все контейнеры, волюмы и данные БД!${NC}"
        read -p "Вы уверены? (y/N): " confirm
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            echo -e "${BLUE}🧹 Удаление...${NC}"
            docker-compose down -v
            echo -e "${GREEN}✅ Удалено!${NC}"
        else
            echo "Отменено"
        fi
        ;;
    7)
        echo -e "${BLUE}📊 Статус контейнеров:${NC}"
        docker-compose ps
        echo ""
        echo -e "${BLUE}Проверка сервисов:${NC}"
        if curl -s http://localhost:5173 > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Frontend${NC}"
        else
            echo -e "${RED}❌ Frontend${NC}"
        fi
        if curl -s http://localhost:8081/actuator/health > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Item Service${NC}"
        else
            echo -e "${RED}❌ Item Service${NC}"
        fi
        if curl -s http://localhost:8082/actuator/health > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Security Service${NC}"
        else
            echo -e "${RED}❌ Security Service${NC}"
        fi
        ;;
    8)
        echo "Выход"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Неверный выбор${NC}"
        exit 1
        ;;
esac


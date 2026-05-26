.help:
	@echo "🚀 Webstore - Полезные команды"
	@echo ""
	@echo "Docker Commands:"
	@echo "  make docker-up          - Запустить все контейнеры"
	@echo "  make docker-down        - Остановить все контейнеры"
	@echo "  make docker-logs        - Просмотреть логи (Ctrl+C для выхода)"
	@echo "  make docker-build       - Пересобрать образы"
	@echo "  make docker-clean       - Удалить контейнеры и волюмы"
	@echo ""
	@echo "Backend Commands:"
	@echo "  make backend-build      - Собрать все backend модули"
	@echo "  make backend-test       - Запустить тесты backend"
	@echo "  make security-dev       - Запустить Security Service в dev режиме"
	@echo "  make items-dev          - Запустить Item Service в dev режиме"
	@echo ""
	@echo "Frontend Commands:"
	@echo "  make frontend-install   - Установить npm зависимости"
	@echo "  make frontend-dev       - Запустить frontend в dev режиме"
	@echo "  make frontend-build     - Собрать production сборку"
	@echo ""
	@echo "Database Commands:"
	@echo "  make db-start           - Запустить PostgreSQL в Docker"
	@echo "  make db-stop            - Остановить PostgreSQL"
	@echo ""
	@echo "Help:"
	@echo "  make help              - Показать эту справку"

.PHONY: help
help: .help

# Docker Commands
.PHONY: docker-up
docker-up:
	@echo "🐳 Запуск всех контейнеров..."
	docker-compose up -d
	@echo "✅ Контейнеры запущены!"
	@echo "🌐 Frontend: http://localhost:5173"

.PHONY: docker-down
docker-down:
	@echo "🛑 Остановка контейнеров..."
	docker-compose down

.PHONY: docker-logs
docker-logs:
	@echo "📋 Просмотр логов (Ctrl+C для выхода)..."
	docker-compose logs -f

.PHONY: docker-build
docker-build:
	@echo "🔨 Пересборка образов..."
	docker-compose build --no-cache

.PHONY: docker-clean
docker-clean:
	@echo "🧹 Удаление контейнеров и данных..."
	docker-compose down -v
	@echo "✅ Очищено!"

.PHONY: docker-ps
docker-ps:
	@echo "📊 Статус контейнеров:"
	docker-compose ps

# Backend Commands
.PHONY: backend-build
backend-build:
	@echo "🔨 Сборка backend модулей..."
	cd backend && ./mvnw clean install

.PHONY: backend-test
backend-test:
	@echo "🧪 Запуск тестов..."
	cd backend && ./mvnw test

.PHONY: security-dev
security-dev:
	@echo "🔐 Security Service запускается на порту 8082..."
	cd backend/security-service && ../../mvnw spring-boot:run

.PHONY: items-dev
items-dev:
	@echo "📦 Item Service запускается на порту 8081..."
	cd backend/item-service && ../../mvnw spring-boot:run

# Frontend Commands
.PHONY: frontend-install
frontend-install:
	@echo "📦 Установка npm зависимостей..."
	cd frontend && npm install

.PHONY: frontend-dev
frontend-dev:
	@echo "🎨 Frontend запускается на порту 5173..."
	cd frontend && npm run dev

.PHONY: frontend-build
frontend-build:
	@echo "🏗️  Сборка production версии..."
	cd frontend && npm run build

# Database Commands
.PHONY: db-start
db-start:
	@echo "🐘 Запуск PostgreSQL..."
	docker run --name webstore-postgres \
		-e POSTGRES_USER=postgres \
		-e POSTGRES_PASSWORD=admin \
		-e POSTGRES_DB=site \
		-p 5432:5432 \
		-d postgres:15-alpine
	@echo "✅ PostgreSQL запущен на localhost:5432"

.PHONY: db-stop
db-stop:
	@echo "🛑 Остановка PostgreSQL..."
	docker stop webstore-postgres || true
	docker rm webstore-postgres || true
	@echo "✅ PostgreSQL остановлен"

# Utility Commands
.PHONY: install-all
install-all: frontend-install backend-build
	@echo "✅ Все зависимости установлены!"

.PHONY: logs-security
logs-security:
	docker-compose logs -f security-service

.PHONY: logs-items
logs-items:
	docker-compose logs -f item-service

.PHONY: logs-postgres
logs-postgres:
	docker-compose logs -f postgres

.PHONY: logs-frontend
logs-frontend:
	docker-compose logs -f frontend

.PHONY: restart
restart: docker-down docker-up
	@echo "✅ Все перезапущено!"

.PHONY: status
status:
	@echo "📊 Статус приложения:"
	@echo "Docker контейнеры:"
	docker-compose ps
	@echo ""
	@echo "Проверка сервисов:"
	@curl -s http://localhost:8081/actuator/health 2>/dev/null && echo "✅ Item Service работает" || echo "❌ Item Service недоступен"
	@curl -s http://localhost:8082/actuator/health 2>/dev/null && echo "✅ Security Service работает" || echo "❌ Security Service недоступен"
	@curl -s http://localhost:5173 2>/dev/null && echo "✅ Frontend работает" || echo "❌ Frontend недоступен"

# Default target
.DEFAULT_GOAL := help


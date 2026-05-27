.PHONY: help
help:
	@echo "Webstore commands"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-up          Start all containers"
	@echo "  make docker-down        Stop all containers"
	@echo "  make docker-logs        Follow all container logs"
	@echo "  make docker-build       Rebuild Docker images"
	@echo "  make docker-clean       Stop containers and remove volumes"
	@echo "  make docker-ps          Show container status"
	@echo ""
	@echo "Backend:"
	@echo "  make backend-build      Build all backend modules"
	@echo "  make backend-test       Run backend tests"
	@echo "  make security-dev       Run Security Service locally on port 8082"
	@echo "  make items-dev          Run Item Service locally on port 8081"
	@echo ""
	@echo "Frontend:"
	@echo "  make frontend-install   Install npm dependencies"
	@echo "  make frontend-dev       Run Vite dev server"
	@echo "  make frontend-build     Build frontend for production"
	@echo ""
	@echo "Database:"
	@echo "  make db-start           Start PostgreSQL in Docker"
	@echo "  make db-stop            Stop PostgreSQL container"
	@echo ""
	@echo "Utility:"
	@echo "  make status             Check running services"

.PHONY: docker-up
docker-up:
	@echo "Starting containers..."
	docker compose up -d
	@echo "Containers started."
	@echo "Frontend: http://localhost:5173"

.PHONY: docker-down
docker-down:
	@echo "Stopping containers..."
	docker compose down

.PHONY: docker-logs
docker-logs:
	docker compose logs -f

.PHONY: docker-build
docker-build:
	@echo "Rebuilding Docker images..."
	docker compose build --no-cache

.PHONY: docker-clean
docker-clean:
	@echo "Stopping containers and removing volumes..."
	docker compose down -v

.PHONY: docker-ps
docker-ps:
	docker compose ps

.PHONY: backend-build
backend-build:
	@echo "Building backend modules..."
	./mvnw -f backend/pom.xml clean install

.PHONY: backend-test
backend-test:
	@echo "Running backend tests..."
	./mvnw -f backend/pom.xml test

.PHONY: security-dev
security-dev:
	@echo "Starting Security Service on port 8082..."
	./mvnw -f backend/pom.xml -pl security-service spring-boot:run

.PHONY: items-dev
items-dev:
	@echo "Starting Item Service on port 8081..."
	./mvnw -f backend/pom.xml -pl item-service spring-boot:run

.PHONY: frontend-install
frontend-install:
	cd frontend && npm install

.PHONY: frontend-dev
frontend-dev:
	cd frontend && npm run dev

.PHONY: frontend-build
frontend-build:
	cd frontend && npm run build

.PHONY: db-start
db-start:
	@echo "Starting PostgreSQL..."
	docker run --name webstore-postgres \
		-e POSTGRES_USER=postgres \
		-e POSTGRES_PASSWORD=admin \
		-e POSTGRES_DB=site \
		-p 5432:5432 \
		-d postgres:15-alpine
	@echo "PostgreSQL is available at localhost:5432"

.PHONY: db-stop
db-stop:
	@echo "Stopping PostgreSQL..."
	docker stop webstore-postgres || true
	docker rm webstore-postgres || true

.PHONY: install-all
install-all: frontend-install backend-build
	@echo "All dependencies are installed and backend modules are built."

.PHONY: logs-security
logs-security:
	docker compose logs -f security-service

.PHONY: logs-items
logs-items:
	docker compose logs -f item-service

.PHONY: logs-postgres
logs-postgres:
	docker compose logs -f postgres

.PHONY: logs-frontend
logs-frontend:
	docker compose logs -f frontend

.PHONY: restart
restart: docker-down docker-up

.PHONY: status
status:
	@echo "Containers:"
	@docker compose ps
	@echo ""
	@echo "Service checks:"
	@curl -s -o /dev/null http://localhost:5173 && echo "Frontend: reachable" || echo "Frontend: not reachable"
	@curl -s -o /dev/null http://localhost:8082/api/auth/login && echo "Security Service: reachable" || echo "Security Service: not reachable"
	@curl -s -o /dev/null http://localhost:8081/api/items && echo "Item Service: reachable" || echo "Item Service: not reachable"

.DEFAULT_GOAL := help

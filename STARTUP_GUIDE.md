# Startup Guide

## Requirements

For Docker startup:

- Docker with Docker Compose

For local development:

- Java 17+
- Node.js 18+
- npm
- Docker, if you want the helper command to start PostgreSQL

The Maven wrapper is included at the repository root as `./mvnw`.

## Docker Startup

```bash
docker compose up -d --build
```

Open:

- Frontend: `http://localhost:5173`
- Auth API: `http://localhost:8082/api/auth/login`
- Items API: `http://localhost:8081/api/items`

Stop containers:

```bash
docker compose down
```

Stop containers and remove database data:

```bash
docker compose down -v
```

## Local Startup

Run in separate terminals:

```bash
make db-start
make security-dev
make items-dev
make frontend-dev
```

The frontend command prints the exact Vite URL. It is usually `http://localhost:5173`.

## API Smoke Test

Register:

```bash
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@example.com","password":"password123"}'
```

Login:

```bash
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"password123"}'
```

Save the returned JWT and use it for protected endpoints:

```bash
curl http://localhost:8081/api/items \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

Create a category:

```bash
curl -X POST http://localhost:8081/api/categories \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Books"}'
```

Create an item:

```bash
curl -X POST "http://localhost:8081/api/items/upload" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -F "name=Clean Code" \
  -F "category=Books" \
  -F "price=39.99"
```

The same category and item creation flow is available in the frontend after login.

## Troubleshooting

Port is busy:

```bash
lsof -i :5173
lsof -i :8081
lsof -i :8082
```

Docker service logs:

```bash
docker compose logs -f security-service
docker compose logs -f item-service
docker compose logs -f postgres
```

Backend build:

```bash
./mvnw -f backend/pom.xml test
```

Frontend build:

```bash
cd frontend
npm run build
```

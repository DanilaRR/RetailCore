# RettailCore Webstore

Microservice e-commerce platform — Spring Boot backend, Vue 3 frontend, PostgreSQL, Docker.

## Services

| Service           | Port | Role                          |
|-------------------|-----:|-------------------------------|
| frontend          | 5173 | Vue 3 + Vite web app          |
| security-service  | 8082 | Registration, login, JWT      |
| item-service      | 8081 | Items, categories, images     |
| postgres          | 5432 | Shared PostgreSQL 15 database |

## Run with Docker

```bash
docker compose up -d --build
```

Open **http://localhost:5173** → register → create categories & items.

## Local Development

```bash
make db-start        # PostgreSQL only (terminal 1)
make security-dev    # port 8082       (terminal 2)
make items-dev       # port 8081       (terminal 3)
make frontend-dev    # port 5173       (terminal 4)
```

## API Quick Reference

```bash
# Register
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@example.com","password":"password123"}'

# Login → copy the returned token
TOKEN=$(curl -s -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"password123"}')

# Use token
curl http://localhost:8081/api/categories -H "Authorization: Bearer $TOKEN"
curl http://localhost:8081/api/items      -H "Authorization: Bearer $TOKEN"
```

## Tech Stack

- **Backend**: Java 21, Spring Boot 3, Spring Security, JWT (HS256), Hibernate
- **Frontend**: Vue 3 (Composition API), TypeScript, Vite, Axios, vue-advanced-cropper
- **DB**: PostgreSQL 15, schema auto-managed by Hibernate (`ddl-auto: update`)
- **Infra**: Docker Compose, Maven multi-module

---
*Русская версия: [README_RU.md](README_RU.md)*

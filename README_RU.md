# RettailCore Webstore

Интернет-магазин на микросервисах — Spring Boot, Vue 3, PostgreSQL, Docker.

## Сервисы

| Сервис            | Порт | Назначение                        |
|-------------------|-----:|-----------------------------------|
| frontend          | 5173 | Vue 3 + Vite веб-приложение       |
| security-service  | 8082 | Регистрация, вход, выдача JWT     |
| item-service      | 8081 | Товары, категории, изображения    |
| postgres          | 5432 | Общая база данных PostgreSQL 15   |

## Запуск через Docker

```bash
docker compose up -d --build
```

Откройте **http://localhost:5173** → зарегистрируйтесь → создайте категории и товары.

## Локальная разработка

```bash
make db-start        # только PostgreSQL  (терминал 1)
make security-dev    # порт 8082          (терминал 2)
make items-dev       # порт 8081          (терминал 3)
make frontend-dev    # порт 5173          (терминал 4)
```

## Быстрые примеры API

```bash
# Регистрация
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@example.com","password":"password123"}'

# Вход → сохрани токен
TOKEN=$(curl -s -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"password123"}')

# Использование токена
curl http://localhost:8081/api/categories -H "Authorization: Bearer $TOKEN"
curl http://localhost:8081/api/items      -H "Authorization: Bearer $TOKEN"
```

## Технологии

- **Backend**: Java 21, Spring Boot 3, Spring Security, JWT (HS256), Hibernate
- **Frontend**: Vue 3 (Composition API), TypeScript, Vite, Axios, vue-advanced-cropper
- **БД**: PostgreSQL 15, схема управляется Hibernate (`ddl-auto: update`)
- **Инфра**: Docker Compose, Maven multi-module

---
*English version: [README.md](README.md)*

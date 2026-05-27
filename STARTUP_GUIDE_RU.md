# Руководство по запуску

## Требования

Для Docker-запуска:

- Docker с Docker Compose

Для локальной разработки:

- Java 17+
- Node.js 18+
- npm
- Docker, если хотите запускать PostgreSQL helper-командой

Maven wrapper находится в корне репозитория: `./mvnw`.

## Запуск через Docker

```bash
docker compose up -d --build
```

Адреса:

- Frontend: `http://localhost:5173`
- Auth API: `http://localhost:8082/api/auth/login`
- Items API: `http://localhost:8081/api/items`

Остановить контейнеры:

```bash
docker compose down
```

Остановить контейнеры и удалить данные БД:

```bash
docker compose down -v
```

## Локальный запуск

Запустите в отдельных терминалах:

```bash
make db-start
make security-dev
make items-dev
make frontend-dev
```

Frontend-команда выведет точный Vite URL. Обычно это `http://localhost:5173`.

## Проверка API

Регистрация:

```bash
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@example.com","password":"password123"}'
```

Вход:

```bash
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"password123"}'
```

Сохраните JWT и используйте его для защищённых endpoints:

```bash
curl http://localhost:8081/api/items \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

Создать категорию:

```bash
curl -X POST http://localhost:8081/api/categories \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Books"}'
```

Создать товар:

```bash
curl -X POST "http://localhost:8081/api/items/upload" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -F "name=Clean Code" \
  -F "category=Books" \
  -F "price=39.99"
```

Этот же сценарий создания категорий и товаров доступен во frontend после входа.

## Диагностика

Порт занят:

```bash
lsof -i :5173
lsof -i :8081
lsof -i :8082
```

Логи Docker-сервисов:

```bash
docker compose logs -f security-service
docker compose logs -f item-service
docker compose logs -f postgres
```

Проверка backend:

```bash
./mvnw -f backend/pom.xml test
```

Проверка frontend:

```bash
cd frontend
npm run build
```

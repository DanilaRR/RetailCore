# Настройка проекта

## Runtime-схема

Docker Compose запускает:

- `postgres` на порту `5432`
- `security-service` на порту `8082`
- `item-service` на порту `8081`
- `frontend` на порту `5173`

Для локальной разработки база называется `site`, пользователь `postgres`, пароль `admin`.

## Backend

Backend - Maven multi-module проект в `backend/pom.xml`.

Активные runtime-модули:

- `security-service`
- `item-service`

Объявленные, но сейчас пустые модули:

- `gateway`
- `common`

Сборка и тесты:

```bash
./mvnw -f backend/pom.xml test
./mvnw -f backend/pom.xml clean install
```

## Frontend

Frontend - Vue 3 и Vite приложение в каталоге `frontend`.

```bash
cd frontend
npm install
npm run dev
npm run build
```

## Helper-команды

Актуальный список команд:

```bash
make help
```

Частые команды:

```bash
make docker-up
make docker-down
make backend-test
make frontend-build
make status
```

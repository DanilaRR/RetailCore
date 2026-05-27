# RettailCore Webstore

Microservice-style webstore template with Spring Boot, Vue 3, TypeScript, PostgreSQL, and Docker.

## Services

| Service | Port | Purpose |
| --- | ---: | --- |
| frontend | 5173 | Vue/Vite web app |
| security-service | 8082 | Registration, login, JWT issuing |
| item-service | 8081 | Items and categories API |
| postgres | 5432 | PostgreSQL database |

The `gateway` and `common` Maven modules are present, but they do not currently contain runtime code and are not started by Docker Compose.

## Quick Start

```bash
docker compose up -d --build
```

Open `http://localhost:5173`.
After login, the app opens the catalog page where you can create categories, create items inside categories, and see both lists update immediately.

## Local Development

Use separate terminals:

```bash
make db-start
make security-dev
make items-dev
make frontend-dev
```

If Vite reports that port `5173` is busy, it will choose the next available port. Backend CORS allows local Vite ports.

## API Examples

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

List items:

```bash
curl http://localhost:8081/api/items \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

## Documentation

- [QUICK_START.md](QUICK_START.md)
- [STARTUP_GUIDE.md](STARTUP_GUIDE.md)
- [SETUP.md](SETUP.md)
- [README_RU.md](README_RU.md)
- [QUICK_START_RU.md](QUICK_START_RU.md)
- [STARTUP_GUIDE_RU.md](STARTUP_GUIDE_RU.md)
- [SETUP_RU.md](SETUP_RU.md)

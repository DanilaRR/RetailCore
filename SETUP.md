# Project Setup

## Runtime Layout

Docker Compose starts:

- `postgres` on port `5432`
- `security-service` on port `8082`
- `item-service` on port `8081`
- `frontend` on port `5173`

The database name is `site`, with user `postgres` and password `admin` for local development.

## Backend

The backend is a Maven multi-module project in `backend/pom.xml`.

Active runtime modules:

- `security-service`
- `item-service`

Declared but currently empty modules:

- `gateway`
- `common`

Build and test:

```bash
./mvnw -f backend/pom.xml test
./mvnw -f backend/pom.xml clean install
```

## Frontend

The frontend is a Vue 3 and Vite application in `frontend`.

```bash
cd frontend
npm install
npm run dev
npm run build
```

## Helper Commands

Use `make help` for the current command list.

Most useful commands:

```bash
make docker-up
make docker-down
make backend-test
make frontend-build
make status
```

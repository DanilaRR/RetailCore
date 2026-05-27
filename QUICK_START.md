# Quick Start

## Docker

```bash
docker compose up -d --build
```

Open `http://localhost:5173`.

Useful commands:

```bash
docker compose ps
docker compose logs -f
docker compose down
```

## Local Development

Run each command in a separate terminal:

```bash
make db-start
make security-dev
make items-dev
make frontend-dev
```

Open the Vite URL printed by `make frontend-dev`. The default is `http://localhost:5173`.

## First UI Check

1. Open the frontend.
2. Register a user.
3. Log in with the registered email and password.
4. Create a category.
5. Create an item in that category.

The catalog page updates categories and items immediately after successful creation.

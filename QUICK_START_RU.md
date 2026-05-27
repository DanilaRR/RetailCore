# Быстрый старт

## Docker

```bash
docker compose up -d --build
```

Откройте `http://localhost:5173`.

Полезные команды:

```bash
docker compose ps
docker compose logs -f
docker compose down
```

## Локальная разработка

Запустите каждую команду в отдельном терминале:

```bash
make db-start
make security-dev
make items-dev
make frontend-dev
```

Откройте URL, который выведет Vite. По умолчанию это `http://localhost:5173`.

## Первая проверка UI

1. Откройте frontend.
2. Зарегистрируйте пользователя.
3. Войдите по email и паролю.
4. Создайте категорию.
5. Создайте товар в этой категории.

Страница каталога обновляет категории и товары сразу после успешного создания.

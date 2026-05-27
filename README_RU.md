# RettailCore Webstore

Шаблон интернет-магазина на Spring Boot, Vue 3, TypeScript, PostgreSQL и Docker.

## Сервисы

| Сервис | Порт | Назначение |
| --- | ---: | --- |
| frontend | 5173 | Vue/Vite веб-приложение |
| security-service | 8082 | Регистрация, вход, выдача JWT |
| item-service | 8081 | API товаров и категорий |
| postgres | 5432 | База данных PostgreSQL |

Модули Maven `gateway` и `common` объявлены, но сейчас не содержат runtime-кода и не запускаются через Docker Compose.

## Быстрый запуск

```bash
docker compose up -d --build
```

Откройте `http://localhost:5173`.
После входа приложение открывает страницу каталога, где можно создать категорию, создать товар в этой категории и сразу увидеть обновлённые списки.

## Локальная разработка

Запустите в отдельных терминалах:

```bash
make db-start
make security-dev
make items-dev
make frontend-dev
```

Если порт `5173` занят, Vite выберет следующий свободный порт. Backend CORS разрешает локальные Vite-порты.

## Документация

- [QUICK_START_RU.md](QUICK_START_RU.md)
- [STARTUP_GUIDE_RU.md](STARTUP_GUIDE_RU.md)
- [SETUP_RU.md](SETUP_RU.md)
- [README.md](README.md)

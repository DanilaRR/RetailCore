# 🚀 Webstore - Руководство по запуску

Это полное руководство по запуску проекта webstore локально с использованием npm и Docker.

---

## 📋 Требования

### Для локального запуска (без Docker):
- **Node.js** 18+ (для Frontend)
- **Java 17+** (для Backend)
- **Maven** 3.9+ или встроенный `mvnw`
- **PostgreSQL** 13+ (или запустить в Docker)
- **npm** или **yarn**

### Для Docker запуска:
- **Docker** 20.10+
- **Docker Compose** 2.0+

---

## 🔧 Вариант 1: Локальный запуск (без Docker)

### Шаг 1: Подготовка PostgreSQL

Если PostgreSQL не установлен, запустите его через Docker:

```bash
docker run --name webstore-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=admin \
  -e POSTGRES_DB=site \
  -p 5432:5432 \
  -d postgres:15-alpine
```

Или используйте локальный PostgreSQL. Убедитесь, что:
- Базы данных: `site`
- Пользователь: `postgres`
- Пароль: `admin`
- Порт: `5432`

### Шаг 2: Запуск Backend сервисов

#### Вариант А: Запуск обоих сервисов одной командой

```bash
cd backend
./mvnw clean install
./mvnw spring-boot:run
```

#### Вариант Б: Запуск каждого сервиса отдельно

**Terminal 1 - Security Service (порт 8082):**
```bash
cd backend/security-service
../../mvnw spring-boot:run
```

**Terminal 2 - Item Service (порт 8081):**
```bash
cd backend/item-service
../../mvnw spring-boot:run
```

### Шаг 3: Запуск Frontend

```bash
cd frontend
npm install
npm run dev
```

Фронтенд будет доступен на `http://localhost:5173`

### Проверка работоспособности

```bash
# Security Service
curl http://localhost:8082/actuator/health

# Item Service
curl http://localhost:8081/actuator/health

# Или через браузер
http://localhost:5173
```

---

## 🐳 Вариант 2: Запуск с Docker Compose (Рекомендуется)

### Шаг 1: Убедитесь, что Docker и Docker Compose установлены

```bash
docker --version
docker-compose --version
```

### Шаг 2: Запустите все контейнеры

```bash
cd webstore
docker-compose up -d
```

### Шаг 3: Дождитесь инициализации

```bash
# Проверить логи
docker-compose logs -f

# Или проверить статус контейнеров
docker-compose ps
```

### Шаг 4: Приложение готово

- **Frontend**: http://localhost:5173
- **Item Service**: http://localhost:8081/api/items
- **Security Service**: http://localhost:8082/api/auth/login
- **PostgreSQL**: localhost:5432

### Остановка контейнеров

```bash
docker-compose down

# Или если нужно удалить также данные БД
docker-compose down -v
```

---

## 🧪 Тестирование API

### Регистрация нового пользователя

```bash
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Вход и получение JWT токена

```bash
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

Сохраните полученный токен для других запросов.

### Получение списка товаров

```bash
curl -X GET http://localhost:8081/api/items \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Создание категории

```bash
curl -X POST http://localhost:8081/api/categories \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Electronics"
  }'
```

### Добавление товара

```bash
curl -X POST http://localhost:8081/api/items/upload \
  -d "name=Laptop" \
  -d "category=Electronics" \
  -d "price=999.99" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 🔍 Полезные команды

### Docker Compose

```bash
# Просмотр логов конкретного сервиса
docker-compose logs -f item-service
docker-compose logs -f security-service
docker-compose logs -f postgres

# Перез запуск сервиса
docker-compose restart item-service

# Удаление конкретного контейнера
docker-compose rm security-service

# Пересборка образов
docker-compose build --no-cache
```

### Maven

```bash
# Полная чистка и сборка всего проекта
./mvnw clean install

# Сборка конкретного модуля
./mvnw clean package -pl security-service

# Пропуск тесты при сборке
./mvnw clean package -DskipTests
```

### npm

```bash
# Установка зависимостей
npm install

# Запуск в режиме разработки
npm run dev

# Сборка для production
npm run build

# Предпросмотр production сборки
npm run preview
```

---

## 🐛 Решение проблем

### Проблема: Port уже занят

```bash
# Найдите процесс на порту
lsof -i :8081
lsof -i :8082
lsof -i :5173

# Убейте процесс
kill -9 <PID>
```

### Проблема: PostgreSQL не подключается

```bash
# Проверьте, работает ли PostgreSQL
docker ps | grep postgres

# Перезапустите контейнер
docker-compose restart postgres

# Проверьте логи
docker-compose logs postgres
```

### Проблема: Frontend не видит Backend

1. Убедитесь, что все сервисы запущены
2. Проверьте URL'ы в Frontend (по умолчанию: localhost:8081, localhost:8082)
3. Убедитесь, что CORS настроен в Back' ende

### Проблема: Build ошибки

```bash
# Очистите Maven кэш
rm -rf ~/.m2/repository

# Попробуйте снова
./mvnw clean install
```

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│              Frontend (Vue.js 3)                     │
│              http://localhost:5173                  │
└────────────────────┬────────────────────────────────┘
                     │ HTTP/REST
         ┌───────────┼───────────┐
         │           │           │
    ┌────▼────┐ ┌───▼────┐ ┌──▼──────┐
    │ Gateway │ │Security│ │  Item   │
    │(8080)   │ │Service │ │ Service │
    │         │ │(8082)  │ │ (8081)  │
    └────┬────┘ └───┬────┘ └──┬──────┘
         │          │         │
         └──────────┼─────────┘
                    │
            ┌───────▼────────┐
            │  PostgreSQL    │
            │  (5432)        │
            └────────────────┘
```

---

## ✅ Production Deployment Checklist

- [ ] All services running: `docker-compose ps`
- [ ] Frontend accessible: `http://localhost:5173`
- [ ] API endpoints responding
- [ ] Database migrations applied
- [ ] JWT tokens generated correctly
- [ ] CORS properly configured
- [ ] SSL/TLS configured (production)
- [ ] Database backups configured
- [ ] Logging configured
- [ ] Monitoring setup

---

## 📚 Additional Resources

- [Vue 3 Documentation](https://vuejs.org/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Maven Documentation](https://maven.apache.org/)

---

## 🆘 Quick Help

| Issue | Solution |
|-------|----------|
| Port 5173 in use | `kill -9 $(lsof -t -i :5173)` |
| Docker won't start | `docker-compose logs postgres` |
| Maven build fails | `rm -rf ~/.m2/repository && ./mvnw clean install` |
| Frontend can't reach API | Check CORS settings and backend URLs |
| Database empty | Check Hibernate DDL-auto is set to `update` |

---

## 🎉 You're Ready!

Choose your deployment method and start building your custom store:

```bash
# Quick: Docker Compose
docker-compose up -d

# Manual: Local development
./local-launcher.sh
```

**Happy building! 🚀**


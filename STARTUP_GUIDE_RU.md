# 🚀 RettailCore - Полное руководство запуска

Полное руководство по развёртыванию RettailCore локально с помощью npm, Docker или Docker Compose.

---

## 📋 Требования

### Для развёртывания Docker (рекомендуется):
- **Docker** 20.10+
- **Docker Compose** 2.0+

### Для локальной разработки:
- **Node.js** 18+ (Frontend)
- **Java 17+** (Backend)
- **Maven** 3.9+
- **PostgreSQL** 13+ (или Docker)
- **npm** 9+

---

## 🔧 Вариант 1: Локальное развёртывание (без Docker)

### Шаг 1: Запустите PostgreSQL

Если PostgreSQL не установлен локально, запустите через Docker:

```bash
docker run --name rettailcore-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=admin \
  -e POSTGRES_DB=site \
  -p 5432:5432 \
  -d postgres:15-alpine
```

Или настройте локальный PostgreSQL:
- База данных: `site`
- Пользователь: `postgres`
- Пароль: `admin`
- Порт: `5432`

### Шаг 2: Сборка и запуск Backend

**Вариант A: Запустить оба сервиса вместе**

```bash
cd backend
./mvnw clean install
./mvnw spring-boot:run
```

**Вариант B: Запустить каждый сервис в отдельном терминале**

**Терминал 1 - Security Service (порт 8082):**
```bash
cd backend/security-service
../../mvnw spring-boot:run
```

**Терминал 2 - Item Service (порт 8081):**
```bash
cd backend/item-service
../../mvnw spring-boot:run
```

### Шаг 3: Запустите Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend будет доступен на: `http://localhost:5173`

### Проверьте, что всё работает

```bash
# Security Service
curl http://localhost:8082/actuator/health

# Item Service
curl http://localhost:8081/actuator/health

# Frontend
http://localhost:5173
```

---

## 🐳 Вариант 2: Развёртывание Docker Compose (рекомендуется)

### Шаг 1: Проверьте установку Docker

```bash
docker --version
docker-compose --version
```

### Шаг 2: Запустите все сервисы

```bash
cd rettailcore
docker-compose up -d
```

### Шаг 3: Дождитесь инициализации

```bash
# Просмотреть логи сервисов
docker-compose logs -f

# Проверить статус контейнеров
docker-compose ps
```

### Шаг 4: Доступ к приложению

- **Frontend**: http://localhost:5173
- **Item Service**: http://localhost:8081/api/items
- **Security Service**: http://localhost:8082/api/auth/login
- **PostgreSQL**: localhost:5432

### Остановка сервисов

```bash
docker-compose down

# Удаление данных
docker-compose down -v
```

---

## 🧪 Тестирование API

### Регистрация нового пользователя

```bash
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "SecurePass123!"
  }'
```

### Вход и получение JWT токена

```bash
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123!"
  }'
# Ответ: JWT токен
```

### Получить список товаров

```bash
TOKEN="ваш_jwt_токен"

curl -X GET http://localhost:8081/api/items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### Создать категорию товаров

```bash
curl -X POST http://localhost:8081/api/categories \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Электроника"
  }'
```

### Добавить товар

```bash
curl -X POST http://localhost:8081/api/items/upload \
  -d "name=Ноутбук Pro" \
  -d "category=Электроника" \
  -d "price=1299.99" \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🔍 Полезные Docker Compose команды

### Просмотр логов конкретного сервиса

```bash
docker-compose logs -f item-service
docker-compose logs -f security-service
docker-compose logs -f postgres
```

### Перезапуск сервисов

```bash
# Конкретный сервис
docker-compose restart item-service

# Все сервисы
docker-compose restart

# Полная пересборка
docker-compose build --no-cache
docker-compose up -d
```

### Удаление сервисов

```bash
# Остановить без удаления
docker-compose stop

# Удалить контейнеры, но сохранить данные
docker-compose down

# Удалить всё включая данные
docker-compose down -v
```

### Управление базой данных

```bash
# Доступ к PostgreSQL CLI
docker-compose exec postgres psql -U postgres -d site

# Просмотр использования ресурсов
docker-compose stats
```

## 🔧 Команды Maven

### Сборка проекта

```bash
# Сборка всего проекта
./mvnw clean install

# Сборка конкретного модуля
./mvnw clean package -pl security-service

# Пропустить тесты
./mvnw clean package -DskipTests
```

### Запуск тестов

```bash
./mvnw test

# Тесты конкретного модуля
./mvnw test -pl item-service
```

## 📦 Команды npm

### Установка зависимостей

```bash
npm install
```

### Сервер разработки

```bash
npm run dev
```

### Production сборка

```bash
npm run build
```

### Предпросмотр production сборки

```bash
npm run preview
```

---

## 🛠️ Команды Makefile

Быстрый доступ к частым операциям:

```bash
# Docker операции
make docker-up              # Запустить все контейнеры
make docker-down            # Остановить все контейнеры
make docker-logs            # Просмотреть логи
make docker-build           # Пересобрать образы
make docker-clean           # Удалить все данные

# Backend операции
make backend-build          # Собрать backend
make backend-test           # Запустить тесты
make security-dev           # Security Service разработка
make items-dev              # Item Service разработка

# Frontend операции
make frontend-install       # Установить зависимости
make frontend-dev           # Сервер разработки
make frontend-build         # Production сборка

# Операции с БД
make db-start               # Запустить PostgreSQL
make db-stop                # Остановить PostgreSQL

# Справка
make help                   # Показать все команды
```

---

## ⚙️ Конфигурация окружения

### Использование .env файла

```bash
# Скопировать пример
cp .env.example .env

# Редактировать при необходимости
nano .env
```

### Ключевые переменные

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=admin
POSTGRES_DB=site
POSTGRES_HOST=postgres

SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/site
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=admin

JWT_SECRET=ваш-секретный-ключ
JWT_EXPIRATION=3600000

FRONTEND_PORT=5173
ITEM_SERVICE_PORT=8081
SECURITY_SERVICE_PORT=8082
```

---

## 🐛 Решение проблем

### Порт уже занят

```bash
# Найдите процесс на порту
lsof -i :5173
lsof -i :8081
lsof -i :8082
lsof -i :5432

# Убейте процесс
kill -9 <PID>
```

### PostgreSQL не подключается

```bash
# Проверьте логи
docker-compose logs postgres

# Перезапустите БД
docker-compose restart postgres

# Проверьте подключение
docker-compose exec postgres pg_isready -U postgres
```

### Frontend не видит Backend

1. Проверьте, что все сервисы запущены: `docker-compose ps`
2. Проверьте URL'ы backend в коде frontend (по умолчанию: localhost:8081, localhost:8082)
3. Убедитесь, что CORS настроен в backend
4. Проверьте консоль браузера на ошибки

### Ошибки сборки Maven

```bash
# Очистить кэш Maven
rm -rf ~/.m2/repository

# Повторить сборку
./mvnw clean install

# Проверить версию Java
java -version  # Должна быть 17+
```

### Ошибки Docker сборки

```bash
# Очистить Docker систему
docker system prune -a

# Принудительная пересборка
docker-compose build --no-cache

# Просмотр детальных логов
docker-compose build --no-cache 2>&1 | tee build.log
```

---

## 📊 Архитектура

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

## ✅ Чек-лист перед production

- [ ] Все сервисы запущены: `docker-compose ps`
- [ ] Frontend доступен: `http://localhost:5173`
- [ ] API endpoints отвечают
- [ ] Миграции БД применены
- [ ] JWT токены генерируются корректно
- [ ] CORS правильно настроен
- [ ] SSL/TLS настроен (для production)
- [ ] Резервные копии БД настроены
- [ ] Логирование настроено
- [ ] Мониторинг установлен

---

## 📚 Дополнительные ресурсы

- [Vue 3 Документация](https://vuejs.org/)
- [Spring Boot Документация](https://spring.io/projects/spring-boot)
- [Docker Документация](https://docs.docker.com/)
- [PostgreSQL Документация](https://www.postgresql.org/docs/)
- [Maven Документация](https://maven.apache.org/)

---

## 🆘 Быстрая справка

| Проблема | Решение |
|----------|---------|
| Порт 5173 занят | `kill -9 $(lsof -t -i :5173)` |
| Docker не запускается | `docker-compose logs postgres` |
| Maven не собирается | `rm -rf ~/.m2/repository && ./mvnw clean install` |
| Frontend не видит API | Проверьте CORS и URL'ы backend |
| БД пустая | Проверьте Hibernate DDL-auto = `update` |

---

## 🎉 Всё готово!

Выберите метод развёртывания и начните создавать ваш магазин:

```bash
# Быстро: Docker Compose
docker-compose up -d

# Вручную: Локальная разработка
./local-launcher.sh
```

**Удачной разработки! 🚀**


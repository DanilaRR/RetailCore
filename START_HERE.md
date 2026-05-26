# 🎉 Инструкции по запуску Webstore

## 📌 Созданные файлы

Я подготовил полный setup для запуска проекта. Вот что было создано:

### 📁 Новые файлы в корне проекта:
```
webstore/
├── 🐳 docker-compose.yml       ← Основной Docker конфиг
├── 📚 README.md                ← Главная документация
├── ⚡ QUICK_START.md           ← Быстрый старт (2 минуты)
├── 📖 STARTUP_GUIDE.md         ← Полное руководство (120+ строк)
├── 📝 SETUP.md                 ← Что было создано
├── 🛠️  Makefile                ← 30+ полезных команд
├── 📋 .env.example             ← Переменные окружения
├── 🐳 docker-launcher.sh       ← Интерактивный скрипт Docker
└── 💻 local-launcher.sh        ← Интерактивный скрипт локально

backend/
├── Dockerfile.security         ← Image для Security Service
├── Dockerfile.item             ← Image для Item Service
└── .dockerignore

frontend/
├── Dockerfile                  ← Image для Frontend
└── .dockerignore
```

---

## 🚀 БЫСТРЫЙ ЗАПУСК (выберите один вариант)

### ✅ Вариант 1: Docker Compose (рекомендуется) - **2 минуты**

```bash
docker-compose up -d
```

*Готово! Откройте:* http://localhost:5173

---

### ✅ Вариант 2: Интерактивный скрипт Docker

```bash
./docker-launcher.sh
```

Выберите нужное действие из меню.

---

### ✅ Вариант 3: Интерактивный скрипт локально

```bash
./local-launcher.sh
```

Выберите вариант запуска (с автоматическим запуском PostgreSQL).

---

### ✅ Вариант 4: Makefile команды

```bash
make docker-up          # Запустить всё
make docker-logs        # Посмотреть логи
make frontend-dev       # Только фронтенд
make items-dev          # Только товары
make security-dev       # Только авторизация
```

---

## 🔍 После запуска

### Доступные сервисы:

| Сервис | URL | Описание |
|--------|-----|---------|
| 🌐 Frontend | http://localhost:5173 | Веб-приложение |
| 📦 Item API | http://localhost:8081 | Товары и категории |
| 🔐 Auth API | http://localhost:8082 | Логин/регистрация |
| 🐘 PostgreSQL | localhost:5432 | База данных |

### Первые действия:

1. Откройте http://localhost:5173 в браузере
2. Нажмите **"Register"**
3. Создайте аккаунт
4. Войдите в систему
5. Добавьте товары через API

---

## 🧪 Тестовые запросы

### Регистрация
```bash
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Вход (получить JWT)
```bash
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Товары (требует JWT)
```bash
curl http://localhost:8081/api/items \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

---

## 📚 Документация

| Файл | Для чего | Когда читать |
|------|----------|-------------|
| **README.md** | Обзор проекта | 👈 Начните отсюда |
| **QUICK_START.md** | Быстрый старт | Нужен быстрый запуск |
| **STARTUP_GUIDE.md** | Молное руководство | Проблемы или специфика |
| **SETUP.md** | Подробно о конфиге | Хотите настроить |

---

## 🛑 Основные команды

### Docker Compose
```bash
docker-compose up -d              # Запустить
docker-compose down               # Остановить
docker-compose logs -f            # Логи
docker-compose restart            # Перезапуск
docker-compose down -v            # Удалить всё
```

### Makefile (еще проще)
```bash
make help                         # Все команды
make docker-up                    # Запуск
make docker-down                  # Остановка
make docker-logs                  # Логи
make restart                      # Перезапуск
make status                       # Статус
```

---

## 🐛 Если что-то не работает

### Порт занят?
```bash
lsof -i :5173    # Найти процесс
kill -9 <PID>    # Убить процесс
```

### PostgreSQL ошибка?
```bash
docker-compose logs postgres
docker-compose restart postgres
```

### Помочь?
1. Посмотрите логи: `make docker-logs`
2. Почитайте STARTUP_GUIDE.md
3. Перезапустите: `docker-compose restart`

---

## 💡 Полезные советы

1. **Первый запуск?** → Используйте `docker-compose up -d`
2. **Проблемы с Docker?** → Используйте `./local-launcher.sh`
3. **Нужны команды?** → `make help` или смотрите Makefile
4. **Медленная сборка?** → Пересоздайте образы: `make docker-build`
5. **Потеряли токен?** → Откройте DevTools (F12) → Application → localStorage

---

## 📊 Архитектура

```
Браузер (http://localhost:5173)
    ↓
Frontend (Vue.js 3 + TypeScript)
    ├→ Security Service (8082) - логин/регистрация
    └→ Item Service (8081) - товары
         ↓
    PostgreSQL (5432)
```

---

## 🎯 Развитие проекта дальше

### Добавить новый endpoint?
Редактируйте файлы в `backend/item-service/src/main/java/com/danrdev/item/`

### Изменить фронтенд?
Редактируйте файлы в `frontend/src/`

### Нужна горячая перезагрузка?
```bash
# Terminal 1
make db-start

# Terminal 2
make frontend-dev

# Terminal 3
make items-dev

# Terminal 4
make security-dev
```

---

## ✅ Checklist после запуска

- [ ] Docker Compose запущен (`docker-compose ps`)
- [ ] Frontend работает (http://localhost:5173)
- [ ] Можно зарегистрироваться
- [ ] Можно войти в систему
- [ ] Видны товары/категории (если они добавлены)
- [ ] API отвечает на запросы

Если всё пункты выполнены ✅ - проект готов к разработке!

---

## 🚀 Запуск Production сборки

```bash
# Build Frontend
npm run build

# Build Backend
./mvnw clean package -DskipTests

# Build Docker образы
docker-compose build --no-cache
```

---

## 📞 Контакты

**Документация:**
- `/README.md` - Главная
- `/QUICK_START.md` - Быстрый старт
- `/STARTUP_GUIDE.md` - Полное руководство
- `/SETUP.md` - Подробно о конфигурации

**Скрипты:**
- `./docker-launcher.sh` - Docker меню
- `./local-launcher.sh` - Локальное меню
- Makefile - Команды

---

## 🎉 ВСЁ ГОТОВО К ЗАПУСКУ!

### Один из двух способов:

**Docker (рекомендуется):**
```bash
docker-compose up -d
# Откройте http://localhost:5173
```

**Локально:**
```bash
./local-launcher.sh
# Выберите вариант
```

---

**Начните разработку! 💻**

`Успеха!`


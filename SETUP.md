# 📚 Что было создано для запуска проекта

## 📋 Созданные файлы

### 1. **Docker Configuration**
- `docker-compose.yml` - Основной файл для запуска всех сервисов в Docker
- `backend/Dockerfile.item` - Dockerfile для Item Service
- `backend/Dockerfile.security` - Dockerfile для Security Service
- `frontend/Dockerfile` - Dockerfile для Frontend (Vue.js)

### 2. **Скрипты запуска**
- `docker-launcher.sh` - 🐳 Интерактивный скрипт для Docker (рекомендуется)
- `local-launcher.sh` - 💻 Интерактивный скрипт для локального запуска

### 3. **Документация**
- `STARTUP_GUIDE.md` - 📖 Полное руководство (120+ строк)
- `QUICK_START.md` - ⚡ Быстрый старт (3 варианта)
- `SETUP.md` - 📝 Этот файл (что было создано)

### 4. **Конфигурационные файлы**
- `Makefile` - 🛠️ Утилита для частых команд (30+ команд)
- `.env.example` - 📋 Пример переменных окружения
- `.dockerignore` - 📁 Оптимизация Docker образов

---

## 🚀 Быстрый старт (3 способа)

### Способ 1: Docker Compose (самый простой)
```bash
docker-compose up -d
```
**Открыть:** http://localhost:5173

### Способ 2: Интерактивный скрипт Docker
```bash
./docker-launcher.sh
```
Выберите действие из меню.

### Способ 3: Интерактивный скрипт локально
```bash
./local-launcher.sh
```
Выберите вариант запуска.

### Способ 4: Makefile команды
```bash
make help    # Показать все команды
make docker-up    # Запустить Docker
make frontend-dev # Только Frontend
make items-dev    # Только Item Service
```

---

## 🐳 Docker Compose структура

```
services:
├── postgres (5432) - База данных
├── security-service (8082) - Аутентификация, регистрация
├── item-service (8081) - Товары, категории
└── frontend (5173) - Vue.js приложение
```

---

## 📊 Доступные команды

### Docker Compose
```bash
docker-compose up -d          # Запустить
docker-compose down           # Остановить
docker-compose logs -f        # Логи
docker-compose ps             # Статус
docker-compose restart        # Перезапуск
docker-compose down -v        # Удалить с данными
```

### Makefile
```bash
make help                 # Справка
make docker-up           # Запуск Docker
make docker-down         # Остановка
make docker-logs         # Логи
make frontend-dev        # Frontend dev
make backend-build       # Сборка Backend
make backend-test        # Тесты
make db-start           # PostgreSQL в Docker
```

### Скрипты
```bash
./docker-launcher.sh     # Интерактивное меню Docker
./local-launcher.sh      # Интерактивное меню локально
```

---

## 🔐 Особенности setup

### ✅ Автоматическая инициализация БД
- PostgreSQL автоматически создается с нужными параметрами
- Hibernate DDL-auto режим: `update` (создает таблицы автоматически)

### ✅ Health checks
- PostgreSQL: 10s интервал, 5 попыток
- Сервисы дожидаются готовности БД перед запуском

### ✅ Оптимизация образов
- Multi-stage builds для Backend (maven → jre-alpine)
- Optimized Node image для Frontend
- .dockerignore файлы исключают ненужные файлы

### ✅ Интерактивные скрипты
- Цветной вывод с индикаторами статуса
- Проверка требуемых инструментов
- Автоматический запуск PostgreSQL
- Лучший UX при выборе действий

---

## 📁 Файловая структура

```
webstore/
├── docker-compose.yml          ← Основной конфиг
├── STARTUP_GUIDE.md           ← Полное руководство
├── QUICK_START.md             ← Быстрый старт
├── SETUP.md                   ← Этот файл
├── Makefile                   ← Команды
├── .env.example               ← Переменные
├── docker-launcher.sh         ← Docker скрипт
├── local-launcher.sh          ← Локальный скрипт
├── backend/
│   ├── Dockerfile.security    ← Security Service
│   ├── Dockerfile.item        ← Item Service
│   ├── .dockerignore
│   ├── security-service/
│   ├── item-service/
│   └── ...
└── frontend/
    ├── Dockerfile            ← Frontend
    ├── .dockerignore
    └── ...
```

---

## 🎯 Рекомендуемый способ запуска

### Для новичков
```bash
./docker-launcher.sh
# Выбрать "1) 🚀 Запустить приложение"
```

### Для опытных
```bash
docker-compose up -d
```

### Для разработки (live reload)
```bash
make frontend-dev      # Terminal 1
make items-dev         # Terminal 2
make security-dev      # Terminal 3
make db-start         # Terminal 4 (если нужна новая БД)
```

---

## 🧪 Тестирование

После запуска:

```bash
# Регистрация
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","password":"123"}'

# Вход
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123"}'

# Список товаров (с токеном)
curl http://localhost:8081/api/items \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🐛 Решение проблем

### Port уже занят
```bash
# Найти процесс
lsof -i :5173  # Frontend
lsof -i :8081  # Item Service
lsof -i :8082  # Security Service

# Убить процесс
kill -9 <PID>
```

### Docker ошибки
```bash
docker-compose down -v  # Удалить всё
docker system prune -a  # Очистить Docker
docker-compose up -d    # Начать заново
```

### Maven ошибки
```bash
rm -rf ~/.m2/repository  # Очистить кэш
cd backend && ./mvnw clean install -DskipTests
```

---

## 📞 Контакты портов

| Сервис | Порт | URL |
|--------|------|-----|
| Frontend | 5173 | http://localhost:5173 |
| Item Service | 8081 | http://localhost:8081 |
| Security Service | 8082 | http://localhost:8082 |
| PostgreSQL | 5432 | localhost:5432 |

---

## 💡 Советы

1. **Для первого запуска используйте Docker** - проще всего
2. **Сохраняйте JWT токен** - нужен для API запросов
3. **Проверяйте логи** при ошибках: `docker-compose logs -f`
4. **Используйте Makefile** для быстрых команд
5. **Увеличивайте timeout** если Docker медленно собирает образы

---

## ✨ Что дальше?

1. ✅ Запустить проект
2. 🔐 Зарегистрироваться и войти
3. 📦 Добавить категории и товары
4. 🛍️ Просмотреть товары
5. 🚀 Собрать production сборку: `npm run build`

---

**Все готово к запуску! 🎉**


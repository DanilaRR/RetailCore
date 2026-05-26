# ⚙️ RettailCore - Что было создано
Полный setup шаблона RettailCore для создания кастомного интернет-магазина.
## 📦 Созданные файлы
### 📄 Документация на английском (основная)
- **README.md** - Главная документация проекта
- **QUICK_START.md** - Быстрый старт (2-3 минуты)
- **STARTUP_GUIDE.md** - Полное руководство (120+ строк)
### 📄 Документация на русском (дубликаты)
- **QUICK_START_RU.md** - Быстрый старт на русском
- **STARTUP_GUIDE_RU.md** - Полное руководство на русском
- **START_HERE_RU.md** - Инструкции на русском
### 🐳 Docker конфигурация
- **docker-compose.yml** - Docker Compose конфиг для всех сервисов
- **backend/Dockerfile.security** - Dockerfile для Security Service
- **backend/Dockerfile.item** - Dockerfile для Item Service
- **frontend/Dockerfile** - Dockerfile для Frontend
- **.dockerignore** - Оптимизация Docker образов
### 🛠️ Утилиты и скрипты
- **docker-launcher.sh** - Интерактивное меню для Docker
- **local-launcher.sh** - Интерактивное меню для локального запуска
- **Makefile** - 30+ команд для частых операций
- **.env.example** - Пример переменных окружения
---
## 🏗️ Архитектура Docker контейнеров
```
RettailCore Template
├── PostgreSQL (5432)
│   └── Database: site
├── Security Service (8082)
│   └── Authentication & JWT
├── Item Service (8081)
│   └── Products & Categories
└── Frontend (5173)
    └── Vue.js 3 Application
```
---
## 🚀 Три способа запуска
### 1. Docker Compose (рекомендуется)
```bash
docker-compose up -d
```
### 2. Интерактивный Docker скрипт
```bash
./docker-launcher.sh
```
### 3. Локально
```bash
./local-launcher.sh
```
---
## 📊 Структура проекта
```
rettailcore/
├── docker-compose.yml              # Main Docker config
├── README.md                       # Main docs (EN)
├── QUICK_START.md                  # Quick start (EN)
├── STARTUP_GUIDE.md                # Complete (EN)
├── QUICK_START_RU.md               # Quick start (RU)
├── STARTUP_GUIDE_RU.md             # Complete (RU)
├── START_HERE_RU.md                # Instructions (RU)
├── SETUP_RU.md                     # This file
├── Makefile
├── .env.example
├── docker-launcher.sh
├── local-launcher.sh
└── ...
```
---
## 🎯 Особенности setup
✅ **Автоматизировано** - не нужна ручная настройка БД
✅ **Health checks** - контейнеры ждут друг друга
✅ **Multi-stage Docker** - оптимизированные образы
✅ **Интерактивные скрипты** - цветной вывод, проверка зависимостей
✅ **Makefile** - удобные команды для разработки
✅ **Двуязычная документация** - на английском и русском
---
## 🔧 Основные команды
### Docker Compose
```bash
docker-compose up -d              # Запустить
docker-compose down               # Остановить
docker-compose logs -f            # Логи
docker-compose ps                 # Статус
```
### Makefile
```bash
make docker-up                    # Запуск
make docker-down                  # Остановка
make docker-logs                  # Логи
make help                         # Все команды
```
---
## 📋 Сервисы и порты
| Контейнер | Порт | URL | Описание |
|-----------|------|-----|---------|
| Frontend | 5173 | http://localhost:5173 | Vue.js приложение |
| Item Service | 8081 | http://localhost:8081 | API товаров |
| Security Service | 8082 | http://localhost:8082 | API авторизации |
| PostgreSQL | 5432 | localhost:5432 | База данных |
---
## 🔐 Учетные данные по умолчанию
**PostgreSQL:**
- User: `postgres`
- Password: `admin`
- Database: `site`
**JWT:**
- Expiration: 1 hour (3600000ms)
---
## 💡 Рекомендации по использованию
**Новичкам:**
```bash
./docker-launcher.sh
```
**Опытным разработчикам:**
```bash
docker-compose up -d
```
**Локальная разработка (live reload):**
```bash
make db-start          # Terminal 1
make frontend-dev      # Terminal 2
make items-dev         # Terminal 3
make security-dev      # Terminal 4
```
---
## ✨ RettailCore как шаблон
Используйте этот проект как основу для создания своего интернет-магазина:
1. 📋 Адаптируйте структуру БД
2. 🎨 Измените дизайн Frontend
3. 🔗 Расширьте API функциональность
4. 🔐 Добавьте дополнительную логику
5. 🚀 Развертните в production
---
## 📚 Документация по языкам
**Главная документация:**
- README.md - Английский
**Быстрый старт:**
- QUICK_START.md - Английский
- QUICK_START_RU.md - Русский
**Полные руководства:**
- STARTUP_GUIDE.md - Английский
- STARTUP_GUIDE_RU.md - Русский
**Инструкции:**
- START_HERE_RU.md - Русский
---
## 🎉 Всё готово!
RettailCore полностью подготовлен. Начните разработку:
```bash
docker-compose up -d
```
Откройте: http://localhost:5173
**Удачи! 🚀**

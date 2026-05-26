# 🎉 RettailCore - Инструкции запуска на русском
Быстрый старт шаблона для создания кастомного интернет-магазина.
## 🚀 БЫСТРЫЙ ЗАПУСК (выберите один)
### Вариант 1: Docker Compose (рекомендуется)
```bash
docker-compose up -d
```
Откройте: http://localhost:5173
### Вариант 2: Интерактивное меню Docker
```bash
./docker-launcher.sh
```
### Вариант 3: Локально (с автозапуском PostgreSQL)
```bash
./local-launcher.sh
```
---
## 🔗 Доступные сервисы
| Сервис | URL | Описание |
|--------|-----|---------|
| 🌐 Веб-приложение | http://localhost:5173 | Vue.js Frontend |
| 📦 API товаров | http://localhost:8081 | Item Service |
| 🔐 API авторизации | http://localhost:8082 | Security Service |
| 🐘 База данных | localhost:5432 | PostgreSQL |
---
## 📚 Полная документация на русском
- **[QUICK_START_RU.md](QUICK_START_RU.md)** - Быстрый старт
- **[STARTUP_GUIDE_RU.md](STARTUP_GUIDE_RU.md)** - Полное руководство
## 📚 Документация на английском
- **[QUICK_START.md](QUICK_START.md)** - Quick start
- **[STARTUP_GUIDE.md](STARTUP_GUIDE.md)** - Complete guide
- **[README.md](README.md)** - Project overview
---
## 🧪 Первое использование
1. Запустить: `docker-compose up -d`
2. Откройте браузер: http://localhost:5173
3. Нажмите "Register" для регистрации
4. Войдите в систему
5. Добавьте товары
---
## ⚙️ Основные команды
### Docker
```bash
docker-compose up -d              # Запустить
docker-compose down               # Остановить
docker-compose logs -f            # Логи
docker-compose ps                 # Статус
```
### Makefile (еще проще)
```bash
make docker-up                    # Запуск
make docker-down                  # Остановка
make docker-logs                  # Логи
make help                         # Все команды
```
---
## 🛑 Проблемы?
Посмотрите полное руководство: **[STARTUP_GUIDE_RU.md](STARTUP_GUIDE_RU.md)**
**Быстрые решения:**
```bash
# Порт занят
lsof -i :5173
kill -9 <PID>
# PostgreSQL ошибка
docker-compose restart postgres
# Перезапуск всего
docker-compose down && docker-compose up -d
```
---
## 🎯 Архитектура
```
Frontend (5173)
    ↓
├─→ Item Service (8081)
├─→ Security Service (8082)
    ↓
PostgreSQL (5432)
```
---
**Начните разработку! 💻**
Используйте RettailCore как шаблон для создания своего интернет-магазина.

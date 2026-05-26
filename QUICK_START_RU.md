# 🚀 RettailCore - Быстрый старт

Запустите RettailCore всего в несколько минут!

## ⚡ Один трюк: Docker Compose

```bash
docker-compose up -d
```

Откройте браузер: **http://localhost:5173**

---

## 🎯 Два варианта быстрого старта

### Вариант 1: Docker (самый быстрый) ✨

```bash
# Запустить все сервисы
docker-compose up -d

# Проверить статус
docker-compose ps

# Просмотреть логи
docker-compose logs -f

# Остановить всё
docker-compose down
```

**Время:** 2-5 минут ⏱️

---

### Вариант 2: Интерактивное Docker меню

```bash
./docker-launcher.sh
```

Выберите действие из меню.

---

### Вариант 3: Локальная разработка

```bash
./local-launcher.sh
```

Выберите предпочтённый вариант установки (PostgreSQL запустится автоматически).

---

## 🔗 Доступные сервисы после запуска

| Сервис | URL | Статус |
|--------|-----|--------|
| 🌐 Веб-приложение | http://localhost:5173 | ✅ Открыть в браузере |
| 📦 API товаров | http://localhost:8081/api/items | 🔐 Требует JWT |
| 🔐 API авторизации | http://localhost:8082/api/auth/login | 📝 POST запрос |
| 🐘 База данных | localhost:5432 | 🔒 Внутренняя |

---

## 🧪 Первый тест

### 1. Зарегистрируйте аккаунт
1. Откройте http://localhost:5173
2. Нажмите **"Register"**
3. Заполните форму
4. Нажмите **"Register"**

### 2. Войдите в систему
1. Нажмите **"Login"**
2. Введите ваши учетные данные
3. Нажмите **"Login"**

### 3. Просмотрите товары
1. Нажмите **"Go to Items"**
2. Посмотрите каталог

---

## 🛑 Остановить всё

```bash
docker-compose down
```

Чтобы также удалить все данные:
```bash
docker-compose down -v
```

---

## 📞 Возникли проблемы?

### Порт уже занят?
```bash
lsof -i :5173
kill -9 <PID>
```

### PostgreSQL не подключается?
```bash
docker-compose logs postgres
docker-compose restart postgres
```

### Нужно полное руководство?

Смотрите **[STARTUP_GUIDE_RU.md](STARTUP_GUIDE_RU.md)** для полной документации.

---

**Готовы создать свой магазин! 🎉**


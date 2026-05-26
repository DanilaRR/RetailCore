# 🚀 RettailCore Quick Start Guide

Get your RettailCore instance up and running in minutes!

## ⚡ One Command: Docker Compose

```bash
docker-compose up -d
```

Open your browser: **http://localhost:5173**

---

## 🎯 Two Quick Start Options

### Option 1: Docker (Fastest) ✨

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop everything
docker-compose down
```

**Time:** 2-5 minutes ⏱️

---

### Option 2: Docker Interactive Menu

```bash
./docker-launcher.sh
```

Choose option from menu.

---

### Option 3: Local Development

```bash
./local-launcher.sh
```

Choose your setup preference (automatically starts PostgreSQL).

---

## 🔗 Available Services After Launch

| Service | URL | Status |
|---------|-----|--------|
| 🌐 Web App | http://localhost:5173 | ✅ Open in browser |
| 📦 Items API | http://localhost:8081/api/items | 🔐 Needs JWT |
| 🔐 Auth API | http://localhost:8082/api/auth/login | 📝 POST request |
| 🐘 Database | localhost:5432 | 🔒 Internal |

---

## 🧪 First Test

### 1. Register a New Account
1. Open http://localhost:5173
2. Click **"Register"**
3. Fill in the form
4. Click **"Register"**

### 2. Login
1. Click **"Login"**
2. Enter your credentials
3. Click **"Login"**

### 3. View Items
1. Click **"Go to Items"**
2. View the catalog

---

## 🛑 Stop Everything

```bash
docker-compose down
```

To also remove all data:
```bash
docker-compose down -v
```

---

## 📞 Having Issues?

### Port Already in Use?
```bash
lsof -i :5173
kill -9 <PID>
```

### PostgreSQL Connection Failed?
```bash
docker-compose logs postgres
docker-compose restart postgres
```

### Need Full Guide?

See **[STARTUP_GUIDE.md](STARTUP_GUIDE.md)** for complete documentation.

---

**Ready to build your custom store! 🎉**


# 🛍️ RettailCore - eCommerce Platform Template
A comprehensive, production-ready microservices-based eCommerce platform template. Perfect for building custom online stores with Spring Boot and Vue.js.
**Stack:** Spring Boot 3.3.0 | Vue.js 3 | TypeScript | PostgreSQL | Docker
---
## 🚀 Quick Start
### Option 1: Docker Compose (Recommended)
```bash
docker-compose up -d
# Open http://localhost:5173
```
### Option 2: Interactive Script
```bash
./docker-launcher.sh
```
### Option 3: Local Development
```bash
./local-launcher.sh
```
---
## 📖 Documentation
| Document | Description |
|----------|------------|
| [QUICK_START.md](QUICK_START.md) | ⚡ Fastest way to start |
| [STARTUP_GUIDE.md](STARTUP_GUIDE.md) | 📚 Complete guide |
| [SETUP.md](SETUP.md) | 📝 What was created |
| [README_RU.md](README_RU.md) | 🇷🇺 Russian documentation |
---
## 🏗️ Architecture
```
┌─────────────┐
│  Frontend   │ Vue.js 3 + TypeScript (5173)
│  (Vite)     │
└──────┬──────┘
       │
       │ HTTP/REST
       │
       ├─────────────────────┬──────────────────┐
       │                     │                  │
┌──────▼──────┐     ┌───────▼────┐     ┌──────▼──────┐
│  Gateway    │     │  Security  │     │    Item    │
│   (8080)    │────▶│  Service   │────▶│  Service   │
│             │      │  (8082)    │     │  (8081)    │
└─────────────┘     └───────┬────┘     └──────┬──────┘
                             │                 │
                             └────────┬────────┘
                                      │
                             ┌────────▼────────┐
                             │  PostgreSQL     │
                             │  Database       │
                             │  (5432)         │
                             └─────────────────┘
```
---
## 🎯 Key Features
### 🔐 Authentication
- User registration
- JWT token-based login
- Route protection
- Session management
### 📦 Product Management
- Product listing
- Add/remove products
- Update product information
### 🏷️ Categories
- Create categories
- Delete categories
- Rename categories
---
## 💻 Technology Stacks
### Backend
- **Spring Boot** 3.3.0
- **Spring Security**
- **Spring Data JPA**
- **PostgreSQL**
- **JWT (JJWT)**
- **Java** 17
### Frontend
- **Vue.js** 3
- **TypeScript**
- **Vite**
- **Vue Router**
- **Axios**
---
## 🐳 Docker Services
```yaml
postgresql:5432       # Database
item-service:8081     # Product API
security-service:8082 # Auth API
frontend:5173         # Web Application
```
---
## 📋 System Requirements
### For Docker
- Docker 20.10+
- Docker Compose 2.0+
### For Local Development
- Java 17+
- Maven 3.9+
- Node.js 18+
- PostgreSQL 13+
---
## 🎓 Commands
### Docker
```bash
docker-compose up -d       # Start all services
docker-compose down        # Stop all services
docker-compose logs -f     # View logs
docker-compose ps          # Check status
```
### Makefile
```bash
make help                  # Show all commands
make docker-up            # Start Docker
make docker-down          # Stop Docker
make frontend-dev         # Frontend development
make backend-build        # Build Backend
```
---
## 🧪 First Test
1. Open http://localhost:5173
2. Click "Register"
3. Fill in the form
4. Login with your credentials
5. Add some products
---
## 📊 Project Structure
```
webstore/
├── backend/
│   ├── security-service/      # Authentication (8082)
│   ├── item-service/          # Products & Categories (8081)
│   ├── gateway/               # API Gateway
│   └── common/                # Shared utilities
├── frontend/
│   ├── src/
│   │   ├── views/            # Vue components
│   │   ├── router/           # Routes
│   │   └── styles/           # Stylesheets
│   └── package.json
└── docker-compose.yml
```
---
## 🚀 API Examples
### Register User
```bash
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john",
    "email": "john@example.com",
    "password": "secure123"
  }'
```
### Login
```bash
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "secure123"
  }'
```
### Get Products
```bash
curl http://localhost:8081/api/items \
  -H "Authorization: Bearer <JWT_TOKEN>"
```
---
## 🛠️ Development
### Local Development with Live Reload
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
### Production Build
```bash
# Frontend
npm run build
# Backend
./mvnw clean package -DskipTests
```
---
## 🐛 Troubleshooting
### PostgreSQL not working?
```bash
docker-compose logs postgres
docker-compose restart postgres
```
### Port already in use?
```bash
lsof -i :5173
kill -9 <PID>
```
---
## 📚 Useful Resources
- [Vue 3 Documentation](https://vuejs.org/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
---
## 📄 License
MIT License
---
## 🎉 Ready to Launch!
```bash
docker-compose up -d
```
Application: **http://localhost:5173**
---
**Questions?** → [STARTUP_GUIDE.md](STARTUP_GUIDE.md)
**Faster?** → [QUICK_START.md](QUICK_START.md)
**Details?** → [SETUP.md](SETUP.md)

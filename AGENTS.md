# AGENTS.md — AI Context for Webstore Project

> Read this file first on every session. Do NOT update docs (README, etc.) during development to save tokens. Update this file when architecture changes.

---

## Stack

| Layer | Tech |
|-------|------|
| Frontend | Vue 3 + TS, Vite 6, Axios, vue-advanced-cropper 2.8 |
| Security Service | Spring Boot 3, port 8082, issues JWT |
| Item Service | Spring Boot 3, port 8081, validates JWT |
| DB | PostgreSQL 15, shared, credentials: postgres/admin, DB: site |
| Infra | Docker Compose, Maven multi-module |

---

## File Map (critical files only)

```
backend/
  security-service/src/main/java/com/danrdev/security/
    jwt/JwtService.java               ← token generate/validate/parse
    controller/AuthController.java    ← POST /api/auth/register, /login
    model/User.java                   ← User entity + UserDetails impl
    config/SecurityConfig.java        ← Spring Security + CORS
    resources/application.yml         ← port 8082, jwt.secret

  item-service/src/main/java/com/danrdev/item/
    config/JwtAuthenticationFilter.java  ← validates Bearer token per-request
    config/SecurityConfig.java           ← CORS, permit rules
    controller/ItemController.java       ← /api/items/*
    controller/CategoryController.java   ← /api/categories/*
    service/ItemService.java             ← CRUD + base64 image logic
    model/item/Item.java                 ← id, name, price, category, imageData (LONGTEXT)
    model/category/Category.java
    resources/application.yml            ← port 8081, same jwt.secret

frontend/src/
  App.vue                   ← isLoggedIn ref, navbar, logout
  router/index.ts           ← routes, beforeEach auth guard (meta.requiresAuth)
  views/CategoryDetails.vue ← item CRUD + ImageUploader integration
  views/Categories.vue      ← category CRUD
  views/Login.vue           ← POST /api/auth/login, stores token in localStorage
  components/ImageUploader.vue ← file pick → vue-advanced-cropper → base64 emit
```

---

## Auth Flow

1. `POST /api/auth/login` → returns raw JWT string
2. Frontend: `localStorage.setItem('token', jwt)`
3. Every Item Service request: `Authorization: Bearer <token>` header
4. `JwtAuthenticationFilter` validates → sets SecurityContext

**Token**: HS256, 1h expiry, same secret in both services (`application.yml → jwt.secret`)

---

## API Reference

### Security Service (8082)
```
POST /api/auth/register   body: {username, email, password}
POST /api/auth/login      body: {email, password}  → JWT string
```

### Item Service (8081) — all require Bearer token
```
GET    /api/categories
POST   /api/categories              body: {name}
PATCH  /api/categories/{id}/name    body: {name}
DELETE /api/categories/{id}

GET    /api/items
GET    /api/items/{id}
POST   /api/items/upload            body: FormData(name, category, price)
PATCH  /api/items/{id}              body: {name, price}
DELETE /api/items/{id}
POST   /api/items/{id}/upload-image body: {imageData: "data:image/png;base64,..."}
GET    /api/items/{id}/image        returns: {imageData: "data:image/png;base64,..."}
```

---

## Frontend Patterns

### Auth headers (use everywhere)
```typescript
const API = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8081';
const authHeaders = () => ({ Authorization: `Bearer ${localStorage.getItem('token')}` });

const handleUnauthorized = (err: any) => {
  if (err.response?.status === 401 || err.response?.status === 403) {
    localStorage.removeItem('token');
    window.location.href = '/login';
    return true;
  }
  return false;
};

const getErrorReason = (err: any, fallback: string) => {
  if (err.response) {
    const d = err.response.data;
    return typeof d === 'string' ? d : d?.message || JSON.stringify(d);
  }
  return `${fallback}: ${err.message || 'Unknown'}`;
};
```

### ImageUploader.vue API
```typescript
// Emits:
emit('imageSelected', base64String)  // "data:image/png;base64,..."

// Exposed (via ref):
imageUploaderRef.value?.reset()      // clears file, crop state, preview
```

### vue-advanced-cropper usage
```typescript
import { Cropper } from 'vue-advanced-cropper';
import 'vue-advanced-cropper/dist/style.css';
// template: <Cropper ref="cropperRef" :src="imagePreview" :stencil-props="{ aspectRatio: 1 }" />
const result = cropperRef.value.getResult();
// result.canvas → HTMLCanvasElement  |  result.coordinates → {left,top,width,height}
```

---

## Common Tasks

### Add field to Item
1. `Item.java` → field + getter/setter
2. `ItemRequest.java` (DTO) → add field
3. `ItemService.java` → map in create/update
4. Frontend `CategoryDetails.vue` → add to form
5. Hibernate auto-migrates (ddl-auto: update)

### Add endpoint (Item Service)
1. `ItemService.java` → logic
2. `ItemController.java` → `@GetMapping` / `@PostMapping`
3. Auto-protected by `JwtAuthenticationFilter` — no extra config needed

### Add Vue route
1. `router/index.ts` → add `{ path, component, meta: { requiresAuth: true } }`

---

## Image Storage
- Stored as base64 LONGTEXT in `Item.imageData`
- Limit: 2MB raw file → ~2.7MB after base64 encoding
- Formats: JPG, PNG only — validated client + server side
- Always cropped to square (800×800 PNG) before upload

---

## Debugging

| Symptom | Cause / Fix |
|---------|-------------|
| 401 on every request | Token expired (1h) — re-login |
| Image not displaying | Check `GET /api/items/{id}/image` returns `imageData` field |
| CORS error on frontend | Security Service not running on 8082 |
| Cropper no square | Missing `:stencil-props="{ aspectRatio: 1 }"` |
| `getResult()` null canvas | Cropper not mounted — check `v-if` |
| Port conflicts | 5173/8081/8082/5432 busy — stop conflicting procs |

---

## Build Commands
```bash
make db-start          # start only postgres (docker)
make security-dev      # run security-service locally
make items-dev         # run item-service locally
make frontend-dev      # vite dev server
make backend-build     # mvn clean install all modules
make backend-test      # mvn test
make docker-up         # full docker compose up --build
make docker-clean      # docker compose down -v (wipes volumes)
```

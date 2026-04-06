# DOCKER — PathForge Infrastructure

> All 7 Docker services, volumes, networks, environment variables, and commands. This is the complete infrastructure specification.

---

## Why Docker for This App

PathForge has 7 moving pieces that must work together perfectly. Without Docker:
- Services must be installed manually on every machine
- Version mismatches cause silent bugs
- Dev environment differs from production
- Onboarding a new developer takes hours

With Docker, the entire infrastructure is defined in code. One command starts everything.

---

## The 7 Services

```
┌─────────────────────────────────────────────────────────────────────┐
│                      docker-compose network                          │
│                        pathforge_network                             │
│                                                                      │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │
│  │  frontend   │    │   backend   │    │       postgres           │  │
│  │ React/Vite  │    │   FastAPI   │    │    PostgreSQL 16         │  │
│  │  :3000      │    │   :8000     │    │       :5432             │  │
│  └──────┬──────┘    └──────┬──────┘    └───────────┬─────────────┘  │
│         │                  │                       │                 │
│  ┌──────┴──────┐    ┌──────┴──────┐    ┌───────────┴─────────────┐  │
│  │    nginx    │    │    redis    │    │         pgadmin          │  │
│  │  :80 / :443 │    │    :6379   │    │          :5050           │  │
│  └─────────────┘    └─────────────┘    └─────────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐    │
│  │                         worker                               │    │
│  │              Celery background task processor                │    │
│  └──────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Service Specifications

---

### 1. frontend

| Property | Value |
|---|---|
| Base image | `node:20-alpine` |
| Dev port | `3000` |
| Prod port | Internal only (Nginx serves the build) |
| Hot reload | Yes — Vite watches `./frontend/src` via bind mount |
| Build output | `/app/dist` copied into Nginx container |

**Dev behavior:** Vite dev server runs with `--host` flag so WSL 2 can forward to Windows browser.

**Prod behavior:** `vite build` produces static files. Nginx serves them — the frontend container does not run in production. Its build output is copied into the Nginx image at build time.

---

### 2. backend

| Property | Value |
|---|---|
| Base image | `python:3.12-slim` |
| Dev port | `8000` |
| Prod port | Internal only (Nginx proxies `/api/*`) |
| Hot reload | Yes — uvicorn `--reload` with bind mount |
| Workers | 1 in dev, 4 in prod (uvicorn multiprocess) |

**Startup sequence:**
```bash
# 1. Wait for postgres to be healthy
# 2. Run alembic migrations
# 3. Start uvicorn server
```

---

### 3. postgres

| Property | Value |
|---|---|
| Image | `postgres:16-alpine` |
| Port | `5432` (internal network only — never public) |
| Data persistence | Named volume `postgres_data` |
| Health check | `pg_isready -U pathforge` |

**Never expose port 5432 publicly.** Only the backend service connects to it via the internal Docker network.

---

### 4. redis

| Property | Value |
|---|---|
| Image | `redis:7-alpine` |
| Port | `6379` (internal only) |
| Persistence mode | AOF (append-only file) — survives restarts |
| Data persistence | Named volume `redis_data` |

Redis serves three purposes:
- Celery message broker
- JWT session cache
- Rate limiting counters

---

### 5. worker

| Property | Value |
|---|---|
| Base image | Same as backend (`python:3.12-slim`) |
| Command | `celery -A app.worker.celery_app worker --loglevel=info` |
| Concurrency | 2 workers in dev, 4 in prod |
| Shared code | Same `./backend` bind mount as backend service |

The worker is not a separate codebase. It runs Celery using the same Python application as the backend. It processes jobs from the Redis queue that the backend puts there.

---

### 6. nginx

| Property | Value |
|---|---|
| Image | `nginx:alpine` |
| Public ports | `80` (HTTP), `443` (HTTPS prod only) |
| Config | `./nginx/nginx.dev.conf` or `./nginx/nginx.prod.conf` |
| SSL | Certbot in production, self-signed in dev (optional) |

**Routing rules:**
```nginx
/api/*      → proxy_pass http://backend:8000
/ws/*       → proxy_pass http://backend:8000 (WebSocket, future)
/*          → serve /usr/share/nginx/html (React build)
```

**Why SVG files need Nginx compression:**
SVG is XML text. Gzip reduces SVG file sizes by 70–90%. Without this, large SVGs load slowly over the network.

---

### 7. pgadmin (Dev Only)

| Property | Value |
|---|---|
| Image | `dpage/pgadmin4` |
| Port | `5050` |
| Environment | Dev only — removed from `docker-compose.prod.yml` |
| Credentials | Set in `.env` file |

Access at `http://localhost:5050`. Connect to `postgres:5432` using the credentials from your `.env` file. Use this to inspect tables, run manual queries, and verify migrations.

---

## Docker Compose Files

Three files — base + two overrides:

```
docker-compose.yml          ← Shared config (service definitions, networks, volumes)
docker-compose.dev.yml      ← Dev additions (bind mounts, hot reload, pgadmin, debug)
docker-compose.prod.yml     ← Prod additions (SSL, no pgadmin, multiple workers, restart policies)
```

---

### docker-compose.yml (Base)

```yaml
version: '3.9'

services:

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    networks:
      - pathforge_network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    env_file: .env
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - pathforge_network

  postgres:
    image: postgres:16-alpine
    env_file: .env
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 5s
      timeout: 5s
      retries: 10
    networks:
      - pathforge_network

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - pathforge_network

  worker:
    build:
      context: ./backend
      dockerfile: Dockerfile
    command: celery -A app.worker.celery_app worker --loglevel=info
    env_file: .env
    depends_on:
      - redis
      - postgres
    networks:
      - pathforge_network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    depends_on:
      - frontend
      - backend
    networks:
      - pathforge_network

volumes:
  postgres_data:
  redis_data:
  svg_assets:

networks:
  pathforge_network:
    driver: bridge
```

---

### docker-compose.dev.yml (Dev Overrides)

```yaml
version: '3.9'

services:

  frontend:
    volumes:
      - ./frontend:/app
      - /app/node_modules        # preserve node_modules inside container
    ports:
      - "3000:3000"
    command: npm run dev -- --host
    environment:
      - NODE_ENV=development

  backend:
    volumes:
      - ./backend:/app
    ports:
      - "8000:8000"
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    environment:
      - DEBUG=true

  worker:
    volumes:
      - ./backend:/app
    environment:
      - DEBUG=true

  nginx:
    volumes:
      - ./nginx/nginx.dev.conf:/etc/nginx/conf.d/default.conf

  pgadmin:
    image: dpage/pgadmin4
    ports:
      - "5050:80"
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD}
    networks:
      - pathforge_network
```

---

### docker-compose.prod.yml (Prod Overrides)

```yaml
version: '3.9'

services:

  frontend:
    build:
      target: production       # multi-stage build — prod stage only
    restart: always

  backend:
    command: >
      sh -c "alembic upgrade head &&
             uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4"
    restart: always

  worker:
    command: celery -A app.worker.celery_app worker --loglevel=warning --concurrency=4
    restart: always

  postgres:
    restart: always

  redis:
    restart: always

  nginx:
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.prod.conf:/etc/nginx/conf.d/default.conf
      - nginx_certs:/etc/nginx/certs
    restart: always

volumes:
  nginx_certs:
```

---

## Volume Strategy

| Volume | What It Stores | Survives Restart |
|---|---|---|
| `postgres_data` | All database rows | Yes |
| `redis_data` | Job queue and session cache | Yes |
| `svg_assets` | Uploaded SVG files and embedded images | Yes |
| `nginx_certs` | SSL certificates (prod) | Yes |
| `./frontend` (bind) | Source code — hot reload | Dev only |
| `./backend` (bind) | Source code — hot reload | Dev only |

---

## Network Strategy

```
Internal network: pathforge_network
  All services communicate by service name:
  backend  → postgres at postgres:5432
  backend  → redis    at redis:6379
  nginx    → frontend at frontend:3000
  nginx    → backend  at backend:8000
  worker   → redis    at redis:6379
  worker   → postgres at postgres:5432

Public exposure (only through Nginx):
  Port 80   → HTTP (redirects to HTTPS in prod)
  Port 443  → HTTPS (prod only)
  Port 5050 → pgadmin (dev only, NEVER in prod)
  Port 3000 → frontend dev server (dev only)
  Port 8000 → backend dev server (dev only)
```

---

## Environment Variables (.env)

```bash
# ── App ──────────────────────────────────────────
APP_NAME=PathForge
APP_ENV=development           # development | production
SECRET_KEY=                   # 64-char random string — openssl rand -hex 32
DEBUG=true

# ── Database ─────────────────────────────────────
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=pathforge
POSTGRES_USER=pathforge
POSTGRES_PASSWORD=            # strong random password

# ── Redis ────────────────────────────────────────
REDIS_URL=redis://redis:6379/0

# ── JWT ──────────────────────────────────────────
JWT_SECRET_KEY=               # different from SECRET_KEY
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=60
JWT_REFRESH_TOKEN_EXPIRE_DAYS=30

# ── Storage (DigitalOcean Spaces) ────────────────
DO_SPACES_KEY=
DO_SPACES_SECRET=
DO_SPACES_BUCKET=pathforge-assets
DO_SPACES_REGION=nyc3
DO_SPACES_ENDPOINT=https://nyc3.digitaloceanspaces.com

# ── Email (Resend) ────────────────────────────────
RESEND_API_KEY=
FROM_EMAIL=noreply@pathforge.app

# ── PGAdmin (dev only) ───────────────────────────
PGADMIN_EMAIL=admin@pathforge.local
PGADMIN_PASSWORD=

# ── Frontend (Vite exposes these as VITE_ prefix) ─
VITE_API_URL=http://localhost/api/v1
VITE_APP_NAME=PathForge
```

---

## Makefile Commands

```makefile
# Development
make dev          # Start all services in dev mode
make dev-build    # Rebuild images and start dev
make stop         # Stop all containers
make restart      # Stop and start
make logs         # Tail all container logs
make logs-back    # Tail backend logs only
make logs-front   # Tail frontend logs only

# Database
make migrate      # Run alembic migrations inside backend container
make migration    # Create new migration (make migration msg="add users table")
make db-shell     # Open psql shell inside postgres container
make db-reset     # Drop and recreate database (dev only — destructive)

# Development utilities
make shell-back   # bash shell inside backend container
make shell-front  # bash shell inside frontend container
make test-back    # Run Python tests inside backend container
make test-front   # Run frontend tests inside frontend container
make test         # Run all tests

# Production
make prod-build   # Build production images
make prod         # Start production stack
make prod-deploy  # Pull latest and restart production (run on server)

# Cleanup
make clean        # Remove stopped containers
make clean-all    # Remove containers, volumes, and images (destructive)
```

---

## WSL 2 Specific Setup

Since the development environment is WSL 2 on Windows:

```bash
# Requirement 1: Docker Desktop with WSL 2 backend
# Settings → Resources → WSL Integration → enable your distro

# Requirement 2: Work from Linux filesystem (critical for performance)
# CORRECT:
cd /home/frandy/pathforge

# WRONG (10x slower volume performance):
cd /mnt/c/Users/Frandy/pathforge

# Requirement 3: Access from Windows browser
# WSL 2 forwards ports automatically
# Frontend: http://localhost:3000
# Backend:  http://localhost:8000
# PGAdmin:  http://localhost:5050

# If ports don't forward, find WSL IP:
ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1
# Then access: http://<wsl-ip>:3000
```

---

## Multi-Stage Dockerfiles

Both frontend and backend use multi-stage builds to keep production images small.

### frontend/Dockerfile

```dockerfile
# ── Stage 1: Dependencies ──────────────────────────
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

# ── Stage 2: Development ───────────────────────────
FROM deps AS development
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev", "--", "--host"]

# ── Stage 3: Build ─────────────────────────────────
FROM deps AS builder
COPY . .
RUN npm run build

# ── Stage 4: Production (Nginx serves static files) ─
FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

### backend/Dockerfile

```dockerfile
# ── Stage 1: Base ─────────────────────────────────
FROM python:3.12-slim AS base
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev && rm -rf /var/lib/apt/lists/*

# ── Stage 2: Dependencies ─────────────────────────
FROM base AS deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Stage 3: Development ──────────────────────────
FROM deps AS development
COPY . .
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# ── Stage 4: Production ───────────────────────────
FROM deps AS production
COPY . .
EXPOSE 8000
CMD ["sh", "-c", "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4"]
```

---

## Health Checks

Every service that other services depend on must have a health check:

```yaml
postgres:
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
    interval: 5s
    timeout: 5s
    retries: 10
    start_period: 10s

redis:
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 5s
    timeout: 3s
    retries: 5

backend:
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
    interval: 10s
    timeout: 5s
    retries: 3
    start_period: 30s
```

The backend exposes a `/health` endpoint that returns 200 when the app is ready and connected to the database.

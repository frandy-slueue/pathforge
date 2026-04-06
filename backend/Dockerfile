# ════════════════════════════════════════════════════
# PathForge — Backend Dockerfile
# Multi-stage build: dependencies → development → production
# ════════════════════════════════════════════════════

# ── Stage 1: Base ────────────────────────────────────
# Shared foundation for all stages.
# Installs system packages needed by Python dependencies.
FROM python:3.12-slim AS base

WORKDIR /app

# Install system dependencies
# gcc + libpq-dev are required to compile asyncpg (PostgreSQL driver)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Prevents Python from writing .pyc files
ENV PYTHONDONTWRITEBYTECODE=1
# Prevents Python from buffering stdout/stderr
# (so Docker logs appear immediately)
ENV PYTHONUNBUFFERED=1


# ── Stage 2: Dependencies ────────────────────────────
# Installs Python packages into a layer that can be cached.
# This layer only rebuilds when requirements.txt changes.
FROM base AS dependencies

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt


# ── Stage 3: Development ─────────────────────────────
# Used by docker-compose.dev.yml.
# Installs dev dependencies and starts uvicorn with --reload.
# Source code is bind-mounted in, not copied.
FROM dependencies AS development

COPY requirements.dev.txt .
RUN pip install --no-cache-dir -r requirements.dev.txt

EXPOSE 8000

# --reload watches for file changes (works with bind mount)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]


# ── Stage 4: Production ──────────────────────────────
# Used by docker-compose.prod.yml.
# Copies source code into the image (no bind mount).
# Runs alembic migrations then starts uvicorn with 4 workers.
FROM dependencies AS production

# Copy application source code
COPY . .

EXPOSE 8000

# Run migrations then start the server
CMD ["sh", "-c", "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4"]

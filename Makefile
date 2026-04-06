# ════════════════════════════════════════════════════
# PathForge — Makefile
# ════════════════════════════════════════════════════
# Usage: make <command>
# Run   make help   to see all available commands.
# ════════════════════════════════════════════════════

.PHONY: help dev dev-build stop restart logs logs-back logs-front logs-worker \
        migrate migration db-shell db-reset \
        shell-back shell-front \
        test test-back test-front lint \
        prod prod-build prod-deploy \
        clean clean-all

# ── Default ───────────────────────────────────────────
.DEFAULT_GOAL := help

# ── Colors ────────────────────────────────────────────
GREEN  := \033[0;32m
YELLOW := \033[0;33m
CYAN   := \033[0;36m
RESET  := \033[0m

# ── Help ─────────────────────────────────────────────
help:
	@echo ""
	@echo "$(CYAN)PathForge — Available Commands$(RESET)"
	@echo "════════════════════════════════════════"
	@echo ""
	@echo "$(YELLOW)Development$(RESET)"
	@echo "  make dev           Start all services in development mode"
	@echo "  make dev-build     Rebuild images and start development"
	@echo "  make stop          Stop all running containers"
	@echo "  make restart       Stop then start all containers"
	@echo ""
	@echo "$(YELLOW)Logs$(RESET)"
	@echo "  make logs          Tail logs from all containers"
	@echo "  make logs-back     Tail backend container logs only"
	@echo "  make logs-front    Tail frontend container logs only"
	@echo "  make logs-worker   Tail worker container logs only"
	@echo ""
	@echo "$(YELLOW)Database$(RESET)"
	@echo "  make migrate       Run Alembic migrations (upgrade head)"
	@echo "  make migration     Create new migration  (msg='your message')"
	@echo "  make db-shell      Open psql shell inside postgres container"
	@echo "  make db-reset      Drop and recreate database (DEV ONLY)"
	@echo ""
	@echo "$(YELLOW)Shell Access$(RESET)"
	@echo "  make shell-back    bash shell inside backend container"
	@echo "  make shell-front   sh shell inside frontend container"
	@echo ""
	@echo "$(YELLOW)Testing$(RESET)"
	@echo "  make test          Run all tests (backend + frontend)"
	@echo "  make test-back     Run Python tests (pytest)"
	@echo "  make test-front    Run TypeScript type check + lint"
	@echo "  make lint          Run linters (ruff + eslint)"
	@echo ""
	@echo "$(YELLOW)Production$(RESET)"
	@echo "  make prod-build    Build production Docker images"
	@echo "  make prod          Start production stack"
	@echo "  make prod-deploy   Pull latest and restart (run on server)"
	@echo ""
	@echo "$(YELLOW)Cleanup$(RESET)"
	@echo "  make clean         Remove stopped containers"
	@echo "  make clean-all     Remove containers, volumes, images (DESTRUCTIVE)"
	@echo ""

# ── Development ───────────────────────────────────────
dev:
	@echo "$(GREEN)Starting PathForge in development mode...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up

dev-build:
	@echo "$(GREEN)Rebuilding images and starting development...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build

stop:
	@echo "$(YELLOW)Stopping all containers...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml down

restart: stop dev

# ── Logs ─────────────────────────────────────────────
logs:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f

logs-back:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f backend

logs-front:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f frontend

logs-worker:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f worker

# ── Database ──────────────────────────────────────────
migrate:
	@echo "$(GREEN)Running Alembic migrations...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec backend alembic upgrade head

migration:
	@echo "$(GREEN)Creating new migration: $(msg)$(RESET)"
	@[ -n "$(msg)" ] || (echo "Error: provide a message — make migration msg='your message'" && exit 1)
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec backend alembic revision --autogenerate -m "$(msg)"

db-shell:
	@echo "$(CYAN)Opening psql shell...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec postgres psql -U pathforge -d pathforge

db-reset:
	@echo "$(YELLOW)WARNING: This will destroy all data. Press Ctrl+C to cancel.$(RESET)"
	@sleep 3
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec postgres psql -U pathforge -c "DROP DATABASE IF EXISTS pathforge;"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec postgres psql -U pathforge -c "CREATE DATABASE pathforge;"
	$(MAKE) migrate

# ── Shell Access ──────────────────────────────────────
shell-back:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec backend bash

shell-front:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec frontend sh

# ── Testing ───────────────────────────────────────────
test: test-back test-front
	@echo "$(GREEN)All tests passed.$(RESET)"

test-back:
	@echo "$(GREEN)Running backend tests...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec backend pytest tests/ -v

test-front:
	@echo "$(GREEN)Running frontend type check...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec frontend npx tsc --noEmit
	@echo "$(GREEN)Running ESLint...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec frontend npm run lint

lint:
	@echo "$(GREEN)Running ruff (Python)...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec backend ruff check .
	@echo "$(GREEN)Running ESLint (TypeScript)...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml \
		exec frontend npm run lint

# ── Production ────────────────────────────────────────
prod-build:
	@echo "$(GREEN)Building production images...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.prod.yml build

prod:
	@echo "$(GREEN)Starting production stack...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

prod-deploy:
	@echo "$(GREEN)Pulling latest and restarting...$(RESET)"
	git pull origin main
	docker compose -f docker-compose.yml -f docker-compose.prod.yml pull
	docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
	docker compose -f docker-compose.yml -f docker-compose.prod.yml \
		exec backend alembic upgrade head

# ── Cleanup ───────────────────────────────────────────
clean:
	@echo "$(YELLOW)Removing stopped containers...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml rm -f

clean-all:
	@echo "$(YELLOW)WARNING: Removing ALL containers, volumes, and images.$(RESET)"
	@sleep 3
	docker compose -f docker-compose.yml -f docker-compose.dev.yml down -v --rmi all

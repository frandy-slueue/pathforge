# PathForge — Professional SVG & File Editor

> A production-grade, browser-based creative editor for SVG design, logo creation, and multi-format file editing. Built for artists, designers, and developers who want a real tool — not a toy.

---

## What Is PathForge?

PathForge is a full-stack web application that gives users a professional canvas environment to:

- Design logos, icons, illustrations, and artwork using SVG
- Edit and manipulate SVG files with full path-level control
- Work with multiple file formats (SVG, PNG, JPG, PDF, and more)
- Save projects to the cloud and access them from anywhere
- Export finished work in multiple formats and resolutions

The long-term vision is a tool comparable to Figma or Inkscape — browser-native, fast, and accessible to anyone without an install.

---

## Documentation Index

| File | What It Covers |
|---|---|
| `README.md` | This file — project overview and quick start |
| `TECH_STACK.md` | Every technology choice and why it was selected |
| `DOCKER.md` | All 7 Docker services, volumes, networks, and commands |
| `ARCHITECTURE.md` | Folder structure, data flow, and architectural rules |
| `FEATURES.md` | Every feature, tool, and panel the app must have |
| `BUILD_PLAN.md` | Step-by-step build order with testing and Git workflow |
| `FILE_SUPPORT.md` | File type support roadmap and extensibility design |
| `THEMES.md` | UI themes, design system, and visual language |

---

## Core Principles

These rules guide every decision made during the build:

```
1. Write the spec before writing the code
2. Each build step is tested before moving to the next
3. Every step is committed to GitHub with a clear message
4. Separation of concerns at every layer
5. The app is extensible — new file types and tools can be added
   without rewriting existing ones
6. Docker from day one — dev and prod behave identically
7. Skeleton loading on every async operation — no blank screens
8. Mobile-aware layout — panels collapse gracefully
```

---

## Quick Start (Once Built)

```bash
# Clone the repo
git clone https://github.com/frandy-slueue/pathforge.git
cd pathforge

# Copy environment template
cp .env.example .env
# (fill in your values)

# Start all services in development mode
make dev

# App runs at:
# Frontend:  http://localhost:3000
# Backend:   http://localhost:8000
# API Docs:  http://localhost:8000/docs
# PGAdmin:   http://localhost:5050
```

---

## Repository Structure (Top Level)

```
pathforge/
├── frontend/          React + TypeScript + Vite
├── backend/           FastAPI + PostgreSQL + Redis
├── nginx/             Reverse proxy configuration
├── docs/              All .md documentation files
├── docker-compose.yml
├── docker-compose.dev.yml
├── docker-compose.prod.yml
├── Makefile
├── .env.example
├── .gitignore
└── README.md
```

---

## Build Status

| Phase | Status | Description |
|---|---|---|
| Phase 1 | 🔲 Pending | Docker infrastructure + project scaffold |
| Phase 2 | 🔲 Pending | Backend skeleton + database + auth |
| Phase 3 | 🔲 Pending | Frontend scaffold + routing + state |
| Phase 4 | 🔲 Pending | Canvas engine base (Konva) |
| Phase 5 | 🔲 Pending | Pen tool + path rendering |
| Phase 6 | 🔲 Pending | Selection tool + node editing |
| Phase 7 | 🔲 Pending | Layers + style panels |
| Phase 8 | 🔲 Pending | Shapes, text, image tools |
| Phase 9 | 🔲 Pending | SVG import + export |
| Phase 10 | 🔲 Pending | Project save/load + cloud sync |
| Phase 11 | 🔲 Pending | Extended file type support |
| Phase 12 | 🔲 Pending | Themes + polish + production deploy |

---

## Author

**Frandy Slueue**
Full Stack Software Engineer · Atlas School of Tulsa Graduate
GitHub: [@frandy-slueue](https://github.com/frandy-slueue)
Portfolio: [frandy.dev](https://frandy.dev)

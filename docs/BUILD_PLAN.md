# BUILD PLAN — PathForge

> Step-by-step build order, testing requirements, and Git workflow. Every step is tested and committed before moving to the next. No exceptions.

---

## The Rule

```
Write code → Test it → Document it → Commit to GitHub → Move to next step
```

If a step is not tested, it does not get committed. If it is not committed, the next step does not begin. This is non-negotiable because bugs compound. A bug in step 3 that is discovered in step 9 costs 10x more to fix than catching it in step 3.

---

## Git Workflow

### Branch Strategy

```
main              Production-ready code only. Never commit directly here.
develop           Integration branch. All features merge here first.
feature/*         Individual feature branches, cut from develop.
fix/*             Bug fix branches.
```

### Commit Message Format

Every commit follows this format exactly:

```
<type>(<scope>): <short description>

Types:
  feat      A new feature
  fix       A bug fix
  test      Adding or updating tests
  docs      Documentation changes
  chore     Build process, dependencies, config
  refactor  Code change that neither adds feature nor fixes bug
  style     Formatting, no logic change

Examples:
  feat(auth): add JWT refresh token endpoint
  fix(canvas): correct zoom center calculation on scroll
  test(auth): add registration validation tests
  docs(docker): add WSL 2 port forwarding instructions
  chore(deps): upgrade FastAPI to 0.110.0
```

### Per-Step Git Flow

```bash
# Before starting each step:
git checkout develop
git pull origin develop
git checkout -b feature/step-N-description

# During the step, commit small and often:
git add .
git commit -m "feat(scope): description"

# When step is complete and tested:
git push origin feature/step-N-description
# Open Pull Request → develop
# Merge after review
# Tag the milestone
git tag -a v0.N.0 -m "Phase N complete: description"
git push origin --tags
```

---

## Phase 1 — Docker Infrastructure + Project Scaffold

> Goal: A running Docker stack with hello-world frontend and backend. Nothing more. Foundation must be solid before any features are built.

---

### Step 1.1 — Monorepo Scaffold

```
Create:
  pathforge/
  ├── frontend/
  ├── backend/
  ├── nginx/
  ├── docs/
  ├── .gitignore
  ├── .env.example
  ├── Makefile
  └── README.md

Test:
  ☐ Directory structure matches ARCHITECTURE.md
  ☐ .gitignore covers: .env, node_modules, __pycache__,
    *.pyc, dist, .DS_Store, *.egg-info

Commit: chore(scaffold): initialize monorepo structure
```

---

### Step 1.2 — Backend Dockerfile + FastAPI Skeleton

```
Create:
  backend/
  ├── app/
  │   ├── __init__.py
  │   └── main.py       (returns {"status": "ok"} at GET /)
  ├── requirements.txt
  ├── requirements.dev.txt
  └── Dockerfile        (multi-stage: development + production)

main.py contains only:
  - FastAPI app creation
  - CORS middleware
  - GET /health endpoint returning {"status": "ok", "service": "pathforge-api"}
  - GET / returning {"message": "PathForge API"}

Test:
  ☐ docker build -t pathforge-backend ./backend  succeeds
  ☐ Container starts without errors
  ☐ GET http://localhost:8000/health returns 200
  ☐ GET http://localhost:8000/docs loads Swagger UI

Commit: feat(backend): add FastAPI skeleton with health endpoint
```

---

### Step 1.3 — Frontend Dockerfile + React Skeleton

```
Create:
  frontend/
  ├── src/
  │   ├── main.tsx
  │   └── App.tsx      (renders <h1>PathForge</h1>)
  ├── index.html
  ├── vite.config.ts
  ├── tsconfig.json
  ├── tailwind.config.ts
  ├── package.json
  └── Dockerfile        (multi-stage: development + production)

Test:
  ☐ npm install succeeds (no audit errors blocking build)
  ☐ docker build -t pathforge-frontend ./frontend  succeeds
  ☐ Container starts, Vite dev server runs
  ☐ Browser shows "PathForge" heading at localhost:3000
  ☐ TypeScript check passes: npx tsc --noEmit

Commit: feat(frontend): add React + Vite + TypeScript skeleton
```

---

### Step 1.4 — Docker Compose (All 7 Services)

```
Create:
  docker-compose.yml
  docker-compose.dev.yml
  docker-compose.prod.yml
  nginx/nginx.dev.conf
  .env.example         (with all required variables, no real values)

Test:
  ☐ make dev  starts all containers without errors
  ☐ docker ps shows 7 containers running (or 6 in dev
    if pgadmin counts as extra)
  ☐ Frontend accessible at http://localhost:3000
  ☐ Backend accessible at http://localhost:8000
  ☐ Nginx routes /api/* to backend (GET localhost/api returns
    backend response through Nginx)
  ☐ postgres container is healthy (docker inspect shows healthy)
  ☐ redis container is running
  ☐ pgadmin accessible at http://localhost:5050
  ☐ Backend connects to postgres (logs show no connection errors)
  ☐ make stop  stops all containers cleanly
  ☐ make dev  again starts without errors (volumes persist)

Commit: chore(docker): configure all 7 services with compose
```

---

### Step 1.5 — Database Models + Alembic

```
Create:
  backend/app/database.py
  backend/app/models/base.py
  backend/app/models/user.py
  backend/app/models/project.py
  backend/app/models/version.py
  backend/app/models/asset.py
  backend/alembic.ini
  backend/migrations/env.py
  backend/migrations/script.py.mako

Test:
  ☐ make migrate  runs without errors
  ☐ pgadmin shows all 4 tables created: users, projects,
    project_versions, assets
  ☐ make migration msg="test"  creates a new migration file
  ☐ alembic downgrade -1  reverts last migration successfully
  ☐ alembic upgrade head  re-applies migration

Commit: feat(backend): add database models and Alembic migrations
```

---

### Phase 1 Tag

```bash
git tag -a v0.1.0 -m "Phase 1 complete: Docker infrastructure + scaffold"
```

---

## Phase 2 — Authentication

> Goal: Working registration, login, logout, and JWT refresh. Protected routes on both frontend and backend.

---

### Step 2.1 — Auth Backend (Register + Login)

```
Create:
  backend/app/core/security.py
  backend/app/schemas/auth.py
  backend/app/schemas/user.py
  backend/app/services/auth_service.py
  backend/app/api/deps.py
  backend/app/api/v1/auth.py
  backend/app/api/v1/router.py

Endpoints:
  POST /api/v1/auth/register
  POST /api/v1/auth/login
  POST /api/v1/auth/logout
  POST /api/v1/auth/refresh
  GET  /api/v1/users/me

Test:
  ☐ POST /register with valid data creates user in database
  ☐ POST /register with duplicate email returns 409
  ☐ POST /register with invalid email returns 422
  ☐ POST /register with short password returns 422
  ☐ POST /login with correct credentials returns access token
  ☐ POST /login with wrong password returns 401
  ☐ GET /users/me with valid token returns user data
  ☐ GET /users/me with expired token returns 401
  ☐ POST /refresh with valid refresh token returns new access token
  ☐ All tests pass: make test-back

Commit: feat(auth): add registration, login, and JWT endpoints
```

---

### Step 2.2 — Auth Frontend (Login + Register Pages)

```
Create:
  frontend/src/pages/Auth.tsx
  frontend/src/store/userStore.ts
  frontend/src/api/client.ts   (axios instance with interceptors)
  frontend/src/api/auth.ts
  frontend/src/components/ui/Button.tsx
  frontend/src/components/ui/Input.tsx
  frontend/src/components/ui/Skeleton.tsx

Test:
  ☐ /login page renders with email + password fields
  ☐ Form validation shows errors for empty fields
  ☐ Successful login redirects to /dashboard
  ☐ Failed login shows error message toast
  ☐ /register page renders with name + email + password fields
  ☐ Successful registration redirects to /dashboard
  ☐ Skeleton shows on auth check while token is being verified
  ☐ Logged-in user visiting /login redirects to /dashboard
  ☐ Unauthenticated user visiting /dashboard redirects to /login
  ☐ TypeScript check passes: npx tsc --noEmit

Commit: feat(auth): add login and register pages with form validation
```

---

### Step 2.3 — Protected Routes + Persistent Auth

```
Create:
  frontend/src/components/layout/ProtectedRoute.tsx

Test:
  ☐ Refresh page while logged in — stays logged in (token persists)
  ☐ Token expiry triggers silent refresh via interceptor
  ☐ Failed refresh redirects to /login
  ☐ Logout clears cookie and redirects to /login
  ☐ Direct URL navigation to /editor while logged out redirects to /login

Commit: feat(auth): add persistent sessions and protected routes
```

---

### Phase 2 Tag

```bash
git tag -a v0.2.0 -m "Phase 2 complete: Authentication system"
```

---

## Phase 3 — Dashboard + Project Management

> Goal: Users can create, list, rename, and delete projects from a dashboard.

---

### Step 3.1 — Projects Backend

```
Create:
  backend/app/api/v1/projects.py
  backend/app/schemas/project.py
  backend/app/services/project_service.py

Endpoints:
  GET    /api/v1/projects
  POST   /api/v1/projects
  GET    /api/v1/projects/{id}
  PUT    /api/v1/projects/{id}
  DELETE /api/v1/projects/{id}

Test:
  ☐ GET /projects returns only the authenticated user's projects
  ☐ POST /projects creates a new project with default name "Untitled"
  ☐ GET /projects/{id} returns project data
  ☐ GET /projects/{id} for another user's project returns 403
  ☐ PUT /projects/{id} updates name and description
  ☐ DELETE /projects/{id} deletes project and cascades to versions
  ☐ All tests pass: make test-back

Commit: feat(projects): add project CRUD API endpoints
```

---

### Step 3.2 — Dashboard Frontend

```
Create:
  frontend/src/pages/Dashboard.tsx
  frontend/src/store/projectStore.ts
  frontend/src/api/projects.ts
  frontend/src/components/shared/ProjectCard.tsx
  frontend/src/components/shared/ProjectCardSkeleton.tsx
  frontend/src/components/shared/ConfirmDialog.tsx

Test:
  ☐ Dashboard loads and shows skeleton grid while fetching
  ☐ After load, shows real project cards (or empty state message)
  ☐ "New Project" button creates project and navigates to /editor
  ☐ Project card shows name and creation date
  ☐ Click project card navigates to /editor/:id
  ☐ Rename project inline on the card works
  ☐ Delete project shows confirmation dialog
  ☐ Confirm delete removes card from grid
  ☐ Skeleton: exactly matches card dimensions (no layout shift)

Commit: feat(dashboard): add project grid with skeleton loading
```

---

### Phase 3 Tag

```bash
git tag -a v0.3.0 -m "Phase 3 complete: Dashboard and project management"
```

---

## Phase 4 — Editor Shell + Canvas Foundation

> Goal: The editor page loads with a real layout — toolbar, panels, canvas. Canvas pans, zooms, and shows grid. No drawing yet.

---

### Step 4.1 — Editor Layout

```
Create:
  frontend/src/pages/Editor.tsx
  frontend/src/components/layout/AppShell.tsx
  frontend/src/editor/toolbar/Toolbar.tsx
  frontend/src/editor/toolbar/ToolButton.tsx
  frontend/src/editor/toolbar/ZoomControl.tsx
  frontend/src/store/uiStore.ts

Test:
  ☐ /editor renders AppShell with toolbar (top), left panel, canvas, right panel
  ☐ Layout fills full viewport with no scrollbars
  ☐ Toolbar renders tool buttons (no functionality yet)
  ☐ Left panel placeholder renders
  ☐ Right panel placeholder renders
  ☐ Canvas area fills remaining space
  ☐ Editor page shows skeleton while project data loads
  ☐ Project name shows in toolbar after load

Commit: feat(editor): add editor layout shell with toolbar and panels
```

---

### Step 4.2 — Konva Canvas Base

```
Install: react-konva, konva

Create:
  frontend/src/editor/canvas/KonvaCanvas.tsx
  frontend/src/editor/canvas/GridLayer.tsx
  frontend/src/store/canvasStore.ts   (zoom, pan only for now)
  frontend/src/editor/hooks/useKeyboard.ts  (G, +, -, 0)

Test:
  ☐ Konva Stage renders inside canvas wrapper area
  ☐ Stage fills full canvas wrapper dimensions
  ☐ Scroll to zoom works, centered on cursor position
  ☐ Middle-mouse drag pans the canvas
  ☐ Space + drag pans the canvas
  ☐ G key toggles grid overlay
  ☐ Grid moves correctly with pan and zoom
  ☐ + and - keys zoom in and out
  ☐ 0 key fits content to view (nothing to fit yet — just resets)
  ☐ Zoom percentage shows correctly in toolbar
  ☐ No performance issues at 60fps during pan/zoom

Commit: feat(canvas): add Konva canvas with zoom, pan, and grid
```

---

### Phase 4 Tag

```bash
git tag -a v0.4.0 -m "Phase 4 complete: Editor shell and canvas foundation"
```

---

## Phase 5 — Pen Tool + Path Rendering

> Goal: Users can draw Bézier paths on the canvas.

---

### Step 5.1 — Canvas Store (Paths)

```
Expand:
  frontend/src/store/canvasStore.ts
  frontend/src/types/canvas.ts

Add to canvas store:
  paths: PathObject[]
  activePathId: string | null
  addPath, updatePath, deletePath, closePath

Test:
  ☐ Path data structure matches canvas.ts types exactly
  ☐ TypeScript: no type errors in canvasStore

Commit: feat(canvas): add path data model to canvas store
```

---

### Step 5.2 — Pen Tool

```
Create:
  frontend/src/editor/tools/PenTool.ts
  frontend/src/editor/canvas/PathLayer.tsx
  frontend/src/editor/canvas/OverlayLayer.tsx
  frontend/src/lib/svg/pathMath.ts
  frontend/src/lib/geometry/bounds.ts

Test:
  ☐ P key activates pen tool (uiStore.activeTool = 'pen')
  ☐ Click canvas places anchor point
  ☐ Second click places second anchor — straight line renders
  ☐ Click + drag creates smooth Bézier curve
  ☐ Control handles appear and are draggable
  ☐ Live rubber-band preview curve follows cursor
  ☐ Click first anchor closes path (pulsing ring shows near first anchor)
  ☐ Escape key ends open path
  ☐ Multiple independent paths can be drawn
  ☐ Each path renders correctly at any zoom level
  ☐ Anchors scale correctly with zoom (stay same screen size)

Commit: feat(pen-tool): add Bézier pen tool with live preview
```

---

### Step 5.3 — History (Undo/Redo)

```
Create:
  frontend/src/store/historyStore.ts
  frontend/src/editor/hooks/useHistory.ts

Test:
  ☐ Ctrl+Z undoes last placed anchor
  ☐ Ctrl+Z undoes path deletion
  ☐ Ctrl+Shift+Z redoes
  ☐ 100 undo steps available
  ☐ History clears redo stack on new action
  ☐ Undo/redo buttons in toolbar work

Commit: feat(history): add 100-step undo/redo system
```

---

### Phase 5 Tag

```bash
git tag -a v0.5.0 -m "Phase 5 complete: Pen tool and path rendering"
```

---

## Phase 6 — Selection + Node Editing

---

### Step 6.1 — Select Tool

```
Create:
  frontend/src/editor/tools/SelectTool.ts
  frontend/src/editor/canvas/SelectionBox.tsx

Test:
  ☐ V key activates select tool
  ☐ Click path selects it (renders in selection color)
  ☐ Click empty canvas deselects
  ☐ Shift+click adds to selection
  ☐ Drag on empty canvas creates lasso selection box
  ☐ Lasso selects all paths it intersects
  ☐ Arrow keys nudge selected element 1px
  ☐ Shift+arrow nudges 10px
  ☐ Delete key deletes selected element
  ☐ Drag selected element moves it

Commit: feat(select-tool): add selection and move tool
```

---

### Step 6.2 — Node Editing (Direct Select)

```
Create:
  frontend/src/editor/tools/DirectSelectTool.ts

Test:
  ☐ A key activates direct select tool
  ☐ Click path to see all anchor points
  ☐ Click anchor to select it (highlights in selection color)
  ☐ Drag anchor to reshape path
  ☐ Drag control handle to adjust curve
  ☐ Smooth node: handles mirror across anchor
  ☐ Corner node: handles move independently
  ☐ Right-click anchor to toggle smooth ↔ corner
  ☐ Node type panel buttons also toggle type

Commit: feat(node-edit): add direct selection and node editing
```

---

### Phase 6 Tag

```bash
git tag -a v0.6.0 -m "Phase 6 complete: Selection and node editing"
```

---

## Phase 7 — Panels

---

### Step 7.1 — Layers Panel

```
Create:
  frontend/src/editor/panels/LayersPanel.tsx

Test:
  ☐ One row per path, top = front
  ☐ Click row selects path on canvas
  ☐ Eye icon toggles visibility
  ☐ Double-click name to rename
  ☐ Drag row to reorder (changes z-index)
  ☐ Trash icon deletes path
  ☐ Color bar shows path stroke color
  ☐ Skeleton rows show while project loads

Commit: feat(layers): add layers panel with visibility and reorder
```

---

### Step 7.2 — Style Panel

```
Create:
  frontend/src/editor/panels/StylePanel.tsx
  frontend/src/components/ui/ColorPicker.tsx
  frontend/src/components/ui/Slider.tsx

Test:
  ☐ Fill color picker updates selected path fill live
  ☐ Fill opacity slider updates live
  ☐ Fill None toggle shows/hides fill
  ☐ Stroke color picker updates live
  ☐ Stroke opacity slider updates live
  ☐ Stroke width slider updates live
  ☐ Dashed stroke toggle works
  ☐ Panel shows placeholder when nothing is selected
  ☐ Panel updates instantly when different path is selected

Commit: feat(style-panel): add fill, stroke, and opacity controls
```

---

### Phase 7 Tag

```bash
git tag -a v0.7.0 -m "Phase 7 complete: Layers and style panels"
```

---

## Phase 8 — Shape Tools + Text

---

### Step 8.1 — Rectangle + Ellipse Tools

```
Test:
  ☐ R key activates rect tool
  ☐ Drag to draw rectangle
  ☐ Shift+drag draws square
  ☐ O key activates ellipse tool
  ☐ Drag to draw ellipse
  ☐ Shift+drag draws circle
  ☐ Shapes appear in layers panel
  ☐ Shapes are editable via style panel

Commit: feat(shapes): add rectangle and ellipse drawing tools
```

---

### Step 8.2 — Text Tool

```
Test:
  ☐ T key activates text tool
  ☐ Click canvas places text cursor
  ☐ Type to enter text
  ☐ Font family, size, color controls in style panel
  ☐ Text appears in layers panel
  ☐ Text renders in SVG export

Commit: feat(text): add text tool with font controls
```

---

## Phase 9 — SVG Import + Export

---

### Step 9.1 — Export

```
Test:
  ☐ Ctrl+Shift+E opens export modal
  ☐ Preview panel shows SVG markup
  ☐ Download .svg works
  ☐ Copy to clipboard works
  ☐ All paths / selection only toggle works
  ☐ Pretty / minified toggle works
  ☐ PNG export at 1x, 2x, 3x works

Commit: feat(export): add SVG and PNG export with options
```

---

### Step 9.2 — Import

```
Test:
  ☐ Drag .svg file onto canvas imports all paths
  ☐ File picker button imports .svg
  ☐ Imported paths are editable
  ☐ Drag .png/.jpg onto canvas embeds as image
  ☐ Error toast for unsupported file types

Commit: feat(import): add SVG and image file import
```

---

## Phase 10 — Cloud Save + Versions

---

### Step 10.1 — Auto-save + Project Save

```
Test:
  ☐ Canvas change triggers auto-save after 2s of inactivity
  ☐ Saving indicator appears in toolbar while saving
  ☐ "Saved" indicator appears after successful save
  ☐ Ctrl+S creates named manual version
  ☐ Refresh page — canvas state restored from last save
  ☐ Project thumbnail generated after save

Commit: feat(save): add auto-save and manual version saving
```

---

### Step 10.2 — Version History

```
Test:
  ☐ Version history panel lists all versions
  ☐ Auto-saves shown with timestamp
  ☐ Manual versions shown with user label
  ☐ Click version restores that canvas state
  ☐ Restore requires confirmation

Commit: feat(versions): add version history and restore
```

---

## Phase 11 — File Type Extensibility

See `FILE_SUPPORT.md` for full roadmap.

---

## Phase 12 — Polish + Production Deploy

---

### Step 12.1 — Themes

```
Test:
  ☐ Dark theme is default
  ☐ Light theme toggle works
  ☐ Theme persists on page refresh
  ☐ All UI elements respect theme variables

Commit: feat(themes): add dark and light theme system
```

---

### Step 12.2 — Production Deploy

```
Test:
  ☐ make prod-build succeeds
  ☐ Production images push to Docker registry
  ☐ DigitalOcean VPS pulls and starts production stack
  ☐ HTTPS works with SSL certificate
  ☐ All functionality verified on production URL

Commit: chore(deploy): configure production deployment
git tag -a v1.0.0 -m "v1.0.0: Production launch"
```

---

## Testing Standards

### Backend Tests (pytest)

```python
# Every API endpoint needs at minimum:
# 1. Happy path test
# 2. Unauthorized access test
# 3. Invalid input test

# Run with:
make test-back
```

### Frontend Tests

```typescript
// Every new component needs:
// 1. Renders without crashing
// 2. Skeleton state renders correctly
// 3. Key interactions work

// TypeScript check must pass at every commit:
npx tsc --noEmit
```

### Manual Test Checklist (Before Every Commit)

```
☐ make dev starts cleanly with no errors in logs
☐ The specific feature being committed works as described
☐ Previously working features are not broken (smoke test)
☐ No console errors in browser DevTools
☐ TypeScript check passes: npx tsc --noEmit
☐ Python tests pass: make test-back
```

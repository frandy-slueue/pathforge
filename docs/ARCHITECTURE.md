# ARCHITECTURE — PathForge

> Folder structure, data flow, architectural rules, and the reasoning behind every organizational decision.

---

## The Guiding Principle

> **Separation of concerns at every level. Each layer does exactly one job.**

The canvas engine never touches the UI.
The UI never talks to the database directly.
The backend never knows what the canvas looks like.
Tools are stateless functions, not components.

Break these rules early and the codebase becomes unmaintainable fast.

---

## Top-Level Monorepo

```
pathforge/
├── frontend/                 React app (everything the user sees)
├── backend/                  FastAPI app (everything server-side)
├── nginx/                    Reverse proxy configuration
├── docs/                     All .md documentation files
├── docker-compose.yml        Base Docker service definitions
├── docker-compose.dev.yml    Dev overrides (hot reload, pgadmin)
├── docker-compose.prod.yml   Production overrides (SSL, workers)
├── Makefile                  Shortcut commands
├── .env.example              Template — NEVER commit the real .env
├── .gitignore
└── README.md
```

---

## Frontend Architecture

```
frontend/
├── public/
│   └── fonts/                    Self-hosted fonts (no external CDN in prod)
│
├── src/
│   ├── main.tsx                  App entry point — ReactDOM.createRoot
│   ├── App.tsx                   Root component, router configuration
│   │
│   ├── pages/                    Route-level components (one file per page)
│   │   ├── Landing.tsx           Marketing / home page
│   │   ├── Auth.tsx              Login and registration
│   │   ├── Dashboard.tsx         User project library
│   │   ├── Editor.tsx            THE main canvas editor (the core of the app)
│   │   ├── Share.tsx             Public read-only project view
│   │   └── NotFound.tsx          404 page
│   │
│   ├── editor/                   Everything specific to the canvas editor
│   │   │
│   │   ├── canvas/               Konva rendering engine
│   │   │   ├── KonvaCanvas.tsx   Root canvas — mounts Stage, manages layers
│   │   │   ├── PathLayer.tsx     Renders all SVG path elements
│   │   │   ├── ShapeLayer.tsx    Renders rect, ellipse, polygon shapes
│   │   │   ├── TextLayer.tsx     Renders SVG text elements
│   │   │   ├── ImageLayer.tsx    Renders embedded raster images
│   │   │   ├── OverlayLayer.tsx  Anchor points, handles, bounding boxes
│   │   │   ├── GridLayer.tsx     Grid lines and ruler markings
│   │   │   ├── GuideLayer.tsx    User-placed alignment guides
│   │   │   └── SelectionBox.tsx  Drag-select rectangle
│   │   │
│   │   ├── tools/                One file per drawing/editing tool
│   │   │   ├── PenTool.ts        Bézier curve drawing (the core tool)
│   │   │   ├── SelectTool.ts     Selection, move, multi-select
│   │   │   ├── DirectSelectTool.ts  Node-level editing (anchor + handles)
│   │   │   ├── RectTool.ts       Rectangle drawing
│   │   │   ├── EllipseTool.ts    Ellipse and circle drawing
│   │   │   ├── PolygonTool.ts    Regular polygon drawing
│   │   │   ├── TextTool.ts       SVG text insertion and editing
│   │   │   ├── ImageTool.ts      Raster image embedding
│   │   │   ├── EyedropperTool.ts Color sampling from canvas
│   │   │   └── ZoomTool.ts       Click-to-zoom behavior
│   │   │
│   │   ├── panels/               All sidebar and floating panel UI
│   │   │   ├── LayersPanel.tsx   Layer list, visibility, rename, reorder
│   │   │   ├── StylePanel.tsx    Fill, stroke, opacity controls
│   │   │   ├── TransformPanel.tsx X, Y, W, H, rotation, flip inputs
│   │   │   ├── TextPanel.tsx     Font family, size, weight, alignment
│   │   │   ├── AlignPanel.tsx    Align and distribute multiple elements
│   │   │   ├── BooleanPanel.tsx  Union, subtract, intersect operations
│   │   │   └── ExportPanel.tsx   Export options and format selection
│   │   │
│   │   ├── toolbar/              Top toolbar
│   │   │   ├── Toolbar.tsx       Main toolbar container
│   │   │   ├── ToolButton.tsx    Reusable tool button with tooltip
│   │   │   ├── ZoomControl.tsx   Zoom in/out/reset/fit controls
│   │   │   ├── HistoryControls.tsx Undo/redo buttons
│   │   │   └── MenuBar.tsx       File, Edit, View, Object menus
│   │   │
│   │   └── hooks/                Editor-specific React hooks
│   │       ├── useCanvas.ts      Access canvas state from Zustand
│   │       ├── useHistory.ts     Undo/redo logic and keyboard trigger
│   │       ├── useKeyboard.ts    All keyboard shortcut registration
│   │       ├── useClipboard.ts   Copy/paste/duplicate elements
│   │       ├── useExport.ts      SVG and PNG export logic
│   │       ├── useSnap.ts        Snap to grid, guides, and objects
│   │       └── useAutoSave.ts    Debounced project save trigger
│   │
│   ├── store/                    Zustand global state stores
│   │   ├── canvasStore.ts        Paths, nodes, shapes, transforms (the big one)
│   │   ├── uiStore.ts            Active tool, panel open states, zoom level
│   │   ├── historyStore.ts       Undo/redo action stacks
│   │   ├── projectStore.ts       Current project metadata and save state
│   │   └── userStore.ts          Auth state, user profile, preferences
│   │
│   ├── components/               Reusable UI components (not editor-specific)
│   │   │
│   │   ├── ui/                   Base design system — atoms
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Select.tsx
│   │   │   ├── Slider.tsx
│   │   │   ├── Toggle.tsx
│   │   │   ├── Modal.tsx
│   │   │   ├── Tooltip.tsx
│   │   │   ├── Dropdown.tsx
│   │   │   ├── ColorPicker.tsx
│   │   │   ├── NumberInput.tsx
│   │   │   ├── Skeleton.tsx      Skeleton loading placeholder component
│   │   │   └── Spinner.tsx
│   │   │
│   │   ├── layout/
│   │   │   ├── AppShell.tsx      Toolbar + panels + canvas layout wrapper
│   │   │   ├── PanelGroup.tsx    Resizable panel container
│   │   │   └── Sidebar.tsx       Collapsible sidebar wrapper
│   │   │
│   │   └── shared/
│   │       ├── ProjectCard.tsx   Dashboard project thumbnail card
│   │       ├── ProjectCardSkeleton.tsx  Skeleton state for loading
│   │       ├── Notification.tsx  Toast notification system
│   │       ├── ConfirmDialog.tsx Destructive action confirmation
│   │       └── ErrorBoundary.tsx React error boundary wrapper
│   │
│   ├── lib/                      Pure logic — zero React imports (fully testable)
│   │   │
│   │   ├── svg/
│   │   │   ├── parser.ts         SVG file string → internal data model
│   │   │   ├── exporter.ts       Internal data model → SVG string
│   │   │   ├── optimizer.ts      SVGO integration for clean output
│   │   │   ├── pathMath.ts       Bézier math, boolean ops via Paper.js
│   │   │   └── validator.ts      SVG structure validation on import
│   │   │
│   │   ├── geometry/
│   │   │   ├── transforms.ts     Matrix math, rotate, scale, translate
│   │   │   ├── snap.ts           Snap to grid, guides, object edges
│   │   │   ├── bounds.ts         Bounding box calculation for any element
│   │   │   └── hit.ts            Point-in-path hit testing
│   │   │
│   │   ├── file/
│   │   │   ├── fileDetector.ts   Detect file type from extension and MIME
│   │   │   ├── fileLoader.ts     Load and parse any supported file type
│   │   │   └── fileExporter.ts   Export to any supported output format
│   │   │
│   │   └── utils/
│   │       ├── color.ts          Color format conversion (hex, rgb, hsl, oklch)
│   │       ├── keyboard.ts       Key combination parsing and matching
│   │       ├── debounce.ts       Debounce and throttle utilities
│   │       └── id.ts             Deterministic unique ID generation
│   │
│   ├── api/                      All backend HTTP calls — centralized here only
│   │   ├── client.ts             Axios instance, interceptors, auth headers
│   │   ├── auth.ts               /auth/* endpoints
│   │   ├── projects.ts           /projects/* endpoints
│   │   ├── assets.ts             /assets/* endpoints
│   │   ├── users.ts              /users/* endpoints
│   │   └── types.ts              TypeScript types matching backend Pydantic schemas
│   │
│   ├── types/                    Global TypeScript type definitions
│   │   ├── canvas.ts             Path, Node, Handle, Shape, Layer, Transform
│   │   ├── project.ts            Project, Version, Asset, ShareLink
│   │   ├── user.ts               User, Settings, Preferences
│   │   ├── tools.ts              ToolName enum, ToolState types
│   │   └── file.ts               FileType enum, SupportedFormat types
│   │
│   └── styles/
│       ├── globals.css           CSS reset, base styles, font declarations
│       ├── variables.css         All CSS custom properties
│       └── themes/
│           ├── dark.css          Default dark theme (launched with this)
│           ├── light.css
│           ├── midnight.css
│           └── solarized.css
│
├── Dockerfile
├── index.html
├── vite.config.ts
├── tsconfig.json
├── tsconfig.node.json
├── tailwind.config.ts
├── postcss.config.js
└── package.json
```

---

## Backend Architecture

```
backend/
│
├── app/
│   ├── main.py               FastAPI app creation, middleware, CORS, router mounting
│   ├── config.py             All settings loaded from environment (pydantic-settings)
│   ├── database.py           Async SQLAlchemy engine and session factory
│   │
│   ├── api/
│   │   ├── deps.py           Shared dependencies (get_current_user, get_db session)
│   │   └── v1/
│   │       ├── router.py     Mounts all v1 sub-routers at /api/v1/
│   │       ├── auth.py       POST /auth/login, /auth/register, /auth/refresh, /auth/logout
│   │       ├── projects.py   GET/POST/PUT/DELETE /projects, /projects/{id}
│   │       ├── versions.py   GET /projects/{id}/versions, POST restore
│   │       ├── assets.py     POST /assets/upload, GET /assets/{id}
│   │       └── users.py      GET/PUT /users/me, PUT /users/me/preferences
│   │
│   ├── models/               SQLAlchemy ORM models — one file per table
│   │   ├── base.py           Base model with id (UUID), created_at, updated_at
│   │   ├── user.py           users table
│   │   ├── project.py        projects table
│   │   ├── version.py        project_versions table (SVG snapshots)
│   │   └── asset.py          assets table (file references in object storage)
│   │
│   ├── schemas/              Pydantic schemas for request/response validation
│   │   ├── auth.py           LoginRequest, RegisterRequest, TokenResponse
│   │   ├── project.py        ProjectCreate, ProjectUpdate, ProjectResponse
│   │   ├── version.py        VersionResponse, VersionRestore
│   │   ├── asset.py          AssetUpload, AssetResponse
│   │   └── user.py           UserResponse, UserUpdate, PreferencesUpdate
│   │
│   ├── services/             Business logic — the real work happens here
│   │   ├── auth_service.py   JWT creation, refresh, password hashing, verification
│   │   ├── project_service.py CRUD, fork, duplicate, share link generation
│   │   ├── version_service.py Auto-save snapshots, manual versions, restore
│   │   ├── asset_service.py  Upload to DO Spaces, generate thumbnails, delete
│   │   └── svg_service.py    SVG parsing, validation, SVGO optimization
│   │
│   ├── worker/
│   │   ├── celery_app.py     Celery configuration, broker and result backend
│   │   └── tasks/
│   │       ├── email.py      send_verification_email, send_reset_email
│   │       ├── thumbnails.py generate_project_thumbnail (SVG → PNG)
│   │       └── export.py     export_to_pdf, export_to_png (heavy jobs)
│   │
│   ├── core/
│   │   ├── security.py       bcrypt password hashing, JWT encode/decode
│   │   ├── exceptions.py     Custom exception classes and FastAPI exception handlers
│   │   └── middleware.py     CORS config, rate limiting, request logging middleware
│   │
│   └── migrations/
│       ├── env.py            Alembic environment configuration
│       ├── script.py.mako    Migration file template
│       └── versions/         Auto-generated migration scripts (committed to Git)
│
├── tests/
│   ├── conftest.py           Pytest fixtures, async test client, test database
│   ├── test_auth.py          Registration, login, token refresh tests
│   ├── test_projects.py      CRUD, permissions, sharing tests
│   ├── test_versions.py      Auto-save, restore, history tests
│   └── test_svg_service.py   SVG parsing and validation tests
│
├── Dockerfile
├── requirements.txt
├── requirements.dev.txt      Dev-only: pytest, httpx, black, ruff
└── alembic.ini
```

---

## The Data Flow

Every user interaction follows this exact path, no exceptions:

```
USER ACTION (e.g. draws a path on canvas)
          │
          ▼
  React Component
  KonvaCanvas.tsx
  receives pointer event
          │
          ▼
  Tool Function
  PenTool.ts
  calculates new node position,
  constructs updated path object
          │
          ▼
  Zustand Store ◄────────────────────────────────────────────┐
  canvasStore.ts                                             │
  stores the updated paths array                             │
  as the single source of truth                             │
          │                                                  │
          ├──► PathLayer.tsx re-renders                      │
          │    (Konva draws the updated path)                │
          │                                                  │
          ├──► historyStore.ts receives snapshot             │
          │    (undo is now available)                       │
          │                                                  │
          └──► useAutoSave.ts detects change                 │
               debounces 2 seconds                           │
                      │                                      │
                      ▼                                      │
               api/projects.ts                               │
               axios POST /api/v1/projects/{id}/versions     │
                      │                                      │
                      ▼                                      │
               FastAPI route handler                         │
               versions.py                                   │
               validates request body                        │
                      │                                      │
                      ▼                                      │
               version_service.py                            │
               saves SVG snapshot to database                │
                      │                                      │
                      ▼                                      │
               Celery queues thumbnail job ──────────────────┘
               (background, non-blocking)
                      │
                      ▼
               worker/tasks/thumbnails.py
               generates PNG preview
               uploads to DO Spaces
               updates project record
```

---

## Database Schema

```sql
-- users
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email       TEXT UNIQUE NOT NULL,
  username    TEXT UNIQUE NOT NULL,
  password    TEXT NOT NULL,          -- bcrypt hash
  is_verified BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- projects
CREATE TABLE projects (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  name         TEXT NOT NULL DEFAULT 'Untitled',
  description  TEXT,
  thumbnail    TEXT,                  -- URL in DO Spaces
  is_public    BOOLEAN DEFAULT false,
  share_token  TEXT UNIQUE,           -- for public share links
  canvas_w     INTEGER DEFAULT 800,
  canvas_h     INTEGER DEFAULT 600,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- project_versions (auto-save + manual snapshots)
CREATE TABLE project_versions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id  UUID REFERENCES projects(id) ON DELETE CASCADE,
  svg_data    TEXT NOT NULL,          -- full SVG string at this point in time
  label       TEXT,                  -- null = auto-save, text = manual version
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- assets (images and fonts embedded in projects)
CREATE TABLE assets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id    UUID REFERENCES users(id) ON DELETE CASCADE,
  project_id  UUID REFERENCES projects(id) ON DELETE SET NULL,
  filename    TEXT NOT NULL,
  file_type   TEXT NOT NULL,         -- 'image/png', 'image/jpeg', etc.
  url         TEXT NOT NULL,         -- DO Spaces URL
  size_bytes  INTEGER,
  created_at  TIMESTAMPTZ DEFAULT now()
);
```

---

## Architectural Rules (Non-Negotiable)

```
RULE 1: Components never fetch data directly
  ✅ Component → Zustand store → api/ client → Backend
  ❌ Component → fetch('/api/projects') directly

RULE 2: Stores hold data, not rendering logic
  ✅ canvasStore: { paths: PathObject[], selectedId: string | null }
  ❌ canvasStore: { renderPath: (path) => <KonvaPath ... /> }

RULE 3: Tool files are pure TypeScript functions
  ✅ PenTool.ts exports: handleMouseDown(event, state): StateUpdate
  ❌ PenTool.tsx: a React component with hooks and JSX

RULE 4: lib/ files have zero React imports
  ✅ lib/svg/parser.ts — pure functions, fully testable with jest
  ❌ lib/svg/parser.ts importing useState or useEffect

RULE 5: api/ is the only place that knows the backend URL
  ✅ import { getProjects } from '../api/projects'
  ❌ axios.get('http://localhost:8000/api/v1/projects') in a component

RULE 6: Backend routes are thin — max 15 lines
  ✅ Route validates input, calls service, returns response
  ❌ Route contains SQL queries, business logic, and file I/O

RULE 7: Every async UI state has a skeleton loading state
  ✅ {isLoading ? <ProjectCardSkeleton /> : <ProjectCard />}
  ❌ Showing a blank screen or spinner while data loads

RULE 8: All database changes go through Alembic migrations
  ✅ alembic revision --autogenerate -m "add share_token to projects"
  ❌ Manually running ALTER TABLE in a database shell
```

---

## Skeleton Loading Strategy

Every screen that loads async data must implement skeleton states. This is a hard requirement — no blank screens or layout shift.

```tsx
// Pattern for every data-loading component
const Dashboard = () => {
  const { projects, isLoading } = useProjectStore();

  return (
    <div className="grid grid-cols-3 gap-4">
      {isLoading
        ? Array.from({ length: 6 }).map((_, i) => (
            <ProjectCardSkeleton key={i} />
          ))
        : projects.map(p => (
            <ProjectCard key={p.id} project={p} />
          ))
      }
    </div>
  );
};

// Skeleton component mirrors the real component's dimensions
const ProjectCardSkeleton = () => (
  <div className="rounded-lg overflow-hidden">
    <Skeleton className="w-full h-40" />      {/* thumbnail */}
    <div className="p-3 space-y-2">
      <Skeleton className="w-3/4 h-4" />      {/* title */}
      <Skeleton className="w-1/2 h-3" />      {/* date */}
    </div>
  </div>
);
```

**Screens that require skeleton states:**
```
Dashboard         → Project card grid
Editor (loading)  → Canvas area + panels
Layers panel      → Layer list items
Style panel       → Color swatches and values
Share view        → Full canvas skeleton
```

---

## Adding a New File Type (Extensibility Design)

The architecture is explicitly designed so new file type support never breaks existing code:

```
To add PNG editing support:

Frontend:
  1. Add 'png' to src/types/file.ts FileType enum
  2. Create src/lib/file/pngLoader.ts (pure function)
  3. Create src/editor/tools/ImageTool.ts (if not exists)
  4. Register in src/lib/file/fileDetector.ts

Backend:
  1. Create app/services/png_service.py
  2. Add route in app/api/v1/assets.py
  3. Add Celery task in app/worker/tasks/export.py if needed

Nothing else changes. Zero modifications to existing code.
```

See `FILE_SUPPORT.md` for the complete file type roadmap.

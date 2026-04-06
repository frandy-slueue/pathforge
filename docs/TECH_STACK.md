# TECH STACK — PathForge

> Every technology choice, the reason it was selected, and what it is responsible for in the application.

---

## The Core Problem This Stack Solves

A professional SVG editor has two competing demands that most stacks handle poorly:

**Demand A — Rich interactive UI**
Panels, toolbars, modals, color pickers, dropdowns, real-time property updates across dozens of components simultaneously.

**Demand B — High-performance canvas rendering**
Drawing, hit-testing, transformations, Bézier math, handling hundreds of nodes without lag, 60fps interactions.

Generic frameworks are great at Demand A but fight you on Demand B. Raw canvas/SVG is great at Demand B but has no opinion on Demand A.

**The solution:** Keep them completely separate. The UI layer and the rendering engine are different systems that share state through a central store — the same pattern Figma uses.

---

## Full Stack at a Glance

```
┌─────────────────────────────────────────────────────────────────┐
│                         PathForge                               │
├──────────────────────────────┬──────────────────────────────────┤
│          FRONTEND            │            BACKEND               │
│  React 18 + TypeScript 5     │  FastAPI (Python 3.12)           │
│  Vite 5 (build tool)         │  PostgreSQL 16                   │
│  Zustand (state management)  │  SQLAlchemy 2.0 async ORM        │
│  Konva.js + react-konva      │  Alembic (migrations)            │
│  Paper.js (path math)        │  Redis 7                         │
│  Tailwind CSS + CSS vars     │  Celery (background jobs)        │
│  React Router v6             │  JWT auth (httpOnly cookies)     │
│  SVGO (SVG optimization)     │  Resend (transactional email)    │
│  react-dropzone              │  python-multipart (file uploads) │
├──────────────────────────────┴──────────────────────────────────┤
│                       INFRASTRUCTURE                            │
│  Docker + Docker Compose (7 services)                           │
│  Nginx (reverse proxy + static file serving)                    │
│  DigitalOcean VPS (production hosting)                          │
│  DigitalOcean Spaces (object storage for files and assets)      │
│  GitHub Actions (CI/CD pipeline)                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Frontend Technologies

---

### React 18 + TypeScript 5

**What it is:** The UI framework. Every panel, button, modal, and sidebar is a React component.

**Why React:**
- Component model maps perfectly to a panel-based editor layout
- Huge ecosystem — every UI primitive we need already exists
- Concurrent features (Suspense, transitions) enable skeleton loading natively
- Industry standard — skills transfer directly to job market

**Why TypeScript specifically:**
- An SVG node has 15+ properties
- A path object has nodes, handles, styles, transforms, and metadata
- Without types, bugs in a codebase this size are invisible until runtime
- TypeScript catches entire categories of errors before you run a single line
- Every serious production application at this scale uses TypeScript

```typescript
// Example: Without TypeScript, this bug is silent
const node = path.nodes[0];
node.cp1.x = 100; // crashes if node is undefined

// With TypeScript, this is caught at compile time
const node: PathNode | undefined = path.nodes[0];
if (node) node.cp1.x = 100; // compiler forces the check
```

---

### Vite 5

**What it is:** The build tool and development server.

**Why Vite:**
- Instant hot module replacement — save a file, see it update in under 100ms
- Native TypeScript and JSX support with no configuration
- Dramatically faster than Webpack or Create React App
- You already use it in DriveReady — no learning curve

---

### Zustand

**What it is:** The global state management library. Every piece of canvas state lives here.

**Why not Redux:**
Redux is powerful but requires enormous boilerplate for what is essentially a large shared object that updates 60 times per second during drawing.

**Why Zustand:**
- Minimal boilerplate — a store is just a function
- Stores the entire canvas state (paths, layers, selection, history, settings) in one accessible place
- Persists state across re-renders without prop drilling
- Built-in middleware support for undo/redo via `temporal` middleware
- Works perfectly alongside React without any Provider wrapping gymnastics

```typescript
// Zustand store example
const useCanvasStore = create<CanvasStore>((set, get) => ({
  paths: [],
  selectedId: null,
  addPath: (path) => set(state => ({ paths: [...state.paths, path] })),
  selectPath: (id) => set({ selectedId: id }),
}));

// Used in any component with zero prop drilling
const { paths, selectedId } = useCanvasStore();
```

---

### Konva.js + react-konva

**What it is:** The canvas rendering engine. This is what actually draws on screen.

**Why not raw SVG DOM:**
```
Problem with raw SVG DOM at scale:
  - Hit-testing 500 overlapping paths is slow
  - No built-in selection, snapping, or transformation handles
  - You rebuild everything Figma already solved from scratch
  - Event handling across hundreds of elements gets extremely complex
```

**Why Konva:**
- Built specifically for interactive canvas applications exactly like this
- Built-in: drag and drop, selection boxes, transformer handles, layers, groups
- Hit-testing is fast and accurate even with hundreds of elements
- react-konva gives you a React component API over the Konva canvas
- Exports canvas content to SVG natively
- Used in production by real design tools

```tsx
// Konva feels like React — familiar and composable
<Stage width={800} height={600}>
  <Layer>
    <KonvaPath data={svgD} fill="none" stroke="#00F5C4" />
    <Circle x={100} y={100} radius={5} fill="teal" draggable />
  </Layer>
</Stage>
```

---

### Paper.js

**What it is:** A computational geometry library for complex path math.

**Why it exists alongside Konva:**
Konva handles rendering and interaction. Paper.js handles the hard math that Konva does not do:
- Boolean path operations (union, subtract, intersect)
- Path simplification and smoothing
- Offset path (stroke expansion)
- Finding intersections between paths
- Measuring path length and area

Paper.js is used as a utility library called from service functions. It never touches the UI.

---

### Tailwind CSS + CSS Custom Properties

**What it is:** The styling system.

**Why Tailwind for layout and utility classes:**
- Rapid development of complex layouts without writing CSS files
- Consistent spacing, sizing, and color scales
- Responsive utilities for panel collapse behavior

**Why CSS custom properties for the theme system:**
- The editor supports multiple themes (dark, light, midnight, solarized)
- CSS variables update instantly without re-rendering React components
- The canvas and SVG elements can also reference the same variables
- Theme switching is a single class change on `<html>`

---

### SVGO

**What it is:** An SVG optimization library.

**Why it is needed:**
SVG files exported from design tools (Illustrator, Figma, Inkscape) are bloated with unnecessary attributes, comments, and redundant paths. SVGO runs as a post-processing step on all exports to produce clean, minimal SVG output.

---

### React Router v6

**What it is:** Client-side routing.

**Routes the app needs:**
```
/                   Landing page
/login              Authentication
/register
/dashboard          User's project library
/editor             New blank project
/editor/:projectId  Open existing project
/share/:shareId     Public read-only project view
```

---

## Backend Technologies

---

### FastAPI (Python 3.12)

**What it is:** The web framework for all API endpoints.

**Why FastAPI:**
- You already know this stack from frandy.dev — no context switch
- Async-native — handles many simultaneous connections without blocking
- Automatic OpenAPI docs at `/docs` — the entire API is self-documenting
- Pydantic validation on every request and response — type safety on the backend mirrors TypeScript on the frontend
- Fastest Python web framework in benchmarks

---

### PostgreSQL 16

**What it is:** The primary relational database.

**What it stores:**
```
users               Account credentials and preferences
projects            Project metadata (name, created_at, owner)
project_versions    SVG snapshots over time (auto-save + manual versions)
assets              References to uploaded files in object storage
shared_links        Public share URLs with permission settings
```

**Why not SQLite or MongoDB:**
- SQLite cannot handle concurrent writes from multiple users
- MongoDB's flexible schema is actually a liability here — we need
  consistent structure for relational data (users → projects → versions)
- PostgreSQL is the correct tool for structured relational data at any scale

---

### SQLAlchemy 2.0 Async + Alembic

**What it is:** The ORM (object-relational mapper) and migration tool.

**Why the async version:**
FastAPI is async. Using a synchronous ORM blocks the event loop and defeats the entire point of async. SQLAlchemy 2.0 async runs database queries without blocking.

**Why Alembic:**
Every change to the database schema is tracked as a migration file. This means:
- Database changes are version-controlled alongside code
- Rolling back a schema change is a single command
- Every environment (dev, staging, prod) gets the exact same schema

---

### Redis 7

**What it is:** An in-memory data store used for multiple purposes.

**What Redis handles in this app:**
```
Session caching     Fast JWT token lookup without hitting PostgreSQL
Celery broker       Message queue for background jobs
Rate limiting       Track API request counts per user/IP
Real-time state     Foundation for future collaboration features
```

---

### Celery

**What it is:** A distributed task queue for background jobs.

**Why background jobs are needed:**
Some operations are too slow to run during an API request:
```
Thumbnail generation    Convert SVG to PNG preview image
Email delivery          Send via Resend without blocking the response
SVG optimization        Run SVGO on large files
PDF export              Convert SVG → PDF (CPU intensive)
File format conversion  Process uploaded files into supported formats
```

Without Celery, these operations block the API response and make the app feel slow.

---

### JWT Auth (httpOnly Cookies)

**What it is:** The authentication system.

**Why httpOnly cookies over localStorage:**
- httpOnly cookies cannot be accessed by JavaScript
- This prevents XSS attacks from stealing tokens
- Same pattern used in frandy.dev — already familiar

---

### Resend

**What it is:** The transactional email service.

**What it sends:**
```
Email verification      On registration
Password reset          On request
Share notifications     When someone shares a project with you
Export ready            When a large export job completes
```

---

## Infrastructure

---

### Docker + Docker Compose

**7 services total — see DOCKER.md for full breakdown.**

Docker ensures the application runs identically on:
- Your WSL 2 development machine
- A teammate's Mac
- The DigitalOcean production server

No more "works on my machine" problems.

---

### Nginx

**What it is:** The reverse proxy and static file server.

**What Nginx handles:**
```
Port 80/443         Single public entry point for all traffic
/api/*              Proxied to FastAPI backend
/*                  Served from React build output
SSL termination     HTTPS in production
Gzip compression    SVG files compress 70-90% — critical for performance
Static caching      Assets cached aggressively (content-hashed filenames)
```

---

### DigitalOcean Spaces

**What it is:** S3-compatible object storage for files that should not live in PostgreSQL.

**What it stores:**
```
User-uploaded SVG files
Embedded raster images (JPG/PNG inside SVG documents)
Project thumbnail previews
Exported files (PDF, PNG) awaiting download
```

---

### GitHub Actions (CI/CD)

**What it does:**
```
On every push to main:
  1. Run TypeScript type check
  2. Run Python tests (pytest)
  3. Build Docker images
  4. Push images to registry
  5. Deploy to DigitalOcean via SSH

On pull requests:
  1. Run all tests
  2. Block merge if tests fail
```

---

## Why This Stack Is Future-Proof for File Editing

The architecture is explicitly designed so new file type support can be added without touching existing code:

```
Current:   SVG editing
Future:    PNG/JPG editing → add ImageTool.ts + image service
Future:    PDF editing    → add PDF renderer + pdf_service.py
Future:    Figma import   → add figma_parser.ts
Future:    AI generation  → add AI service + prompt panel
```

Each file type is a plugin — a new tool file on the frontend and a new service on the backend. The canvas, state management, and infrastructure never change.

See `FILE_SUPPORT.md` for the full file type roadmap.

---

## Technology Decisions That Were Considered and Rejected

| Technology | Why It Was Rejected |
|---|---|
| Next.js | Server-side rendering adds complexity with no benefit for a canvas app. All rendering is client-side. |
| Redux Toolkit | Too much boilerplate for state that updates 60fps during drawing. Zustand is cleaner. |
| Fabric.js | Good library but older API design. Konva has better React integration and more active maintenance. |
| Three.js | 3D library — overkill. Adds massive bundle size for 2D vector work. |
| MongoDB | No relational integrity. Users, projects, versions, and assets are deeply relational. |
| Firebase | Vendor lock-in. We control our own data and infrastructure. |
| Express.js | You are targeting Python Pro level. FastAPI keeps the backend in Python. |
| GraphQL | REST is simpler, easier to test, and sufficient for this data model. GraphQL complexity is not justified here. |

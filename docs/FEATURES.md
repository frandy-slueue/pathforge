# FEATURES — PathForge

> Every feature, tool, panel, and capability the app must have to function as a true professional SVG editor. Organized by category with priority levels.

---

## Priority Levels

```
P0 — Core (app cannot function without this)
P1 — Essential (professional tool requires this)
P2 — Important (significantly improves the tool)
P3 — Nice to have (adds polish and power)
```

---

## 1. Canvas Engine

| Feature | Priority | Description |
|---|---|---|
| Infinite canvas | P0 | Pan and zoom to any area, no hard edges |
| Zoom (scroll wheel) | P0 | Centered on cursor position, 0.5%–3200% range |
| Zoom (keyboard) | P0 | Cmd/Ctrl + and - for fixed zoom steps |
| Fit to content | P0 | F key or button — fits all elements in view |
| Fit to canvas | P1 | Fits the defined canvas/artboard dimensions |
| Pan (Space + drag) | P0 | Hold space, drag to pan |
| Pan (middle mouse) | P0 | Middle mouse button drag |
| Zoom reset | P1 | Click zoom display to reset to 100% |
| Canvas background | P1 | Configurable background color or transparent |
| Artboard / frame | P1 | Defined canvas dimensions shown as white rect |
| Rulers | P2 | X/Y rulers on canvas edges showing coordinates |
| Grid overlay | P1 | Configurable grid with major/minor lines |
| Snap to grid | P1 | Anchor points snap when grid is active |
| Snap to objects | P2 | Snap to bounding boxes and center points of other elements |
| Smart guides | P2 | Alignment guides appear when dragging near other objects |
| Pixel preview | P2 | Toggle to see how raster export will look |
| Crosshair cursor | P1 | Fine crosshair with coordinate readout |
| Skeleton loading | P0 | Canvas area shows skeleton while project loads |

---

## 2. Drawing Tools

### Pen Tool (P0)
```
Click to place sharp corner anchor points
Click + drag to create smooth Bézier curve nodes
Live rubber-band preview curve follows cursor
Click first anchor to close a path (pulsing ring indicator)
Escape to end open path
Multiple independent paths per canvas
Full cubic Bézier (C command) SVG output
```

### Direct Selection Tool (P0)
```
Click any path to select it
Click empty canvas to deselect
Shift + click for multi-select
Drag to lasso-select multiple elements
Drag anchor points to reshape path
Drag control handles to adjust curve tension
Smooth ↔ corner node toggle (right-click or panel button)
```

### Selection / Move Tool (P0)
```
Click to select entire path or shape
Drag to move selected elements
Arrow keys to nudge (1px), Shift + arrow (10px)
Bounding box with scale handles
Shift + drag scale handle to maintain aspect ratio
Corner radius handle on rectangles
```

### Rectangle Tool (P1)
```
Click + drag to draw rectangle
Shift + drag for perfect square
Corner radius via panel input
Converts to editable path
```

### Ellipse Tool (P1)
```
Click + drag to draw ellipse
Shift + drag for perfect circle
Start angle and sweep angle controls
Converts to editable path
```

### Polygon Tool (P2)
```
Click + drag to draw regular polygon
Side count input (3-12)
Star variant with inner radius control
```

### Line Tool (P1)
```
Click + drag to draw straight line
Shift + drag to constrain to 45° angles
Arrowhead options (start, end, both)
```

### Text Tool (P1)
```
Click to place text cursor
Type to enter text
Font family selection
Font size, weight, style (bold, italic)
Text color
Letter spacing and line height
Convert text to path
```

### Image Tool (P1)
```
Click to place image from computer
Drag and drop image onto canvas
Resize with aspect ratio lock
Clip mask (fit image inside a shape)
```

### Eyedropper Tool (P2)
```
Click anywhere on canvas to sample color
Sampled color applied to selected element fill or stroke
Works on paths, shapes, and images
```

---

## 3. Node Editing

| Feature | Priority | Description |
|---|---|---|
| Anchor point drag | P0 | Move individual nodes to reshape path |
| Control handle drag | P0 | Adjust incoming and outgoing curve tension independently |
| Smooth node | P0 | Handles mirror each other across the anchor point |
| Corner node | P0 | Handles move independently with no mirroring |
| Asymmetric node | P1 | Handles mirror angle but not length |
| Add anchor point | P1 | Click on path segment to add new node |
| Remove anchor point | P1 | Delete selected node, path reconnects |
| Node type toggle | P0 | Right-click or panel button to switch smooth ↔ corner |
| Select all nodes | P1 | Ctrl+A while in Direct Selection mode |
| Cut path at node | P2 | Split one path into two at selected node |
| Join paths | P2 | Connect two open path endpoints |

---

## 4. Layers Panel

| Feature | Priority | Description |
|---|---|---|
| Layer list | P0 | One row per element, top = front |
| Visibility toggle | P0 | Eye icon shows/hides element on canvas |
| Lock toggle | P1 | Lock icon prevents editing |
| Rename inline | P0 | Double-click name to edit |
| Drag to reorder | P0 | Drag rows to change z-index |
| Color bar | P1 | Small color indicator of element's stroke |
| Delete from panel | P0 | Trash icon per row |
| Select from panel | P0 | Click row to select element on canvas |
| Expand groups | P2 | Groups show nested children in panel |
| Collapse all | P2 | Collapse all group trees |
| Multi-select in panel | P1 | Shift-click to select multiple layers |
| Skeleton state | P0 | Skeleton rows while project is loading |

---

## 5. Style Panel (Properties)

### Fill
```
Color picker (hex, RGB, HSL, oklch)
Opacity control (0-100%)
None / solid / linear gradient / radial gradient / pattern
Gradient editor with stop handles
```

### Stroke
```
Color picker
Opacity control
Width slider (0-100px)
Line cap: butt, round, square
Line join: miter, round, bevel
Dashed stroke: dash length and gap controls
Arrowheads: start and end options
```

### Effects (P2)
```
Drop shadow (x, y, blur, spread, color)
Inner shadow
Blur (Gaussian)
```

### Transform
```
X, Y position inputs
Width, Height inputs
Lock aspect ratio toggle
Rotation input (degrees)
Flip horizontal / vertical
```

---

## 6. Alignment and Distribution

| Feature | Priority | Description |
|---|---|---|
| Align left | P1 | Align left edges of selected elements |
| Align center H | P1 | Center horizontally |
| Align right | P1 | Align right edges |
| Align top | P1 | Align top edges |
| Align center V | P1 | Center vertically |
| Align bottom | P1 | Align bottom edges |
| Distribute horizontal | P2 | Equal horizontal spacing |
| Distribute vertical | P2 | Equal vertical spacing |
| Align to canvas | P1 | Align relative to artboard, not selection |
| Align to key object | P2 | Click to designate which element others align to |

---

## 7. Boolean Path Operations

| Operation | Priority | Description |
|---|---|---|
| Union | P1 | Merge two paths into one outer shape |
| Subtract | P1 | Cut second path from first path |
| Intersect | P1 | Keep only the overlapping area |
| Exclude | P2 | Opposite of intersect — keep non-overlapping |
| Divide | P2 | Split paths at all intersection points |

All operations require exactly 2 paths selected. Result is editable. Operation is undoable.

---

## 8. Groups

| Feature | Priority | Description |
|---|---|---|
| Group elements | P1 | Cmd/Ctrl+G groups selected elements |
| Ungroup | P1 | Cmd/Ctrl+Shift+G dissolves group |
| Enter group | P1 | Double-click to edit inside group |
| Exit group | P1 | Escape to exit group editing mode |
| Move group | P1 | Drag group as single unit |
| Nested groups | P2 | Groups inside groups |
| Clip mask | P2 | Use top shape as mask for group contents |

---

## 9. History (Undo/Redo)

| Feature | Priority | Description |
|---|---|---|
| Undo | P0 | Ctrl/Cmd+Z — 100 step depth |
| Redo | P0 | Ctrl/Cmd+Shift+Z or Ctrl+Y |
| History covers: | P0 | All draw, move, delete, style, transform operations |
| History panel | P3 | Visual list of recent actions, click to jump to any state |

---

## 10. Clipboard

| Feature | Priority | Description |
|---|---|---|
| Copy | P0 | Ctrl/Cmd+C — copies selected elements |
| Cut | P0 | Ctrl/Cmd+X |
| Paste | P0 | Ctrl/Cmd+V — pastes with slight offset |
| Paste in place | P1 | Ctrl/Cmd+Shift+V — pastes at exact original position |
| Duplicate | P0 | Ctrl/Cmd+D — copy + paste in one step |
| Copy as SVG | P1 | Copy selected as SVG markup string |
| Copy style | P2 | Copy fill/stroke settings only |
| Paste style | P2 | Apply copied style to another element |

---

## 11. Export

| Format | Priority | Description |
|---|---|---|
| SVG | P0 | Clean, optimized SVG with SVGO |
| PNG | P0 | Rasterized at 1x, 2x, 3x options |
| JPG | P1 | Rasterized with quality setting |
| PDF | P2 | Vector PDF via backend Celery job |
| WebP | P2 | Modern web format |
| Export options | P0 | All elements vs selection only |
| Pretty / minified | P0 | Human-readable vs compressed SVG |
| Background | P1 | Transparent or filled |
| Canvas bounds | P1 | Artboard size vs content bounds |
| Export panel | P0 | Modal with format options and live preview of SVG markup |

---

## 12. Import

| Format | Priority | Description |
|---|---|---|
| SVG | P0 | Full parsing into editable elements |
| PNG/JPG | P1 | Embedded as image element |
| WebP | P1 | Embedded as image element |
| PDF | P2 | First page rasterized as image |
| Drag and drop | P0 | Drop file directly onto canvas |
| File picker | P0 | Click to browse files |
| URL import | P3 | Import SVG from a URL |

---

## 13. Project Management

| Feature | Priority | Description |
|---|---|---|
| Create project | P0 | Blank canvas with given dimensions |
| Name project | P0 | Click to rename at top of editor |
| Auto-save | P0 | Saves every 2 seconds of inactivity |
| Manual save | P0 | Ctrl/Cmd+S — creates named version |
| Version history | P1 | List of all auto-saves and manual versions |
| Restore version | P1 | Click any version to restore that state |
| Duplicate project | P1 | Copy to a new project |
| Delete project | P0 | From dashboard — requires confirmation |
| Project thumbnail | P1 | Auto-generated PNG preview shown on dashboard |

---

## 14. Sharing and Collaboration

| Feature | Priority | Description |
|---|---|---|
| Public share link | P1 | Generate URL for read-only view |
| Revoke share link | P1 | Disable the link |
| Share view | P1 | Clean viewer with export button, no editing |
| Copy link | P1 | One-click copy share URL |
| Real-time collab | P3 | Multiple users editing simultaneously (WebSocket) |

---

## 15. User Accounts

| Feature | Priority | Description |
|---|---|---|
| Register | P0 | Email + password, email verification |
| Login | P0 | Email + password, JWT session |
| Logout | P0 | Clears httpOnly cookie |
| Forgot password | P1 | Email reset link |
| Change password | P1 | In settings |
| Delete account | P1 | Requires confirmation, cascades delete projects |
| User preferences | P1 | Theme, default canvas size, grid settings |
| Profile page | P2 | Public page with shared projects |

---

## 16. UI and Theme System

| Feature | Priority | Description |
|---|---|---|
| Dark theme | P0 | Default — deep dark with teal accent |
| Light theme | P1 | Professional light mode |
| Midnight theme | P2 | Near-black with purple accent |
| Solarized theme | P2 | Classic solarized palette |
| Theme persistence | P1 | Saved to user preferences |
| Skeleton loading | P0 | Every async UI state has skeleton |
| Panel resize | P2 | Drag panel edges to resize |
| Panel collapse | P1 | Click to collapse left/right panels |
| Keyboard shortcuts overlay | P1 | ? key shows all shortcuts in modal |
| Context menus | P2 | Right-click menus on canvas elements |
| Notification toasts | P0 | Success, error, warning, info toasts |
| Responsive layout | P1 | Panels collapse on smaller screens |

---

## 17. Keyboard Shortcuts (Complete List)

### Tools
```
V             Select / Move tool
A             Direct Select (node editing)
P             Pen tool
R             Rectangle tool
O             Ellipse tool
L             Line tool
T             Text tool
I             Eyedropper
Z             Zoom tool
Space         Hold to activate pan
```

### Canvas
```
+  or  =      Zoom in
-             Zoom out
0             Fit content to view
Cmd/Ctrl+0    Reset zoom to 100%
G             Toggle grid
Shift+G       Toggle snap
```

### Elements
```
Cmd/Ctrl+A    Select all
Escape        Deselect all / exit tool
Delete        Delete selected
Cmd/Ctrl+D    Duplicate
Cmd/Ctrl+G    Group
Cmd/Ctrl+Shift+G  Ungroup
```

### History
```
Cmd/Ctrl+Z         Undo
Cmd/Ctrl+Shift+Z   Redo
Cmd/Ctrl+Y         Redo (Windows)
```

### Clipboard
```
Cmd/Ctrl+C         Copy
Cmd/Ctrl+X         Cut
Cmd/Ctrl+V         Paste
Cmd/Ctrl+Shift+V   Paste in place
```

### Arrange
```
Cmd/Ctrl+]    Bring forward
Cmd/Ctrl+[    Send backward
Cmd/Ctrl+Shift+]  Bring to front
Cmd/Ctrl+Shift+[  Send to back
```

### File
```
Cmd/Ctrl+S         Save (manual version)
Cmd/Ctrl+Shift+E   Export
Cmd/Ctrl+Shift+I   Import
```

### Nudge
```
Arrow keys         Move 1px
Shift+Arrow        Move 10px
```

---

## Skeleton Loading Checklist

Every one of these states must have a skeleton implementation before shipping:

```
☐ Dashboard project grid
☐ Editor canvas area (while project SVG loads)
☐ Layers panel (while layer list populates)
☐ Style panel (while element properties load)
☐ Version history list
☐ Asset browser
☐ Share view canvas
☐ User preferences panel
```

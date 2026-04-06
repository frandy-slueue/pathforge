# FILE SUPPORT — PathForge

> Supported file types, the extensibility architecture that makes adding new types possible, and the full roadmap for format support.

---

## Design Philosophy

PathForge is not just an SVG editor. The long-term vision is a creative tool that handles **any file type a designer or developer might encounter**. The architecture is built from day one so that adding a new file type never requires modifying existing code — only adding new files.

This is the Open/Closed Principle applied to file format support:
> **Open for extension. Closed for modification.**

---

## How File Type Support Works

Every file type the app handles is registered in one central place:

```typescript
// src/lib/file/fileRegistry.ts

export const FILE_REGISTRY: FileTypeDefinition[] = [
  {
    type: 'svg',
    mimeTypes: ['image/svg+xml'],
    extensions: ['.svg'],
    canEdit: true,
    canImport: true,
    canExport: true,
    loader: () => import('./loaders/svgLoader'),
    exporter: () => import('./exporters/svgExporter'),
  },
  {
    type: 'png',
    mimeTypes: ['image/png'],
    extensions: ['.png'],
    canEdit: false,      // embed only, not editable at path level
    canImport: true,
    canExport: true,
    loader: () => import('./loaders/imageLoader'),
    exporter: () => import('./exporters/pngExporter'),
  },
  // Adding a new type = adding one object here + creating the loader/exporter
];
```

The loader and exporter are lazy-loaded — they only download to the browser when actually needed. This keeps the initial bundle small.

---

## Adding a New File Type (Step-by-Step)

To add support for a new file format, you create 4 files and register in 1 place:

```
1. src/lib/file/loaders/newformatLoader.ts
   - Reads the file, converts to internal canvas data model
   - Pure function: (file: File) => Promise<CanvasElements>

2. src/lib/file/exporters/newformatExporter.ts
   - Converts internal canvas data model to the output format
   - Pure function: (elements: CanvasElements, options: ExportOptions) => Promise<Blob>

3. backend/app/services/newformat_service.py
   - Server-side processing if the format requires it
   - (not needed for formats handled entirely client-side)

4. backend/app/worker/tasks/newformat.py
   - Celery tasks for heavy conversion jobs
   - (only needed for CPU-intensive formats like PDF)

5. Register in src/lib/file/fileRegistry.ts
   - One object in the array
   - That's it. Everything else picks it up automatically.
```

---

## File Support Roadmap

---

### Phase 1 — Core (Launching With These)

| Format | Import | Export | Edit | Notes |
|---|---|---|---|---|
| SVG | ✅ | ✅ | ✅ | Full path-level editing |
| PNG | ✅ | ✅ | ❌ | Import as embedded image, export as raster |
| JPG/JPEG | ✅ | ✅ | ❌ | Import as embedded image, export as raster |

---

### Phase 2 — Shortly After Launch

| Format | Import | Export | Edit | Notes |
|---|---|---|---|---|
| WebP | ✅ | ✅ | ❌ | Modern web image format |
| GIF | ✅ | ❌ | ❌ | Import static frame only |
| PDF | ✅ | ✅ | ❌ | Import first page as image, export via Celery |
| SVGZ | ✅ | ✅ | ✅ | Gzip-compressed SVG |

---

### Phase 3 — Extended Format Support

| Format | Import | Export | Edit | Notes |
|---|---|---|---|---|
| Figma (fig) | ✅ | ❌ | ❌ | Via Figma REST API — import designs |
| Sketch | ✅ | ❌ | ❌ | Parse sketch file format |
| Adobe Illustrator (ai) | ✅ | ❌ | ❌ | AI files are PostScript-based |
| EPS | ✅ | ✅ | ❌ | Encapsulated PostScript |
| DXF | ✅ | ✅ | ❌ | CAD format — popular for laser cutting |
| ICO | ❌ | ✅ | ❌ | Export favicon packages |
| AVIF | ✅ | ✅ | ❌ | Next-gen image format |

---

### Phase 4 — Power User Formats

| Format | Import | Export | Edit | Notes |
|---|---|---|---|---|
| Lottie (JSON) | ✅ | ✅ | ❌ | After Effects animations as JSON |
| GIF (animated) | ❌ | ✅ | ❌ | Export SVG animation as GIF |
| MP4/WebM | ❌ | ✅ | ❌ | Export SVG animation as video |
| Font (TTF/OTF) | ✅ | ❌ | ❌ | Use custom fonts in designs |
| WOFF2 | ✅ | ❌ | ❌ | Web font format |
| ZIP | ✅ | ✅ | ❌ | Multi-file export bundles |

---

## Format-Specific Technical Notes

---

### SVG (Primary Format)

SVG is the native format of PathForge. The internal canvas data model is a superset of SVG — it adds metadata that SVG does not have (layer names, version info, editing handles).

**Import pipeline:**
```
.svg file
  → SVG parser (lib/svg/parser.ts)
  → Internal CanvasElements model
  → Rendered by Konva
```

**Export pipeline:**
```
CanvasElements in Zustand store
  → SVG exporter (lib/svg/exporter.ts)
  → SVGO optimizer (lib/svg/optimizer.ts)
  → Clean .svg file
```

**What gets preserved on import:**
```
✅ All <path> elements and their d attributes
✅ Fill and stroke colors and opacities
✅ Stroke width and dash arrays
✅ Transforms (translate, rotate, scale)
✅ Text elements (best effort — some fonts may not match)
✅ Embedded raster images
✅ Groups and nesting
✅ ViewBox and dimensions
```

**What may not survive:**
```
⚠️  Filters (blur, drop shadow) — imported as image fallback
⚠️  Animations — static snapshot only
⚠️  External CSS stylesheets — inlined values only
⚠️  JavaScript embedded in SVG — stripped for security
```

---

### PNG / JPG (Raster Import)

Raster images are not editable at the pixel level in PathForge (that is Photoshop territory). They are embedded as `<image>` elements in the SVG document and can be:

- Moved and resized on the canvas
- Clipped to a path shape (clip mask)
- Used as a reference/tracing layer

**Import pipeline:**
```
.png or .jpg file
  → FileReader API reads as Data URL
  → Uploaded to DO Spaces via backend
  → URL stored in asset record
  → Rendered as Konva Image element
```

**Export consideration:**
When a SVG containing embedded images is exported, images are either:
- Base64 encoded inline (self-contained, larger file)
- Referenced by URL (requires internet to render, smaller file)

User controls this via export options.

---

### PDF (Import)

PDF import uses the backend because PDF rendering requires server-side tools:

```
.pdf file
  → Uploaded to backend /api/v1/assets/upload
  → Celery task: pdf_to_png (using pdf2image library)
  → First page converted to PNG at 150 DPI
  → PNG stored in DO Spaces
  → Returned to frontend as image URL
  → Embedded as reference image on canvas
```

PDF export works in reverse — the SVG is converted to PDF by the backend using a headless browser (Chromium via Playwright) and returned as a download.

---

### Figma Import (Phase 3)

Figma files can only be accessed through Figma's official REST API. This requires:

1. User provides their Figma personal access token in settings
2. User pastes a Figma file URL
3. Backend calls Figma API to fetch the file JSON
4. JSON parsed to extract frames, components, and paths
5. Converted to PathForge internal format

**Limitations:**
- Requires active Figma account and API token
- Complex components may not translate perfectly
- Auto-layout rules are not preserved
- Interactive components are imported as static shapes

---

## Security Considerations for File Import

All uploaded files go through server-side validation before being processed:

```python
# backend/app/services/asset_service.py

ALLOWED_MIME_TYPES = {
    'image/svg+xml',
    'image/png',
    'image/jpeg',
    'image/webp',
    'image/gif',
    'application/pdf',
}

MAX_FILE_SIZE_MB = 25

def validate_upload(file: UploadFile) -> None:
    # 1. Check MIME type against allowlist
    if file.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(400, "File type not supported")

    # 2. Check file size
    if file.size > MAX_FILE_SIZE_MB * 1024 * 1024:
        raise HTTPException(413, "File too large")

    # 3. For SVG: sanitize before storing
    if file.content_type == 'image/svg+xml':
        sanitize_svg(file)     # strips <script>, event handlers, external refs
```

SVG files specifically receive sanitization because SVG can contain JavaScript, external resource references, and event handlers. We strip all of these before the file touches our storage or canvas.

---

## Client-Side File Detection

```typescript
// src/lib/file/fileDetector.ts

export function detectFileType(file: File): FileTypeDefinition | null {
  // 1. Check MIME type first (most reliable)
  const byMime = FILE_REGISTRY.find(ft =>
    ft.mimeTypes.includes(file.type)
  );
  if (byMime) return byMime;

  // 2. Fall back to extension (some browsers report wrong MIME for SVG)
  const ext = '.' + file.name.split('.').pop()?.toLowerCase();
  const byExt = FILE_REGISTRY.find(ft =>
    ft.extensions.includes(ext)
  );
  if (byExt) return byExt;

  // 3. Unknown type
  return null;
}
```

---

## Export Format Matrix

| Export Format | Client-Side | Server-Side | Notes |
|---|---|---|---|
| SVG | ✅ | ❌ | SVGO optimization client-side |
| PNG (1x/2x/3x) | ✅ | ❌ | Konva toDataURL() |
| JPG | ✅ | ❌ | Konva toDataURL() with quality |
| WebP | ✅ | ❌ | Canvas API |
| PDF | ❌ | ✅ | Playwright headless browser |
| GIF (animated) | ❌ | ✅ | FFMPEG via Celery task |
| MP4/WebM | ❌ | ✅ | FFMPEG via Celery task |
| ICO | ❌ | ✅ | Python Pillow library |
| ZIP bundle | ❌ | ✅ | Multiple formats in one download |

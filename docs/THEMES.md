# THEMES — PathForge Design System

> UI themes, visual language, design tokens, and the component styling system.

---

## Design Direction

PathForge is a professional creative tool. The visual design must feel like it belongs in the same category as Figma and Linear — not like a side project. The aesthetic is:

```
Precise       Every element has a reason to exist
Dark-native   Dark mode is the primary experience
High contrast Buttons, icons, and labels are always legible
Restrained    No decorative elements that compete with the user's work
Focused       The canvas is the star — the UI frames it, not fights it
```

The UI intentionally recedes so the user's artwork is the focal point. Panels are dark, compact, and dense. The canvas is slightly lighter. Color accents are used surgically — only for active states and important actions.

---

## Theme System Architecture

Themes are implemented as CSS custom property overrides on the `<html>` element. Switching themes is one class change — no re-render, no flicker, no JavaScript required for the visual update.

```css
/* Default: dark theme is applied by default */
html {
  --bg-app: #07090F;
  /* ...all variables... */
}

/* Light theme override */
html.theme-light {
  --bg-app: #F8F9FA;
  /* ...override variables... */
}

/* Theme switch: just one line of JS */
document.documentElement.className = 'theme-light';
```

---

## CSS Custom Properties (Design Tokens)

These are the complete token set used across all components and themes.

```css
:root {

  /* ── Backgrounds ──────────────────────────────────── */
  --bg-app:        ;  /* Outermost app background */
  --bg-surface:    ;  /* Panel and modal backgrounds */
  --bg-elevated:   ;  /* Dropdown menus, tooltips */
  --bg-canvas:     ;  /* Drawing canvas background */
  --bg-hover:      ;  /* Element hover state */
  --bg-active:     ;  /* Element active/pressed state */
  --bg-selected:   ;  /* Selected item background */
  --bg-input:      ;  /* Input field background */

  /* ── Accent Colors ────────────────────────────────── */
  --accent:        ;  /* Primary brand accent (teal) */
  --accent-dim:    ;  /* 10% opacity accent — subtle backgrounds */
  --accent-glow:   ;  /* 20% opacity accent — hover backgrounds */
  --accent-2:      ;  /* Danger / destructive / delete (red-pink) */
  --accent-2-dim:  ;  /* 10% opacity accent-2 */
  --accent-3:      ;  /* Tertiary accent (purple) — informational */

  /* ── Text ────────────────────────────────────────── */
  --text-primary:  ;  /* Main readable text */
  --text-secondary:;  /* Labels, secondary info */
  --text-muted:    ;  /* Disabled, placeholder */
  --text-on-accent:;  /* Text on accent-colored backgrounds */

  /* ── Borders ─────────────────────────────────────── */
  --border:        ;  /* Default border — subtle */
  --border-strong: ;  /* Emphasized border */
  --border-accent: ;  /* Accent-colored border — focused inputs */

  /* ── Canvas-Specific ─────────────────────────────── */
  --anchor-fill:   ;  /* SVG anchor point fill color */
  --anchor-stroke: ;  /* SVG anchor point stroke */
  --handle-fill:   ;  /* Bézier handle dot fill */
  --selection:     ;  /* Selected element highlight color */
  --guide:         ;  /* Smart guide line color */
  --grid-minor:    ;  /* Minor grid line color */
  --grid-major:    ;  /* Major grid line color (every 5 lines) */

  /* ── Shadows ─────────────────────────────────────── */
  --shadow-sm:     ;  /* Subtle shadow — cards */
  --shadow-md:     ;  /* Medium shadow — panels */
  --shadow-lg:     ;  /* Heavy shadow — modals */
  --shadow-glow:   ;  /* Accent-colored glow — focused elements */

  /* ── Typography ──────────────────────────────────── */
  --font-ui:       ;  /* UI labels and headings */
  --font-mono:     ;  /* Coordinate readouts, code, hex values */

  /* ── Sizing ──────────────────────────────────────── */
  --toolbar-h:     46px;   /* Top toolbar height */
  --panel-w:       216px;  /* Side panel default width */
  --status-h:      26px;   /* Bottom status bar height */
  --r:             5px;    /* Default border radius */
  --r-lg:          10px;   /* Large border radius — modals */
}
```

---

## Theme 1 — Dark (Default)

The primary experience. Deep dark backgrounds with a teal accent system. Designed for long editing sessions with minimal eye strain.

```css
html,
html.theme-dark {
  /* Backgrounds */
  --bg-app:         #07090F;
  --bg-surface:     #0B0F1A;
  --bg-elevated:    #111827;
  --bg-canvas:      #0A0D16;
  --bg-hover:       #111826;
  --bg-active:      #162038;
  --bg-selected:    #162038;
  --bg-input:       #060810;

  /* Accents */
  --accent:         #00F5C4;
  --accent-dim:     rgba(0, 245, 196, 0.10);
  --accent-glow:    rgba(0, 245, 196, 0.18);
  --accent-2:       #FF4D6D;
  --accent-2-dim:   rgba(255, 77, 109, 0.10);
  --accent-3:       #A78BFA;

  /* Text */
  --text-primary:   #DDE3F0;
  --text-secondary: #5A6A88;
  --text-muted:     #2E3A52;
  --text-on-accent: #000000;

  /* Borders */
  --border:         rgba(255, 255, 255, 0.055);
  --border-strong:  rgba(255, 255, 255, 0.12);
  --border-accent:  rgba(0, 245, 196, 0.28);

  /* Canvas */
  --anchor-fill:    #00F5C4;
  --anchor-stroke:  rgba(0, 245, 196, 0.9);
  --handle-fill:    #38BDF8;
  --selection:      #FF4D6D;
  --guide:          rgba(0, 245, 196, 0.5);
  --grid-minor:     rgba(255, 255, 255, 0.032);
  --grid-major:     rgba(255, 255, 255, 0.06);

  /* Shadows */
  --shadow-sm:      0 2px 8px rgba(0, 0, 0, 0.4);
  --shadow-md:      0 4px 20px rgba(0, 0, 0, 0.5);
  --shadow-lg:      0 12px 40px rgba(0, 0, 0, 0.7);
  --shadow-glow:    0 0 20px rgba(0, 245, 196, 0.15);

  /* Typography */
  --font-ui:        'Syne', sans-serif;
  --font-mono:      'Space Mono', monospace;
}
```

---

## Theme 2 — Light

Professional light mode for users who prefer a brighter workspace or work in high-ambient-light environments.

```css
html.theme-light {
  /* Backgrounds */
  --bg-app:         #F0F2F5;
  --bg-surface:     #FFFFFF;
  --bg-elevated:    #FFFFFF;
  --bg-canvas:      #E8EBF0;
  --bg-hover:       #F5F7FA;
  --bg-active:      #EBF0FF;
  --bg-selected:    #E8F0FF;
  --bg-input:       #FAFBFC;

  /* Accents — same hue, adjusted for light bg */
  --accent:         #00A884;
  --accent-dim:     rgba(0, 168, 132, 0.10);
  --accent-glow:    rgba(0, 168, 132, 0.18);
  --accent-2:       #E03050;
  --accent-2-dim:   rgba(224, 48, 80, 0.10);
  --accent-3:       #7C3AED;

  /* Text */
  --text-primary:   #111827;
  --text-secondary: #6B7280;
  --text-muted:     #9CA3AF;
  --text-on-accent: #FFFFFF;

  /* Borders */
  --border:         rgba(0, 0, 0, 0.08);
  --border-strong:  rgba(0, 0, 0, 0.16);
  --border-accent:  rgba(0, 168, 132, 0.4);

  /* Canvas */
  --anchor-fill:    #00A884;
  --anchor-stroke:  rgba(0, 168, 132, 0.9);
  --handle-fill:    #0284C7;
  --selection:      #E03050;
  --guide:          rgba(0, 168, 132, 0.6);
  --grid-minor:     rgba(0, 0, 0, 0.05);
  --grid-major:     rgba(0, 0, 0, 0.10);

  /* Shadows */
  --shadow-sm:      0 1px 4px rgba(0, 0, 0, 0.08);
  --shadow-md:      0 4px 16px rgba(0, 0, 0, 0.10);
  --shadow-lg:      0 8px 32px rgba(0, 0, 0, 0.14);
  --shadow-glow:    0 0 20px rgba(0, 168, 132, 0.12);
}
```

---

## Theme 3 — Midnight

Deeper than dark — near-pure black with a purple accent. High contrast for precision work.

```css
html.theme-midnight {
  --bg-app:         #030408;
  --bg-surface:     #080B12;
  --bg-elevated:    #0D1018;
  --bg-canvas:      #050709;
  --bg-hover:       #0D1120;
  --bg-active:      #12183A;
  --bg-selected:    #12183A;
  --bg-input:       #030408;

  --accent:         #A78BFA;
  --accent-dim:     rgba(167, 139, 250, 0.10);
  --accent-glow:    rgba(167, 139, 250, 0.18);
  --accent-2:       #F43F5E;
  --accent-2-dim:   rgba(244, 63, 94, 0.10);
  --accent-3:       #34D399;

  --text-primary:   #E2E8F0;
  --text-secondary: #475569;
  --text-muted:     #1E293B;
  --text-on-accent: #000000;

  --border:         rgba(255, 255, 255, 0.04);
  --border-strong:  rgba(255, 255, 255, 0.08);
  --border-accent:  rgba(167, 139, 250, 0.3);

  --anchor-fill:    #A78BFA;
  --anchor-stroke:  rgba(167, 139, 250, 0.9);
  --handle-fill:    #60A5FA;
  --selection:      #F43F5E;
  --guide:          rgba(167, 139, 250, 0.5);
  --grid-minor:     rgba(255, 255, 255, 0.025);
  --grid-major:     rgba(255, 255, 255, 0.05);
}
```

---

## Theme 4 — Solarized

Based on Ethan Schoonover's classic Solarized palette. Warm background tones that reduce eye strain.

```css
html.theme-solarized {
  --bg-app:         #002B36;
  --bg-surface:     #073642;
  --bg-elevated:    #0D4555;
  --bg-canvas:      #00212B;
  --bg-hover:       #073642;
  --bg-active:      #0D4555;
  --bg-selected:    #0D4555;
  --bg-input:       #002B36;

  --accent:         #2AA198;  /* Solarized cyan */
  --accent-dim:     rgba(42, 161, 152, 0.12);
  --accent-glow:    rgba(42, 161, 152, 0.20);
  --accent-2:       #DC322F;  /* Solarized red */
  --accent-2-dim:   rgba(220, 50, 47, 0.12);
  --accent-3:       #268BD2;  /* Solarized blue */

  --text-primary:   #839496;
  --text-secondary: #586E75;
  --text-muted:     #073642;
  --text-on-accent: #002B36;

  --border:         rgba(131, 148, 150, 0.08);
  --border-strong:  rgba(131, 148, 150, 0.16);
  --border-accent:  rgba(42, 161, 152, 0.35);

  --anchor-fill:    #2AA198;
  --anchor-stroke:  rgba(42, 161, 152, 0.9);
  --handle-fill:    #268BD2;
  --selection:      #DC322F;
  --guide:          rgba(42, 161, 152, 0.5);
  --grid-minor:     rgba(131, 148, 150, 0.06);
  --grid-major:     rgba(131, 148, 150, 0.12);
}
```

---

## Typography

```css
/* Font stack — loaded via self-hosted files in /public/fonts */
@font-face {
  font-family: 'Syne';
  src: url('/fonts/Syne-Variable.woff2') format('woff2');
  font-weight: 400 800;
  font-display: swap;
}

@font-face {
  font-family: 'Space Mono';
  src: url('/fonts/SpaceMono-Regular.woff2') format('woff2');
  font-weight: 400;
  font-display: swap;
}

@font-face {
  font-family: 'Space Mono';
  src: url('/fonts/SpaceMono-Bold.woff2') format('woff2');
  font-weight: 700;
  font-display: swap;
}
```

### Type Scale

```css
/* Used via Tailwind classes + these CSS variables */
--text-xs:    9px;    /* Status bar, captions */
--text-sm:    10px;   /* Panel labels, secondary info */
--text-base:  11px;   /* Main panel text */
--text-md:    13px;   /* Toolbar labels, modal text */
--text-lg:    15px;   /* Modal titles, headings */
--text-xl:    20px;   /* Page headings */
--text-2xl:   28px;   /* Landing page headings */
```

### Typography Rules

```
Panel labels:     9px, 700 weight, 1.8px letter-spacing, uppercase
Panel values:     11px, 400 weight, var(--text-primary)
Monospace values: 10px, Space Mono (hex codes, coordinates, dimensions)
Toolbar buttons:  No text — icon only with tooltip on hover
Modal titles:     15px, 700 weight
Status bar:       9px, Space Mono
```

---

## Skeleton Loading System

Skeleton screens are the standard for loading states throughout the app. No spinners. No blank screens.

### The Skeleton Component

```tsx
// src/components/ui/Skeleton.tsx

interface SkeletonProps {
  className?: string;
  variant?: 'rect' | 'circle' | 'text';
}

export const Skeleton = ({ className, variant = 'rect' }: SkeletonProps) => (
  <div
    className={`skeleton ${variant} ${className}`}
    aria-hidden="true"
  />
);
```

```css
/* Animated shimmer effect */
.skeleton {
  background: linear-gradient(
    90deg,
    var(--bg-surface) 25%,
    var(--bg-hover) 50%,
    var(--bg-surface) 75%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: var(--r);
}

@keyframes shimmer {
  0%   { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

.skeleton.circle { border-radius: 50%; }
.skeleton.text   { border-radius: 3px; height: 1em; }
```

### Skeleton Implementations

Every loading state in the app uses this pattern:

```tsx
// Dashboard — project grid
{isLoading
  ? Array.from({ length: 6 }).map((_, i) => <ProjectCardSkeleton key={i} />)
  : projects.map(p => <ProjectCard key={p.id} project={p} />)
}

// Layers panel — layer list
{isLoading
  ? Array.from({ length: 4 }).map((_, i) => <LayerItemSkeleton key={i} />)
  : layers.map(l => <LayerItem key={l.id} layer={l} />)
}

// Editor canvas — while SVG project loads
{isProjectLoading
  ? <CanvasSkeleton />
  : <KonvaCanvas />
}
```

---

## Layout Measurements

```
Toolbar height:           46px
Left panel width:         216px (collapsible to 0)
Right panel width:        216px (collapsible to 0)
Status bar height:        26px
Panel section padding:    11px 12px
Panel header height:      34px
Toolbar button size:      32 × 32px
Layer item height:        32px
Style section gap:        6–9px between controls
Color swatch size:        26 × 26px
Handle dot radius:        3.5px (scaled by zoom)
Anchor dot size:          5.5 × 5.5px (scaled by zoom)
Selected anchor size:     6.5 × 6.5px (scaled by zoom)
```

---

## Icon System

All icons are inline SVGs — no icon font, no external sprite. This keeps the icon set:
- Instantly available (no network request)
- Perfectly sharp at any display density
- Easy to animate and style with CSS

Icons follow a consistent visual language:
```
Stroke weight:  2px (regular), 2.2px (emphasized)
Size:           13 × 13px in toolbar, 12 × 12px in panels
Color:          currentColor (inherits from button/element)
Cap:            Round
Join:           Round
```

---

## Responsive Behavior

PathForge is primarily a desktop tool. Mobile is not the target use case. However, the layout gracefully handles different desktop viewport sizes:

```
≥ 1440px   Full layout — both panels open, generous canvas space
1200–1440px  Panels slightly narrower (200px), canvas fills rest
1024–1200px  Panels collapse to icon-only strip (48px), expand on hover
< 1024px   Single panel at a time, canvas fills most of screen
< 768px    Editor not supported — friendly message with desktop redirect
```

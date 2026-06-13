# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **3D Gaussian Splatting viewer and editor** — a pure static web project with no build step, no npm, and no bundler. All logic lives as inline `<script type="module">` inside HTML files. The only runtime dependency is PlayCanvas 2, loaded from jsDelivr CDN.

## Running Locally

No build step exists. Serve files directly from the project root:

```powershell
# PowerShell (built-in server on port 8173)
.\serve.ps1

# Or any static server
python3 -m http.server 8173
npx serve .
```

Then open `http://localhost:8173/3D-Interactive.html` (studio) or `http://localhost:8173/index.html` (viewer).

There are no tests, no linter, no CI/CD pipeline.

## File Roles & Architecture

The project has three distinct runtime modes that share the same PlayCanvas-based rendering logic:

| File | Mode | Purpose |
|------|------|---------|
| `3D-Interactive.html` | **Studio** | Drag-drop editor: load splat files, configure limits, export locked HTML |
| `index.html` | **Viewer** | Embeddable viewer; config via URL params |
| `locked-template.html` | **Locked** | Template used by studio at export time; placeholders replaced with actual data |
| `embed.js` | **Embed** | Script tag that injects an iframe pointing at `index.html` |

### Data Flow

```
Content creator:
  splat file (.ply / .sog / SuperSplat .html)
    → 3D-Interactive.html (studio)
      → adjusts radius, center, FOV, elevation limits
      → "Export locked HTML" button
        → reads locked-template.html
        → replaces __CFG__, __DATA__, __NAME__ placeholders
        → downloads *-locked.html (self-contained, base64-embedded splat)

End user:
  receives *-locked.html
    → uploads to web host
    → embeds via <iframe> or embed.js
```

### Camera Constraint System

The core feature is restricting viewer movement to a sphere without modifying splat geometry:

- `radiusM` = sphere radius in real-world meters
- `mpu` = meters per unit (scene-specific scale, Choisy = 10)
- Unit-space sphere radius = `radiusM / mpu`
- Pan target clamped to `TARGET_R = R * 0.5`
- Camera position ray-cast against sphere boundary at each frame
- Elevation clamped by `elev` parameter (pitch min/max in degrees)

### locked-template.html Placeholders

When the studio exports a locked file, it performs string replacement on the template:

```javascript
const CFG = __CFG__;      // → JSON config object (no URL params parsed)
const DATA = '__DATA__';  // → data: URL with base64-encoded splat file
const NAME = '__NAME__';  // → original filename string
```

The resulting file is fully self-contained (~1.33× the raw splat size due to base64).

## Supported File Formats

| Format | Parsing method | Crop support |
|--------|---------------|--------------|
| `.ply` | Binary typed array header parse | Full (filters individual splats) |
| `.sog` | `pc.GSplatHandler` decompression, `res._centers` for positions | Count-only (exports full data) |
| SuperSplat `.html` | Extracts base64 data block from HTML source | Same as underlying format |

SOG files expose `res._centers` (not `splatData.getProp()`) — this was the root cause of the `sd.getProp` bug fixed in the latest commit.

## URL Parameters (index.html)

| Param | Default | Description |
|-------|---------|-------------|
| `src` | `./index.sog` | Splat file URL |
| `radius` | `150` | Movement sphere radius in meters |
| `mpu` | `10` | Meters per unit (scale calibration) |
| `center` | `[-0.951,-0.229,2.605]` | Sphere center in scene units |
| `pos` | `[3.586,2.324,7.048]` | Initial camera position |
| `fov` | `65` | Field of view in degrees |
| `bg` | `000000` | Background hex color |
| `autorotate` | `false` | Spin camera when idle |
| `elev` | `[-10,85]` | Pitch limits in degrees |
| `ui` | `true` | Show hint UI and fullscreen button |

Locked files ignore all URL params — config is hardcoded in the exported `CFG` constant.

## PlayCanvas Usage

All files import PlayCanvas as an ES module:

```javascript
import * as pc from 'https://cdn.jsdelivr.net/npm/playcanvas@2/build/playcanvas.mjs';
```

Components used: `RenderComponentSystem`, `CameraComponentSystem`, `LightComponentSystem`, `GSplatComponentSystem`, `GSplatHandler`. The splat data is never modified in memory — only camera movement is constrained.

## Key Conventions

- **No external files modified at runtime**: splat geometry/colors/opacity are always passed through unchanged.
- **Vietnamese in README**: The README is intentionally in Vietnamese (target audience). Code and UI strings are English.
- **Inline everything**: Avoid introducing external `.js` or `.css` files — keep logic in the HTML `<script type="module">` blocks to maintain zero-dependency deployability.
- **No node_modules, no build**: Any change that requires a build step breaks the deployment model (drag-and-drop HTML to any web host).
- **Toast notifications** in the studio use a `showToast(msg)` helper defined in `3D-Interactive.html`; use it for all user-facing feedback.

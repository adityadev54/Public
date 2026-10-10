# ShaderX implementation decisions

The product study is implemented as a working Flutter foundation with separate catalog, composition, library, rendering, and shared interface layers. The first iteration uses a small experimental collection and proposed tools to make the architecture testable without treating the earlier rejected draft as product requirements.

## Proposed defaults

| Decision | Working implementation | Status |
| --- | --- | --- |
| Four master tools | Stack, Fuse, Shape, Flow | Proposed names and responsibilities; replaceable through the tool contract |
| Initial themes | Optics, Materials, Topography | Experimental collection, not the final taxonomy |
| Components | Interference film, Folded membrane, Contour field | Independent rendering/parameter examples |
| Interface accent | Spectral yellow on neutral surfaces | Provisional brand direction; does not tint shader output |
| Primary validation target | macOS and Flutter widget rendering | Other platforms retained but not device verified |
| Outputs | Editable locally saved recipes | Export destination remains open |

## Tool contracts

**Stack** accepts catalog components and operates on the ordered component-instance list. It adds, selects, reorders, hides, or removes ingredients. Component-specific controls are shown here because they describe the ingredient rather than a universal operation.

**Fuse** accepts a selected layer and the canvas beneath it. It applies normal, screen, multiply, or difference compositing and per-layer opacity. Rendering uses isolated canvas layers with premultiplied shader output. It is not a two-shader color crossfade.

**Shape** accepts a selected layer’s domain transform. It changes scale, rotation, and distortion before that component computes its appearance. These values are saved per instance, so two instances of the same component can be different.

**Flow** accepts composition timing and a selected layer’s phase. It changes playback speed, cycle length, and temporal offsets. Components use a normalized periodic time domain so cycle length changes do not introduce a reset discontinuity. Playback can be paused independently of the saved recipe.

All four tool states are reproducible from the versioned recipe. Undo/redo restores recipe snapshots; successive slider events are grouped into a single history entry for each drag. Recipe identity remains stable across saves.

## Session and storage

`StudioSession` coordinates the composition controller and repository. It debounces draft saves and serializes writes. Named library snapshots and working drafts have separate storage keys. Storage failures are surfaced without deleting unreadable data. New compositions replace the current draft only after a dialog when that draft contains layers.

Component IDs and layer-instance IDs are persisted, not catalog positions. Schema parsing validates numeric ranges and component parameter contracts. Unsupported versions and unknown components produce a visible storage error rather than automatic fallback to a different effect.

The old draft’s `compositions` key remains untouched. Migrating its numeric shader indices would falsely preserve rejected catalog assumptions.

## Rendering lifecycle

`ComponentRegistry` maps stable component IDs to assets and uniform schemas. `ShaderRuntime` caches compiled programs. Each viewport owns and disposes its fragment shader instances. Frame changes repaint the canvas without rebuilding the application or catalog. Static thumbnails do not allocate tickers that run continuously.

Workspace animation pauses when obscured, the drawer is open, the app is backgrounded, the user pauses, or reduced motion is active. Detail previews obey the same animation preference. A six-layer initial budget is enforced by the controller. Each shader is a separate component asset rather than a numeric branch in a universal shader.

## Extending a component

1. Add its theme/component metadata and parameter definitions to `ComponentCatalog`.
2. Implement its fragment shader under `shaders/components` and declare that asset in `pubspec.yaml`.
3. Register its asset and uniform parameter order in `ComponentRegistry`.
4. Exercise rendering and recipe round trips in tests.

Home, library storage, and workspace screen code do not need a new subject-specific branch. The current renderer shares spatial/time/opacity uniforms and supports two component parameters in the experimental shaders. Components needing a different uniform layout should extend the renderer binding contract explicitly; the domain parameter map is not limited to two parameters.

## Interface foundation

The shell implements Gita’s drawer reveal, adaptive slide/scale, scroll-driven header handoff, reduced-motion behavior, hidden-control semantics, and content width constraints. A contextual resume surface appears when a draft exists outside the workspace. Kin supplies text, press/button behavior, card surfaces, fields, sliders, toggles, and dialog surfaces while Flutter owns navigation, focus, native controls, and scroll hosts.

Dark, light, and system appearance preferences are persisted. Core controls use semantic theme colors and the interface accent is independent of component artwork. The workspace uses two columns only when there is enough width; on phones the canvas and tool panel stack.

## Verification scope

Tests cover full discovery-to-save-to-reopen flow; narrow phone and desktop layouts; recipe round trips; undo gesture grouping; invalid schema/value rejection; layer limits; separate draft/library saves; unreadable storage preservation; independent shader loading and pixel changes after blend/shape edits. The QA layout test writes rendered desktop and phone images for inspection.

A native macOS debug build is checked separately. Mobile device behavior, export formats, production bundle identifiers, final brand selection, and final component/tool taxonomy remain release work.

## Studio and navigation refinement

Navigation is a standalone circular menu/back control with the current screen title beside it. The soft status fade protects text over the shader canvas. Root vertical scrolling grows the circle from 48 to 56 dp, the icon from 22 to 26 dp, and the title from 18 to 21 sp; nested scrolling and bounce do not affect this transition. Content has no duplicate oversized header beneath the overlay.

Home, component detail, and the composition workspace use live, full-bleed canvases. Home supports direct preview controls before opening a composition. Component detail exposes real parameter sliders and preserves their values when the component is added. The workspace presents transport and Heroicons tool controls alongside or below the canvas, without a decorative card around the shader or tool panel.

Interface copy uses sentence case, concise labels, and proper names. Uppercase eyebrows, slogans, repeated headings, and implementation descriptions have been removed from normal screens. These requirements are recorded in the project’s AGENTS.md.


## Dashboard and galleries

Home uses a fixed two-column, two-row action grid, followed by every locally saved composition in a responsive portrait gallery. Saved tiles reopen their editable recipes; long press removes a saved copy with confirmation. Studio remains a separate route. Themes uses the same rounded portrait grid with alternating proportions and names over artwork, plus theme filters. Library is no longer a navigation destination; the storage repository remains intact.


## Simplified Home

The current header omits visible titles and places Settings in a second circle on the right. Both circles grow from 48 to 50 pixels when root content scrolls, with icons growing from 22 to 23. The status fade and safe areas remain. Home starts with a flat, illustrated New composition card, retaining the 26-pixel radius and 166-pixel base height. The four newest saved compositions updated within seven days occupy at most a 2×2 grid. Overflow and older work move to grouped lists under it: This week, This month, then named months and years. Tiles and list rows both reopen editable work and retain long-press removal. Local storage is unchanged.


## Home surface correction

Settings is removed from navigation. The menu position, soft status fade, and subtle scroll growth are retained. The new-composition card now uses an explicit warm peach surface and outline in a KinPress wrapper so its boundary remains visible across platforms. Saved compositions on Home separate names from artwork in a surface caption, while Themes keeps names over artwork. Recent tiles and grouped older rows expose a Remove menu with confirmation, alongside the existing long-press interaction. The dashboard rendering check now uses the iOS target platform as well as narrow and desktop dimensions.


## Settings placement and lighter card

Settings remains available through the circular top-right control on screens, and is absent from the sidebar. The new-composition surface is near-white ivory (#FFFAF4), with a faint neutral outline (#EEE8DF) and dark readable text, replacing the stronger peach fill.


## Grouped Home and simplified Themes

All saved Home compositions are now date-grouped list tiles, with no four-item cap or recent grid. Groups preserve newest-first order and the existing thumbnail, reopening, and removal interactions. Themes displays the entire composition gallery without filters. The new-composition card uses a 55% ivory surface in light mode (70% in dark mode for text contrast); label and illustration remain fully opaque.


## Centered home mark

Home follows Gita’s measured upper spacing: top safe inset plus 84 pixels, a 32-pixel centered vector ShaderX mark at subdued opacity, then 55 pixels before the new-composition card. Recent grouped compositions have no This week heading. Older month headings remain.


## Expanded theme collection

Four additional theme families ship with separate live shader ingredients: Acoustics / Resonant sand (frequency, grain size), Botany / Leaf veins (branch spacing, translucency), Minerals / Crystal facets (facet size, brilliance), and Atmosphere / Vapor layers (vapor density, drift). All preserve the common Shape/Flow uniforms, layer blending, editable parameters, persistence, and 16-second animation phase. Renderer tests verify their loading, pixel diversity, control changes, and time changes. The collection now contains seven ingredients.

Home is displayed as Atelier with a sparkles icon. Studio uses a transparent cube icon. The push drawer has a charcoal theme with light text, isolated from the content theme; Settings remains in the top-right header only.


## Composition creation and navigation refinement

New composition collects a title and optional description before theme selection. Descriptions are backward-compatible optional schema-1 fields and survive edits, saves, and drafts; legacy recipes default to an empty description. Home displays descriptions when present. Saved rows reveal a Delete action on a left swipe, with confirmation and no visible options menu. The centered mark is a layered prism. The drawer uses a softer gray (#252729), requests light status-bar icons while open, and labels Home Compositions with a collection icon.


## Native composition setup sheet

New composition opens AppSheetRoute (CupertinoSheetRoute), using the route-provided scroll controller and Gita-style delegated transition corners. Setup collects name, description, six icon choices, six muted color choices, and 24/30/60 fps. Appearance and frame rate persist as optional schema-1 fields with safe defaults for older recipes. Home thumbnails display the chosen identity badge. Live shader publication follows the chosen frame-rate cap while shader time advances continuously. Cancellation preserves the current draft. Header circles remain 48 pixels with 22-pixel icons regardless of body scrolling.

### Composition setup refinement
The native iOS sheet now follows the app’s Kin UI surfaces, with grouped borderless fields, soft circular identity choices, a quiet frame-rate selector, and circular close/check actions.

### Creative composition setup
Setup now places name and description directly into an illustrated composition identity card. Icon, palette, and playback controls sit in the sheet without separate form cards.

### Dedicated studio
Theme detail now provides information and an Open studio action, with no parameter controls. Studio keeps its canvas full-screen and uses a bottom Kin dock with separate Stack/Fuse/Shape/Flow panels above it.

### Interactive studio
StudioControlCard combines a KinBottomBar and custom three-detent glass card. Vortex field is a new bundled GLSL shader with touch-driven center and pinch zoom; other ingredients respond to rotation and distortion while playing. Interaction is transient play state. Runtime GLSL source compilation is not provided.

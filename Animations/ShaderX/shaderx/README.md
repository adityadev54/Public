# ShaderX

A Flutter workspace for composing theme-derived visual components. The project
separates discovery, editable recipes, persistence, rendering, and interface
foundations. Kin UI and Heroicons follow Gita’s component adaptation approach.

## Run

```sh
flutter pub get
flutter run -d macos
```

## Create

Explore a theme, inspect a component, and add it to a composition. The proposed
four master tools are **Stack** (ingredients and order), **Fuse** (layer blend
modes and opacity), **Shape** (scale, rotation and domain distortion), and
**Flow** (speed, cycle length and layer phase). These are working defaults pending
product refinement, rather than inherited requirements from the earlier draft.

The experimental collection contains interference film, folded membrane, and
contour field. Each has its own parameter schema and independently registered
fragment shader. The collection proves the component architecture; it is not a
final catalog. The galaxy example is not used as an implementation requirement.

Save a named recipe from the workspace. Library recipes stay editable. A separate
working draft is saved after edits and on application backgrounding. Opening a
saved recipe does not replace its saved copy until you save again. A save updates
the recipe with the same stable ID. Six layers are supported as an initial runtime
budget. Undo/redo includes layer operations and groups a slider drag as one edit.

## Project structure

- `lib/app`: startup composition, navigation shell, and session coordination.
- `lib/core`: semantic themes, responsive layouts, Kin adapters, and shared routes.
- `lib/features/catalog`: theme/component definitions and discovery.
- `lib/features/composition`: recipes, edit history, controller, and tool workspace.
- `lib/features/library`: repository contract, local storage, and saved work.
- `lib/features/home` and `lib/features/settings`: entry point and preferences.
- `lib/rendering`: registry, shader loading, resource lifecycle, and layer rendering.
- `shaders/components`: separate shader programs per visual component.

Read `docs/implementation.md` for the current decisions and extension workflow.
The product study remains in `docs/product_brief.md`, `gita_reference.md`, and
`architecture.md`.

## Verify

```sh
flutter analyze
flutter test
flutter build macos --debug
```

Tests exercise recipe serialization, editing and undo, storage preservation,
discovery-to-library flow, responsive layouts, and actual shader pixel changes.
Rendered QA images are generated under `build/qa`.

## Current boundaries

Local recipes and preferences use shared_preferences. Schema validation surfaces
unreadable saved data without clearing it. The rejected draft’s storage key is
left untouched; its incompatible recipe format is not silently migrated.

The interface has dark/light/system appearance with a provisional spectral yellow
accent, independent of shader output colors. Catalog thumbnails are still;
workspace/detail animation respects reduced motion, route visibility, and app
lifecycle. macOS is the native build target verified for this iteration. Other
platform folders are retained but require their own testing.

Image/video capture, developer code export, cloud sync, accounts, and publishing
remain outside this iteration until the intended output is established. This is
a working product foundation, not a completed export product.

The vendored Kin UI license and compatibility notes are retained. Platform bundle
identifiers are still the Flutter starter values and must be set before release.

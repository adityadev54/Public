# ShaderX interface rules

- Use sentence case for interface copy. Do not use all-caps labels, uppercase transformations, spaced uppercase branding, or uppercase eyebrows. Preserve proper names such as ShaderX and user-authored composition names.
- Keep copy functional and concise. Omit slogans, instructional filler, implementation descriptions, and repeated headings from normal screens.
- Navigation uses independent circular menu/back and right-side settings controls. Omit visible screen titles from the header. Settings belongs in the top-right header only; do not show it in the sidebar. Never use a full-width pill or bar.
- Use a soft, non-interactive fade below the status bar to keep navigation legible over content.
- Navigation circles and icons keep a fixed size while content scrolls. Respect reduced motion, text scaling, and system safe areas.
- Studio screens lead with a live shader canvas and working controls. Do not wrap the creative canvas in decorative content cards.
- Use Heroicons outline glyphs for interface actions. Retain Kin UI adapters and native interaction semantics.

- Home starts with one flat illustrated New composition card (26-pixel radius, 166-pixel base height). Show all saved compositions as date-grouped list tiles, newest first. Do not use a composition card grid on Home. Editing belongs in the separate Studio screen.
- Saved compositions are accessed on Home. Do not reintroduce a Library navigation destination.
- Themes uses a portrait image grid with only composition names on tiles and no filter chips. Follow Gita’s consistent gutters, rounded surfaces, and calm hierarchy while giving ShaderX its own gallery rhythm.

- Give the New composition card an explicit translucent ivory fill and subtle outline on every platform. Saved Home list tiles have thumbnails, readable names, and a hidden Delete action revealed by a left swipe.

- Home centers a subdued 32-pixel ShaderX mark, 84 pixels below the top safe inset and 55 pixels above the first card, following Gita’s spacing. Omit the This week heading.

- The Home destination is named Compositions and uses the Heroicons rectangleStack icon; Studio uses cubeTransparent. The drawer always uses a gray dark theme with light text, regardless of the content theme.

- New compositions open a Cupertino sheet route to collect name, description, icon, color, and frame rate before choosing an ingredient. Persist both in saved recipes and drafts. Keep the drawer’s status bar legible with light system icons.

- Composition setup uses an illustrated identity card with direct name and description editing, borderless Kin fields, and circular Heroicons close/check actions. Avoid text Cancel/Create actions and Material segmented or outlined selection controls.

- Theme detail is a live preview with a concise information card and Open studio action. Editing stays in Studio: full-screen canvas, a fixed bottom Kin dock, and scrollable controls above the dock opened by tool icons.

- Studio uses circular Heroicons back and ellipsisVertical actions instead of menu/settings. Use KinMaterial glass for the compact dock and control panel; preserve accessible press targets.

- Studio uses StudioControlCard, a custom glass card with collapsed/compact/expanded detents and KinBottomBar, never KinSheet. Drag the handle or use expand/close actions. Canvas interaction stays enabled during playback.

- Studio embeds KinBottomBar transparently inside its single glass card; no second tab-bar surface or border. Keep layer rows compact with contextual options, and size controls to their content within detent limits.

- Studio uses an independent compact tool rail with an underline selection and a separate floating inspector. Transport is a small upper-right glass toolbar. Do not nest KinBottomBar or a tab pill inside the inspector.

- Studio has no top status fade. Double-tap the live canvas to hide/restore all app controls; single taps never toggle visibility. Keep transport inside the inspector or collapsed tool card, with inspector state preserved in focus mode.

- Studio uses focused control pages in one dock with its opening animation; do not use a vertically scrolling upper inspector. Stack separates Layers from Surface, and each parameter page presents one control.

- Studio uses custom KinSlider appearance, a 32-pixel dock radius and bottom safe-area alignment without extra bottom padding. Studio options is an anchored KinPopupMenu, not a dialog.

- Both Studio more actions use anchored KinPopupMenu. Shared top navigation circles use KinMaterial glass with transparent interaction surfaces.

- Navigation circles and Studio glass dock are borderless. Use an explicit empty Border to suppress Kin glass edge outlines.

- Visible themes are particle-built examples grouped into Formation, Collage, Drawing, and Motion. Keep legacy shader IDs loadable for existing recipes. Change control meaning without changing the studio layout.

- Preserve all earlier themes in the visible catalog. Particle work should emphasize retained state, momentum, meaningful shapes, and recovery rather than multiplying procedural dot masks. Kinetic sculpture is the first retained-particle prototype; do not describe it as GPU compute.

- Original shaders are hidden from Themes at the user’s request, while retained for saved recipe compatibility. New sculptural themes use retained particle dynamics and distinct target geometry.

- Core emitter examples include liquid streams and reflective chrome beads, with distinct geometry, shading and material controls. Preserve the existing Kin studio layout. These procedural material studies are not a fluid solver or environment ray tracer.

- Canvas drag applies material forces, never implicit rotation or distortion controls. Emitters use aspect-correct local touch coordinates and ease out after release.

- Vortex descent is a full-canvas layered flow. Its canonical shader lives in packages/shaderx_vortex, a Flutter-only reusable background package; keep studio UI dependencies out of that package.

- Ember flock and Orbital dust use retained full-canvas particle fields. Copper storm and Prism rain add distinct advected grains and falling shards. Sculptures use distinct finishes, breathing relief and velocity trails; preserve aspect-correct touch forces.

- Particle fields must avoid galaxy-like orbital/spiral defaults. Woven field preserves the orbital_dust.v1 recipe ID but uses interlaced strands. Formation themes transform retained particles into recognizable objects using assembly/morph controls; Vortex descent remains its own distinct effect.

# Particle theme direction

Build tangible visual examples rather than a list of generic effects. Six initial directions:
- Particle sphere: grains gather into a shaded object.
- Paper fragments: rectangular cuts reconstruct a procedural silhouette.
- Graphite bloom: tiny pencil strokes build a botanical contour.
- Ember flock: elongated grains gather along flowing currents.
- Petal assembly: particles describe nested radial petals.
- Orbital dust: grains trace concentric object-like orbits.

These are procedural GLSL fields, not a simulated particle physics engine. Paper fragments demonstrates cut-image composition without importing a photograph. Image import, silhouette extraction, and runtime GLSL authoring remain separate future work.

Each ingredient exposes its own particle controls in the existing focused studio pages. Touch displaces grains and pinch changes scale. Older recipes keep their original shaders and metadata; the visible theme catalog moves to particles.

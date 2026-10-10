# Particle research and revised direction

Sources studied:
- https://tympanus.net/codrops/2024/12/19/crafting-a-dreamy-particle-effect-with-three-js-and-gpgpu/
- https://threejs.org/examples/webgpu_tsl_compute_attractors_particles.html
- https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/webgpu_tsl_compute_attractors_particles.html
- https://docs.flutter.dev/ui/design/graphics/fragment-shaders

The initial examples were procedural pixel fields. The references retain position/velocity state, sample object surfaces, apply forces, and use depth/lighting. A stronger visual must demonstrate behavior as well as a silhouette.

First implementation: Kinetic sculpture has up to 2400 retained particles, a sphere-to-torus target shape, spring forces, damping, touch disturbance, release recovery, perspective depth, and batched luminous point rendering. Simulation currently runs on CPU and rasterization uses Canvas; it is not a compute-shader/GPGPU implementation. Real-device profiling remains necessary before claiming a larger particle budget.

All eight earlier shaders are restored to the visible catalog. Five other new particle studies remain procedural drafts. Next candidates are image-derived colored particle targets, textured paper fragments, and a graphite stroke renderer; these are not yet implemented. No claim of superiority to reference systems is supported by the current prototype.

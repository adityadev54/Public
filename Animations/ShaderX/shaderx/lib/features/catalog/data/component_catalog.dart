import '../domain/shader_theme.dart';
import '../domain/shader_component.dart';
import '../domain/component_parameters.dart';

/// A small experimental catalog, independent of UI and shader uniform offsets.
class ComponentCatalog {
  static const legacyThemes = [
    ShaderTheme(
      id: 'optics',
      name: 'Optics',
      description: 'Light shaped by surfaces, thickness and interference.',
    ),
    ShaderTheme(
      id: 'materials',
      name: 'Materials',
      description: 'Soft structures with tension, folds and depth.',
    ),
    ShaderTheme(
      id: 'topography',
      name: 'Topography',
      description: 'Fields, elevation and the paths between them.',
    ),
    ShaderTheme(
      id: 'acoustics',
      name: 'Acoustics',
      description: 'Patterns formed by vibration.',
    ),
    ShaderTheme(
      id: 'botany',
      name: 'Botany',
      description: 'Growth, branching and living structures.',
    ),
    ShaderTheme(
      id: 'minerals',
      name: 'Minerals',
      description: 'Crystals, facets and mineral light.',
    ),
    ShaderTheme(
      id: 'atmosphere',
      name: 'Atmosphere',
      description: 'Suspended matter and layers of air.',
    ),
  ];
  static const legacyComponents = [
    ShaderComponent(
      id: 'film.v1',
      themeId: 'optics',
      name: 'Interference film',
      description:
          'A thin surface whose changing thickness separates light into spectral bands.',
      behavior: 'Thickness changes the bands; tension stretches the surface.',
      parameters: [
        ComponentParameter('thickness', 'Film thickness', initial: .46),
        ComponentParameter('tension', 'Surface tension', initial: .62),
      ],
    ),
    ShaderComponent(
      id: 'membrane.v1',
      themeId: 'materials',
      name: 'Folded membrane',
      description:
          'A suspended sheet with soft ridges that gather and release light.',
      behavior:
          'Fold depth changes the relief; spacing changes its repetition.',
      parameters: [
        ComponentParameter('depth', 'Fold depth', initial: .58),
        ComponentParameter('spacing', 'Fold spacing', initial: .45),
      ],
    ),
    ShaderComponent(
      id: 'contours.v1',
      themeId: 'topography',
      name: 'Contour field',
      description:
          'Elevation lines moving across a continuous, shifting landscape.',
      behavior:
          'Elevation changes the terrain; line density changes its contours.',
      parameters: [
        ComponentParameter('elevation', 'Elevation', initial: .5),
        ComponentParameter('density', 'Line density', initial: .55),
      ],
    ),
    ShaderComponent(
      id: 'resonance.v1',
      themeId: 'acoustics',
      name: 'Resonant sand',
      description:
          'A vibrating surface gathers fine grains along its still lines.',
      behavior:
          'Frequency reshapes the nodal pattern; grain size softens its edges.',
      parameters: [
        ComponentParameter('frequency', 'Frequency', initial: 0.45),
        ComponentParameter('grain', 'Grain size', initial: 0.55),
      ],
    ),
    ShaderComponent(
      id: 'veins.v1',
      themeId: 'botany',
      name: 'Leaf veins',
      description:
          'Branching veins carry light through a translucent leaf surface.',
      behavior:
          'Branch spacing changes the rhythm; translucency reveals the veins.',
      parameters: [
        ComponentParameter('branching', 'Branch spacing', initial: 0.5),
        ComponentParameter('translucency', 'Translucency', initial: 0.6),
      ],
    ),
    ShaderComponent(
      id: 'crystal.v1',
      themeId: 'minerals',
      name: 'Crystal facets',
      description: 'Uneven crystal faces catch and scatter a moving light.',
      behavior:
          'Facet size changes the crystal structure; brilliance changes the reflections.',
      parameters: [
        ComponentParameter('facets', 'Facet size', initial: 0.45),
        ComponentParameter('brilliance', 'Brilliance', initial: 0.65),
      ],
    ),
    ShaderComponent(
      id: 'vapor.v1',
      themeId: 'atmosphere',
      name: 'Vapor layers',
      description:
          'Soft atmospheric layers drift through warm scattered light.',
      behavior:
          'Density gathers the vapor; drift changes the movement of its layers.',
      parameters: [
        ComponentParameter('density', 'Vapor density', initial: 0.55),
        ComponentParameter('drift', 'Drift', initial: 0.45),
      ],
    ),
    ShaderComponent(
      id: 'vortex.v1',
      themeId: 'atmosphere',
      name: 'Vortex field',
      description:
          'A rotating field of luminous currents that bends around your touch.',
      behavior: 'Drag to move its center. Pinch to change its scale.',
      parameters: [
        ComponentParameter('curl', 'Curl strength', initial: .55),
        ComponentParameter('arms', 'Current density', initial: .45),
      ],
    ),
  ];
  static const themes = [
    ShaderTheme(
      id: 'emitters',
      name: 'Emitters',
      description: 'Material sources with their own surface and motion.',
    ),
    ShaderTheme(
      id: 'formation',
      name: 'Formation',
      description: 'Particles assembling into tangible objects.',
    ),
    ShaderTheme(
      id: 'collage',
      name: 'Collage',
      description: 'Fragments and cut-paper silhouettes.',
    ),
    ShaderTheme(
      id: 'drawing',
      name: 'Drawing',
      description: 'Particle strokes with a hand-drawn character.',
    ),
    ShaderTheme(
      id: 'motion',
      name: 'Motion',
      description: 'Fields, falling shards and moving particle structures.',
    ),
  ];
  static const particleComponents = [
    ShaderComponent(
      id: 'particle_sphere.v1',
      themeId: 'formation',
      name: 'Kinetic sculpture',
      description:
          'A rotating sculpture with depth, inertia and a touch-responsive particle surface.',
      behavior:
          'Morph a sphere into a torus. Drag to disturb it; release to watch it recover.',
      parameters: [
        ComponentParameter('density', 'Particle count', initial: 0.65),
        ComponentParameter('gather', 'Sphere to torus', initial: 0.65),
      ],
    ),
    ShaderComponent(
      id: 'paper_fragments.v1',
      themeId: 'collage',
      name: 'Paper fragments',
      description:
          'Cut-paper pieces reconstruct an abstract portrait-like silhouette.',
      behavior: 'Fragment size and cut depth reshape the collage.',
      parameters: [
        ComponentParameter('density', 'Fragment count', initial: 0.45),
        ComponentParameter('cut', 'Cut depth', initial: 0.6),
      ],
    ),
    ShaderComponent(
      id: 'graphite_bloom.v1',
      themeId: 'drawing',
      name: 'Graphite bloom',
      description:
          'Fine pencil strokes gather into a living botanical drawing.',
      behavior: 'Stroke count builds the drawing; pencil pressure darkens it.',
      parameters: [
        ComponentParameter('density', 'Stroke count', initial: 0.65),
        ComponentParameter('pressure', 'Pencil pressure', initial: 0.6),
      ],
    ),
    ShaderComponent(
      id: 'ember_flock.v1',
      themeId: 'motion',
      name: 'Ember flock',
      description:
          'Copper grains retain their motion through a full-canvas current field.',
      behavior:
          'Drag to stir the grains. Population fills the field; cohesion tightens its currents.',
      parameters: [
        ComponentParameter('density', 'Population', initial: 0.6),
        ComponentParameter('cohesion', 'Cohesion', initial: 0.6),
      ],
    ),
    ShaderComponent(
      id: 'petal_assembly.v1',
      themeId: 'formation',
      name: 'Petal assembly',
      description: 'Rose and copper particles assemble into layered petals.',
      behavior: 'Petal count shapes the bloom; openness unfolds its particles.',
      parameters: [
        ComponentParameter('density', 'Particle count', initial: 0.65),
        ComponentParameter('open', 'Bloom openness', initial: 0.6),
      ],
    ),
    ShaderComponent(
      id: 'orbital_dust.v1',
      themeId: 'motion',
      name: 'Woven field',
      description:
          'Interlaced strands of particles travel through a full-canvas woven structure.',
      behavior:
          'Drag to separate the strands. Particle count fills the weave; tension straightens it.',
      parameters: [
        ComponentParameter('density', 'Particle count', initial: 0.6),
        ComponentParameter('pull', 'Weave tension', initial: 0.65),
      ],
    ),
    ShaderComponent(
      id: 'sculpture_knot.v1',
      themeId: 'formation',
      name: 'Braided knot',
      description: 'A luminous trefoil built from strands of particles.',
      behavior:
          'Change the braid thickness, disturb its strands, and watch them recover.',
      parameters: [
        ComponentParameter('density', 'Particle count', initial: .75),
        ComponentParameter('gather', 'Braid thickness', initial: .55),
      ],
    ),
    ShaderComponent(
      id: 'sculpture_shell.v1',
      themeId: 'formation',
      name: 'Chambered shell',
      description:
          'Particles assemble along the growing chambers of a spiral shell.',
      behavior: 'Open the chambers and explore the sculpture through touch.',
      parameters: [
        ComponentParameter('density', 'Particle count', initial: .8),
        ComponentParameter('gather', 'Chamber opening', initial: .65),
      ],
    ),
    ShaderComponent(
      id: 'sculpture_ribbon.v1',
      themeId: 'motion',
      name: 'Folded ribbon',
      description: 'A twisted particle ribbon reveals its folded surface.',
      behavior:
          'Twist the ribbon, disturb its surface, and let its form return.',
      parameters: [
        ComponentParameter('density', 'Particle count', initial: .75),
        ComponentParameter('gather', 'Ribbon width', initial: .6),
      ],
    ),
  ];
  static const emitterComponents = [
    ShaderComponent(
      id: 'formation_crane.v1',
      themeId: 'formation',
      name: 'Crane assembly',
      description: 'Scattered particles fold into a faceted paper crane.',
      behavior:
          'Assembly gathers the same particles into the crane. Drag to scatter its surface; release to rebuild it.',
      parameters: [
        ComponentParameter('density', 'Particle count', initial: .85),
        ComponentParameter('gather', 'Assembly', initial: 1),
      ],
    ),
    ShaderComponent(
      id: 'formation_butterfly.v1',
      themeId: 'formation',
      name: 'Butterfly assembly',
      description:
          'Loose particles gather into a butterfly with gently moving wings.',
      behavior:
          'Assembly forms the butterfly. Drag to break its wings into particles, then let them return.',
      parameters: [
        ComponentParameter('density', 'Particle count', initial: .85),
        ComponentParameter('gather', 'Assembly', initial: 1),
      ],
    ),
    ShaderComponent(
      id: 'formation_botanical.v1',
      themeId: 'formation',
      name: 'Leaf to bloom',
      description: 'A particle leaf transforms into a five-petal bloom.',
      behavior:
          'Move Leaf to bloom to reshape the same particles between both forms.',
      parameters: [
        ComponentParameter('density', 'Particle count', initial: .85),
        ComponentParameter('gather', 'Leaf to bloom', initial: 0),
      ],
    ),
    ShaderComponent(
      id: 'particle_storm.v1',
      themeId: 'motion',
      name: 'Copper storm',
      description:
          'A full-screen cloud of copper grains carried by turbulent currents.',
      behavior:
          'Drag to stir the cloud; momentum carries the grains after release.',
      parameters: [
        ComponentParameter('density', 'Population', initial: .8),
        ComponentParameter('gather', 'Turbulence', initial: .7),
      ],
    ),
    ShaderComponent(
      id: 'particle_rain.v1',
      themeId: 'motion',
      name: 'Prism rain',
      description: 'Layered glass-like shards fall across the entire canvas.',
      behavior: 'Drag to bend the falling shards and leave a moving wake.',
      parameters: [
        ComponentParameter('density', 'Shard count', initial: .55),
        ComponentParameter('fall', 'Fall speed', initial: .6),
      ],
    ),
    ShaderComponent(
      id: 'glass_tide.v1',
      themeId: 'emitters',
      name: 'Glass tide',
      description:
          'Broad translucent currents catch light across a continuous surface.',
      behavior:
          'Drag to ripple the surface. Adjust wave height and caustic light.',
      parameters: [
        ComponentParameter('height', 'Wave height', initial: .65),
        ComponentParameter('light', 'Caustic light', initial: .6),
      ],
    ),
    ShaderComponent(
      id: 'vortex_depth.v1',
      themeId: 'motion',
      name: 'Vortex descent',
      description:
          'Layered copper currents descend into a deep, full-canvas funnel.',
      behavior:
          'Drag to bend the current and pull its center. Pinch to open the funnel.',
      parameters: [
        ComponentParameter('pull', 'Spiral pull', initial: .65),
        ComponentParameter('density', 'Filament density', initial: .6),
      ],
    ),
    ShaderComponent(
      id: 'emitter_liquid.v1',
      themeId: 'emitters',
      name: 'Liquid cascade',
      description:
          'Viscous amber streams pour from independent sources and stretch into droplets.',
      behavior: 'Drag to bend the pour. Adjust emission and viscosity.',
      parameters: [
        ComponentParameter('rate', 'Emission', initial: .55),
        ComponentParameter('viscosity', 'Viscosity', initial: .6),
      ],
    ),
    ShaderComponent(
      id: 'emitter_chrome.v1',
      themeId: 'emitters',
      name: 'Chrome beads',
      description:
          'Reflective silver beads orbit and merge into a sculptural metal source.',
      behavior: 'Drag to move the source. Adjust bead size and surface polish.',
      parameters: [
        ComponentParameter('size', 'Bead size', initial: .55),
        ComponentParameter('polish', 'Surface polish', initial: .7),
      ],
    ),
  ];
  static const components = [...particleComponents, ...emitterComponents];
  ShaderComponent component(String id) =>
      [...components, ...legacyComponents].firstWhere(
        (c) => c.id == id,
        orElse: () => throw FormatException('Unknown component: $id'),
      );
  ShaderTheme theme(String id) =>
      [...themes, ...legacyThemes].firstWhere((t) => t.id == id);
  List<ShaderComponent> inTheme(String id) =>
      components.where((c) => c.themeId == id).toList();
}

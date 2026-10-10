class ShaderSpecification {
  final String asset;
  final List<String> parameterOrder;
  const ShaderSpecification(this.asset, this.parameterOrder);
}

abstract final class ComponentRegistry {
  static const specifications = {
    'formation_crane.v1': ShaderSpecification(
      'shaders/components/particle_sphere.frag',
      ['density', 'gather'],
    ),
    'formation_butterfly.v1': ShaderSpecification(
      'shaders/components/particle_sphere.frag',
      ['density', 'gather'],
    ),
    'formation_botanical.v1': ShaderSpecification(
      'shaders/components/particle_sphere.frag',
      ['density', 'gather'],
    ),
    'particle_storm.v1': ShaderSpecification(
      'shaders/components/ember_flock.frag',
      ['density', 'gather'],
    ),
    'particle_rain.v1': ShaderSpecification(
      'shaders/components/ember_flock.frag',
      ['density', 'fall'],
    ),
    'glass_tide.v1': ShaderSpecification('shaders/components/glass_tide.frag', [
      'height',
      'light',
    ]),
    'vortex_depth.v1': ShaderSpecification(
      'packages/shaderx_vortex/shaders/vortex.frag',
      ['pull', 'density'],
    ),
    'emitter_liquid.v1': ShaderSpecification(
      'shaders/components/emitter_liquid.frag',
      ['rate', 'viscosity'],
    ),
    'emitter_chrome.v1': ShaderSpecification(
      'shaders/components/emitter_chrome.frag',
      ['size', 'polish'],
    ),
    'sculpture_knot.v1': ShaderSpecification(
      'shaders/components/particle_sphere.frag',
      ['density', 'gather'],
    ),
    'sculpture_shell.v1': ShaderSpecification(
      'shaders/components/particle_sphere.frag',
      ['density', 'gather'],
    ),
    'sculpture_ribbon.v1': ShaderSpecification(
      'shaders/components/particle_sphere.frag',
      ['density', 'gather'],
    ),

    'particle_sphere.v1': ShaderSpecification(
      'shaders/components/particle_sphere.frag',
      ['density', 'gather'],
    ),
    'paper_fragments.v1': ShaderSpecification(
      'shaders/components/paper_fragments.frag',
      ['density', 'cut'],
    ),
    'graphite_bloom.v1': ShaderSpecification(
      'shaders/components/graphite_bloom.frag',
      ['density', 'pressure'],
    ),
    'ember_flock.v1': ShaderSpecification(
      'shaders/components/ember_flock.frag',
      ['density', 'cohesion'],
    ),
    'petal_assembly.v1': ShaderSpecification(
      'shaders/components/petal_assembly.frag',
      ['density', 'open'],
    ),
    'orbital_dust.v1': ShaderSpecification(
      'shaders/components/orbital_dust.frag',
      ['density', 'pull'],
    ),

    'vortex.v1': ShaderSpecification('shaders/components/vortex_field.frag', [
      'curl',
      'arms',
    ]),
    'film.v1': ShaderSpecification(
      'shaders/components/interference_film.frag',
      ['thickness', 'tension'],
    ),
    'membrane.v1': ShaderSpecification(
      'shaders/components/folded_membrane.frag',
      ['depth', 'spacing'],
    ),
    'contours.v1': ShaderSpecification(
      'shaders/components/contour_field.frag',
      ['elevation', 'density'],
    ),
    'resonance.v1': ShaderSpecification(
      'shaders/components/resonant_sand.frag',
      ['frequency', 'grain'],
    ),
    'veins.v1': ShaderSpecification('shaders/components/leaf_veins.frag', [
      'branching',
      'translucency',
    ]),
    'crystal.v1': ShaderSpecification(
      'shaders/components/crystal_facets.frag',
      ['facets', 'brilliance'],
    ),
    'vapor.v1': ShaderSpecification('shaders/components/vapor_layers.frag', [
      'density',
      'drift',
    ]),
  };
}

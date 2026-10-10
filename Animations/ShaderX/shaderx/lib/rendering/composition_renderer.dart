import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import '../features/composition/domain/composition.dart';
import '../features/composition/domain/master_tool.dart';
import 'component_registry.dart';
import 'particle_sculpture.dart';

class CompositionRenderer extends CustomPainter {
  final Map<String, ParticleSculpture> particleFields;
  final ui.Offset pointer;
  final double touch, gestureScale;
  final double Function()? touchValue;
  final Composition recipe;
  final Map<String, ui.FragmentShader> shaders;
  final double Function() time;
  CompositionRenderer({
    this.particleFields = const {},
    this.pointer = const ui.Offset(.5, .5),
    this.touch = 0,
    this.touchValue,
    this.gestureScale = 1,
    required this.recipe,
    required this.shaders,
    required this.time,
    super.repaint,
  });
  static const modes = {
    LayerBlend.normal: ui.BlendMode.srcOver,
    LayerBlend.screen: ui.BlendMode.screen,
    LayerBlend.multiply: ui.BlendMode.multiply,
    LayerBlend.difference: ui.BlendMode.difference,
  };
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final touch = touchValue?.call() ?? this.touch;
    final bounds = ui.Offset.zero & size;
    canvas.drawRect(bounds, ui.Paint()..color = const ui.Color(0xFF10110F));
    for (final layer in recipe.layers) {
      if (!layer.visible) continue;
      final sculpture = particleFields[layer.id];
      if (sculpture != null) {
        final unit =
            size.shortestSide *
            (sculpture.isField ? 1 : 1.24) *
            layer.scale *
            gestureScale;
        final px = (pointer.dx - .5) * size.width / unit;
        final py = (pointer.dy - .5) * size.height / unit;
        final c = math.cos(layer.rotation), s = math.sin(layer.rotation);
        sculpture.step(
          time: time(),
          count: layer.parameters['density']!,
          form:
              layer.parameters['gather'] ??
              layer.parameters['cohesion'] ??
              layer.parameters['pull'] ??
              layer.parameters['fall'] ??
              .6,
          aspect: size.width / size.height,
          pointer: ui.Offset(.5 + px * c + py * s, .5 - px * s + py * c),
          touch: touch,
        );
        canvas.saveLayer(bounds, ui.Paint()..blendMode = modes[layer.blend]!);
        sculpture.paint(
          canvas,
          size,
          count: layer.parameters['density']!,
          scale: layer.scale * gestureScale,
          rotation: layer.rotation,
          opacity: layer.opacity,
        );
        canvas.restore();
        continue;
      }
      final shader = shaders[layer.id];
      if (shader == null) continue;
      final spec = ComponentRegistry.specifications[layer.componentId]!;
      final uniforms = [
        size.width,
        size.height,
        (time() + layer.phase * recipe.duration) * 16 / recipe.duration,
        layer.scale * gestureScale,
        layer.rotation,
        layer.warp,
        ...spec.parameterOrder.map((id) => layer.parameters[id]!),
        layer.opacity,
        if (ParticleSculpture.supports(layer.componentId) ||
            layer.componentId == 'vortex.v1' ||
            layer.componentId == 'vortex_depth.v1' ||
            layer.componentId == 'glass_tide.v1' ||
            layer.componentId.startsWith('emitter_') ||
            [
              'particle_sphere.v1',
              'paper_fragments.v1',
              'graphite_bloom.v1',
              'ember_flock.v1',
              'petal_assembly.v1',
              'orbital_dust.v1',
            ].contains(layer.componentId)) ...[
          pointer.dx,
          pointer.dy,
          touch,
        ],
        if (layer.componentId == 'vortex_depth.v1') ...[.94, .37, .16],
      ];
      for (var i = 0; i < uniforms.length; i++) {
        shader.setFloat(i, uniforms[i]);
      }
      canvas.saveLayer(bounds, ui.Paint()..blendMode = modes[layer.blend]!);
      canvas.drawRect(bounds, ui.Paint()..shader = shader);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CompositionRenderer old) =>
      old.recipe != recipe || old.shaders != shaders;
}

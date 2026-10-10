import 'master_tool.dart';

class ComponentInstance {
  final String id, componentId;
  final Map<String, double> parameters;
  final double opacity, scale, rotation, warp, phase;
  final LayerBlend blend;
  final bool visible;
  ComponentInstance({
    required this.id,
    required this.componentId,
    required Map<String, double> parameters,
    this.opacity = 1,
    this.scale = 1,
    this.rotation = 0,
    this.warp = 0,
    this.phase = 0,
    this.blend = LayerBlend.normal,
    this.visible = true,
  }) : parameters = Map.unmodifiable(parameters);
  ComponentInstance copyWith({
    Map<String, double>? parameters,
    double? opacity,
    double? scale,
    double? rotation,
    double? warp,
    double? phase,
    LayerBlend? blend,
    bool? visible,
  }) => ComponentInstance(
    id: id,
    componentId: componentId,
    parameters: parameters ?? this.parameters,
    opacity: opacity ?? this.opacity,
    scale: scale ?? this.scale,
    rotation: rotation ?? this.rotation,
    warp: warp ?? this.warp,
    phase: phase ?? this.phase,
    blend: blend ?? this.blend,
    visible: visible ?? this.visible,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'component': componentId,
    'parameters': parameters,
    'opacity': opacity,
    'scale': scale,
    'rotation': rotation,
    'warp': warp,
    'phase': phase,
    'blend': blend.name,
    'visible': visible,
  };
  factory ComponentInstance.fromJson(Map<String, dynamic> json) {
    double read(String key, double fallback, double min, double max) {
      final value = json[key];
      if (value == null) return fallback;
      if (value is! num || !value.isFinite || value < min || value > max) {
        throw FormatException('Invalid layer $key');
      }
      return value.toDouble();
    }

    final params = (json['parameters'] as Map<String, dynamic>).map((k, v) {
      if (v is! num || !v.isFinite) {
        throw const FormatException('Invalid component parameter');
      }
      return MapEntry(k, v.toDouble());
    });
    return ComponentInstance(
      id: json['id'] as String,
      componentId: json['component'] as String,
      parameters: params,
      opacity: read('opacity', 1, 0, 1),
      scale: read('scale', 1, .4, 2),
      rotation: read('rotation', 0, -3.142, 3.142),
      warp: read('warp', 0, 0, 1),
      phase: read('phase', 0, 0, 1),
      blend: LayerBlend.values.byName(json['blend'] as String? ?? 'normal'),
      visible: json['visible'] as bool? ?? true,
    );
  }
}

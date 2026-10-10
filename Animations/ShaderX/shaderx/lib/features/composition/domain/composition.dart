import 'component_instance.dart';

class Composition {
  static const schemaVersion = 1;
  static const iconIds = [
    'layers',
    'wave',
    'prism',
    'leaf',
    'orbit',
    'contours',
  ];
  static const frameRates = [24, 30, 60];
  final String id, name, description, iconId;
  final int colorValue, frameRate;
  final List<ComponentInstance> layers;
  final double speed, duration, playhead;
  final DateTime updatedAt;
  Composition({
    required this.id,
    required this.name,
    this.description = '',
    this.iconId = 'layers',
    this.colorValue = 0xFFAAB85A,
    this.frameRate = 30,
    required List<ComponentInstance> layers,
    this.speed = .65,
    this.duration = 16,
    this.playhead = 0,
    DateTime? updatedAt,
  }) : layers = List.unmodifiable(layers),
       updatedAt = updatedAt ?? DateTime.now();
  Composition copyWith({
    String? name,
    String? description,
    String? iconId,
    int? colorValue,
    int? frameRate,
    List<ComponentInstance>? layers,
    double? speed,
    double? duration,
    double? playhead,
  }) => Composition(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    iconId: iconId ?? this.iconId,
    colorValue: colorValue ?? this.colorValue,
    frameRate: frameRate ?? this.frameRate,
    layers: layers ?? this.layers,
    speed: speed ?? this.speed,
    duration: duration ?? this.duration,
    playhead: playhead ?? this.playhead,
  );
  Map<String, dynamic> toJson() => {
    'schema': schemaVersion,
    'id': id,
    'name': name,
    'description': description,
    'icon': iconId,
    'color': colorValue,
    'frameRate': frameRate,
    'layers': layers.map((l) => l.toJson()).toList(),
    'speed': speed,
    'duration': duration,
    'playhead': playhead,
    'updatedAt': updatedAt.toIso8601String(),
  };
  factory Composition.fromJson(Map<String, dynamic> json) {
    if (json['schema'] != schemaVersion) {
      throw const FormatException('Unsupported composition version');
    }
    final layers = (json['layers'] as List)
        .map((l) => ComponentInstance.fromJson(l as Map<String, dynamic>))
        .toList();
    if (layers.length > 6 ||
        layers.map((l) => l.id).toSet().length != layers.length) {
      throw const FormatException('Invalid layer list');
    }
    double number(String key, double min, double max) {
      final v = json[key];
      if (v is! num || !v.isFinite || v < min || v > max) {
        throw FormatException('Invalid $key');
      }
      return v.toDouble();
    }

    final icon = (json['icon'] as String?) ?? 'layers';
    final color = json['color'] ?? 0xFFAAB85A;
    final fps = json['frameRate'] ?? 30;
    if (!iconIds.contains(icon) ||
        color is! int ||
        color < 0 ||
        color > 0xFFFFFFFF ||
        fps is! int ||
        !frameRates.contains(fps)) {
      throw const FormatException(
        'Invalid composition appearance or frame rate',
      );
    }
    return Composition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      iconId: icon,
      colorValue: color,
      frameRate: fps,
      layers: layers,
      speed: number('speed', 0, 2),
      duration: number('duration', 4, 40),
      playhead: number('playhead', 0, 40),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

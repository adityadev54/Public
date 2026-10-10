import 'component_parameters.dart';

class ShaderComponent {
  final String id, themeId, name, description, behavior;
  final List<ComponentParameter> parameters;
  const ShaderComponent({
    required this.id,
    required this.themeId,
    required this.name,
    required this.description,
    required this.behavior,
    required this.parameters,
  });
  Map<String, double> get defaults => {
    for (final p in parameters) p.id: p.initial,
  };
}

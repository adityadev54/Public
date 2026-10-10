class ComponentParameter {
  final String id, label;
  final double minimum, maximum, initial;
  const ComponentParameter(
    this.id,
    this.label, {
    this.minimum = 0,
    this.maximum = 1,
    required this.initial,
  });
}

import 'dart:ui' as ui;
import 'component_registry.dart';

class ShaderRuntime {
  final Map<String, Future<ui.FragmentProgram>> _programs = {};
  Future<ui.FragmentProgram> load(String id) => _programs.putIfAbsent(id, () {
    final spec = ComponentRegistry.specifications[id];
    if (spec == null) throw FormatException('No renderer for $id');
    return ui.FragmentProgram.fromAsset(spec.asset);
  });
  void retry(String id) => _programs.remove(id);
}

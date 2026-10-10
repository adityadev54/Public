import 'package:flutter/foundation.dart';
import '../../catalog/data/component_catalog.dart';
import '../../catalog/domain/shader_component.dart';
import '../domain/composition.dart';
import '../domain/component_instance.dart';

class CompositionController extends ChangeNotifier {
  final ComponentCatalog catalog;
  Composition recipe = Composition(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    name: 'Untitled composition',
    layers: [],
  );
  String? selectedId;
  final List<Composition> _undo = [], _redo = [];
  CompositionController(this.catalog);
  ComponentInstance? get selected =>
      recipe.layers.where((l) => l.id == selectedId).firstOrNull;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  bool get canAdd => recipe.layers.length < 6;
  bool _editing = false, _recorded = false;
  void beginEdit() {
    _editing = true;
    _recorded = false;
  }

  void endEdit() {
    _editing = false;
    _recorded = false;
  }

  void _set(Composition next, {bool history = true}) {
    if (history && (!_editing || !_recorded)) {
      _recorded = true;
      _undo.add(recipe);
      if (_undo.length > 60) {
        _undo.removeAt(0);
      }
      _redo.clear();
    }
    recipe = next;
    notifyListeners();
  }

  void newComposition({
    String title = 'Untitled composition',
    String description = '',
    String iconId = 'layers',
    int colorValue = 0xFFAAB85A,
    int frameRate = 30,
  }) {
    _undo.clear();
    _redo.clear();
    selectedId = null;
    recipe = Composition(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: title,
      description: description,
      iconId: iconId,
      colorValue: colorValue,
      frameRate: frameRate,
      layers: [],
    );
    notifyListeners();
  }

  void open(Composition saved) {
    validate(saved);
    recipe = saved;
    selectedId = saved.layers.firstOrNull?.id;
    _undo.clear();
    _redo.clear();
    notifyListeners();
  }

  void validate(Composition saved) {
    for (final layer in saved.layers) {
      final component = catalog.component(layer.componentId);
      if (layer.parameters.length != component.parameters.length) {
        throw const FormatException('Incomplete component parameters');
      }
      for (final p in component.parameters) {
        final v = layer.parameters[p.id];
        if (v == null || v < p.minimum || v > p.maximum) {
          throw FormatException('Invalid ${p.id}');
        }
      }
    }
  }

  void select(String id) {
    selectedId = id;
    notifyListeners();
  }

  void add(ShaderComponent component) {
    if (!canAdd) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    selectedId = id;
    _set(
      recipe.copyWith(
        layers: [
          ...recipe.layers,
          ComponentInstance(
            id: id,
            componentId: component.id,
            parameters: component.defaults,
          ),
        ],
      ),
    );
  }

  void update(ComponentInstance layer) {
    _set(
      recipe.copyWith(
        layers: recipe.layers.map((l) => l.id == layer.id ? layer : l).toList(),
      ),
    );
  }

  void parameter(String key, double value) {
    final layer = selected;
    if (layer == null) return;
    final spec = catalog
        .component(layer.componentId)
        .parameters
        .firstWhere((p) => p.id == key);
    update(
      layer.copyWith(
        parameters: {
          ...layer.parameters,
          key: value.clamp(spec.minimum, spec.maximum),
        },
      ),
    );
  }

  void remove(String id) {
    final layers = recipe.layers.where((l) => l.id != id).toList();
    if (selectedId == id) {
      selectedId = layers.lastOrNull?.id;
    }
    _set(recipe.copyWith(layers: layers));
  }

  void reorder(String id, int delta) {
    final layers = [...recipe.layers];
    final i = layers.indexWhere((l) => l.id == id);
    final target = i + delta;
    if (i < 0 || target < 0 || target >= layers.length) return;
    final layer = layers.removeAt(i);
    layers.insert(target, layer);
    _set(recipe.copyWith(layers: layers));
  }

  void timing({double? speed, double? duration}) => _set(
    recipe.copyWith(
      speed: speed?.clamp(0, 2),
      duration: duration?.clamp(4, 40),
    ),
  );
  void rename(String name) {
    if (name.trim().isNotEmpty) {
      _set(recipe.copyWith(name: name.trim()));
    }
  }

  void undo() {
    if (!canUndo) return;
    _redo.add(recipe);
    recipe = _undo.removeLast();
    selectedId = recipe.layers.any((l) => l.id == selectedId)
        ? selectedId
        : recipe.layers.lastOrNull?.id;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _undo.add(recipe);
    recipe = _redo.removeLast();
    selectedId = recipe.layers.lastOrNull?.id;
    notifyListeners();
  }
}

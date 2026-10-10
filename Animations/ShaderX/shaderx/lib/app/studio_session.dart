import 'dart:async';
import 'package:flutter/foundation.dart';
import '../features/catalog/data/component_catalog.dart';
import '../features/composition/application/composition_controller.dart';
import '../features/composition/domain/composition.dart';
import '../features/library/domain/composition_repository.dart';
import '../rendering/shader_runtime.dart';

class StudioSession extends ChangeNotifier {
  final ComponentCatalog catalog;
  final CompositionRepository repository;
  final ShaderRuntime runtime;
  late final CompositionController composition;
  List<Composition> library = [];
  String? error;
  bool busy = false;
  Timer? _draftTimer;
  Future<void> _writes = Future.value();
  StudioSession({
    required this.catalog,
    required this.repository,
    required this.runtime,
  }) {
    composition = CompositionController(catalog);
    composition.addListener(_changed);
  }
  Future<void> initialize() async {
    error = null;
    try {
      final saved = await repository.load();
      for (final item in saved) {
        composition.validate(item);
      }
      library = saved;
      final draft = await repository.loadDraft();
      if (draft != null) composition.open(draft);
    } catch (_) {
      error =
          'Saved work could not be read. Your existing storage has been preserved.';
    }
    notifyListeners();
  }

  void _changed() {
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 600), flushDraft);
    notifyListeners();
  }

  Future<void> _queue(Future<void> Function() action) {
    final next = _writes.then((_) => action());
    _writes = next.catchError((Object _) {});
    return next;
  }

  Future<void> flushDraft() async {
    _draftTimer?.cancel();
    final snapshot = composition.recipe;
    try {
      await _queue(() => repository.saveDraft(snapshot));
    } catch (_) {
      error = 'The current draft could not be saved. Try saving again.';
      notifyListeners();
    }
  }

  Future<bool> save() async {
    if (busy || composition.recipe.layers.isEmpty) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      final snapshot = composition.recipe;
      await _queue(() => repository.save(snapshot));
      library = await repository.load();
      return true;
    } catch (_) {
      error =
          'The composition could not be saved. Your canvas is still available.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      await _queue(() => repository.delete(id));
      library = await repository.load();
    } catch (_) {
      error = 'The composition could not be removed.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> retryLibrary() async {
    await initialize();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    composition.removeListener(_changed);
    composition.dispose();
    super.dispose();
  }
}

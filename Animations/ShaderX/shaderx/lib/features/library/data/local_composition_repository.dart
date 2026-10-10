import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/composition_repository.dart';
import '../../composition/domain/composition.dart';

class LocalCompositionRepository implements CompositionRepository {
  final SharedPreferences preferences;
  static const _library = 'shaderx.library.v1', _draft = 'shaderx.draft.v1';
  LocalCompositionRepository(this.preferences);
  @override
  Future<List<Composition>> load() async {
    final raw = preferences.getString(_library);
    if (raw == null) return [];
    final items = jsonDecode(raw) as List;
    return items
        .map((v) => Composition.fromJson(v as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _write(String key, Object value) async {
    if (!await preferences.setString(key, jsonEncode(value))) {
      throw StateError('Local storage did not accept the save');
    }
  }

  @override
  Future<void> save(Composition composition) async {
    final items = await load();
    items.removeWhere((c) => c.id == composition.id);
    items.insert(0, composition);
    await _write(_library, items.map((c) => c.toJson()).toList());
  }

  @override
  Future<void> delete(String id) async {
    final items = await load();
    items.removeWhere((c) => c.id == id);
    await _write(_library, items.map((c) => c.toJson()).toList());
  }

  @override
  Future<Composition?> loadDraft() async {
    final raw = preferences.getString(_draft);
    return raw == null
        ? null
        : Composition.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveDraft(Composition composition) =>
      _write(_draft, composition.toJson());
}

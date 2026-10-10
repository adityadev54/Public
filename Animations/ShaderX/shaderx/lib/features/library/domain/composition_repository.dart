import '../../composition/domain/composition.dart';

abstract interface class CompositionRepository {
  Future<List<Composition>> load();
  Future<void> save(Composition composition);
  Future<void> delete(String id);
  Future<Composition?> loadDraft();
  Future<void> saveDraft(Composition composition);
}

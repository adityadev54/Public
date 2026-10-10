import '../../composition/domain/composition.dart';

class CompositionSections {
  final Map<String, List<Composition>> groups;
  CompositionSections._(this.groups);

  factory CompositionSections.from(List<Composition> saved, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final cutoff = today.subtract(const Duration(days: 7));
    final sorted = [...saved]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final groups = <String, List<Composition>>{};
    for (final item in sorted) {
      final date = item.updatedAt.toLocal();
      final label = !item.updatedAt.isBefore(cutoff)
          ? 'This week'
          : date.year == today.year && date.month == today.month
          ? 'This month'
          : '${const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][date.month - 1]} ${date.year}';
      (groups[label] ??= []).add(item);
    }
    return CompositionSections._(groups);
  }
}

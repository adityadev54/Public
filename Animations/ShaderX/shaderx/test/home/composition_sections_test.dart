import 'package:flutter_test/flutter_test.dart';
import 'package:shaderx/features/composition/domain/composition.dart';
import 'package:shaderx/features/home/domain/composition_sections.dart';

void main() {
  test(
    'All saved recipes appear once in newest-first date groups without a recent cap',
    () {
      final now = DateTime(2026, 10, 20, 12);
      final saved = List.generate(
        8,
        (i) => Composition(
          id: '$i',
          name: 'Study $i',
          layers: [],
          updatedAt: now.subtract(
            Duration(days: i < 5 ? i : 10 + (i - 5) * 30),
          ),
        ),
      ).reversed.toList();
      final sections = CompositionSections.from(saved, now: now);
      expect(sections.groups.keys, [
        'This week',
        'This month',
        'September 2026',
        'August 2026',
      ]);
      expect(sections.groups['This week']!.map((c) => c.id), [
        '0',
        '1',
        '2',
        '3',
        '4',
      ]);
      final all = sections.groups.values.expand((items) => items).toList();
      expect(all.map((c) => c.id), List.generate(8, (i) => '$i'));
      final later = CompositionSections.from(
        saved,
        now: now.add(const Duration(days: 8)),
      );
      expect(later.groups.containsKey('This week'), isFalse);
      expect(later.groups.values.expand((items) => items), hasLength(8));
    },
  );
}

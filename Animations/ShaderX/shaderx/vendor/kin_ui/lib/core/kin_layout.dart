import 'package:flutter/widgets.dart';
import 'kin_spacing.dart';

/// Responsive breakpoint tiers: [compact] (<600), [medium] (600–1200), [expanded] (≥1200).
enum LayoutType { compact, medium, expanded }

/// Immutable snapshot of the current layout tier, column count, and margins.
class KinLayoutData {
  final LayoutType type;
  final int columns;
  final EdgeInsets margins;

  const KinLayoutData({
    required this.type,
    required this.columns,
    required this.margins,
  });

  bool get isCompact => type == LayoutType.compact;
  bool get isMedium => type == LayoutType.medium;
  bool get isExpanded => type == LayoutType.expanded;

  /// Uses the shortest side of the available size so that rotating
  /// to landscape keeps the same layout tier (compact stays compact).
  factory KinLayoutData.fromWidth(double width) {
    if (width < 600) {
      return KinLayoutData(
        type: LayoutType.compact,
        columns: 4,
        margins: const EdgeInsets.symmetric(horizontal: KinSpacing.screen),
      );
    } else if (width < 1200) {
      return KinLayoutData(
        type: LayoutType.medium,
        columns: 8,
        margins: const EdgeInsets.symmetric(horizontal: KinSpacing.lg),
      );
    } else {
      return KinLayoutData(
        type: LayoutType.expanded,
        columns: 12,
        margins: const EdgeInsets.symmetric(horizontal: KinSpacing.xl),
      );
    }
  }
}

/// [InheritedWidget] that provides [KinLayoutData] to the widget tree.
class KinLayout extends InheritedWidget {
  /// The current layout data.
  final KinLayoutData data;

  const KinLayout({super.key, required this.data, required super.child});

  static KinLayoutData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<KinLayout>();
    assert(widget != null, 'No KinLayout found in context. Wrap with KinApp.');
    return widget!.data;
  }

  @override
  bool updateShouldNotify(KinLayout oldWidget) =>
      data.type != oldWidget.data.type;
}

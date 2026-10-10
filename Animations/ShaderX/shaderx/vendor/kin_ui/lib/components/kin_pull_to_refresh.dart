import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_spacing.dart';

/// A pull-to-refresh wrapper that themes the refresh indicator
/// with the Kin design system colors.
///
/// Wrap your scrollable content (e.g. a [ListView] or
/// [CustomScrollView]) with this widget and provide an
/// [onRefresh] callback.
class KinPullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final double displacement;
  final double edgeOffset;

  const KinPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.displacement = KinSpacing.xl,
    this.edgeOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      displacement: displacement,
      edgeOffset: edgeOffset,
      color: theme.primary,
      backgroundColor: theme.surfaceVariant,
      strokeWidth: 2.5,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import '../core/kin_layout.dart';
import '../navigation/kin_top_bar.dart';
import '../core/kin_spacing.dart';

/// A dashboard template with a stat-card row at the top and an
/// activity feed below.
///
/// The [stats] are laid out in a horizontal [Wrap] so they reflow on
/// narrower screens. The [feed] items are rendered as a vertical list.
class KinDashboardTemplate extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  /// Small summary cards displayed at the top (e.g. KPIs).
  final List<Widget> stats;

  /// Main content list below the stats row (activity items, charts).
  final List<Widget> feed;

  const KinDashboardTemplate({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    required this.stats,
    required this.feed,
  });

  @override
  Widget build(BuildContext context) {
    final layout = KinLayout.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        KinTopBar(
          title: title,
          actions: actions,
          leading: leading,
        ),
        SliverPadding(
          padding: layout.margins,
          sliver: SliverList.list(
            children: [
              const SizedBox(height: KinSpacing.md),

              // ── Stat cards ──
              Wrap(
                spacing: KinSpacing.sm,
                runSpacing: KinSpacing.sm,
                children: stats,
              ),

              const SizedBox(height: KinSpacing.lg),

              // ── Activity feed ──
              ...feed,

              const SizedBox(height: 160),
            ],
          ),
        ),
      ],
    );
  }
}

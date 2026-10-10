import 'package:flutter/material.dart';
import '../core/kin_layout.dart';
import '../navigation/kin_top_bar.dart';
import '../core/kin_theme.dart';
import '../core/kin_spacing.dart';

/// A detail page with a hero area, scrollable body, and an optional
/// sticky action bar at the bottom.
///
/// Typical use: product pages, article views, profile screens.
class KinDetailTemplate extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  /// Widget displayed in the expanded header area (image, illustration).
  final Widget? hero;
  final double heroHeight;

  /// Main body content below the hero.
  final List<Widget> children;

  /// Sticky bar pinned to the bottom of the screen.
  final Widget? stickyAction;

  const KinDetailTemplate({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.hero,
    this.heroHeight = 260,
    required this.children,
    this.stickyAction,
  });

  @override
  Widget build(BuildContext context) {
    final layout = KinLayout.of(context);
    final theme = KinTheme.of(context);

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              KinTopBar(
                title: title,
                actions: actions,
                leading: leading,
                expandedHeight: hero != null ? heroHeight : 120,
              ),
              if (hero != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: layout.margins,
                    child: hero!,
                  ),
                ),
              SliverPadding(
                padding: layout.margins,
                sliver: SliverList.list(
                  children: [
                    const SizedBox(height: KinSpacing.md),
                    ...children,
                    SizedBox(
                      height: stickyAction != null ? KinSpacing.xl : 160,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (stickyAction != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: KinSpacing.md,
              right: KinSpacing.md,
              top: KinSpacing.sm,
              bottom: MediaQuery.paddingOf(context).bottom + KinSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.outline.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: stickyAction!,
          ),
      ],
    );
  }
}

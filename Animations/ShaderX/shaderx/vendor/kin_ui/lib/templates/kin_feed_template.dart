import 'package:flutter/material.dart';
import '../components/kin_pull_to_refresh.dart';
import '../core/kin_layout.dart';
import '../navigation/kin_top_bar.dart';
import '../core/kin_spacing.dart';

/// A scrollable feed layout with an optional pull-to-refresh.
///
/// Provides a [KinTopBar] collapsing header, adaptive padding via
/// [KinLayout], and the content rendered as a sliver list.
class KinFeedTemplate extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final double bottomPadding;

  const KinFeedTemplate({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    required this.children,
    this.onRefresh,
    this.bottomPadding = 160,
  });

  @override
  Widget build(BuildContext context) {
    final layout = KinLayout.of(context);

    Widget scrollView = CustomScrollView(
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
              ...children,
              SizedBox(height: bottomPadding),
            ],
          ),
        ),
      ],
    );

    if (onRefresh != null) {
      scrollView = KinPullToRefresh(
        onRefresh: onRefresh!,
        child: scrollView,
      );
    }

    return scrollView;
  }
}

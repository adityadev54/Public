import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';

/// Shimmer placeholder for loading states.
class KinSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const KinSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = KinRadius.smAll,
  });

  factory KinSkeleton.card() => const KinSkeleton(
        height: 120,
        borderRadius: KinRadius.lgAll,
      );

  factory KinSkeleton.circle({double size = 40}) => KinSkeleton(
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(size / 2),
      );

  @override
  State<KinSkeleton> createState() => _KinSkeletonState();
}

class _KinSkeletonState extends State<KinSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmer = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    final baseColor = theme.outline.withValues(alpha: 0.3);
    final highlightColor = theme.outline.withValues(alpha: 0.15);

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _shimmer.value, 0),
              end: Alignment(-1.0 + 2.0 * _shimmer.value + 1.0, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

/// A preset skeleton layout with title + subtitle + optional avatar.
class KinSkeletonListTile extends StatelessWidget {
  final bool showAvatar;

  const KinSkeletonListTile({super.key, this.showAvatar = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KinSpacing.md,
        vertical: KinSpacing.sm + 2,
      ),
      child: Row(
        spacing: KinSpacing.md,
        children: [
          if (showAvatar) KinSkeleton.circle(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: KinSpacing.xs,
              children: [
                const KinSkeleton(width: 140, height: 14),
                KinSkeleton(
                  width: 200,
                  height: 12,
                  borderRadius: KinRadius.smAll,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

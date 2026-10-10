import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';

/// Visual transition modes for page changes.
enum KinPageTransition {
  /// Default horizontal slide.
  slide,

  /// Scale + fade between pages.
  fade,

  /// Parallax depth effect.
  parallax,

  /// Stacked card with depth.
  stack,

  /// iOS 18 zoom — pages scale in/out with opacity.
  zoom,

  /// 3D cube rotation around the Y axis.
  cube,

  /// Horizontal flip (card flip effect).
  flip,

  /// Fluid iOS 18 depth — incoming page rises from behind with scale + blur feel.
  depth,
}

/// Indicator styles for [KinPageView].
enum KinPageIndicator { dot, dash, numbered, none }

/// A highly customizable page view with transition effects,
/// indicators, and flexible configuration.
class KinPageView extends StatefulWidget {
  final List<Widget> children;
  final KinPageTransition transition;
  final KinPageIndicator indicator;
  final int initialPage;
  final bool enableLoop;
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final double? height;
  final bool pageSnapping;
  final ValueChanged<int>? onPageChanged;
  final EdgeInsetsGeometry? padding;

  const KinPageView({
    super.key,
    required this.children,
    this.transition = KinPageTransition.slide,
    this.indicator = KinPageIndicator.dot,
    this.initialPage = 0,
    this.enableLoop = false,
    this.scrollDirection = Axis.horizontal,
    this.physics,
    this.height,
    this.pageSnapping = true,
    this.onPageChanged,
    this.padding,
  });

  /// Convenience for parallax pages.
  const KinPageView.parallax({
    super.key,
    required this.children,
    this.indicator = KinPageIndicator.dash,
    this.initialPage = 0,
    this.enableLoop = false,
    this.scrollDirection = Axis.horizontal,
    this.physics,
    this.height,
    this.pageSnapping = true,
    this.onPageChanged,
    this.padding,
  }) : transition = KinPageTransition.parallax;

  /// Convenience for stacked card pages.
  const KinPageView.stack({
    super.key,
    required this.children,
    this.indicator = KinPageIndicator.dot,
    this.initialPage = 0,
    this.enableLoop = false,
    this.scrollDirection = Axis.horizontal,
    this.physics,
    this.height,
    this.pageSnapping = true,
    this.onPageChanged,
    this.padding,
  }) : transition = KinPageTransition.stack;

  @override
  State<KinPageView> createState() => _KinPageViewState();
}

class _KinPageViewState extends State<KinPageView> {
  late PageController _controller;
  int _currentPage = 0;

  int get _itemCount => widget.children.length;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _controller = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    Widget pageView = PageView.builder(
      controller: _controller,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      pageSnapping: widget.pageSnapping,
      itemCount: widget.enableLoop ? null : _itemCount,
      onPageChanged: (index) {
        final normalised = index % _itemCount;
        HapticFeedback.selectionClick();
        setState(() => _currentPage = normalised);
        widget.onPageChanged?.call(normalised);
      },
      itemBuilder: (context, index) {
        final normalised = index % _itemCount;
        final child = widget.children[normalised];

        if (widget.transition == KinPageTransition.slide) return child;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double pageOffset = 0;
            if (_controller.position.haveDimensions) {
              pageOffset = (_controller.page ?? _controller.initialPage.toDouble()) - index;
            }

            return switch (widget.transition) {
              KinPageTransition.slide => child!,
              KinPageTransition.fade => Opacity(
                  opacity: (1 - pageOffset.abs()).clamp(0.0, 1.0),
                  child: child,
                ),
              KinPageTransition.parallax => Transform.translate(
                  offset: Offset(pageOffset * 100, 0),
                  child: child,
                ),
              KinPageTransition.stack => Builder(
                  builder: (context) {
                    final s = 1 - (pageOffset.abs() * 0.1).clamp(0.0, 0.3);
                    final tx = pageOffset * 30;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..scaleByDouble(s, s, 1.0, 1.0)
                        ..translateByDouble(tx, 0.0, 0.0, 1.0),
                      child: Opacity(
                        opacity: (1 - pageOffset.abs() * 0.5).clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                ),
              KinPageTransition.zoom => Builder(
                  builder: (context) {
                    final scale = 1.0 - (pageOffset.abs() * 0.25).clamp(0.0, 1.0);
                    final opacity = (1.0 - pageOffset.abs() * 1.5).clamp(0.0, 1.0);
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(opacity: opacity, child: child),
                    );
                  },
                ),
              KinPageTransition.cube => Builder(
                  builder: (context) {
                    final angle = pageOffset * math.pi / 2;
                    final alignment = pageOffset > 0 ? Alignment.centerLeft : Alignment.centerRight;
                    return Transform(
                      alignment: alignment,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateY(angle),
                      child: Opacity(
                        opacity: (1.0 - pageOffset.abs() * 0.5).clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                ),
              KinPageTransition.flip => Builder(
                  builder: (context) {
                    final angle = pageOffset * math.pi;
                    final isFlipped = pageOffset.abs() > 0.5;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: Opacity(
                        opacity: isFlipped ? 0.0 : (1.0 - pageOffset.abs()).clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                ),
              KinPageTransition.depth => Builder(
                  builder: (context) {
                    if (pageOffset >= 0) {
                      // Current page — slides out and scales down
                      final scale = (1.0 - pageOffset * 0.3).clamp(0.75, 1.0);
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..scaleByDouble(scale, scale, 1.0, 1.0),
                        child: Opacity(
                          opacity: (1.0 - pageOffset).clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    } else {
                      // Incoming page — rises from below with scale
                      final scale = (1.0 + pageOffset * 0.15).clamp(0.85, 1.0);
                      final ty = pageOffset.abs() * 40;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..scaleByDouble(scale, scale, 1.0, 1.0)
                          ..translateByDouble(0.0, ty, 0.0, 1.0),
                        child: Opacity(
                          opacity: (1.0 - pageOffset.abs() * 0.6).clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    }
                  },
                ),
            };
          },
          child: child,
        );
      },
    );

    if (widget.padding != null) {
      pageView = Padding(padding: widget.padding!, child: pageView);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.height != null)
          SizedBox(height: widget.height, child: pageView)
        else
          Expanded(child: pageView),
        if (widget.indicator != KinPageIndicator.none && _itemCount > 1)
          Padding(
            padding: const EdgeInsets.only(top: KinSpacing.sm),
            child: _buildIndicator(theme),
          ),
      ],
    );
  }

  Widget _buildIndicator(KinTheme theme) {
    if (widget.indicator == KinPageIndicator.numbered) {
      return Text(
        '${_currentPage + 1} / $_itemCount',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: theme.onSurfaceVariant,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: KinSpacing.xs,
      children: List.generate(_itemCount, (i) {
        final isActive = i == _currentPage;
        final isDash = widget.indicator == KinPageIndicator.dash;
        return AnimatedContainer(
          duration: KinMotion.fast,
          curve: KinMotion.enter,
          width: isDash
              ? (isActive ? 20 : 8)
              : (isActive ? 10 : 6),
          height: isDash ? 4 : 6,
          decoration: BoxDecoration(
            color: isActive ? theme.primary : theme.outline,
            borderRadius: KinRadius.pillAll,
          ),
        );
      }),
    );
  }
}

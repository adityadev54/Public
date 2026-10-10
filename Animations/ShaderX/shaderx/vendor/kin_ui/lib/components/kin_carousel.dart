import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';

/// Visual variants for [KinCarousel].
enum KinCarouselVariant {
  /// Full-width pages with no gap between items.
  fullBleed,

  /// Card-style pages with peek from adjacent items.
  card,

  /// Stacked cards with depth effect.
  stacked,
}

/// Indicator styles for [KinCarousel].
enum KinCarouselIndicator { dot, dash, none }

/// A highly customizable carousel with iOS 18-style fluid spring animations.
///
/// Pages transition with subtle 3D parallax, spring-based scale effects,
/// and smoothly morphing indicators.
class KinCarousel extends StatefulWidget {
  final List<Widget> children;
  final KinCarouselVariant variant;
  final KinCarouselIndicator indicator;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final double viewportFraction;
  final double itemSpacing;
  final double? height;
  final int initialPage;
  final bool enableLoop;
  final bool padEnds;
  final EdgeInsetsGeometry contentPadding;
  final ValueChanged<int>? onPageChanged;
  final Axis scrollDirection;

  const KinCarousel({
    super.key,
    required this.children,
    this.variant = KinCarouselVariant.fullBleed,
    this.indicator = KinCarouselIndicator.dot,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.viewportFraction = 0.92,
    this.itemSpacing = KinSpacing.sm,
    this.height,
    this.initialPage = 0,
    this.enableLoop = false,
    this.padEnds = true,
    this.contentPadding = EdgeInsets.zero,
    this.onPageChanged,
    this.scrollDirection = Axis.horizontal,
  });

  const KinCarousel.card({
    super.key,
    required this.children,
    this.indicator = KinCarouselIndicator.dot,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.height,
    this.initialPage = 0,
    this.enableLoop = false,
    this.contentPadding = EdgeInsets.zero,
    this.onPageChanged,
    this.scrollDirection = Axis.horizontal,
  })  : variant = KinCarouselVariant.card,
        viewportFraction = 0.85,
        itemSpacing = KinSpacing.sm,
        padEnds = true;

  const KinCarousel.stacked({
    super.key,
    required this.children,
    this.indicator = KinCarouselIndicator.dash,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.height,
    this.initialPage = 0,
    this.enableLoop = false,
    this.contentPadding = EdgeInsets.zero,
    this.onPageChanged,
    this.scrollDirection = Axis.horizontal,
  })  : variant = KinCarouselVariant.stacked,
        viewportFraction = 0.82,
        itemSpacing = 0,
        padEnds = true;

  @override
  State<KinCarousel> createState() => _KinCarouselState();
}

class _KinCarouselState extends State<KinCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _controller;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  int get _itemCount => widget.children.length;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;

    final fraction = switch (widget.variant) {
      KinCarouselVariant.fullBleed => widget.viewportFraction,
      KinCarouselVariant.card => widget.viewportFraction,
      KinCarouselVariant.stacked => widget.viewportFraction,
    };

    _controller = PageController(
      initialPage: widget.initialPage,
      viewportFraction: fraction,
    );

    if (widget.autoPlay && _itemCount > 1) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(KinCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoPlay != oldWidget.autoPlay) {
      widget.autoPlay ? _startAutoPlay() : _stopAutoPlay();
    }
  }

  void _startAutoPlay() {
    _stopAutoPlay();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || _itemCount <= 1) return;
      int next = _currentPage + 1;
      if (next >= _itemCount) {
        next = widget.enableLoop ? 0 : _currentPage;
      }
      if (next != _currentPage) {
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: KinMotion.fluidEnter,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    return Padding(
      padding: widget.contentPadding,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height ?? 200,
          child: PageView.builder(
            controller: _controller,
            scrollDirection: widget.scrollDirection,
            padEnds: widget.padEnds,
            physics: const _KinCarouselScrollPhysics(),
            itemCount:
                (widget.enableLoop && _itemCount > 1) ? null : _itemCount,
            onPageChanged: (index) {
              final normalised = index % _itemCount;
              setState(() => _currentPage = normalised);
              widget.onPageChanged?.call(normalised);
            },
            itemBuilder: (context, index) {
              final normalised = index % _itemCount;
              final child = widget.children[normalised];

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double value = 1.0;
                  if (_controller.position.haveDimensions) {
                    value = (_controller.page ??
                            _controller.initialPage.toDouble()) -
                        index;
                    value = (1 - value.abs().clamp(0.0, 1.0));
                  }

                  final parallax = (1.0 - value) * 0.015;

                  return switch (widget.variant) {
                    KinCarouselVariant.fullBleed => Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.itemSpacing,
                        ),
                        child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(parallax),
                        child: child,
                      ),
                      ),
                    KinCarouselVariant.card => Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(parallax),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.itemSpacing,
                            vertical: KinSpacing.sm * (1 - value),
                          ),
                          child: AnimatedScale(
                            scale: 0.95 + (0.05 * value),
                            duration: KinMotion.fast,
                            curve: KinMotion.fluidEnter,
                            child: child,
                          ),
                        ),
                      ),
                    KinCarouselVariant.stacked => Transform.scale(
                        scale: 0.88 + (0.12 * value),
                        child: AnimatedOpacity(
                          opacity: 0.4 + (0.6 * value),
                          duration: KinMotion.fast,
                          curve: KinMotion.fluidEnter,
                          child: child,
                        ),
                      ),
                  };
                },
                child: child,
              );
            },
          ),
        ),
        if (widget.indicator != KinCarouselIndicator.none && _itemCount > 1)
          Padding(
            padding: const EdgeInsets.only(top: KinSpacing.sm),
            child: _KinFluidIndicator(
              count: _itemCount,
              current: _currentPage,
              style: widget.indicator,
              activeColor: theme.primary,
              inactiveColor: theme.outline,
            ),
          ),
      ],
    ),
    );
  }
}

class _KinFluidIndicator extends StatelessWidget {
  final int count;
  final int current;
  final KinCarouselIndicator style;
  final Color activeColor;
  final Color inactiveColor;

  const _KinFluidIndicator({
    required this.count,
    required this.current,
    required this.style,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: KinSpacing.xs,
      children: List.generate(count, (i) {
        final isActive = i == current;
        final distance = (i - current).abs();
        final nearScale = math.max(0.0, 1.0 - distance * 0.3);

        return TweenAnimationBuilder<double>(
          tween: Tween(end: isActive ? 1.0 : nearScale),
          duration: const Duration(milliseconds: 500),
          curve: KinMotion.fluidEnter,
          builder: (context, activity, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: KinMotion.fluidEnter,
              width: switch (style) {
                KinCarouselIndicator.dot => 6.0 + (6.0 * activity),
                KinCarouselIndicator.dash => 8.0 + (14.0 * activity),
                KinCarouselIndicator.none => 0,
              },
              height: switch (style) {
                KinCarouselIndicator.dot => 6,
                KinCarouselIndicator.dash => 4,
                KinCarouselIndicator.none => 0,
              },
              decoration: BoxDecoration(
                color: Color.lerp(inactiveColor, activeColor, activity),
                borderRadius: KinRadius.pillAll,
              ),
            );
          },
        );
      }),
    );
  }
}

/// iOS 18-style spring scroll physics for carousel pages.
/// Uses a softer spring than default for that fluid, weighty feel.
class _KinCarouselScrollPhysics extends ScrollPhysics {
  const _KinCarouselScrollPhysics({super.parent});

  @override
  _KinCarouselScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _KinCarouselScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription(
        mass: 1.0,
        stiffness: 180.0,
        damping: 22.0,
      );
}

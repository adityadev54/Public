import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kin_ui/core/kin_motion.dart';
import 'package:kin_ui/core/kin_radius.dart';
import 'package:kin_ui/core/kin_spacing.dart';
import 'package:kin_ui/core/kin_theme.dart';


/// Icon and label pair for navigation destinations.
class KinNavItem {
  /// The icon displayed in the navigation item.
  final IconData icon;

  /// The text label displayed below the icon.
  final String label;

  /// Optional icon shown when this item is selected.
  final IconData? activeIcon;

  const KinNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });
}

/// Vertical icon rail for medium-width layouts.
///
/// Features a spring-driven sliding indicator, per-item bounce feedback,
/// frosted glass in dark mode, and smooth icon/label color transitions
/// matching KinUI's physics-first design language.
class KinNavRail extends StatefulWidget {
  final List<KinNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const KinNavRail({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<KinNavRail> createState() => _KinNavRailState();
}

class _KinNavRailState extends State<KinNavRail>
    with TickerProviderStateMixin {
  // Sliding indicator
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late int _prevIndex;

  // Per-item bounce
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  int _bouncingIndex = -1;

  // Height of a single nav item (icon only).
  static const double _itemExtent = 56;
  // Height of the sliding indicator pill.
  static const double _pillHeight = 40;
  // Top offset before first item.
  static const double _topPadding = KinSpacing.xl;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex;

    _slideController = AnimationController(
      vsync: this,
      duration: KinMotion.normal,
    )..value = 1.0;
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.10), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.10, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(KinNavRail old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _prevIndex = old.currentIndex;
      _slideController
        ..reset()
        ..forward();
      _bouncingIndex = widget.currentIndex;
      _bounceController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  double _indicatorY(int index) =>
      _topPadding + index * _itemExtent + (_itemExtent - _pillHeight) / 2;

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: KinRadius.lgAll,
      child: Container(
      width: 64,
      decoration: BoxDecoration(
        color: isDark
            ? theme.surfaceVariant.withValues(alpha: 0.55)
            : theme.surfaceVariant,
        borderRadius: KinRadius.lgAll,
        border: Border.all(
          color: theme.outline.withValues(alpha: isDark ? 0.25 : 0.5),
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          // ── Frosted backdrop (dark mode only) ──
          if (isDark)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: const SizedBox.expand(),
                ),
              ),
            ),

          // ── Sliding indicator pill ──
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, _) {
              final fromY = _indicatorY(_prevIndex);
              final toY = _indicatorY(widget.currentIndex);
              final y = lerpDouble(fromY, toY, _slideAnimation.value)!;

              return Positioned(
                left: 10,
                right: 10,
                top: y,
                height: _pillHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.primaryContainer.withValues(alpha: 0.85)
                        : theme.primaryContainer,
                    borderRadius: KinRadius.pillAll,
                    border: Border.all(
                      color: theme.primary.withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primary.withValues(alpha: isDark ? 0.20 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Navigation items ──
          Column(
            children: [
              const SizedBox(height: _topPadding),
              ...List.generate(widget.items.length, (i) {
                final item = widget.items[i];
                final isSelected = i == widget.currentIndex;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (i != widget.currentIndex) {
                      HapticFeedback.lightImpact();
                      widget.onTap(i);
                    }
                  },
                  child: SizedBox(
                    height: _itemExtent,
                    width: 64,
                    child: AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        final scale = (i == _bouncingIndex)
                            ? _bounceAnimation.value
                            : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: KinMotion.fast,
                          switchInCurve: KinMotion.enter,
                          child: Icon(
                            isSelected
                                ? (item.activeIcon ?? item.icon)
                                : item.icon,
                            key: ValueKey(isSelected),
                            size: 22,
                            color: isSelected
                                ? theme.primary
                                : theme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

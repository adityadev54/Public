import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';

/// A pill-shaped icon tab bar with iOS 18-style fluid sliding pill.
///
/// The glass selector pill physically **slides** from the previous tab
/// to the tapped tab using spring physics. The selected icon gets a
/// subtle bounce, and the pill smoothly widens at the destination.
class KinBottomBar extends StatefulWidget {
  const KinBottomBar({
    super.key,
    this.embedded = false,
    this.initialIndex = 0,
    this.currentIndex,
    this.onTabChanged,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.iconSize = 24,
    this.height = 62,
    this.borderRadius = 32,
    this.barBlurSigma = 10,
    this.selectorBlurSigma = 6,
    this.items,
    this.labels,
    this.labelStyle,
  });

  final bool embedded;
  final int initialIndex;
  final int? currentIndex;
  final ValueChanged<int>? onTabChanged;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final Color? selectedLabelColor;
  final Color? unselectedLabelColor;
  final double iconSize;
  final double height;
  final double borderRadius;
  final double barBlurSigma;
  final double selectorBlurSigma;
  final List<Widget>? items;
  final List<String>? labels;
  final TextStyle? labelStyle;

  @override
  State<KinBottomBar> createState() => _KinBottomBarState();
}

class _KinBottomBarState extends State<KinBottomBar>
    with TickerProviderStateMixin {
  late int _selectedIndex;

  /// Spring-driven 0→1 animation for sliding the pill.
  late AnimationController _pillController;
  late num _pillFromIndex;
  late num _pillToIndex;

  /// Bounce animation for the tapped icon.
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  int _bouncingIndex = -1;

  // Layout constants
  static const double _hPad = 4.0;

  int get _resolvedIndex {
    final itemCount = _icons.length;
    if (itemCount == 0) return 0;
    final requested = widget.currentIndex ?? widget.initialIndex;
    return requested.clamp(0, itemCount - 1);
  }

  double _slotWidth(double barWidth) {
    final usable = barWidth - _hPad * 2;
    return usable / _icons.length;
  }

  double _pillRestWidth(double slotW) => slotW;

  List<Widget> get _icons =>
      widget.items ??
      const [
        Icon(CupertinoIcons.house_fill),
        Icon(CupertinoIcons.square_grid_2x2),
        Icon(CupertinoIcons.star),
        Icon(CupertinoIcons.gear),
      ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = _resolvedIndex;
    _pillFromIndex = _resolvedIndex.toDouble();
    _pillToIndex = _resolvedIndex.toDouble();

    _pillController = AnimationController.unbounded(vsync: this)..value = 1.0;

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _bounceAnim =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 15),
          TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.08), weight: 35),
          TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.97), weight: 20),
          TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0), weight: 30),
        ]).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.easeOut),
        );
  }

  @override
  void didUpdateWidget(covariant KinBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = _resolvedIndex;
    if (widget.currentIndex != null && nextIndex != _selectedIndex) {
      _animateTo(nextIndex, notify: false);
    }
  }

  @override
  void dispose() {
    _pillController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  /// Current fractional pill position (interpolated tab index).
  double get _pillPos {
    final t = _pillController.value.clamp(0.0, 1.0);
    return lerpDouble(_pillFromIndex.toDouble(), _pillToIndex.toDouble(), t)!;
  }

  void _onTap(int index) {
    if (index == _selectedIndex) {
      widget.onTabChanged?.call(index);
      return;
    }
    HapticFeedback.selectionClick();
    _animateTo(index);
  }

  void _animateTo(int index, {bool notify = true}) {
    _pillFromIndex = _selectedIndex.toDouble();
    _pillToIndex = index.toDouble();

    setState(() {
      _selectedIndex = index;
      _bouncingIndex = index;
    });

    // Smooth spring slide
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 280.0,
      damping: 24.0,
    );
    _pillController.animateWith(SpringSimulation(spring, 0.0, 1.0, 0.0));

    // Icon bounce
    _bounceController.forward(from: 0).then((_) {
      if (mounted) setState(() => _bouncingIndex = -1);
    });

    if (notify) {
      widget.onTabChanged?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kinTheme = KinTheme.of(context);

    final selIcon =
        widget.selectedIconColor ??
        (isDark ? kinTheme.onSurface : kinTheme.primary);
    final unselIcon = widget.unselectedIconColor ?? kinTheme.onSurfaceVariant;
    final selLabel =
        widget.selectedLabelColor ??
        (isDark ? kinTheme.onSurface : kinTheme.primary);
    final unselLabel = widget.unselectedLabelColor ?? kinTheme.onSurfaceVariant;

    final barBlur = widget.embedded ? 0.0 : widget.barBlurSigma;
    final barColor = widget.embedded ? Colors.transparent : isDark
        ? kinTheme.surfaceVariant.withValues(alpha: 0.65)
        : kinTheme.surfaceVariant.withValues(alpha: 0.78);
    final barBorder = Border.all(
      color: kinTheme.outline.withValues(alpha: 0.72),
      width: 0.5,
    );
    final barShadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ];
    final pillBlurSigma = isDark
        ? widget.selectorBlurSigma
        : widget.selectorBlurSigma * 0.6;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final slotW = _slotWidth(barWidth);
        final pillRest = _pillRestWidth(slotW) * (widget.embedded ? .84 : 1);
        final pillH = widget.height - 10;
        final pillR = widget.embedded ? 14.0 : pillH / 2;

        return AnimatedBuilder(
          animation: Listenable.merge([_pillController, _bounceAnim]),
          builder: (context, _) {
            final pos = _pillPos;

            // Pill stretches wider as the spring progresses
            final springT = _pillController.value.clamp(0.0, 1.0);
            final stretchFactor = 1.0 + 0.12 * (1.0 - (2 * springT - 1).abs());
            final pillW = pillRest * stretchFactor;

            // Calculate pill left based on dynamic slot widths
            final pillLeft = _hPad + pos * slotW + (slotW - pillW) / 2;
            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: barBlur, sigmaY: barBlur),
                child: Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: widget.embedded ? null : barBorder,
                    boxShadow: widget.embedded ? null : barShadow,
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // ── Sliding glass pill ──
                      Positioned(
                        left: pillLeft,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(pillR),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: pillBlurSigma,
                              sigmaY: pillBlurSigma,
                            ),
                            child: Container(
                              width: pillW,
                              height: pillH,
                              decoration: BoxDecoration(
                                color: kinTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(pillR),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Tab icons row ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: _hPad),
                        child: Row(
                          children: List.generate(_icons.length, (i) {
                            final isSelected = i == _selectedIndex;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _onTap(i),
                                behavior: HitTestBehavior.opaque,
                                child: Transform.scale(
                                  scale: i == _bouncingIndex
                                      ? _bounceAnim.value
                                      : 1.0,
                                  child: SizedBox(
                                    height: widget.height,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TweenAnimationBuilder<Color?>(
                                          tween: ColorTween(
                                            end: isSelected
                                                ? selIcon
                                                : unselIcon,
                                          ),
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: KinMotion.fluidEnter,
                                          builder: (context, color, _) {
                                            return IconTheme(
                                              data: IconThemeData(
                                                size: widget.iconSize,
                                                color: color,
                                              ),
                                              child: _icons[i],
                                            );
                                          },
                                        ),
                                        if (widget.labels != null &&
                                            i < widget.labels!.length) ...[
                                          const SizedBox(height: 1),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: KinMotion.fluidEnter,
                                            style:
                                                widget.labelStyle ??
                                                TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected
                                                      ? selLabel
                                                      : unselLabel,
                                                ),
                                            child: Text(
                                              widget.labels![i],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

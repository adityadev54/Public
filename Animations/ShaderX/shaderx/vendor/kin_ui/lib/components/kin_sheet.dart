import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../core/kin_theme.dart';
import '../core/kin_material.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';

/// Detent presets for KinSheet — mirrors iOS 18 sheet presentation API.
enum KinSheetDetent {
  /// ~25% of screen height
  small,
  /// ~50% of screen height
  medium,
  /// ~92% of screen height
  large,
}

/// A custom detent defined by a fractional height (0.0 – 1.0).
class KinSheetCustomDetent {
  final double fraction;
  const KinSheetCustomDetent(this.fraction)
      : assert(fraction > 0.0 && fraction <= 1.0);
}

/// iOS 18-style draggable bottom sheet with fluid spring physics.
///
/// Features:
/// - Multi-stop detents (medium ↔ large) with spring snapping
/// - Background scale-down + corner radius (iOS modal stack)
/// - Spring-driven drag dismiss with velocity-sensitive threshold
/// - Rubber-band resistance at boundaries
/// - Rounded grab handle with subtle backdrop blur
class KinSheet extends StatelessWidget {
  final Widget child;
  final bool showHandle;
  final bool showClose;
  final EdgeInsetsGeometry? padding;
  final KinMaterial? material;

  const KinSheet({
    super.key,
    required this.child,
    this.showHandle = true,
    this.showClose = true,
    this.padding,
    this.material,
  });

  /// Show the sheet with iOS 18-style presentation.
  ///
  /// [detents] — Which stops the sheet can rest at. Defaults to `[large]`.
  /// When both medium and large are provided, the sheet starts at medium
  /// and can be dragged up to large.
  ///
  /// [initialDetent] — Which detent to start at. Defaults to the smallest.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool showHandle = true,
    bool showClose = true,
    bool isDismissible = true,
    bool enableDrag = true,
    EdgeInsetsGeometry? padding,
    List<KinSheetDetent> detents = const [KinSheetDetent.large],
    KinSheetDetent? initialDetent,
    List<KinSheetCustomDetent>? customDetents,
    KinMaterial? material,
  }) {
    return Navigator.of(context).push<T>(
      _KinSheetModalRoute<T>(
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        detents: detents,
        initialDetent: initialDetent ?? detents.first,
        customDetents: customDetents,
        child: KinSheet(
          showHandle: showHandle,
          showClose: showClose,
          padding: padding,
          material: material,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = KinTheme.of(context);

    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.82)
        : theme.surfaceVariant;
    final handleColor = theme.onSurfaceVariant.withValues(alpha: 0.35);

    final sheetRadius = const BorderRadius.vertical(
      top: Radius.circular(KinRadius.xl),
    );

    final viewInsets = MediaQuery.viewInsetsOf(context);
    final safePadding = MediaQuery.paddingOf(context);

    final resolvedPadding = padding ?? EdgeInsets.only(
      left: KinSpacing.md,
      right: KinSpacing.md,
      top: showHandle ? KinSpacing.xs : KinSpacing.md,
      bottom: viewInsets.bottom + safePadding.bottom,
    );

    final decoration = BoxDecoration(
      color: bgColor,
      borderRadius: sheetRadius,
      boxShadow: isDark
          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16)]
          : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -2))],
    );

    Widget body = ClipRect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: KinRadius.pillAll,
                    ),
                  ),
                ),
                if (showClose)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.onSurfaceVariant.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
            const SizedBox(height: KinSpacing.sm),
          ] else if (showClose) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.onSurfaceVariant.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: theme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: KinSpacing.sm),
          ],
          Flexible(child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, 0.04, 0.96, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: child,
            ),
          )),
        ],
      ),
    );

    // If a material is provided, use KinMaterialSurface
    final mat = material;
    if (mat != null && mat.type != KinMaterialType.opaque) {
      return ClipRRect(
        borderRadius: sheetRadius,
        child: KinMaterialSurface(
          material: mat,
          backgroundColor: bgColor,
          borderRadius: sheetRadius,
          boxShadow: decoration.boxShadow,
          child: Padding(padding: resolvedPadding, child: body),
        ),
      );
    }

    return ClipRRect(
      borderRadius: sheetRadius,
      child: isDark
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: DecoratedBox(
                decoration: decoration,
                child: Padding(padding: resolvedPadding, child: body),
              ),
            )
          : DecoratedBox(
              decoration: decoration,
              child: Padding(padding: resolvedPadding, child: body),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Route
// ---------------------------------------------------------------------------

class _KinSheetModalRoute<T> extends PopupRoute<T> {
  final Widget child;
  final bool isDismissible;
  final bool enableDrag;
  final List<KinSheetDetent> detents;
  final KinSheetDetent initialDetent;
  final List<KinSheetCustomDetent>? customDetents;

  _KinSheetModalRoute({
    required this.child,
    required this.isDismissible,
    required this.enableDrag,
    required this.detents,
    required this.initialDetent,
    this.customDetents,
  });

  @override
  Color? get barrierColor => const Color(0x88000000);

  @override
  bool get barrierDismissible => isDismissible;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 380);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _KinSheetScaffold(
      animation: animation,
      enableDrag: enableDrag,
      detents: detents,
      initialDetent: initialDetent,
      customDetents: customDetents,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Scaffold — handles background scale + sheet positioning
// ---------------------------------------------------------------------------

double _detentFraction(KinSheetDetent d) => switch (d) {
  KinSheetDetent.small => 0.25,
  KinSheetDetent.medium => 0.50,
  KinSheetDetent.large => 0.92,
};

class _KinSheetScaffold extends StatefulWidget {
  final Animation<double> animation;
  final bool enableDrag;
  final List<KinSheetDetent> detents;
  final KinSheetDetent initialDetent;
  final List<KinSheetCustomDetent>? customDetents;
  final Widget child;

  const _KinSheetScaffold({
    required this.animation,
    required this.enableDrag,
    required this.detents,
    required this.initialDetent,
    this.customDetents,
    required this.child,
  });

  @override
  State<_KinSheetScaffold> createState() => _KinSheetScaffoldState();
}

class _KinSheetScaffoldState extends State<_KinSheetScaffold>
    with SingleTickerProviderStateMixin {

  /// Current sheet height as fraction of screen (0 = hidden, 1 = full screen).
  late double _heightFraction;
  late double _targetFraction;
  late AnimationController _springCtrl;

  // Sorted detent fractions for snapping
  late List<double> _stops;
  bool _entryComplete = false;

  @override
  void initState() {
    super.initState();
    _stops = [
      ...widget.detents.map(_detentFraction),
      if (widget.customDetents != null)
        ...widget.customDetents!.map((d) => d.fraction),
    ]..sort();
    _targetFraction = _detentFraction(widget.initialDetent);
    _heightFraction = 0; // will animate in via entry animation
    _springCtrl = AnimationController.unbounded(vsync: this);

    // When entry animation completes, sync _heightFraction to target
    widget.animation.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_entryComplete) {
      _entryComplete = true;
      setState(() => _heightFraction = _targetFraction);
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_onAnimationStatus);
    _springCtrl.dispose();
    super.dispose();
  }

  // --- Drag handling ---

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enableDrag) return;
    final screenH = MediaQuery.sizeOf(context).height;
    final deltaFrac = -details.primaryDelta! / screenH; // negative = up = bigger
    setState(() {
      final next = _heightFraction + deltaFrac;
      final maxStop = _stops.last;
      if (next > maxStop) {
        // Rubber-band above largest detent
        _heightFraction += deltaFrac * 0.25;
      } else if (next < 0) {
        _heightFraction += deltaFrac * 0.25;
      } else {
        _heightFraction = next;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enableDrag) return;
    final screenH = MediaQuery.sizeOf(context).height;
    final velocity = -(details.primaryVelocity ?? 0) / screenH; // positive = expanding

    // Fast downward flick → dismiss
    if (velocity < -1.0 || (_heightFraction < _stops.first * 0.6 && velocity < 0)) {
      _animateDismiss(velocity);
      return;
    }

    // Dragged well below the smallest stop → dismiss
    if (_heightFraction < _stops.first * 0.35) {
      _animateDismiss(velocity);
      return;
    }

    // Fast upward flick → snap to next stop up
    // Slow release → snap to nearest stop
    double target;
    if (velocity > 1.2 && _stops.length > 1) {
      target = _stops.last;
    } else if (velocity < -0.8 && _stops.length > 1) {
      target = _stops.first;
    } else {
      target = _nearestStop(_heightFraction);
    }

    _animateTo(target, velocity);
  }

  double _nearestStop(double frac) {
    double best = _stops.first;
    double bestDist = (frac - best).abs();
    for (final s in _stops) {
      final d = (frac - s).abs();
      if (d < bestDist) {
        bestDist = d;
        best = s;
      }
    }
    return best;
  }

  void _animateDismiss([double velocity = 0]) {
    _springCtrl.value = _heightFraction;
    _springCtrl.animateWith(SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 300, damping: 28),
      _heightFraction,
      0,
      velocity,
    ));
    _springCtrl.addListener(_dismissTick);
  }

  void _dismissTick() {
    if (!mounted) return;
    setState(() => _heightFraction = _springCtrl.value.clamp(0.0, 1.0));
    if (_springCtrl.value <= 0.01 || _springCtrl.isCompleted) {
      _springCtrl.removeListener(_dismissTick);
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _animateTo(double target, [double velocity = 0]) {
    _targetFraction = target;
    _springCtrl.value = _heightFraction;
    _springCtrl.animateWith(SpringSimulation(
      KinMotion.fluidSnap,
      _heightFraction,
      target,
      velocity,
    ));
    _springCtrl.addListener(_springTick);
  }

  void _springTick() {
    if (!mounted) return;
    setState(() => _heightFraction = _springCtrl.value);
    if (_springCtrl.isCompleted) _springCtrl.removeListener(_springTick);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final screenW = MediaQuery.sizeOf(context).width;
    final topPad = MediaQuery.paddingOf(context).top;
    final isLandscape = screenW > screenH;

    // Usable height: below status bar / dynamic island
    final usableH = screenH - topPad - 12;

    // In landscape, use larger fractions so content is usable
    final landscapeBoost = isLandscape ? 0.15 : 0.0;

    // Entry animation drives the initial slide-up
    final entryT = KinMotion.fluidEnter.transform(
      widget.animation.value.clamp(0.0, 1.0),
    );

    // Effective height fraction: entry animation lerps from 0 → target,
    // reverse animation lerps current → 0
    final double effectiveFrac;
    if (widget.animation.isCompleted) {
      effectiveFrac = _heightFraction;
    } else if (widget.animation.isDismissed) {
      effectiveFrac = 0;
    } else if (widget.animation.status == AnimationStatus.reverse) {
      effectiveFrac = lerpDouble(0, _heightFraction, widget.animation.value)!;
    } else {
      effectiveFrac = lerpDouble(0, _targetFraction, entryT)!;
    }

    // Sheet height relative to usable space (not full screen)
    final sheetH = ((effectiveFrac + landscapeBoost) * usableH).clamp(0.0, usableH);

    // Background scale: 1.0 → 0.92 as sheet opens to large
    final bgScale = lerpDouble(1.0, 0.92, (effectiveFrac / 0.92).clamp(0.0, 1.0))!;
    final bgRadius = lerpDouble(0, 12, (effectiveFrac / 0.92).clamp(0.0, 1.0))!;

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) {
        return Stack(
          children: [
            // Background scale-down effect (iOS modal stack)
            Positioned.fill(
              child: Transform.scale(
                scale: bgScale,
                alignment: Alignment.topCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(bgRadius),
                  child: ColoredBox(color: Colors.transparent),
                ),
              ),
            ),

            // Sheet — edge-to-edge, touching bezels
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: sheetH,
              child: GestureDetector(
                onVerticalDragStart: (_) {},
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: Material(
                  color: Colors.transparent,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ─ KIN PAGE TRANSITION ─
// One transition system: spring bounciness × morphing × elastic physics.
// ═══════════════════════════════════════════════════════════════════════════════

/// Where the incoming page originates from.
enum KinTransitionOrigin {
  /// Slides from the right edge (standard forward navigation).
  right,

  /// Slides from the left edge (backward navigation).
  left,

  /// Slides up from the bottom (modal / sheet style).
  bottom,

  /// Zooms in from the center (spotlight / focus transition).
  center,
}

/// A physics-based page route that combines morphing scale, spring bounce,
/// and elastic motion into a single premium transition.
///
/// ```dart
/// Navigator.of(context).push(
///   KinPageRoute(page: const DetailScreen()),
/// );
///
/// // or via extension
/// context.kinNavigator.kinPush(
///   page: const DetailScreen(),
///   origin: KinTransitionOrigin.center,
/// );
/// ```
class KinPageRoute<T> extends PageRoute<T> {
  /// The destination page widget.
  final Widget page;

  /// Entry origin — controls slide direction and perspective tilt.
  final KinTransitionOrigin origin;

  /// Spring stiffness (300–800). Higher = snappier bounce.
  final double stiffness;

  /// Spring damping (15–50). Lower = more visible bounce.
  final double damping;

  final Duration _duration;

  KinPageRoute({
    required this.page,
    this.origin = KinTransitionOrigin.right,
    this.stiffness = 500.0,
    this.damping = 28.0,
    Duration duration = const Duration(milliseconds: 550),
  }) : _duration = duration;

  @override
  Duration get transitionDuration => _duration;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      page;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _KinTransitionWidget(
      animation: animation,
      origin: origin,
      stiffness: stiffness,
      damping: damping,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The actual transition composition.
// ─────────────────────────────────────────────────────────────────────────────

class _KinTransitionWidget extends StatelessWidget {
  final Animation<double> animation;
  final KinTransitionOrigin origin;
  final double stiffness;
  final double damping;
  final Widget child;

  const _KinTransitionWidget({
    required this.animation,
    required this.origin,
    required this.stiffness,
    required this.damping,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // ── Spring curve: real bounce ──
    final spring = _SpringCurve(stiffness: stiffness, damping: damping);

    final curved = CurvedAnimation(parent: animation, curve: spring);

    // ── Slide offset (only for directional origins) ──
    final Offset slideBegin = switch (origin) {
      KinTransitionOrigin.right => const Offset(1.0, 0.0),
      KinTransitionOrigin.left => const Offset(-1.0, 0.0),
      KinTransitionOrigin.bottom => const Offset(0.0, 0.6),
      KinTransitionOrigin.center => Offset.zero,
    };

    final slideOffset =
        Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(curved);

    // ── Morphing scale (center origin starts smaller) ──
    final double scaleBegin = switch (origin) {
      KinTransitionOrigin.center => 0.75,
      KinTransitionOrigin.bottom => 0.92,
      _ => 0.94,
    };
    final scale =
        Tween<double>(begin: scaleBegin, end: 1.0).animate(curved);

    // ── Fast fade-in (quick so spring bounce is visible on opaque page) ──
    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    // ── Subtle perspective rotation (directional origins only) ──
    final double rotBegin = switch (origin) {
      KinTransitionOrigin.right => 0.015,
      KinTransitionOrigin.left => -0.015,
      KinTransitionOrigin.bottom => 0.0,
      KinTransitionOrigin.center => 0.0,
    };

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = curved.value;
        final rotAngle = rotBegin * (1.0 - t);

        Widget result = child;

        // Apply perspective rotation when there is one
        if (rotBegin != 0.0) {
          result = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0008)
              ..rotateY(rotAngle),
            child: result,
          );
        }

        return FadeTransition(
          opacity: fade,
          child: Transform.translate(
            offset: Offset(
              slideOffset.value.dx * MediaQuery.sizeOf(context).width,
              slideOffset.value.dy * MediaQuery.sizeOf(context).height,
            ),
            child: Transform.scale(
              scale: scale.value,
              child: result,
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─ SPRING CURVE ─
// ═══════════════════════════════════════════════════════════════════════════════

/// Real spring physics curve with configurable stiffness and damping.
/// Produces natural overshoot/bounce when underdamped.
class _SpringCurve extends Curve {
  final double stiffness;
  final double damping;

  const _SpringCurve({required this.stiffness, required this.damping});

  @override
  double transformInternal(double t) {
    // mass fixed at 1.0 — stiffness & damping are the user-facing knobs.
    final omega = math.sqrt(stiffness);
    final zeta = damping / (2 * omega); // damping ratio

    if (zeta >= 1.0) {
      // Critically/over-damped — smooth approach, no oscillation.
      return 1.0 - math.exp(-omega * t) * (1 + omega * t);
    }

    // Under-damped — bouncy.
    final omegaD = omega * math.sqrt(1 - zeta * zeta);
    final decay = math.exp(-zeta * omega * t);
    final osc =
        math.cos(omegaD * t) + (zeta / math.sqrt(1 - zeta * zeta)) * math.sin(omegaD * t);

    return 1.0 - decay * osc;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─ NAVIGATION EXTENSIONS ─
// ═══════════════════════════════════════════════════════════════════════════════

extension KinTransitionNavigation on NavigatorState {
  /// Push a page with KinUI's unified physics transition.
  Future<T?> kinPush<T>({
    required Widget page,
    KinTransitionOrigin origin = KinTransitionOrigin.right,
    double stiffness = 500.0,
    double damping = 28.0,
    Duration duration = const Duration(milliseconds: 550),
  }) {
    return push<T>(
      KinPageRoute<T>(
        page: page,
        origin: origin,
        stiffness: stiffness,
        damping: damping,
        duration: duration,
      ),
    );
  }
}

extension KinBuildContextTransitionNavigation on BuildContext {
  NavigatorState get kinNavigator => Navigator.of(this);
}

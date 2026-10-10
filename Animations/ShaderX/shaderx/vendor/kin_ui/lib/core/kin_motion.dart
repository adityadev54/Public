import 'package:flutter/widgets.dart';

/// Animation durations, curves, and spring constants used across Kin widgets.
abstract final class KinMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration emphasized = Duration(milliseconds: 420);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  static final SpringDescription spring = SpringDescription(
    mass: 1.0,
    stiffness: 400.0,
    damping: 30.0,
  );

  static const double pressScale = 0.97;

  // ── fluid spring curves ──

  /// Snappy interactive spring — used for tab switches, search focus.
  static final SpringDescription fluidSnap = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 22.0,
  );

  /// Bouncy spring — used for carousel transitions, item reveals.
  static final SpringDescription fluidBounce = SpringDescription(
    mass: 1.0,
    stiffness: 220.0,
    damping: 18.0,
  );

  /// Gentle spring — used for subtle morphing and layout changes.
  static final SpringDescription fluidGentle = SpringDescription(
    mass: 1.0,
    stiffness: 170.0,
    damping: 20.0,
  );

  /// Fluid curve: overshoots slightly then settles.
  static const Curve fluidEnter = _FluidCurve(0.25, 1.05);

  /// Fast settle curve for interactive dismissals.
  static const Curve fluidExit = Curves.easeOutExpo;

  /// Slightly weightier curve for layered, depth-forward transitions.
  static const Curve depthEnter = Cubic(0.22, 1.0, 0.36, 1.0);

  /// Smooth exit for floating chrome.
  static const Curve depthExit = Cubic(0.4, 0.0, 0.2, 1.0);

  /// Spring used for elements that lift and settle in place.
  static final SpringDescription fluidDepth = SpringDescription(
    mass: 1.0,
    stiffness: 190.0,
    damping: 18.0,
  );
}

/// Custom curve that overshoots by [overshoot] for fluid feel.
class _FluidCurve extends Curve {
  final double tension;
  final double overshoot;

  const _FluidCurve(this.tension, this.overshoot);

  @override
  double transformInternal(double t) {
    // Spring-inspired overshoot curve
    final p = 1.0 - t;
    return 1.0 - p * p * ((overshoot + 1) * p - overshoot);
  }
}

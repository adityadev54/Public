import 'package:flutter/material.dart';

/// Accessibility filters for [KinAccessibility].
enum KinAccessibilityFilter {
  /// No filter applied.
  none,

  /// Full greyscale.
  greyscale,

  /// High contrast — boosts saturation + contrast.
  highContrast,

  /// Reduced motion — disables all animations subtree-wide.
  reducedMotion,

  /// Inverted colors.
  inverted,

  /// Deuteranopia simulation (red-green deficiency).
  deuteranopia,

  /// Protanopia simulation (red deficiency).
  protanopia,

  /// Tritanopia simulation (blue-yellow deficiency).
  tritanopia,

  /// Large text — scales text up by 1.3×.
  largeText,
}

/// Wraps a subtree with accessibility enhancements.
///
/// Supports greyscale, high contrast, inverted colors,
/// color-blindness simulations, and reduced motion.
/// Can be nested at any level — typically placed near the root.
class KinAccessibility extends StatelessWidget {
  final Widget child;
  final KinAccessibilityFilter filter;
  final double textScaleFactor;
  final bool boldText;
  final bool semanticLabels;

  const KinAccessibility({
    super.key,
    required this.child,
    this.filter = KinAccessibilityFilter.none,
    this.textScaleFactor = 1.0,
    this.boldText = false,
    this.semanticLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    // Apply color matrix filter
    final matrix = _matrixForFilter(filter);
    if (matrix != null) {
      result = ColorFiltered(
        colorFilter: ColorFilter.matrix(matrix),
        child: result,
      );
    }

    // Apply bold text
    if (boldText) {
      result = DefaultTextStyle.merge(
        style: const TextStyle(fontWeight: FontWeight.w700),
        child: result,
      );
    }

    // Apply text scaling
    if (textScaleFactor != 1.0 || filter == KinAccessibilityFilter.largeText) {
      final scale = filter == KinAccessibilityFilter.largeText
          ? (textScaleFactor != 1.0 ? textScaleFactor : 1.3)
          : textScaleFactor;
      result = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
        ),
        child: result,
      );
    }

    // Disable animations for reduced motion
    if (filter == KinAccessibilityFilter.reducedMotion) {
      result = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: true,
        ),
        child: result,
      );
    }

    return result;
  }

  static List<double>? _matrixForFilter(KinAccessibilityFilter filter) {
    return switch (filter) {
      KinAccessibilityFilter.none => null,
      KinAccessibilityFilter.reducedMotion => null,
      KinAccessibilityFilter.greyscale => <double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ],
      KinAccessibilityFilter.highContrast => <double>[
          1.5, -0.25, -0.25, 0, 0,
          -0.25, 1.5, -0.25, 0, 0,
          -0.25, -0.25, 1.5, 0, 0,
          0, 0, 0, 1, 0,
        ],
      KinAccessibilityFilter.inverted => <double>[
          -1, 0, 0, 0, 255,
          0, -1, 0, 0, 255,
          0, 0, -1, 0, 255,
          0, 0, 0, 1, 0,
        ],
      KinAccessibilityFilter.deuteranopia => <double>[
          0.625, 0.375, 0, 0, 0,
          0.7, 0.3, 0, 0, 0,
          0, 0.3, 0.7, 0, 0,
          0, 0, 0, 1, 0,
        ],
      KinAccessibilityFilter.protanopia => <double>[
          0.567, 0.433, 0, 0, 0,
          0.558, 0.442, 0, 0, 0,
          0, 0.242, 0.758, 0, 0,
          0, 0, 0, 1, 0,
        ],
      KinAccessibilityFilter.tritanopia => <double>[
          0.95, 0.05, 0, 0, 0,
          0, 0.433, 0.567, 0, 0,
          0, 0.475, 0.525, 0, 0,
          0, 0, 0, 1, 0,
        ],
      KinAccessibilityFilter.largeText => null,
    };
  }
}

/// Provides the current [KinAccessibilityFilter] to descendants.
///
/// Wrap your app or a subtree to allow child widgets to react to
/// the active accessibility mode.
class KinAccessibilityScope extends InheritedWidget {
  final KinAccessibilityFilter filter;
  final double textScaleFactor;
  final bool boldText;

  const KinAccessibilityScope({
    super.key,
    required super.child,
    this.filter = KinAccessibilityFilter.none,
    this.textScaleFactor = 1.0,
    this.boldText = false,
  });

  static KinAccessibilityScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<KinAccessibilityScope>();
  }

  static KinAccessibilityFilter filterOf(BuildContext context) {
    return maybeOf(context)?.filter ?? KinAccessibilityFilter.none;
  }

  @override
  bool updateShouldNotify(KinAccessibilityScope old) =>
      filter != old.filter ||
      textScaleFactor != old.textScaleFactor ||
      boldText != old.boldText;
}

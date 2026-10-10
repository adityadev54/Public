import 'dart:ui';
import 'package:flutter/material.dart';
import 'kin_theme.dart';

/// Apple-style material appearance for surfaces.
///
/// - [opaque] — Default solid background (current behaviour).
/// - [glass]  — Frosted-glass / vibrancy (backdrop blur + translucent fill).
/// - [tinted] — Semi-transparent surface tinted with primary or custom color.
enum KinMaterialType { opaque, glass, tinted }

/// Thickness presets for glass material — mirrors Apple's SwiftUI materials.
enum KinGlassThickness {
  /// Very subtle blur, highly transparent.
  ultraThin,
  /// Light frosted glass.
  thin,
  /// Standard frosted glass (default).
  regular,
  /// Heavy frosted glass, less transparency.
  thick,
  /// Nearly opaque frosted surface.
  ultraThick,
}

/// Configuration for [KinMaterialType.glass] and [KinMaterialType.tinted].
class KinMaterial {
  /// The material appearance type.
  final KinMaterialType type;

  /// Glass thickness — only used when [type] is [KinMaterialType.glass].
  final KinGlassThickness thickness;

  /// Tint color — only used when [type] is [KinMaterialType.tinted].
  /// Defaults to the theme's primary color.
  final Color? tintColor;

  /// Tint opacity (0.0 – 1.0) for tinted surfaces.
  final double tintOpacity;

  const KinMaterial.opaque()
      : type = KinMaterialType.opaque,
        thickness = KinGlassThickness.regular,
        tintColor = null,
        tintOpacity = 0.0;

  const KinMaterial.glass({
    this.thickness = KinGlassThickness.regular,
  })  : type = KinMaterialType.glass,
        tintColor = null,
        tintOpacity = 0.0;

  const KinMaterial.tinted({
    this.tintColor,
    this.tintOpacity = 0.12,
  })  : type = KinMaterialType.tinted,
        thickness = KinGlassThickness.regular;

  /// Default opaque material.
  static const defaultMaterial = KinMaterial.opaque();

  // ── Glass parameters ──

  /// Blur sigma for the given thickness.
  double get blurSigma => switch (thickness) {
        KinGlassThickness.ultraThin => 4.0,
        KinGlassThickness.thin => 10.0,
        KinGlassThickness.regular => 20.0,
        KinGlassThickness.thick => 30.0,
        KinGlassThickness.ultraThick => 40.0,
      };

  /// Fill opacity for the glass surface (dark mode).
  double get glassFillOpacityDark => switch (thickness) {
        KinGlassThickness.ultraThin => 0.15,
        KinGlassThickness.thin => 0.25,
        KinGlassThickness.regular => 0.35,
        KinGlassThickness.thick => 0.50,
        KinGlassThickness.ultraThick => 0.65,
      };

  /// Fill opacity for the glass surface (light mode).
  double get glassFillOpacityLight => switch (thickness) {
        KinGlassThickness.ultraThin => 0.30,
        KinGlassThickness.thin => 0.45,
        KinGlassThickness.regular => 0.55,
        KinGlassThickness.thick => 0.70,
        KinGlassThickness.ultraThick => 0.82,
      };

  /// Border opacity for the glass edge highlight.
  double get glassBorderOpacity => switch (thickness) {
        KinGlassThickness.ultraThin => 0.08,
        KinGlassThickness.thin => 0.10,
        KinGlassThickness.regular => 0.12,
        KinGlassThickness.thick => 0.14,
        KinGlassThickness.ultraThick => 0.16,
      };
}

/// Wraps a child widget with the appropriate material treatment.
///
/// Use this inside any component that needs glass/tinted support.
class KinMaterialSurface extends StatelessWidget {
  final Widget child;
  final KinMaterial material;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const KinMaterialSurface({
    super.key,
    required this.child,
    required this.material,
    required this.backgroundColor,
    required this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = KinTheme.of(context);

    switch (material.type) {
      case KinMaterialType.opaque:
        return DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: border,
            boxShadow: boxShadow,
          ),
          child: child,
        );

      case KinMaterialType.glass:
        final fillOpacity = isDark
            ? material.glassFillOpacityDark
            : material.glassFillOpacityLight;
        final sigma = material.blurSigma;
        final edgeBorder = border ??
            Border.all(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: material.glassBorderOpacity),
            );

        return ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: fillOpacity),
                borderRadius: borderRadius,
                border: edgeBorder,
                boxShadow: boxShadow,
              ),
              child: child,
            ),
          ),
        );

      case KinMaterialType.tinted:
        final tint = material.tintColor ?? theme.primary;
        final tintedBg = Color.lerp(
          backgroundColor,
          tint,
          material.tintOpacity,
        )!;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: tintedBg,
            borderRadius: borderRadius,
            border: border,
            boxShadow: boxShadow,
          ),
          child: child,
        );
    }
  }
}

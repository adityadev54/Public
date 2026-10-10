import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_material.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';

/// Background variants for [KinSurface].
enum SurfaceVariant { page, card, elevated }

/// Themed container that reads [KinTheme] and supports glass/tinted materials.
class KinSurface extends StatelessWidget {
  final Widget child;
  final SurfaceVariant variant;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final bool frosted;
  final KinMaterial? material;

  const KinSurface({
    super.key,
    required this.child,
    this.variant = SurfaceVariant.card,
    this.borderRadius,
    this.padding,
    this.border,
    this.frosted = false,
    this.material,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? KinRadius.lgAll;

    final Color bgColor;
    final BoxBorder? resolvedBorder;
    final List<BoxShadow>? shadow;

    switch (variant) {
      case SurfaceVariant.page:
        bgColor = theme.surface;
        resolvedBorder = border;
        shadow = null;
      case SurfaceVariant.card:
        bgColor = theme.surfaceVariant;
        resolvedBorder = border;
        shadow = isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ];
      case SurfaceVariant.elevated:
        bgColor = theme.surfaceVariant;
        resolvedBorder = border;
        shadow = isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ];
    }

    final decoration = BoxDecoration(
      color: bgColor,
      borderRadius: radius,
      border: resolvedBorder,
      boxShadow: shadow,
    );

    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(KinSpacing.md),
      child: child,
    );

    // Use KinMaterial system if provided
    final mat = material;
    if (mat != null && mat.type != KinMaterialType.opaque) {
      return KinMaterialSurface(
        material: mat,
        backgroundColor: bgColor,
        borderRadius: radius,
        border: resolvedBorder,
        boxShadow: shadow,
        child: content,
      );
    }

    if (frosted && isDark) {
      return ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: decoration,
            child: content,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: decoration,
      child: content,
    );
  }
}

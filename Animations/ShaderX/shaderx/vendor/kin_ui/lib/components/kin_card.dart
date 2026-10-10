import 'package:flutter/material.dart';
import 'kin_press.dart';
import 'kin_surface.dart';
import '../core/kin_theme.dart';
import '../core/kin_material.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';

/// Visual variants for [KinCard].
enum KinCardVariant { standard, elevated, outlined }

/// Themed container with optional tap, long-press, and card variant.
class KinCard extends StatelessWidget {
  final BoxBorder? border;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final KinCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final KinMaterial? material;

  const KinCard({
    super.key,
    required this.child,
    this.border,
    this.onTap,
    this.onLongPress,
    this.variant = KinCardVariant.standard,
    this.padding,
    this.borderRadius,
    this.heroTag,
    this.material,
  });

  @override
  Widget build(BuildContext context) {
    final SurfaceVariant surfaceVariant = switch (variant) {
      KinCardVariant.standard => SurfaceVariant.card,
      KinCardVariant.elevated => SurfaceVariant.elevated,
      KinCardVariant.outlined => SurfaceVariant.card,
    };

    final card = KinSurface(
      variant: surfaceVariant,
      borderRadius: borderRadius ?? KinRadius.lgAll,
      padding: padding ?? const EdgeInsets.all(KinSpacing.md),
      material: material,
      border: border,
      child: child,
    );

    final resolvedRadius = borderRadius ?? KinRadius.lgAll;

    if (onTap != null || onLongPress != null) {
      final theme = KinTheme.of(context);
      Widget tappable = KinPress(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ClipRRect(
          borderRadius: resolvedRadius,
          child: Stack(
            children: [
              card,
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: resolvedRadius,
                    splashColor: theme.onSurface.withValues(alpha: 0.06),
                    highlightColor: theme.onSurface.withValues(alpha: 0.04),
                    onTap: onTap,
                    onLongPress: onLongPress,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      if (heroTag != null) {
        tappable = Hero(tag: heroTag!, child: tappable);
      }
      return tappable;
    }

    final result = ClipRRect(
      borderRadius: resolvedRadius,
      child: card,
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: result);
    }
    return result;
  }
}

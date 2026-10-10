import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';
import 'kin_text.dart';

/// A themed divider — horizontal or vertical, with optional label.
class KinDivider extends StatelessWidget {
  /// Horizontal spacing above and below (horizontal) or left/right (vertical).
  final bool nativeAppearance;
  final double? height;
  final double spacing;
  final Axis direction;
  final double thickness;
  final double? indent;
  final double? endIndent;
  final String? label;
  final Color? color;

  const KinDivider({
    super.key,
    this.nativeAppearance = false,
    this.height,
    this.spacing = KinSpacing.md,
    this.direction = Axis.horizontal,
    this.thickness = 0.5,
    this.indent,
    this.endIndent,
    this.label,
    this.color,
  });

  const KinDivider.vertical({
    super.key,
    this.nativeAppearance = false,
    this.height,
    this.spacing = KinSpacing.sm,
    this.thickness = 0.5,
    this.indent,
    this.endIndent,
    this.color,
  }) : direction = Axis.vertical,
       label = null;

  @override
  Widget build(BuildContext context) {
    if (nativeAppearance)
      return Divider(
        height: height,
        color: color,
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
      );
    final theme = KinTheme.of(context);
    final lineColor = color ?? theme.outline.withValues(alpha: 0.3);

    if (direction == Axis.vertical) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing),
        child: Container(
          width: thickness,
          margin: EdgeInsets.only(top: indent ?? 0, bottom: endIndent ?? 0),
          color: lineColor,
        ),
      );
    }

    if (label != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: spacing),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: thickness,
                margin: EdgeInsets.only(left: indent ?? 0),
                color: lineColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KinSpacing.sm),
              child: KinText(
                label!,
                style: KinTypography.captionLarge,
                color: theme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: Container(
                height: thickness,
                margin: EdgeInsets.only(right: endIndent ?? 0),
                color: lineColor,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: Container(
        height: thickness,
        margin: EdgeInsets.only(left: indent ?? 0, right: endIndent ?? 0),
        color: lineColor,
      ),
    );
  }
}

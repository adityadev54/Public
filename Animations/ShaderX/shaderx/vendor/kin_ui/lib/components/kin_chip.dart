import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kin_press.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Small selectable pill with optional leading widget and haptic feedback.
///
/// Supply either [label] (string shorthand) or [child] (full widget control).
/// If both are provided, [child] takes precedence.
class KinChip extends StatelessWidget {
  final String? label;
  final Widget? child;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final Color? selectedColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const KinChip({
    super.key,
    this.label,
    this.child,
    this.isSelected = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.selectedColor,
    this.borderRadius,
    this.padding,
  }) : assert(label != null || child != null, 'Provide either label or child');

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    final Color bg;
    final Color fg;

    if (isSelected) {
      bg = (selectedColor ?? theme.primary).withValues(alpha: 0.12);
      fg = selectedColor ?? theme.primary;
    } else {
      bg = theme.onSurface.withValues(alpha: 0.06);
      fg = theme.onSurfaceVariant;
    }

    return KinPress(
      onTap: onTap != null
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      child: AnimatedContainer(
        duration: KinMotion.fast,
        curve: KinMotion.enter,
        padding:
            padding ??
            const EdgeInsets.symmetric(
              horizontal: KinSpacing.sm + 4,
              vertical: KinSpacing.xs + 2,
            ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: borderRadius ?? KinRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: KinSpacing.xs,
          children: [
            if (leading != null) leading!,
            if (child != null)
              child!
            else
              KinText(
                label!,
                style: KinTypography.labelLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                color: fg,
              ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

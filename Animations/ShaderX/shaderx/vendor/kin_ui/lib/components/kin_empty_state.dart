import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';
import 'kin_button.dart';

/// A full-area empty state placeholder with icon, title, subtitle, and optional action.
class KinEmptyState extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  const KinEmptyState({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final iconSize = compact ? 40.0 : 56.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KinSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null)
              iconWidget!
            else if (icon != null)
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: theme.onSurfaceVariant.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: iconSize * 0.5, color: theme.onSurfaceVariant),
              ),
            if (icon != null || iconWidget != null)
              SizedBox(height: compact ? KinSpacing.md : KinSpacing.lg),
            Text(
              title,
              style: (compact ? KinTypography.titleSmall : KinTypography.titleMedium).copyWith(
                color: theme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: KinSpacing.xs),
              Text(
                subtitle!,
                style: KinTypography.bodyMedium.copyWith(color: theme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: KinSpacing.lg),
              KinButton(
                label: actionLabel,
                onTap: onAction,
                size: compact ? KinButtonSize.small : KinButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

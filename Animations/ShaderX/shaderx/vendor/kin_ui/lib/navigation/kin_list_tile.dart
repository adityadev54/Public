import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/kin_press.dart';
import '../components/kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Visual density for [KinListTile].
enum KinListTileDensity { compact, standard, comfortable }

/// A themed list tile with ink-splash tap feedback, haptic, and iOS 18 styling.
///
/// Wraps content in [KinPress] (scale feedback) layered with [InkWell] (ripple).
class KinListTile extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final int? titleMaxLines;
  final int? subtitleMaxLines;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final bool showDivider;
  final KinListTileDensity density;

  const KinListTile({
    super.key,
    required this.title,
    this.titleStyle,
    this.subtitleStyle,
    this.titleMaxLines,
    this.subtitleMaxLines,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.showDivider = false,
    this.density = KinListTileDensity.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    final verticalPad = switch (density) {
      KinListTileDensity.compact => KinSpacing.xs + 2,
      KinListTileDensity.standard => KinSpacing.sm + 2,
      KinListTileDensity.comfortable => KinSpacing.md,
    };

    final content = Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: KinSpacing.md,
            vertical: verticalPad,
          ),
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(color: theme.onSurfaceVariant, size: 22),
              child: leading!,
            ),
            const SizedBox(width: KinSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                KinText(
                  title,
                  style: titleStyle ?? KinTypography.bodyLarge,
                  maxLines: titleMaxLines,
                  overflow: titleMaxLines == null
                      ? null
                      : TextOverflow.ellipsis,
                  color: theme.onSurface,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: KinText(
                      subtitle!,
                      style: subtitleStyle ?? KinTypography.bodyMedium,
                      maxLines: subtitleMaxLines,
                      overflow: subtitleMaxLines == null
                          ? null
                          : TextOverflow.ellipsis,
                      color: theme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: KinSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );

    final resolvedRadius = borderRadius ?? KinRadius.mdAll;
    final bg = backgroundColor ?? Colors.transparent;

    Widget tile;
    if (onTap != null || onLongPress != null) {
      tile = KinPress(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        child: Container(
          decoration: BoxDecoration(color: bg, borderRadius: resolvedRadius),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              content,
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: resolvedRadius,
                    splashColor: theme.onSurface.withValues(alpha: 0.06),
                    highlightColor: theme.onSurface.withValues(alpha: 0.04),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap?.call();
                    },
                    onLongPress: onLongPress,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      tile = Container(
        decoration: BoxDecoration(color: bg, borderRadius: resolvedRadius),
        child: content,
      );
    }

    if (showDivider) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile,
          Padding(
            padding: EdgeInsets.only(
              left: leading != null ? 54.0 : KinSpacing.md,
            ),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: theme.outline.withValues(alpha: 0.3),
            ),
          ),
        ],
      );
    }

    return tile;
  }
}

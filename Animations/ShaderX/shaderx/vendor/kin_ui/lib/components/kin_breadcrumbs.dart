import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// A single breadcrumb item.
class KinBreadcrumbItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const KinBreadcrumbItem({
    required this.label,
    this.icon,
    this.onTap,
  });
}

/// Horizontal breadcrumb navigation trail.
///
/// Displays a row of tappable path segments separated by chevrons.
/// The last item is always rendered as the active (non-tappable) item.
class KinBreadcrumbs extends StatelessWidget {
  final List<KinBreadcrumbItem> items;
  final IconData separator;
  final double separatorSize;

  const KinBreadcrumbs({
    super.key,
    required this.items,
    this.separator = Icons.chevron_right_rounded,
    this.separatorSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    if (items.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  separator,
                  size: separatorSize,
                  color: theme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            _BreadcrumbChip(
              item: items[i],
              isLast: i == items.length - 1,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

class _BreadcrumbChip extends StatefulWidget {
  final KinBreadcrumbItem item;
  final bool isLast;
  final KinTheme theme;

  const _BreadcrumbChip({
    required this.item,
    required this.isLast,
    required this.theme,
  });

  @override
  State<_BreadcrumbChip> createState() => _BreadcrumbChipState();
}

class _BreadcrumbChipState extends State<_BreadcrumbChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isTappable = !widget.isLast && widget.item.onTap != null;
    final color = widget.isLast
        ? widget.theme.onSurface
        : widget.theme.onSurfaceVariant;
    final fontWeight = widget.isLast ? FontWeight.w600 : FontWeight.w400;

    return GestureDetector(
      onTapDown: isTappable ? (_) => setState(() => _pressed = true) : null,
      onTapUp: isTappable
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.item.onTap!();
            }
          : null,
      onTapCancel: isTappable
          ? () => setState(() => _pressed = false)
          : null,
      child: AnimatedContainer(
        duration: KinMotion.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: KinSpacing.sm,
          vertical: KinSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _pressed
              ? widget.theme.onSurface.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.item.icon != null) ...[
              Icon(widget.item.icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              widget.item.label,
              style: KinTypography.bodySmall.copyWith(
                color: color,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

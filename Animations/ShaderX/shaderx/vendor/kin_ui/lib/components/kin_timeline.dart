import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Visual style for timeline items.
enum KinTimelineStyle { solid, dashed }

/// A single timeline entry.
class KinTimelineItem {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final IconData? icon;
  final Color? color;
  final bool isCompleted;

  const KinTimelineItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.icon,
    this.color,
    this.isCompleted = false,
  });
}

/// A vertical timeline component.
class KinTimeline extends StatelessWidget {
  final List<KinTimelineItem> items;
  final int activeIndex;
  final KinTimelineStyle style;

  const KinTimeline({
    super.key,
    required this.items,
    this.activeIndex = -1,
    this.style = KinTimelineStyle.solid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++)
          _TimelineEntry(
            item: items[i],
            isActive: i == activeIndex,
            isCompleted: items[i].isCompleted || i < activeIndex,
            isLast: i == items.length - 1,
            style: style,
            theme: theme,
          ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final KinTimelineItem item;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;
  final KinTimelineStyle style;
  final KinTheme theme;

  const _TimelineEntry({
    required this.item,
    required this.isActive,
    required this.isCompleted,
    required this.isLast,
    required this.style,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = item.color ??
        (isCompleted
            ? theme.primary
            : isActive
                ? theme.primary
                : theme.outline);

    final lineColor = isCompleted ? theme.primary : theme.outline;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? dotColor
                        : dotColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: dotColor.withValues(alpha: 0.3), width: 3)
                        : null,
                  ),
                  child: item.icon != null
                      ? Icon(item.icon, size: 12,
                          color: isCompleted || isActive ? Colors.white : dotColor)
                      : isCompleted
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: style == KinTimelineStyle.dashed ? 0 : 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: style == KinTimelineStyle.dashed
                          ? null
                          : BoxDecoration(color: lineColor),
                      child: style == KinTimelineStyle.dashed
                          ? CustomPaint(
                              painter: _DashedLinePainter(color: lineColor),
                              size: const Size(2, double.infinity),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: KinSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : KinSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: KinTypography.labelLarge.copyWith(
                      color: isActive ? theme.onSurface : theme.onSurfaceVariant,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: KinTypography.bodySmall.copyWith(color: theme.onSurfaceVariant),
                    ),
                  ],
                  if (item.leading != null) ...[
                    const SizedBox(height: KinSpacing.xs),
                    item.leading!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(1, startY), Offset(1, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => color != old.color;
}

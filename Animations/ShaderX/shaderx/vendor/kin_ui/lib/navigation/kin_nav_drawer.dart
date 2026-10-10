import 'package:flutter/material.dart';
import '../components/kin_press.dart';
import '../components/kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';
import 'kin_nav_rail.dart';

/// Full-height navigation drawer for expanded layouts.
class KinNavDrawer extends StatelessWidget {
  final List<KinNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? header;

  const KinNavDrawer({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    final bgColor = theme.surfaceVariant;
    final borderColor = theme.outline;

    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KinSpacing.lg, KinSpacing.xl, KinSpacing.lg, KinSpacing.md,
              ),
              child: KinText.titleLarge(header!),
            ),
          ] else
            const SizedBox(height: KinSpacing.xl),
          ...List.generate(items.length, (i) {
            final item = items[i];
            final isSelected = i == currentIndex;

            final tileBg = isSelected
                ? theme.primaryContainer
                : Colors.transparent;
            final fgColor = isSelected
                ? theme.primary
                : theme.onSurfaceVariant;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KinSpacing.sm,
                vertical: 2,
              ),
              child: KinPress(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: KinMotion.fast,
                  curve: KinMotion.enter,
                  padding: const EdgeInsets.symmetric(
                    horizontal: KinSpacing.md,
                    vertical: KinSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: KinRadius.smAll,
                    border: isSelected
                        ? Border.all(
                            color: theme.primary.withValues(alpha: 0.18),
                            width: 0.5,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                        size: 20,
                        color: fgColor,
                      ),
                      const SizedBox(width: KinSpacing.sm + 4),
                      KinText(
                        item.label,
                        style: KinTypography.bodyMedium,
                        color: fgColor,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';

/// Transient message shown at the bottom of the screen.
class KinToast {
  KinToast._();

  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    Widget? leading,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    final controller = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 500),
    );
    final slideAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
      reverseCurve: KinMotion.exit,
    );
    final fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      reverseCurve: KinMotion.exit,
    );

    entry = OverlayEntry(
      builder: (ctx) => _KinToastOverlay(
        message: message,
        leading: leading,
        slideAnimation: slideAnimation,
        fadeAnimation: fadeAnimation,
      ),
    );

    overlay.insert(entry);
    controller.forward();

    Future.delayed(duration, () {
      controller.reverse().then((_) {
        entry.remove();
        controller.dispose();
      });
    });
  }
}

class _KinToastOverlay extends StatelessWidget {
  final String message;
  final Widget? leading;
  final Animation<double> slideAnimation;
  final Animation<double> fadeAnimation;

  const _KinToastOverlay({
    required this.message,
    required this.leading,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = KinTheme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.85)
        : theme.surfaceVariant;
    final borderColor = theme.outline;

    return Positioned(
      left: KinSpacing.lg,
      right: KinSpacing.lg,
      bottom: bottom + 40,
      child: Material(
        type: MaterialType.transparency,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.6),
            end: Offset.zero,
          ).animate(slideAnimation),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ClipRRect(
              borderRadius: KinRadius.pillAll,
              child: BackdropFilter(
                filter: isDark
                    ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KinSpacing.md,
                    vertical: KinSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: KinRadius.pillAll,
                    border: Border.all(color: borderColor, width: 0.5),
                    boxShadow: isDark
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)]
                        : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: KinSpacing.sm,
                    children: [
                      ?leading,
                      Expanded(
                        child: KinText.bodyMedium(
                          message,
                          color: theme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

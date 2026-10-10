import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'kin_press.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Visual variants for [KinSnackbar].
enum KinSnackbarVariant {
  /// Neutral informational snackbar.
  standard,

  /// Success feedback.
  success,

  /// Warning / caution.
  warning,

  /// Error / destructive feedback.
  error,
}

/// A themed snackbar shown at the bottom of the screen.
///
/// Unlike [KinToast] which is transient and terse, [KinSnackbar] supports
/// an action button, multiple variants, and a dismiss gesture.
class KinSnackbar {
  KinSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    KinSnackbarVariant variant = KinSnackbarVariant.standard,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    Widget? leading,
    bool dismissible = true,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    final controller = AnimationController(
      vsync: overlay,
      duration: KinMotion.normal,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: KinMotion.enter,
      reverseCurve: KinMotion.exit,
    );

    void remove() {
      controller.reverse().then((_) {
        entry.remove();
        controller.dispose();
      });
    }

    entry = OverlayEntry(
      builder: (ctx) => _KinSnackbarOverlay(
        message: message,
        variant: variant,
        animation: animation,
        actionLabel: actionLabel,
        onAction: () {
          onAction?.call();
          remove();
        },
        leading: leading,
        onDismiss: dismissible ? remove : null,
      ),
    );

    overlay.insert(entry);
    controller.forward();

    Timer(duration, () {
      if (controller.isAnimating || controller.isCompleted) {
        remove();
      }
    });
  }
}

class _KinSnackbarOverlay extends StatelessWidget {
  final String message;
  final KinSnackbarVariant variant;
  final Animation<double> animation;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? leading;
  final VoidCallback? onDismiss;

  const _KinSnackbarOverlay({
    required this.message,
    required this.variant,
    required this.animation,
    this.actionLabel,
    this.onAction,
    this.leading,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = KinTheme.of(context);
    final safePadding = MediaQuery.paddingOf(context);

    final (Color accent, Widget? defaultIcon) = switch (variant) {
      KinSnackbarVariant.standard => (theme.primary, null),
      KinSnackbarVariant.success => (const Color(0xFF34C759), const Icon(Icons.check_circle_outline, size: 20)),
      KinSnackbarVariant.warning => (const Color(0xFFFFCC00), const Icon(Icons.warning_amber_rounded, size: 20)),
      KinSnackbarVariant.error => (theme.destructive, const Icon(Icons.error_outline, size: 20)),
    };

    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.88)
        : theme.surfaceVariant;

    final resolvedLeading = leading ?? defaultIcon;

    Widget snackbar = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KinSpacing.md,
        vertical: KinSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: KinRadius.pillAll,
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Row(
        spacing: KinSpacing.sm,
        children: [
          if (resolvedLeading != null)
            IconTheme(
              data: IconThemeData(color: accent, size: 20),
              child: resolvedLeading,
            ),
          Expanded(
            child: KinText.bodyMedium(
              message,
              color: theme.onSurface,
            ),
          ),
          if (actionLabel != null)
            KinPress(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: KinSpacing.xs),
                child: KinText(
                  actionLabel!,
                  style: KinTypography.labelLarge,
                  color: accent,
                ),
              ),
            ),
        ],
      ),
    );

    if (isDark) {
      snackbar = ClipRRect(
        borderRadius: KinRadius.pillAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: snackbar,
        ),
      );
    }

    if (onDismiss != null) {
      snackbar = Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.down,
        onDismissed: (_) => onDismiss!(),
        child: snackbar,
      );
    }

    return Positioned(
      left: KinSpacing.md,
      right: KinSpacing.md,
      bottom: safePadding.bottom + KinSpacing.lg,
      child: Material(
        type: MaterialType.transparency,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: snackbar,
          ),
        ),
      ),
    );
  }
}

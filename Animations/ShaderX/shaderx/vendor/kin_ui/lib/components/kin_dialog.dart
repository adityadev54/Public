import 'dart:ui';
import 'package:flutter/material.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import 'kin_button.dart';

/// Confirm / cancel dialog with iOS 18 fluid spring entry animation.
class KinDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  /// Use existing form/action content without duplicate dialog chrome.
  final bool contentOnly;

  const KinDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmLabel = 'OK',
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.contentOnly = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String confirmLabel = 'OK',
    String? cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x88000000),
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final raw = animation.value.clamp(0.0, 1.0);
            // Custom spring-like curve with slight overshoot
            final t = Curves.elasticOut.transform(raw).clamp(0.0, 1.15);
            final opacity = Curves.easeOut.transform(raw).clamp(0.0, 1.0);
            final slide = 0.10 * (1.0 - t);
            final scale = 0.88 + 0.12 * t;
            return Transform.translate(
              offset: Offset(0, slide * MediaQuery.sizeOf(context).height),
              child: Transform.scale(
                scale: scale.clamp(0.88, 1.02),
                alignment: Alignment.bottomCenter,
                child: Opacity(opacity: opacity, child: child),
              ),
            );
          },
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  left: KinSpacing.sm + MediaQuery.paddingOf(ctx).left,
                  right: KinSpacing.sm + MediaQuery.paddingOf(ctx).right,
                  bottom: KinSpacing.xs,
                ),
                child: KinDialog(
                  title: title,
                  message: message,
                  content: content,
                  confirmLabel: confirmLabel,
                  cancelLabel: cancelLabel,
                  onConfirm: () => Navigator.pop(ctx, true),
                  onCancel: () => Navigator.pop(ctx, false),
                  isDestructive: isDestructive,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = KinTheme.of(context);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.85)
        : theme.surfaceVariant;

    return ClipRRect(
      borderRadius: KinRadius.xlAll,
      child: BackdropFilter(
        filter: isDark
            ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: isLandscape ? 440 : 340),
            width: double.infinity,
            padding: contentOnly
                ? EdgeInsets.zero
                : EdgeInsets.all(isLandscape ? KinSpacing.md : KinSpacing.lg),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: theme.primary.withValues(alpha: 0.12)),
              borderRadius: KinRadius.xlAll,

              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: contentOnly
                ? content
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KinText.titleLarge(title, color: theme.onSurface),
                      if (message != null) ...[
                        const SizedBox(height: KinSpacing.sm),
                        KinText.bodyMedium(
                          message!,
                          color: theme.onSurfaceVariant,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (content != null) ...[
                        const SizedBox(height: KinSpacing.md),
                        content!,
                      ],
                      SizedBox(
                        height: isLandscape ? KinSpacing.md : KinSpacing.lg,
                      ),
                      Row(
                        spacing: KinSpacing.sm,
                        children: [
                          if (cancelLabel != null)
                            Expanded(
                              child: KinButton(
                                label: cancelLabel!,
                                variant: KinButtonVariant.secondary,
                                onTap: onCancel,
                              ),
                            ),
                          Expanded(
                            child: KinButton(
                              label: confirmLabel,
                              variant: isDestructive
                                  ? KinButtonVariant.destructive
                                  : KinButtonVariant.primary,
                              onTap: onConfirm,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

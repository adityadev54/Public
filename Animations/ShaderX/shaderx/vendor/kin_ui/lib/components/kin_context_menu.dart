import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';
import 'kin_text.dart';

/// A single action in a [KinContextMenu].
class KinContextAction {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const KinContextAction({
    required this.label,
    this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// iOS-style long-press context menu with blurred background and spring animation.
class KinContextMenu extends StatefulWidget {
  final Widget child;
  final List<KinContextAction> actions;
  final Widget? preview;

  const KinContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.preview,
  });

  @override
  State<KinContextMenu> createState() => _KinContextMenuState();
}

class _KinContextMenuState extends State<KinContextMenu> {
  void _show() {
    HapticFeedback.mediumImpact();

    final renderBox = context.findRenderObject() as RenderBox;
    final childSize = renderBox.size;
    final childGlobal = renderBox.localToGlobal(Offset.zero);

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, animation, __) {
          return _ContextMenuOverlay(
            actions: widget.actions,
            preview: widget.preview ?? widget.child,
            childGlobal: childGlobal,
            childSize: childSize,
            animation: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
              reverseCurve: Curves.easeIn,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _show,
      child: widget.child,
    );
  }
}

class _ContextMenuOverlay extends StatelessWidget {
  final List<KinContextAction> actions;
  final Widget preview;
  final Offset childGlobal;
  final Size childSize;
  final Animation<double> animation;

  const _ContextMenuOverlay({
    required this.actions,
    required this.preview,
    required this.childGlobal,
    required this.childSize,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screen = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.paddingOf(context);

    // Compute menu position
    final menuWidth = (childSize.width + 32).clamp(240.0, screen.width - 32);
    final previewH = childSize.height * 0.92;

    // Center menu around the child
    var menuX = childGlobal.dx + childSize.width / 2 - menuWidth / 2;
    menuX = menuX.clamp(16.0, screen.width - menuWidth - 16.0);

    var menuY = childGlobal.dy + childSize.height + 12;
    final menuEstHeight = actions.length * 44.0 + previewH + 24;

    // If it would go off bottom, place above
    if (menuY + menuEstHeight > screen.height - safePadding.bottom - 16) {
      menuY = childGlobal.dy - menuEstHeight + previewH;
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: FadeTransition(
        opacity: animation,
        child: Stack(
          children: [
            // Blurred scrim
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.15),
                ),
              ),
            ),

            // Preview + actions
            Positioned(
              left: menuX,
              top: menuY.clamp(safePadding.top + 16, screen.height - 100.0),
              child: ScaleTransition(
                scale: animation,
                alignment: Alignment.topCenter,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview
                      ClipRRect(
                        borderRadius: KinRadius.lgAll,
                        child: SizedBox(
                          width: menuWidth,
                          child: preview,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Actions
                      ClipRRect(
                        borderRadius: KinRadius.lgAll,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                          child: Container(
                            width: menuWidth,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.surfaceVariant.withValues(alpha: 0.8)
                                  : theme.surfaceVariant.withValues(alpha: 0.95),
                              borderRadius: KinRadius.lgAll,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < actions.length; i++) ...[
                                  if (i > 0)
                                    Divider(
                                      height: 0.5,
                                      thickness: 0.5,
                                      color: theme.outline.withValues(alpha: 0.2),
                                    ),
                                  _ContextActionRow(
                                    action: actions[i],
                                    theme: theme,
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      actions[i].onTap();
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextActionRow extends StatefulWidget {
  final KinContextAction action;
  final KinTheme theme;
  final VoidCallback onTap;

  const _ContextActionRow({
    required this.action,
    required this.theme,
    required this.onTap,
  });

  @override
  State<_ContextActionRow> createState() => _ContextActionRowState();
}

class _ContextActionRowState extends State<_ContextActionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.action.isDestructive
        ? widget.theme.destructive
        : widget.theme.onSurface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        Future.delayed(const Duration(milliseconds: 80), widget.onTap);
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: KinMotion.fast,
        color: _pressed
            ? widget.theme.onSurface.withValues(alpha: 0.08)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: KinSpacing.md,
          vertical: KinSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Expanded(
              child: KinText(
                widget.action.label,
                style: KinTypography.bodyMedium,
                color: color,
              ),
            ),
            if (widget.action.icon != null)
              Icon(widget.action.icon, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}

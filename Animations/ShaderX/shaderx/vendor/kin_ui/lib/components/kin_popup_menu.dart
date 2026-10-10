import 'dart:ui';
import 'package:flutter/material.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// A single item within a [KinPopupMenu].
class KinPopupMenuItem {
  final String label;

  /// False for static informational rows without selection or dismissal.
  final bool selectable;
  final Widget? leading;
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  const KinPopupMenuItem({
    required this.label,
    this.selectable = true,
    this.leading,
    this.trailing,
    this.isDestructive = false,
    this.onTap,
  });
}

/// A divider that can be placed between [KinPopupMenuItem]s.
class KinPopupMenuDivider extends KinPopupMenuItem {
  const KinPopupMenuDivider() : super(label: '');
}

/// A non-material themed popup menu with frosted glass in dark mode.
///
/// Items float in a rounded card anchored to the trigger widget.
/// Supports grouped sections via [KinPopupMenuDivider].
class KinPopupMenu extends StatelessWidget {
  final List<KinPopupMenuItem> items;
  final Widget child;
  final Alignment alignment;
  final Offset offset;

  const KinPopupMenu({
    super.key,
    required this.items,
    required this.child,
    this.alignment = Alignment.topRight,
    this.offset = Offset.zero,
  });

  /// Shows the popup anchored relative to [anchorContext].
  static Future<void> show({
    required BuildContext context,
    required List<KinPopupMenuItem> items,
    required RelativeRect position,
  }) {
    return Navigator.of(
      context,
    ).push(_KinPopupRoute(items: items, position: position));
  }

  void _showMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(
          renderBox.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    show(context: context, items: items, position: position);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showMenu(context),
      child: AbsorbPointer(child: child),
    );
  }
}

class _KinPopupRoute extends PopupRoute<void> {
  final List<KinPopupMenuItem> items;
  final RelativeRect position;

  _KinPopupRoute({required this.items, required this.position});

  @override
  Color? get barrierColor => const Color(0x00000000);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => KinMotion.normal;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: KinMotion.enter,
      reverseCurve: KinMotion.exit,
    );

    return CustomSingleChildLayout(
      delegate: _PopupMenuLayoutDelegate(position: position),
      child: ScaleTransition(
        alignment: Alignment.topRight,
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: Material(
            type: MaterialType.transparency,
            child: _KinPopupPanel(
              items: items,
              onDismiss: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopupMenuLayoutDelegate extends SingleChildLayoutDelegate {
  final RelativeRect position;

  _PopupMenuLayoutDelegate({required this.position});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      Size(constraints.maxWidth - KinSpacing.md * 2, constraints.maxHeight),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = size.width - position.right - childSize.width;
    double y = position.top + (size.height - position.top - position.bottom);

    x = x.clamp(KinSpacing.sm, size.width - childSize.width - KinSpacing.sm);
    y = y.clamp(KinSpacing.sm, size.height - childSize.height - KinSpacing.sm);

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant _PopupMenuLayoutDelegate oldDelegate) {
    return position != oldDelegate.position;
  }
}

class _KinPopupPanel extends StatelessWidget {
  final List<KinPopupMenuItem> items;
  final VoidCallback onDismiss;

  const _KinPopupPanel({required this.items, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = KinTheme.of(context);

    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.8)
        : theme.surfaceVariant;

    final decoration = BoxDecoration(
      color: bgColor,
      borderRadius: KinRadius.lgAll,
      boxShadow: isDark
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
    );

    Widget panel = Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.symmetric(
        vertical: KinSpacing.sm,
        horizontal: KinSpacing.xs,
      ),
      decoration: decoration,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items.map((item) {
            if (item is KinPopupMenuDivider) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: KinSpacing.xs,
                  horizontal: KinSpacing.sm,
                ),
                child: Text(
                  '- - - - - - - - - - - - - - - - - - - -',
                  style: TextStyle(
                    color: theme.outline,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              );
            }
            return _KinPopupRow(item: item, onDismiss: onDismiss);
          }).toList(),
        ),
      ),
    );

    if (isDark) {
      return ClipRRect(
        borderRadius: KinRadius.lgAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: panel,
        ),
      );
    }

    return panel;
  }
}

class _KinPopupRow extends StatefulWidget {
  final KinPopupMenuItem item;
  final VoidCallback onDismiss;

  const _KinPopupRow({required this.item, required this.onDismiss});

  @override
  State<_KinPopupRow> createState() => _KinPopupRowState();
}

class _KinPopupRowState extends State<_KinPopupRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final item = widget.item;
    final textColor = item.isDestructive ? theme.destructive : theme.onSurface;
    final iconColor = item.isDestructive
        ? theme.destructive
        : theme.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: item.selectable
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: item.selectable
          ? (_) async {
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 120));
              if (!mounted) return;
              setState(() => _pressed = false);
              widget.onDismiss();
              item.onTap?.call();
            }
          : null,
      onTapCancel: item.selectable
          ? () => setState(() => _pressed = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: _pressed
              ? theme.onSurface.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        margin: const EdgeInsets.symmetric(horizontal: KinSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: KinSpacing.sm + 2,
          vertical: KinSpacing.sm + 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: KinSpacing.sm + 2,
          children: [
            if (item.leading != null)
              IconTheme(
                data: IconThemeData(color: iconColor, size: 20),
                child: item.leading!,
              ),
            Flexible(
              child: KinText(
                item.label,
                style: KinTypography.bodyMedium,
                color: textColor,
              ),
            ),
            if (item.trailing != null)
              IconTheme(
                data: IconThemeData(color: theme.onSurfaceVariant, size: 16),
                child: item.trailing!,
              ),
          ],
        ),
      ),
    );
  }
}

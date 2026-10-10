import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kin_press.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Visual variants for [KinFloatingButton].
enum KinFloatingButtonVariant {
  primary,
  secondary,
  surface,
  destructive,
}

/// Size variants for [KinFloatingButton].
enum KinFloatingButtonSize { small, regular, large }

/// Themed floating action button with spring entrance animation.
class KinFloatingButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final KinFloatingButtonVariant variant;
  final KinFloatingButtonSize size;
  final String? label;
  final bool enabled;
  final bool animate;

  const KinFloatingButton({
    super.key,
    required this.icon,
    this.onTap,
    this.variant = KinFloatingButtonVariant.primary,
    this.size = KinFloatingButtonSize.regular,
    this.label,
    this.enabled = true,
    this.animate = true,
  });

  const KinFloatingButton.extended({
    super.key,
    required this.icon,
    required String this.label,
    this.onTap,
    this.variant = KinFloatingButtonVariant.primary,
    this.size = KinFloatingButtonSize.regular,
    this.enabled = true,
    this.animate = true,
  });

  @override
  State<KinFloatingButton> createState() => _KinFloatingButtonState();
}

class _KinFloatingButtonState extends State<KinFloatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: const Interval(0, 0.6)),
    );
    if (widget.animate) {
      _entryCtrl.forward();
    } else {
      _entryCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color bg, Color fg, BoxBorder? border) = switch (widget.variant) {
      KinFloatingButtonVariant.primary => (theme.primary, const Color(0xFFFFFFFF), null),
      KinFloatingButtonVariant.secondary => (theme.surfaceVariant, theme.onSurface, null),
      KinFloatingButtonVariant.surface => (theme.surfaceVariant, theme.primary, null),
      KinFloatingButtonVariant.destructive => (theme.destructive, const Color(0xFFFFFFFF), null),
    };

    final double dimension = switch (widget.size) {
      KinFloatingButtonSize.small => 40,
      KinFloatingButtonSize.regular => 56,
      KinFloatingButtonSize.large => 68,
    };

    final double iconSize = switch (widget.size) {
      KinFloatingButtonSize.small => 18,
      KinFloatingButtonSize.regular => 22,
      KinFloatingButtonSize.large => 26,
    };

    final shadow = isDark
        ? <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)]
        : <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 14, offset: const Offset(0, 4))];

    final isExtended = widget.label != null;

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(scale: _scale.value, child: child),
      ),
      child: KinPress(
        onTap: widget.enabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onTap?.call();
              }
            : null,
        enabled: widget.enabled,
        child: AnimatedContainer(
          duration: KinMotion.fast,
          curve: KinMotion.enter,
          height: dimension,
          constraints: isExtended ? null : BoxConstraints.tightFor(width: dimension),
          padding: isExtended
              ? EdgeInsets.symmetric(horizontal: KinSpacing.md + KinSpacing.xs, vertical: KinSpacing.sm)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: KinRadius.pillAll,
            border: border,
            boxShadow: shadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: isExtended ? KinSpacing.sm : 0,
            children: [
              IconTheme(
                data: IconThemeData(color: fg, size: iconSize),
                child: widget.icon,
              ),
              if (isExtended)
                KinText(
                  widget.label!,
                  style: KinTypography.labelLarge,
                  color: fg,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

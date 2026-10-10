import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';
import 'kin_text.dart';

/// A themed radio button with animated fill and haptic feedback.
class KinRadio<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final String? subtitle;
  final Color? activeColor;
  final bool enabled;

  const KinRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.label,
    this.subtitle,
    this.activeColor,
    this.enabled = true,
  });

  @override
  State<KinRadio<T>> createState() => _KinRadioState<T>();
}

class _KinRadioState<T> extends State<KinRadio<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  bool get _isSelected => widget.value == widget.groupValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fillAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    if (_isSelected) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(KinRadio<T> old) {
    super.didUpdateWidget(old);
    final wasSelected = old.value == old.groupValue;
    if (_isSelected && !wasSelected) {
      _controller.forward(from: 0.0);
    } else if (!_isSelected && wasSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select() {
    if (!widget.enabled || widget.onChanged == null) return;
    HapticFeedback.selectionClick();
    widget.onChanged!(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final color = widget.activeColor ?? theme.primary;
    final isDisabled = !widget.enabled || widget.onChanged == null;

    Widget radio = GestureDetector(
      onTap: _select,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _fillAnimation,
        builder: (context, _) {
          return Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isSelected
                    ? (isDisabled ? color.withValues(alpha: 0.4) : color)
                    : (isDisabled
                        ? theme.outline.withValues(alpha: 0.4)
                        : theme.outline),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                width: 12 * _fillAnimation.value.clamp(0.0, 1.0),
                height: 12 * _fillAnimation.value.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSelected
                      ? (isDisabled ? color.withValues(alpha: 0.4) : color)
                      : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.label != null) {
      radio = GestureDetector(
        onTap: _select,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            radio,
            const SizedBox(width: KinSpacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  KinText(
                    widget.label!,
                    style: KinTypography.bodyMedium,
                    color: isDisabled
                        ? theme.onSurfaceVariant.withValues(alpha: 0.5)
                        : theme.onSurface,
                  ),
                  if (widget.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: KinText(
                        widget.subtitle!,
                        style: KinTypography.captionLarge,
                        color: theme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return radio;
  }
}

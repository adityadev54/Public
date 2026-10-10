import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';
import 'kin_text.dart';

/// A themed checkbox with animated checkmark, optional label, and haptic feedback.
class KinCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? subtitle;
  final Color? activeColor;
  final bool enabled;

  const KinCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.subtitle,
    this.activeColor,
    this.enabled = true,
  });

  @override
  State<KinCheckbox> createState() => _KinCheckboxState();
}

class _KinCheckboxState extends State<KinCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;

  /// Bouncy spring for the check-on transition.
  static final _checkSpring = SpringDescription(mass: 1.0, stiffness: 350.0, damping: 15.0);

  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOutBack),
    );
    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(KinCheckbox old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      if (widget.value) {
        _controller.forward(from: 0.0);
        _animateScale();
      } else {
        _controller.reverse();
        setState(() => _scale = 1.0);
      }
    }
  }

  /// Drive a spring bounce on the scale.
  void _animateScale() {
    final sim = SpringSimulation(_checkSpring, 0.0, 1.0, 8.0);
    double t = 0;
    late final void Function() tick;
    tick = () {
      t += 0.016;
      if (t > 0.6) {
        setState(() => _scale = 1.0);
        return;
      }
      // Spring value overshoots past 1.0 giving the bounce
      final v = sim.x(t);
      setState(() => _scale = 0.85 + 0.15 * v.clamp(0.0, 1.3));
      WidgetsBinding.instance.addPostFrameCallback((_) => tick());
    };
    tick();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!widget.enabled || widget.onChanged == null) return;
    HapticFeedback.selectionClick();
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final color = widget.activeColor ?? theme.primary;
    final isDisabled = !widget.enabled || widget.onChanged == null;

    Widget box = GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: widget.value
                    ? (isDisabled ? color.withValues(alpha: 0.4) : color)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: widget.value
                    ? null
                    : Border.all(
                        color: isDisabled
                            ? theme.outline.withValues(alpha: 0.4)
                            : theme.outline,
                        width: 1.5,
                      ),
              ),
              child: widget.value
                  ? CustomPaint(
                      painter: _CheckPainter(
                        progress: _checkAnimation.value,
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );

    if (widget.label != null) {
      box = GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            box,
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

    return box;
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Checkmark points relative to box
    final p1 = Offset(size.width * 0.22, size.height * 0.52);
    final p2 = Offset(size.width * 0.42, size.height * 0.72);
    final p3 = Offset(size.width * 0.78, size.height * 0.30);

    path.moveTo(p1.dx, p1.dy);

    // First segment: p1 → p2
    final seg1End = progress < 0.5 ? progress * 2 : 1.0;
    path.lineTo(
      p1.dx + (p2.dx - p1.dx) * seg1End,
      p1.dy + (p2.dy - p1.dy) * seg1End,
    );

    // Second segment: p2 → p3
    if (progress > 0.5) {
      final seg2End = (progress - 0.5) * 2;
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * seg2End,
        p2.dy + (p3.dy - p2.dy) * seg2End,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => progress != old.progress;
}

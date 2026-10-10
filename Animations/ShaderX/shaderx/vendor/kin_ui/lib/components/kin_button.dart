import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Visual variants for [KinButton].
enum KinButtonVariant { primary, secondary, ghost, destructive }

/// Size variants for [KinButton].
enum KinButtonSize { small, medium, large }

/// Themed button with fluid spring press animation, loading state, and optional leading icon.
class KinButton extends StatefulWidget {
  final Widget? nativeChild;
  final String? label;
  final Widget? child;
  final VoidCallback? onTap;
  final KinButtonVariant variant;
  final KinButtonSize size;
  final bool isLoading;
  final bool enabled;
  final Widget? leading;

  const KinButton({
    super.key,
    this.nativeChild,
    this.label,
    this.child,
    this.onTap,
    this.variant = KinButtonVariant.primary,
    this.size = KinButtonSize.medium,
    this.isLoading = false,
    this.enabled = true,
    this.leading,
  }) : assert(
         nativeChild != null || label != null || child != null,
         'Provide either label or child',
       );

  @override
  State<KinButton> createState() => _KinButtonState();
}

class _KinButtonState extends State<KinButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _springCtrl;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController.unbounded(vsync: this, value: 1.0)
      ..addListener(_scaleListener);
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  void _onPressDown() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    _springCtrl.animateWith(
      SpringSimulation(KinMotion.fluidSnap, _scale, 0.96, 0),
    );
  }

  void _onPressUp() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    _springCtrl.animateWith(
      SpringSimulation(KinMotion.fluidBounce, _scale, 1.0, 0),
    );
  }

  void _scaleListener() {
    if (mounted) setState(() => _scale = _springCtrl.value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nativeChild != null) {
      final active =
          widget.enabled && !widget.isLoading && widget.onTap != null;
      return Listener(
        onPointerDown: active ? (_) => _onPressDown() : null,
        onPointerUp: active ? (_) => _onPressUp() : null,
        onPointerCancel: active ? (_) => _onPressUp() : null,
        child: Transform.scale(scale: _scale, child: widget.nativeChild),
      );
    }
    final theme = KinTheme.of(context);
    final active = widget.enabled && !widget.isLoading;

    final (Color bg, Color fg, BoxBorder? border) = switch (widget.variant) {
      KinButtonVariant.primary => (
        theme.primary,
        const Color(0xFFFFFFFF),
        null,
      ),
      KinButtonVariant.secondary => (
        theme.surfaceVariant,
        theme.onSurface,
        null,
      ),
      KinButtonVariant.ghost => (const Color(0x00000000), theme.primary, null),
      KinButtonVariant.destructive => (
        theme.destructive,
        const Color(0xFFFFFFFF),
        null,
      ),
    };

    return GestureDetector(
      onTapDown: active ? (_) => _onPressDown() : null,
      onTapUp: active
          ? (_) {
              _onPressUp();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: active ? _onPressUp : null,
      child: Transform.scale(
        scale: _scale,
        child: AnimatedContainer(
          duration: KinMotion.fast,
          curve: KinMotion.fluidEnter,
          padding: switch (widget.size) {
            KinButtonSize.small => const EdgeInsets.symmetric(
              horizontal: KinSpacing.md,
              vertical: KinSpacing.xs + 2,
            ),
            KinButtonSize.medium => const EdgeInsets.symmetric(
              horizontal: KinSpacing.lg,
              vertical: KinSpacing.sm + 4,
            ),
            KinButtonSize.large => const EdgeInsets.symmetric(
              horizontal: KinSpacing.xl,
              vertical: KinSpacing.md,
            ),
          },
          decoration: BoxDecoration(
            color: active ? bg : bg.withValues(alpha: 0.5),
            borderRadius: KinRadius.pillAll,
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: KinSpacing.sm,
            children: [
              if (widget.isLoading)
                _LoadingIndicator(color: fg)
              else ...[
                ?widget.leading,
                if (widget.child != null)
                  widget.child!
                else
                  KinText(
                    widget.label!,
                    style: switch (widget.size) {
                      KinButtonSize.small => KinTypography.labelSmall,
                      KinButtonSize.medium => KinTypography.labelLarge,
                      KinButtonSize.large => KinTypography.bodyLarge,
                    },
                    color: active ? fg : fg.withValues(alpha: 0.5),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  final Color color;
  const _LoadingIndicator({required this.color});

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Transform.rotate(
        angle: _controller.value * 2 * math.pi,
        child: SizedBox(
          width: 16,
          height: 16,
          child: CustomPaint(painter: _SpinnerPainter(color: widget.color)),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  _SpinnerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    canvas.drawArc(rect, 0, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => color != old.color;
}

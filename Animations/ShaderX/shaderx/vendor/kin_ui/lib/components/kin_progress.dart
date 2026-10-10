import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';

/// Linear or circular progress indicator with optional determinate value.
class KinProgress extends StatelessWidget {
  final bool nativeAppearance;
  final Animation<Color?>? valueColor;
  final StrokeCap? strokeCap;
  final double? minHeight;
  final double? value;
  final _KinProgressType _type;
  final Color? color;
  final Color? trackColor;
  final double strokeWidth;

  const KinProgress.linear({
    super.key,
    this.nativeAppearance = false,
    this.valueColor,
    this.strokeCap,
    this.minHeight,
    this.value,
    this.color,
    this.trackColor,
    this.strokeWidth = 4,
  }) : _type = _KinProgressType.linear;

  const KinProgress.circular({
    super.key,
    this.nativeAppearance = false,
    this.valueColor,
    this.strokeCap,
    this.minHeight,
    this.value,
    this.color,
    this.trackColor,
    this.strokeWidth = 3,
  }) : _type = _KinProgressType.circular;

  @override
  Widget build(BuildContext context) {
    if (nativeAppearance) {
      return switch (_type) {
        _KinProgressType.linear => LinearProgressIndicator(
          value: value,
          color: color,
          backgroundColor: trackColor,
          valueColor: valueColor,
          minHeight: minHeight,
        ),
        _KinProgressType.circular => CircularProgressIndicator(
          value: value,
          color: color,
          backgroundColor: trackColor,
          valueColor: valueColor,
          strokeWidth: strokeWidth,
          strokeCap: strokeCap,
        ),
      };
    }
    return switch (_type) {
      _KinProgressType.linear => _KinLinearProgress(
        value: value,
        color: color,
        trackColor: trackColor,
        strokeWidth: strokeWidth,
      ),
      _KinProgressType.circular => _KinCircularProgress(
        value: value,
        color: color,
        trackColor: trackColor,
        strokeWidth: strokeWidth,
      ),
    };
  }
}

enum _KinProgressType { linear, circular }

// ─── Linear ──────────────────────────────────────────────────────
class _KinLinearProgress extends StatelessWidget {
  final double? value;
  final Color? color;
  final Color? trackColor;
  final double strokeWidth;

  const _KinLinearProgress({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    final fg = color ?? theme.primary;
    final bg = trackColor ?? theme.outline.withValues(alpha: 0.3);

    if (value == null) {
      return _IndeterminateLinear(fg: fg, bg: bg, height: strokeWidth);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(strokeWidth / 2),
      child: SizedBox(
        height: strokeWidth,
        child: Stack(
          children: [
            Container(color: bg),
            FractionallySizedBox(
              widthFactor: value!.clamp(0.0, 1.0),
              child: AnimatedContainer(
                duration: KinMotion.fast,
                curve: KinMotion.enter,
                decoration: BoxDecoration(
                  color: fg,
                  borderRadius: BorderRadius.circular(strokeWidth / 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndeterminateLinear extends StatefulWidget {
  final Color fg;
  final Color bg;
  final double height;

  const _IndeterminateLinear({
    required this.fg,
    required this.bg,
    required this.height,
  });

  @override
  State<_IndeterminateLinear> createState() => _IndeterminateLinearState();
}

class _IndeterminateLinearState extends State<_IndeterminateLinear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                Container(color: widget.bg),
                Align(
                  alignment: Alignment(-1.0 + 2.0 * _controller.value, 0),
                  child: FractionallySizedBox(
                    widthFactor: 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.fg,
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Circular ────────────────────────────────────────────────────
class _KinCircularProgress extends StatelessWidget {
  final double? value;
  final Color? color;
  final Color? trackColor;
  final double strokeWidth;

  const _KinCircularProgress({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    final fg = color ?? theme.primary;
    final bg = trackColor ?? theme.outline.withValues(alpha: 0.3);

    if (value == null) {
      return _IndeterminateCircular(fg: fg, bg: bg, strokeWidth: strokeWidth);
    }

    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _CircularPainter(
          value: value!.clamp(0.0, 1.0),
          fg: fg,
          bg: bg,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _IndeterminateCircular extends StatefulWidget {
  final Color fg;
  final Color bg;
  final double strokeWidth;

  const _IndeterminateCircular({
    required this.fg,
    required this.bg,
    required this.strokeWidth,
  });

  @override
  State<_IndeterminateCircular> createState() => _IndeterminateCircularState();
}

class _IndeterminateCircularState extends State<_IndeterminateCircular>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      builder: (context, _) {
        return SizedBox(
          width: 24,
          height: 24,
          child: Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(
              painter: _CircularPainter(
                value: 0.25,
                fg: widget.fg,
                bg: widget.bg,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircularPainter extends CustomPainter {
  final double value;
  final Color fg;
  final Color bg;
  final double strokeWidth;

  _CircularPainter({
    required this.value,
    required this.fg,
    required this.bg,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = fg
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularPainter oldDelegate) =>
      value != oldDelegate.value ||
      fg != oldDelegate.fg ||
      bg != oldDelegate.bg;
}

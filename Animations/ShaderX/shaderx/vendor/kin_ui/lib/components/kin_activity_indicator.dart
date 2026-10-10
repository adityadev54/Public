import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/kin_theme.dart';

/// Visual variants for [KinActivityIndicator].
enum KinActivityIndicatorStyle {
  /// iOS-style spinning bars.
  spinner,

  /// Pulsing dots.
  dots,

  /// Circular arc (Material-ish but themed).
  circular,
}

/// Size presets.
enum KinActivityIndicatorSize {
  small(20),
  medium(32),
  large(48);

  final double diameter;
  const KinActivityIndicatorSize(this.diameter);
}

/// A themed loading indicator with multiple styles.
class KinActivityIndicator extends StatefulWidget {
  final KinActivityIndicatorStyle style;
  final KinActivityIndicatorSize size;
  final Color? color;

  const KinActivityIndicator({
    super.key,
    this.style = KinActivityIndicatorStyle.spinner,
    this.size = KinActivityIndicatorSize.medium,
    this.color,
  });

  const KinActivityIndicator.dots({
    super.key,
    this.size = KinActivityIndicatorSize.medium,
    this.color,
  }) : style = KinActivityIndicatorStyle.dots;

  const KinActivityIndicator.circular({
    super.key,
    this.size = KinActivityIndicatorSize.medium,
    this.color,
  }) : style = KinActivityIndicatorStyle.circular;

  @override
  State<KinActivityIndicator> createState() => _KinActivityIndicatorState();
}

class _KinActivityIndicatorState extends State<KinActivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: switch (widget.style) {
        KinActivityIndicatorStyle.spinner => const Duration(milliseconds: 1000),
        KinActivityIndicatorStyle.dots => const Duration(milliseconds: 1200),
        KinActivityIndicatorStyle.circular => const Duration(milliseconds: 1400),
      },
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final resolvedColor = widget.color ?? theme.onSurfaceVariant;
    final d = widget.size.diameter;

    return SizedBox(
      width: d,
      height: d,
      child: switch (widget.style) {
        KinActivityIndicatorStyle.spinner => AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _SpinnerPainter(
                progress: _controller.value,
                color: resolvedColor,
              ),
            ),
          ),
        KinActivityIndicatorStyle.dots => AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _DotsPainter(
                progress: _controller.value,
                color: resolvedColor,
              ),
            ),
          ),
        KinActivityIndicatorStyle.circular => AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _CircularPainter(
                progress: _controller.value,
                color: resolvedColor,
              ),
            ),
          ),
      },
    );
  }
}

// ── iOS-style spinner bars ──

class _SpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;
  static const _barCount = 12;

  _SpinnerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final barLength = radius * 0.35;
    final barWidth = math.max(radius * 0.1, 1.5);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    for (int i = 0; i < _barCount; i++) {
      final angle = (i / _barCount) * 2 * math.pi;
      final opacity = ((1.0 - ((progress * _barCount - i) % _barCount) / _barCount)).clamp(0.15, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = barWidth
        ..strokeCap = StrokeCap.round;

      final innerR = radius - barLength;
      final outerR = radius * 0.9;

      canvas.drawLine(
        Offset(math.cos(angle - math.pi / 2) * innerR, math.sin(angle - math.pi / 2) * innerR),
        Offset(math.cos(angle - math.pi / 2) * outerR, math.sin(angle - math.pi / 2) * outerR),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => progress != old.progress;
}

// ── Pulsing dots ──

class _DotsPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DotsPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dotCount = 3;
    final dotRadius = size.height * 0.15;
    final spacing = size.width / (dotCount + 1);

    for (int i = 0; i < dotCount; i++) {
      final phase = (progress - i * 0.2) % 1.0;
      final scale = (math.sin(phase * math.pi * 2) * 0.4 + 0.6).clamp(0.4, 1.0);
      final opacity = (math.sin(phase * math.pi * 2) * 0.5 + 0.5).clamp(0.3, 1.0);

      canvas.drawCircle(
        Offset(spacing * (i + 1), size.height / 2),
        dotRadius * scale,
        Paint()..color = color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => progress != old.progress;
}

// ── Circular arc ──

class _CircularPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4) / 2;
    final strokeWidth = math.max(radius * 0.15, 2.0);

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Sweeping arc
    final startAngle = progress * math.pi * 4 - math.pi / 2;
    final sweepAngle = math.sin(progress * math.pi) * math.pi * 1.5 + math.pi * 0.3;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircularPainter old) => progress != old.progress;
}

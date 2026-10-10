import 'package:flutter/material.dart';

/// Stacked prism faces reflect the studio’s layered shader compositions.
class ShaderXMark extends StatelessWidget {
  const ShaderXMark({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'ShaderX',
    image: true,
    child: SizedBox(
      key: const ValueKey('shaderx-mark'),
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _MarkPainter(
          Theme.of(context).colorScheme.primary.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? .25 : .30,
          ),
        ),
      ),
    ),
  );
}

class _MarkPainter extends CustomPainter {
  final Color color;
  const _MarkPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 32, size.height / 32);
    Path plane(double y) => Path()
      ..moveTo(16, y)
      ..lineTo(30, y + 7)
      ..lineTo(16, y + 14)
      ..lineTo(2, y + 7)
      ..close();
    canvas.drawPath(
      plane(15),
      Paint()..color = color.withValues(alpha: color.a * .55),
    );
    canvas.drawPath(
      plane(9),
      Paint()..color = color.withValues(alpha: color.a * .8),
    );
    final upper = plane(3);
    canvas.drawPath(upper, Paint()..color = color);
    canvas.drawPath(
      Path()
        ..moveTo(16, 3)
        ..lineTo(16, 17)
        ..lineTo(30, 10)
        ..close(),
      Paint()..color = color.withValues(alpha: color.a * .5),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.color != color;
}

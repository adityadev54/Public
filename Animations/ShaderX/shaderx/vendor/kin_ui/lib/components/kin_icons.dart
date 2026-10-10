import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Minimal hand-drawn vector icons for KinUI.
///
/// Each icon is a [CustomPainter] rendered inside a [CustomPaint] widget.
/// Stroke-only, no fills — matches KinUI's clean, minimal design language.
///
/// Usage:
/// ```dart
/// KinIcon.search(color: theme.onSurface, size: 24)
/// KinIcon.back(color: theme.onSurface, size: 24)
/// KinIcon.timer(color: theme.onSurface, size: 24)
/// KinIcon.plus(color: theme.onSurface, size: 24)
/// KinIcon.close(color: theme.onSurface, size: 24)
/// ```
class KinIcon extends StatelessWidget {
  final CustomPainter Function(Color color, double strokeWidth) _painterFactory;
  final Color? color;
  final double size;
  final double? strokeWidth;

  const KinIcon._({
    super.key,
    required CustomPainter Function(Color, double) painterFactory,
    this.color,
    this.size = 24,
    this.strokeWidth,
  }) : _painterFactory = painterFactory;

  /// Minimal search — small circle with a short angled stick.
  static KinIcon search({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _SearchPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// iOS-style leading chevron arrow (‹).
  static KinIcon back({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _BackPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Minimal timer — circle with two clock hands.
  static KinIcon timer({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _TimerPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Minimal plus (+).
  static KinIcon plus({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _PlusPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Minimal close (×).
  static KinIcon close({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _ClosePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Heart outline.
  static KinIcon heart({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _HeartPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Home — peaked roof + rounded walls + door arch.
  static KinIcon home({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _HomePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Notification bell.
  static KinIcon bell({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _BellPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Share — arrow out of a rounded tray.
  static KinIcon share({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _SharePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Eye — visibility indicator.
  static KinIcon eye({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _EyePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Check / tick mark.
  static KinIcon check({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _CheckPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Book — closed book with rounded spine.
  static KinIcon book({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _BookPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Open book — two curved pages spreading apart.
  static KinIcon bookOpen({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _BookOpenPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Copy — overlapping rounded rectangles.
  static KinIcon copy({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _CopyPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Paste — clipboard with rounded corners.
  static KinIcon paste({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _PastePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Trash — rounded bin with lid.
  static KinIcon trash({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _TrashPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Undo — curved arrow pointing left.
  static KinIcon undo({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _UndoPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Redo — curved arrow pointing right.
  static KinIcon redo({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _RedoPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Edit — pencil with rounded tip.
  static KinIcon edit({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _EditPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Filter — funnel shape with rounded edges.
  static KinIcon filter({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _FilterPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Person — head circle + curved shoulders.
  static KinIcon person({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _PersonPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Thumbs up — like.
  static KinIcon like({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _LikePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Thumbs down — dislike.
  static KinIcon dislike({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _DislikePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Calendar — rounded grid.
  static KinIcon calendar({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _CalendarPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Star — five-point star with rounded joins.
  static KinIcon star({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _StarPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Lock — padlock with rounded body.
  static KinIcon lock({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _LockPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// AI — sparkle / neural icon.
  static KinIcon ai({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _AiPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Microphone.
  static KinIcon mic({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _MicPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Volume / speaker.
  static KinIcon volume({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _VolumePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Calculator.
  static KinIcon calculator({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _CalculatorPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Video camera.
  static KinIcon video({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _VideoPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Message bubble.
  static KinIcon message({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _MessagePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Mail envelope.
  static KinIcon mail({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _MailPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Flower — rounded petals around a center.
  static KinIcon flower({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _FlowerPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Wallet — folded billfold with rounded edges.
  static KinIcon wallet({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _WalletPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Key — horizontal key with teeth.
  static KinIcon keyIcon({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _KeyPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Headphone — over-ear arc + cups.
  static KinIcon headphone({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _HeadphonePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Wristwatch — rounded face + band.
  static KinIcon watch({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _WatchPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Laptop — open screen + base.
  static KinIcon laptop({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _LaptopPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Mobile phone.
  static KinIcon mobile({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _MobilePainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Desktop monitor.
  static KinIcon desktop({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _DesktopPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Cup / mug.
  static KinIcon cup({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _CupPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  /// Flag — rounded flag on pole.
  static KinIcon flag({Key? key, Color? color, double size = 24, double? strokeWidth}) =>
      KinIcon._(key: key, painterFactory: _FlagPainter.new, color: color, size: size, strokeWidth: strokeWidth);

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.white;
    final sw = strokeWidth ?? (size * 0.09).clamp(1.4, 2.2);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _painterFactory(c, sw)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH — small circle + short angled stick
// ─────────────────────────────────────────────────────────────────────────────

class _SearchPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _SearchPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final s = size.shortestSide;
    // Circle: centred in the upper-left area, radius ~35% of size
    final cx = s * 0.42;
    final cy = s * 0.42;
    final r = s * 0.30;
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Stick: from circle edge at 45° (lower-right in canvas coords) outward
    final angle = math.pi * 0.25; // 45°
    final stickStart = Offset(
      cx + r * math.cos(angle),
      cy + r * math.sin(angle),
    );
    // Short stick — only ~25% of size
    final stickEnd = Offset(s * 0.82, s * 0.82);
    canvas.drawLine(stickStart, stickEnd, paint);
  }

  @override
  bool shouldRepaint(_SearchPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// BACK — iOS-style chevron (‹)
// ─────────────────────────────────────────────────────────────────────────────

class _BackPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _BackPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final path = Path()
      ..moveTo(s * 0.62, s * 0.20)
      ..lineTo(s * 0.32, s * 0.50)
      ..lineTo(s * 0.62, s * 0.80);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BackPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// TIMER — circle with a minute + hour hand
// ─────────────────────────────────────────────────────────────────────────────

class _TimerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _TimerPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final s = size.shortestSide;
    final center = Offset(s * 0.5, s * 0.5);
    final r = s * 0.40;

    // Outer circle
    canvas.drawCircle(center, r, paint);

    // Hour hand — points to ~2 o'clock, shorter
    canvas.drawLine(
      center,
      Offset(center.dx + r * 0.45 * math.cos(-math.pi / 6), // 1 o'clock angle
          center.dy + r * 0.45 * math.sin(-math.pi / 6)),
      paint,
    );

    // Minute hand — points to 12 o'clock, longer
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - r * 0.65),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TimerPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// PLUS — clean + sign
// ─────────────────────────────────────────────────────────────────────────────

class _PlusPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _PlusPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final s = size.shortestSide;
    final mid = s * 0.5;
    final inset = s * 0.22;

    // Horizontal
    canvas.drawLine(Offset(inset, mid), Offset(s - inset, mid), paint);
    // Vertical
    canvas.drawLine(Offset(mid, inset), Offset(mid, s - inset), paint);
  }

  @override
  bool shouldRepaint(_PlusPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// CLOSE — clean × sign
// ─────────────────────────────────────────────────────────────────────────────

class _ClosePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _ClosePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final s = size.shortestSide;
    final inset = s * 0.25;

    // Top-left → bottom-right
    canvas.drawLine(Offset(inset, inset), Offset(s - inset, s - inset), paint);
    // Top-right → bottom-left
    canvas.drawLine(Offset(s - inset, inset), Offset(inset, s - inset), paint);
  }

  @override
  bool shouldRepaint(_ClosePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// HEART — outline heart (all curves, no sharp points)
// ─────────────────────────────────────────────────────────────────────────────

class _HeartPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _HeartPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final path = Path()
      ..moveTo(s * 0.50, s * 0.82)
      ..cubicTo(s * 0.14, s * 0.58, s * 0.10, s * 0.28, s * 0.30, s * 0.22)
      ..cubicTo(s * 0.42, s * 0.18, s * 0.50, s * 0.30, s * 0.50, s * 0.30)
      ..cubicTo(s * 0.50, s * 0.30, s * 0.58, s * 0.18, s * 0.70, s * 0.22)
      ..cubicTo(s * 0.90, s * 0.28, s * 0.86, s * 0.58, s * 0.50, s * 0.82);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME — single continuous rounded silhouette + door arch
// ─────────────────────────────────────────────────────────────────────────────

class _HomePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _HomePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Roof — peaked triangle with softened apex via short cubic
    final roof = Path()
      ..moveTo(s * 0.12, s * 0.48)
      ..lineTo(s * 0.44, s * 0.18)
      ..cubicTo(s * 0.46, s * 0.16, s * 0.54, s * 0.16, s * 0.56, s * 0.18)
      ..lineTo(s * 0.88, s * 0.48);
    canvas.drawPath(roof, paint);

    // Walls — rounded-bottom rectangle beneath the roof
    final walls = Path()
      ..moveTo(s * 0.24, s * 0.46)
      ..lineTo(s * 0.24, s * 0.76)
      ..cubicTo(s * 0.24, s * 0.82, s * 0.28, s * 0.84, s * 0.32, s * 0.84)
      ..lineTo(s * 0.68, s * 0.84)
      ..cubicTo(s * 0.72, s * 0.84, s * 0.76, s * 0.82, s * 0.76, s * 0.76)
      ..lineTo(s * 0.76, s * 0.46);
    canvas.drawPath(walls, paint);

    // Door — centered arch
    final door = Path()
      ..moveTo(s * 0.42, s * 0.84)
      ..lineTo(s * 0.42, s * 0.66)
      ..cubicTo(s * 0.42, s * 0.58, s * 0.58, s * 0.58, s * 0.58, s * 0.66)
      ..lineTo(s * 0.58, s * 0.84);
    canvas.drawPath(door, paint);
  }

  @override
  bool shouldRepaint(_HomePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// BELL — rounded notification bell
// ─────────────────────────────────────────────────────────────────────────────

class _BellPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _BellPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Bell body — one continuous rounded shape
    final bell = Path()
      ..moveTo(s * 0.20, s * 0.62)
      ..cubicTo(s * 0.20, s * 0.30, s * 0.32, s * 0.16, s * 0.50, s * 0.16)
      ..cubicTo(s * 0.68, s * 0.16, s * 0.80, s * 0.30, s * 0.80, s * 0.62)
      // Rounded brim — curves out to sides and back
      ..cubicTo(s * 0.80, s * 0.66, s * 0.84, s * 0.68, s * 0.84, s * 0.68)
      ..cubicTo(s * 0.84, s * 0.68, s * 0.16, s * 0.68, s * 0.16, s * 0.68)
      ..cubicTo(s * 0.16, s * 0.68, s * 0.20, s * 0.66, s * 0.20, s * 0.62);
    canvas.drawPath(bell, paint);

    // Clapper — small round arc below
    final clapper = Path()
      ..moveTo(s * 0.40, s * 0.72)
      ..cubicTo(s * 0.40, s * 0.82, s * 0.60, s * 0.82, s * 0.60, s * 0.72);
    canvas.drawPath(clapper, paint);
  }

  @override
  bool shouldRepaint(_BellPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARE — arrow curving up out of a rounded tray
// ─────────────────────────────────────────────────────────────────────────────

class _SharePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _SharePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Tray — open-top rounded container
    final tray = Path()
      ..moveTo(s * 0.22, s * 0.38)
      ..lineTo(s * 0.22, s * 0.72)
      ..cubicTo(s * 0.22, s * 0.82, s * 0.30, s * 0.84, s * 0.36, s * 0.84)
      ..lineTo(s * 0.64, s * 0.84)
      ..cubicTo(s * 0.70, s * 0.84, s * 0.78, s * 0.82, s * 0.78, s * 0.72)
      ..lineTo(s * 0.78, s * 0.38);
    canvas.drawPath(tray, paint);

    // Arrow shaft — vertical line going up from center
    canvas.drawLine(Offset(s * 0.50, s * 0.62), Offset(s * 0.50, s * 0.18), paint);

    // Arrow head — chevron at top
    final head = Path()
      ..moveTo(s * 0.36, s * 0.32)
      ..lineTo(s * 0.50, s * 0.18)
      ..lineTo(s * 0.64, s * 0.32);
    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(_SharePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// EYE — rounded visibility icon
// ─────────────────────────────────────────────────────────────────────────────

class _EyePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _EyePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final s = size.shortestSide;
    final center = Offset(s * 0.5, s * 0.5);

    // Outer eye shape — wider, rounder almond
    final top = Path()
      ..moveTo(s * 0.08, s * 0.50)
      ..cubicTo(s * 0.20, s * 0.24, s * 0.40, s * 0.22, s * 0.50, s * 0.22)
      ..cubicTo(s * 0.60, s * 0.22, s * 0.80, s * 0.24, s * 0.92, s * 0.50);
    canvas.drawPath(top, paint);

    final bottom = Path()
      ..moveTo(s * 0.08, s * 0.50)
      ..cubicTo(s * 0.20, s * 0.76, s * 0.40, s * 0.78, s * 0.50, s * 0.78)
      ..cubicTo(s * 0.60, s * 0.78, s * 0.80, s * 0.76, s * 0.92, s * 0.50);
    canvas.drawPath(bottom, paint);

    // Iris — larger circle for visual weight
    canvas.drawCircle(center, s * 0.14, paint);

    // Pupil — small filled dot
    canvas.drawCircle(
      center,
      s * 0.05,
      paint..style = PaintingStyle.fill,
    );
    paint.style = PaintingStyle.stroke; // restore
  }

  @override
  bool shouldRepaint(_EyePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECK — rounded tick mark ✓
// ─────────────────────────────────────────────────────────────────────────────

class _CheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _CheckPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    // Soft curved checkmark instead of sharp angles
    final path = Path()
      ..moveTo(s * 0.20, s * 0.52)
      ..cubicTo(s * 0.28, s * 0.58, s * 0.36, s * 0.68, s * 0.42, s * 0.72)
      ..cubicTo(s * 0.50, s * 0.66, s * 0.66, s * 0.40, s * 0.80, s * 0.28);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOK — closed book with rounded spine
// ─────────────────────────────────────────────────────────────────────────────

class _BookPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _BookPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.06;

    // Book body — rounded rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.22, s * 0.14, s * 0.78, s * 0.86),
        Radius.circular(r),
      ),
      paint,
    );

    // Spine — curved left edge
    final spine = Path()
      ..moveTo(s * 0.32, s * 0.14)
      ..cubicTo(s * 0.28, s * 0.30, s * 0.28, s * 0.70, s * 0.32, s * 0.86);
    canvas.drawPath(spine, paint);
  }

  @override
  bool shouldRepaint(_BookPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOK OPEN — two curved pages spreading from a center spine
// ─────────────────────────────────────────────────────────────────────────────

class _BookOpenPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _BookOpenPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final mid = s * 0.50;

    // Center spine
    canvas.drawLine(Offset(mid, s * 0.20), Offset(mid, s * 0.80), paint);

    // Left page — curves outward
    final left = Path()
      ..moveTo(mid, s * 0.20)
      ..cubicTo(s * 0.30, s * 0.18, s * 0.14, s * 0.22, s * 0.14, s * 0.32)
      ..lineTo(s * 0.14, s * 0.72)
      ..cubicTo(s * 0.14, s * 0.78, s * 0.30, s * 0.76, mid, s * 0.80);
    canvas.drawPath(left, paint);

    // Right page — mirrors left
    final right = Path()
      ..moveTo(mid, s * 0.20)
      ..cubicTo(s * 0.70, s * 0.18, s * 0.86, s * 0.22, s * 0.86, s * 0.32)
      ..lineTo(s * 0.86, s * 0.72)
      ..cubicTo(s * 0.86, s * 0.78, s * 0.70, s * 0.76, mid, s * 0.80);
    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(_BookOpenPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// COPY — overlapping rounded rectangles
// ─────────────────────────────────────────────────────────────────────────────

class _CopyPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _CopyPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.08;

    // Back rect (offset top-left)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.14, s * 0.14, s * 0.64, s * 0.64),
        Radius.circular(r),
      ),
      paint,
    );

    // Front rect (offset bottom-right)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.36, s * 0.36, s * 0.86, s * 0.86),
        Radius.circular(r),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CopyPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// PASTE — clipboard with rounded corners
// ─────────────────────────────────────────────────────────────────────────────

class _PastePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _PastePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.08;

    // Clipboard body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.20, s * 0.22, s * 0.80, s * 0.88),
        Radius.circular(r),
      ),
      paint,
    );

    // Clip tab at top — rounded pill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.36, s * 0.12, s * 0.64, s * 0.28),
        Radius.circular(r),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PastePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// TRASH — rounded bin with lid
// ─────────────────────────────────────────────────────────────────────────────

class _TrashPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _TrashPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Lid — horizontal line with rounded ends
    canvas.drawLine(Offset(s * 0.18, s * 0.24), Offset(s * 0.82, s * 0.24), paint);

    // Lid handle — small arch
    final handle = Path()
      ..moveTo(s * 0.38, s * 0.24)
      ..cubicTo(s * 0.38, s * 0.14, s * 0.62, s * 0.14, s * 0.62, s * 0.24);
    canvas.drawPath(handle, paint);

    // Bin body — tapered rounded rect
    final body = Path()
      ..moveTo(s * 0.24, s * 0.28)
      ..cubicTo(s * 0.24, s * 0.28, s * 0.28, s * 0.82, s * 0.32, s * 0.84)
      ..cubicTo(s * 0.36, s * 0.86, s * 0.64, s * 0.86, s * 0.68, s * 0.84)
      ..cubicTo(s * 0.72, s * 0.82, s * 0.76, s * 0.28, s * 0.76, s * 0.28);
    canvas.drawPath(body, paint);

    // Two inner lines
    canvas.drawLine(Offset(s * 0.42, s * 0.38), Offset(s * 0.42, s * 0.72), paint);
    canvas.drawLine(Offset(s * 0.58, s * 0.38), Offset(s * 0.58, s * 0.72), paint);
  }

  @override
  bool shouldRepaint(_TrashPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// UNDO — curved arrow pointing left
// ─────────────────────────────────────────────────────────────────────────────

class _UndoPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _UndoPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Curved sweep from right to left
    final arc = Path()
      ..moveTo(s * 0.72, s * 0.66)
      ..cubicTo(s * 0.72, s * 0.36, s * 0.52, s * 0.26, s * 0.30, s * 0.38);
    canvas.drawPath(arc, paint);

    // Arrow head pointing left
    final arrow = Path()
      ..moveTo(s * 0.40, s * 0.26)
      ..lineTo(s * 0.26, s * 0.38)
      ..lineTo(s * 0.40, s * 0.50);
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(_UndoPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// REDO — curved arrow pointing right
// ─────────────────────────────────────────────────────────────────────────────

class _RedoPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _RedoPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Curved sweep from left to right
    final arc = Path()
      ..moveTo(s * 0.28, s * 0.66)
      ..cubicTo(s * 0.28, s * 0.36, s * 0.48, s * 0.26, s * 0.70, s * 0.38);
    canvas.drawPath(arc, paint);

    // Arrow head pointing right
    final arrow = Path()
      ..moveTo(s * 0.60, s * 0.26)
      ..lineTo(s * 0.74, s * 0.38)
      ..lineTo(s * 0.60, s * 0.50);
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(_RedoPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT — pencil with rounded tip
// ─────────────────────────────────────────────────────────────────────────────

class _EditPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _EditPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Pencil body — angled rounded rectangle
    final body = Path()
      ..moveTo(s * 0.62, s * 0.18)
      ..cubicTo(s * 0.66, s * 0.14, s * 0.74, s * 0.14, s * 0.78, s * 0.18)
      ..lineTo(s * 0.82, s * 0.22)
      ..cubicTo(s * 0.86, s * 0.26, s * 0.86, s * 0.34, s * 0.82, s * 0.38)
      ..lineTo(s * 0.38, s * 0.82)
      ..cubicTo(s * 0.36, s * 0.84, s * 0.32, s * 0.86, s * 0.28, s * 0.86)
      ..lineTo(s * 0.16, s * 0.86)
      ..cubicTo(s * 0.14, s * 0.86, s * 0.14, s * 0.84, s * 0.14, s * 0.82)
      ..lineTo(s * 0.14, s * 0.72)
      ..cubicTo(s * 0.14, s * 0.68, s * 0.16, s * 0.64, s * 0.18, s * 0.62)
      ..close();
    canvas.drawPath(body, paint);

    // Collar line
    canvas.drawLine(Offset(s * 0.30, s * 0.70), Offset(s * 0.70, s * 0.30), paint);
  }

  @override
  bool shouldRepaint(_EditPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER — three horizontal lines (decreasing width)
// ─────────────────────────────────────────────────────────────────────────────

class _FilterPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _FilterPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final s = size.shortestSide;

    // Top line — widest
    canvas.drawLine(Offset(s * 0.14, s * 0.28), Offset(s * 0.86, s * 0.28), paint);
    // Middle line — medium
    canvas.drawLine(Offset(s * 0.26, s * 0.50), Offset(s * 0.74, s * 0.50), paint);
    // Bottom line — shortest
    canvas.drawLine(Offset(s * 0.38, s * 0.72), Offset(s * 0.62, s * 0.72), paint);
  }

  @override
  bool shouldRepaint(_FilterPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// PERSON — user avatar (head + body inside circle)
// ─────────────────────────────────────────────────────────────────────────────

class _PersonPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _PersonPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final s = size.shortestSide;
    final center = Offset(s * 0.50, s * 0.50);

    // Outer circle boundary
    canvas.drawCircle(center, s * 0.42, paint);

    // Head
    canvas.drawCircle(Offset(s * 0.50, s * 0.36), s * 0.13, paint);

    // Body — wide arc clipped inside the outer circle
    canvas.save();
    final clip = Path()
      ..addOval(Rect.fromCircle(center: center, radius: s * 0.42));
    canvas.clipPath(clip);
    final body = Path()
      ..moveTo(s * 0.20, s * 0.86)
      ..cubicTo(s * 0.22, s * 0.66, s * 0.34, s * 0.56, s * 0.50, s * 0.56)
      ..cubicTo(s * 0.66, s * 0.56, s * 0.78, s * 0.66, s * 0.80, s * 0.86);
    canvas.drawPath(body, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PersonPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// LIKE — thumbs up (all curves)
// ─────────────────────────────────────────────────────────────────────────────

class _LikePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _LikePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Thumb — curved upward
    final thumb = Path()
      ..moveTo(s * 0.22, s * 0.48)
      ..cubicTo(s * 0.22, s * 0.40, s * 0.30, s * 0.14, s * 0.42, s * 0.14)
      ..cubicTo(s * 0.48, s * 0.14, s * 0.50, s * 0.22, s * 0.50, s * 0.36)
      ..lineTo(s * 0.50, s * 0.42)
      ..cubicTo(s * 0.50, s * 0.42, s * 0.66, s * 0.38, s * 0.72, s * 0.40)
      ..cubicTo(s * 0.80, s * 0.42, s * 0.82, s * 0.48, s * 0.80, s * 0.56)
      ..cubicTo(s * 0.80, s * 0.62, s * 0.78, s * 0.70, s * 0.74, s * 0.76)
      ..cubicTo(s * 0.70, s * 0.82, s * 0.56, s * 0.84, s * 0.46, s * 0.84)
      ..lineTo(s * 0.30, s * 0.84)
      ..cubicTo(s * 0.24, s * 0.84, s * 0.22, s * 0.80, s * 0.22, s * 0.74)
      ..close();
    canvas.drawPath(thumb, paint);
  }

  @override
  bool shouldRepaint(_LikePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// DISLIKE — thumbs down (all curves, mirrored like)
// ─────────────────────────────────────────────────────────────────────────────

class _DislikePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _DislikePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Thumb — curved downward (vertically mirrored like)
    final thumb = Path()
      ..moveTo(s * 0.22, s * 0.52)
      ..cubicTo(s * 0.22, s * 0.60, s * 0.30, s * 0.86, s * 0.42, s * 0.86)
      ..cubicTo(s * 0.48, s * 0.86, s * 0.50, s * 0.78, s * 0.50, s * 0.64)
      ..lineTo(s * 0.50, s * 0.58)
      ..cubicTo(s * 0.50, s * 0.58, s * 0.66, s * 0.62, s * 0.72, s * 0.60)
      ..cubicTo(s * 0.80, s * 0.58, s * 0.82, s * 0.52, s * 0.80, s * 0.44)
      ..cubicTo(s * 0.80, s * 0.38, s * 0.78, s * 0.30, s * 0.74, s * 0.24)
      ..cubicTo(s * 0.70, s * 0.18, s * 0.56, s * 0.16, s * 0.46, s * 0.16)
      ..lineTo(s * 0.30, s * 0.16)
      ..cubicTo(s * 0.24, s * 0.16, s * 0.22, s * 0.20, s * 0.22, s * 0.26)
      ..close();
    canvas.drawPath(thumb, paint);
  }

  @override
  bool shouldRepaint(_DislikePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR — rounded body with date grid
// ─────────────────────────────────────────────────────────────────────────────

class _CalendarPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _CalendarPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.08;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.14, s * 0.20, s * 0.86, s * 0.86),
        Radius.circular(r),
      ),
      paint,
    );

    // Top binding pegs
    canvas.drawLine(Offset(s * 0.36, s * 0.12), Offset(s * 0.36, s * 0.28), paint);
    canvas.drawLine(Offset(s * 0.64, s * 0.12), Offset(s * 0.64, s * 0.28), paint);

    // Divider line below header row
    canvas.drawLine(Offset(s * 0.14, s * 0.40), Offset(s * 0.86, s * 0.40), paint);

    // 4 dot grid representing dates
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final dotR = s * 0.035;
    canvas.drawCircle(Offset(s * 0.36, s * 0.54), dotR, dotPaint);
    canvas.drawCircle(Offset(s * 0.50, s * 0.54), dotR, dotPaint);
    canvas.drawCircle(Offset(s * 0.64, s * 0.54), dotR, dotPaint);
    canvas.drawCircle(Offset(s * 0.36, s * 0.70), dotR, dotPaint);
    canvas.drawCircle(Offset(s * 0.50, s * 0.70), dotR, dotPaint);
  }

  @override
  bool shouldRepaint(_CalendarPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// STAR — five-point star with rounded joins
// ─────────────────────────────────────────────────────────────────────────────

class _StarPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _StarPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final cx = s * 0.50;
    final cy = s * 0.48;
    final outerR = s * 0.38;
    final innerR = s * 0.16;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      // Outer point
      final oAngle = -math.pi / 2 + (i * 2 * math.pi / 5);
      final ox = cx + outerR * math.cos(oAngle);
      final oy = cy + outerR * math.sin(oAngle);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      // Inner notch
      final iAngle = oAngle + math.pi / 5;
      final ix = cx + innerR * math.cos(iAngle);
      final iy = cy + innerR * math.sin(iAngle);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCK — padlock with rounded body + shackle
// ─────────────────────────────────────────────────────────────────────────────

class _LockPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _LockPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.08;

    // Lock body — rounded rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.22, s * 0.46, s * 0.78, s * 0.86),
        Radius.circular(r),
      ),
      paint,
    );

    // Shackle — rounded arc on top
    final shackle = Path()
      ..moveTo(s * 0.32, s * 0.46)
      ..lineTo(s * 0.32, s * 0.34)
      ..cubicTo(s * 0.32, s * 0.16, s * 0.68, s * 0.16, s * 0.68, s * 0.34)
      ..lineTo(s * 0.68, s * 0.46);
    canvas.drawPath(shackle, paint);

    // Keyhole — small circle + short line
    canvas.drawCircle(Offset(s * 0.50, s * 0.62), s * 0.05, paint);
    canvas.drawLine(Offset(s * 0.50, s * 0.67), Offset(s * 0.50, s * 0.74), paint);
  }

  @override
  bool shouldRepaint(_LockPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI — Gemini-style sparkle (pinched 4-point star + companion)
// ─────────────────────────────────────────────────────────────────────────────

class _AiPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _AiPainter(this.color, this.strokeWidth);

  void _drawSparkle(Canvas canvas, Paint paint, double s,
      double cx, double cy, double rx, double ry) {
    // 4-point star: top → left → bottom → right, with pinched waist
    // The control points pull inward creating the signature concave sides
    final path = Path()
      // Top point → left point
      ..moveTo(cx, cy - ry)
      ..cubicTo(cx - rx * 0.12, cy - ry * 0.30,
               cx - rx * 0.30, cy - ry * 0.12,
               cx - rx, cy)
      // Left point → bottom point
      ..cubicTo(cx - rx * 0.30, cy + ry * 0.12,
               cx - rx * 0.12, cy + ry * 0.30,
               cx, cy + ry)
      // Bottom point → right point
      ..cubicTo(cx + rx * 0.12, cy + ry * 0.30,
               cx + rx * 0.30, cy + ry * 0.12,
               cx + rx, cy)
      // Right point → back to top
      ..cubicTo(cx + rx * 0.30, cy - ry * 0.12,
               cx + rx * 0.12, cy - ry * 0.30,
               cx, cy - ry);
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Main sparkle — large, slightly left-of-center
    _drawSparkle(canvas, paint, s,
        s * 0.40, s * 0.50, s * 0.30, s * 0.40);

    // Companion sparkle — smaller, top-right
    _drawSparkle(canvas, paint, s,
        s * 0.80, s * 0.20, s * 0.12, s * 0.14);
  }

  @override
  bool shouldRepaint(_AiPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// MIC — microphone capsule + stand
// ─────────────────────────────────────────────────────────────────────────────

class _MicPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _MicPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Mic capsule — thinner rounded pill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.38, s * 0.10, s * 0.62, s * 0.48),
        Radius.circular(s * 0.12),
      ),
      paint,
    );

    // Pickup arc — gap below capsule, wraps wider
    final arc = Path()
      ..moveTo(s * 0.26, s * 0.40)
      ..cubicTo(s * 0.26, s * 0.66, s * 0.74, s * 0.66, s * 0.74, s * 0.40);
    canvas.drawPath(arc, paint);

    // Stand
    canvas.drawLine(Offset(s * 0.50, s * 0.66), Offset(s * 0.50, s * 0.80), paint);

    // Base
    canvas.drawLine(Offset(s * 0.36, s * 0.80), Offset(s * 0.64, s * 0.80), paint);
  }

  @override
  bool shouldRepaint(_MicPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// VOLUME — speaker with sound waves
// ─────────────────────────────────────────────────────────────────────────────

class _VolumePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _VolumePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Speaker body — cone shape with rounded joins
    final speaker = Path()
      ..moveTo(s * 0.14, s * 0.40)
      ..lineTo(s * 0.28, s * 0.40)
      ..lineTo(s * 0.46, s * 0.22)
      ..cubicTo(s * 0.50, s * 0.18, s * 0.52, s * 0.20, s * 0.52, s * 0.24)
      ..lineTo(s * 0.52, s * 0.76)
      ..cubicTo(s * 0.52, s * 0.80, s * 0.50, s * 0.82, s * 0.46, s * 0.78)
      ..lineTo(s * 0.28, s * 0.60)
      ..lineTo(s * 0.14, s * 0.60)
      ..cubicTo(s * 0.12, s * 0.60, s * 0.12, s * 0.40, s * 0.14, s * 0.40);
    canvas.drawPath(speaker, paint);

    // Sound wave arcs
    for (int i = 0; i < 2; i++) {
      final r = s * (0.14 + i * 0.12);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(s * 0.52, s * 0.50), radius: r),
        -0.8,
        1.6,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_VolumePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// CALCULATOR — rounded body with display + button grid
// ─────────────────────────────────────────────────────────────────────────────

class _CalculatorPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _CalculatorPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.08;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.18, s * 0.10, s * 0.82, s * 0.90),
        Radius.circular(r),
      ),
      paint,
    );

    // Display — small inner rounded rect at top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.28, s * 0.20, s * 0.72, s * 0.36),
        Radius.circular(s * 0.04),
      ),
      paint,
    );

    // Button dots (3×2 grid)
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final dotR = s * 0.035;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        canvas.drawCircle(
          Offset(s * (0.36 + col * 0.14), s * (0.50 + row * 0.12)),
          dotR,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CalculatorPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// VIDEO — camera body with lens
// ─────────────────────────────────────────────────────────────────────────────

class _VideoPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _VideoPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.08;

    // Camera body — rounded rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.10, s * 0.28, s * 0.60, s * 0.72),
        Radius.circular(r),
      ),
      paint,
    );

    // Viewfinder triangle — proper closed wedge pointing right
    final wedge = Path()
      ..moveTo(s * 0.64, s * 0.38)
      ..lineTo(s * 0.84, s * 0.30)
      ..cubicTo(s * 0.88, s * 0.28, s * 0.90, s * 0.30, s * 0.90, s * 0.34)
      ..lineTo(s * 0.90, s * 0.66)
      ..cubicTo(s * 0.90, s * 0.70, s * 0.88, s * 0.72, s * 0.84, s * 0.70)
      ..lineTo(s * 0.64, s * 0.62);
    canvas.drawPath(wedge, paint);
  }

  @override
  bool shouldRepaint(_VideoPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE — speech bubble
// ─────────────────────────────────────────────────────────────────────────────

class _MessagePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _MessagePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    final bubble = Path()
      ..moveTo(s * 0.50, s * 0.82)
      // Tail — soft curve going to bottom-left
      ..cubicTo(s * 0.40, s * 0.74, s * 0.24, s * 0.72, s * 0.16, s * 0.72)
      // Left side curves up
      ..cubicTo(s * 0.10, s * 0.72, s * 0.10, s * 0.58, s * 0.10, s * 0.42)
      // Top-left corner
      ..cubicTo(s * 0.10, s * 0.22, s * 0.18, s * 0.18, s * 0.30, s * 0.18)
      // Top
      ..lineTo(s * 0.70, s * 0.18)
      // Top-right corner
      ..cubicTo(s * 0.82, s * 0.18, s * 0.90, s * 0.22, s * 0.90, s * 0.42)
      // Right side
      ..lineTo(s * 0.90, s * 0.58)
      // Bottom-right corner
      ..cubicTo(s * 0.90, s * 0.72, s * 0.82, s * 0.72, s * 0.70, s * 0.72)
      // Bottom back to tail
      ..lineTo(s * 0.56, s * 0.72)
      ..cubicTo(s * 0.54, s * 0.76, s * 0.52, s * 0.80, s * 0.50, s * 0.82);
    canvas.drawPath(bubble, paint);
  }

  @override
  bool shouldRepaint(_MessagePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIL — envelope with rounded flap
// ─────────────────────────────────────────────────────────────────────────────

class _MailPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _MailPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.08;

    // Envelope body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.10, s * 0.22, s * 0.90, s * 0.78),
        Radius.circular(r),
      ),
      paint,
    );

    // Flap — V shape with curves
    final flap = Path()
      ..moveTo(s * 0.10, s * 0.26)
      ..cubicTo(s * 0.30, s * 0.42, s * 0.44, s * 0.56, s * 0.50, s * 0.56)
      ..cubicTo(s * 0.56, s * 0.56, s * 0.70, s * 0.42, s * 0.90, s * 0.26);
    canvas.drawPath(flap, paint);
  }

  @override
  bool shouldRepaint(_MailPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOWER — rounded petals around a center dot
// ─────────────────────────────────────────────────────────────────────────────

class _FlowerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _FlowerPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final cx = s * 0.50;
    final cy = s * 0.50;
    final petalR = s * 0.16;
    final dist = s * 0.18;

    // 5 rounded petals evenly spaced
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 5);
      final px = cx + dist * math.cos(angle);
      final py = cy + dist * math.sin(angle);
      canvas.drawCircle(Offset(px, py), petalR, paint);
    }

    // Center dot — filled
    canvas.drawCircle(
      Offset(cx, cy),
      s * 0.07,
      paint..style = PaintingStyle.fill,
    );
    paint.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(_FlowerPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// WALLET — folded billfold with rounded edges
// ─────────────────────────────────────────────────────────────────────────────

class _WalletPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _WalletPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.08;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.12, s * 0.24, s * 0.88, s * 0.76),
        Radius.circular(r),
      ),
      paint,
    );

    // Flap fold — subtle curve across the top
    final flap = Path()
      ..moveTo(s * 0.12, s * 0.38)
      ..cubicTo(s * 0.30, s * 0.34, s * 0.70, s * 0.34, s * 0.88, s * 0.38);
    canvas.drawPath(flap, paint);

    // Card slot — small rounded rect on the right
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.62, s * 0.44, s * 0.82, s * 0.56),
        Radius.circular(s * 0.04),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_WalletPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// KEY — rounded key with horizontal shaft
// ─────────────────────────────────────────────────────────────────────────────

class _KeyPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _KeyPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Key head — circle on the left
    final headCx = s * 0.30;
    final headCy = s * 0.50;
    final headR = s * 0.18;
    canvas.drawCircle(Offset(headCx, headCy), headR, paint);

    // Inner keyhole dot
    canvas.drawCircle(Offset(headCx, headCy), s * 0.06, paint);

    // Shaft — horizontal from circle edge to the right
    final shaftStart = headCx + headR;
    canvas.drawLine(Offset(shaftStart, headCy), Offset(s * 0.86, headCy), paint);

    // Teeth — two short downward nubs
    canvas.drawLine(Offset(s * 0.70, headCy), Offset(s * 0.70, s * 0.64), paint);
    canvas.drawLine(Offset(s * 0.82, headCy), Offset(s * 0.82, s * 0.64), paint);
  }

  @override
  bool shouldRepaint(_KeyPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADPHONE — padded band + thick cushion cups
// ─────────────────────────────────────────────────────────────────────────────

class _HeadphonePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _HeadphonePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Headband — thick padded arc
    final band = Path()
      ..moveTo(s * 0.16, s * 0.48)
      ..cubicTo(s * 0.16, s * 0.14, s * 0.84, s * 0.14, s * 0.84, s * 0.48);
    canvas.drawPath(band, paint);

    // Left ear cup — thick rounded capsule with depth
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.08, s * 0.46, s * 0.26, s * 0.78),
        Radius.circular(s * 0.09),
      ),
      paint,
    );
    // Left cushion inner detail
    canvas.drawLine(Offset(s * 0.17, s * 0.52), Offset(s * 0.17, s * 0.72), paint);

    // Right ear cup
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.74, s * 0.46, s * 0.92, s * 0.78),
        Radius.circular(s * 0.09),
      ),
      paint,
    );
    // Right cushion inner detail
    canvas.drawLine(Offset(s * 0.83, s * 0.52), Offset(s * 0.83, s * 0.72), paint);
  }

  @override
  bool shouldRepaint(_HeadphonePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// WATCH — wristwatch face + band hints
// ─────────────────────────────────────────────────────────────────────────────

class _WatchPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _WatchPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Watch face — rounded square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.28, s * 0.28, s * 0.72, s * 0.72),
        Radius.circular(s * 0.12),
      ),
      paint,
    );

    // Top band
    final topBand = Path()
      ..moveTo(s * 0.38, s * 0.28)
      ..cubicTo(s * 0.38, s * 0.16, s * 0.62, s * 0.16, s * 0.62, s * 0.28);
    canvas.drawPath(topBand, paint);

    // Bottom band
    final bottomBand = Path()
      ..moveTo(s * 0.38, s * 0.72)
      ..cubicTo(s * 0.38, s * 0.84, s * 0.62, s * 0.84, s * 0.62, s * 0.72);
    canvas.drawPath(bottomBand, paint);

    // Clock hands — hour + minute
    final center = Offset(s * 0.50, s * 0.50);
    canvas.drawLine(center, Offset(s * 0.50, s * 0.38), paint);
    canvas.drawLine(center, Offset(s * 0.58, s * 0.46), paint);
  }

  @override
  bool shouldRepaint(_WatchPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// LAPTOP — open screen + base
// ─────────────────────────────────────────────────────────────────────────────

class _LaptopPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _LaptopPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.06;

    // Screen — rounded rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.18, s * 0.18, s * 0.82, s * 0.62),
        Radius.circular(r),
      ),
      paint,
    );

    // Base / keyboard — wider trapezoid with rounded ends
    final base = Path()
      ..moveTo(s * 0.18, s * 0.66)
      ..cubicTo(s * 0.14, s * 0.66, s * 0.10, s * 0.76, s * 0.10, s * 0.78)
      ..cubicTo(s * 0.10, s * 0.80, s * 0.12, s * 0.80, s * 0.14, s * 0.80)
      ..lineTo(s * 0.86, s * 0.80)
      ..cubicTo(s * 0.88, s * 0.80, s * 0.90, s * 0.80, s * 0.90, s * 0.78)
      ..cubicTo(s * 0.90, s * 0.76, s * 0.86, s * 0.66, s * 0.82, s * 0.66);
    canvas.drawPath(base, paint);
  }

  @override
  bool shouldRepaint(_LaptopPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE — phone with rounded corners
// ─────────────────────────────────────────────────────────────────────────────

class _MobilePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _MobilePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.10;

    // Phone body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.28, s * 0.10, s * 0.72, s * 0.90),
        Radius.circular(r),
      ),
      paint,
    );

    // Notch / earpiece — small pill at top
    canvas.drawLine(Offset(s * 0.44, s * 0.18), Offset(s * 0.56, s * 0.18), paint);

    // Home indicator — small bar at bottom
    canvas.drawLine(Offset(s * 0.40, s * 0.82), Offset(s * 0.60, s * 0.82), paint);
  }

  @override
  bool shouldRepaint(_MobilePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP — monitor on a stand
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _DesktopPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;
    final r = s * 0.06;

    // Screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.10, s * 0.14, s * 0.90, s * 0.62),
        Radius.circular(r),
      ),
      paint,
    );

    // Neck
    canvas.drawLine(Offset(s * 0.50, s * 0.62), Offset(s * 0.50, s * 0.74), paint);

    // Base — wide rounded line
    final base = Path()
      ..moveTo(s * 0.30, s * 0.78)
      ..cubicTo(s * 0.34, s * 0.74, s * 0.66, s * 0.74, s * 0.70, s * 0.78);
    canvas.drawPath(base, paint);
  }

  @override
  bool shouldRepaint(_DesktopPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// CUP — mug with rounded handle
// ─────────────────────────────────────────────────────────────────────────────

class _CupPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _CupPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Mug body — tapered rounded shape
    final body = Path()
      ..moveTo(s * 0.18, s * 0.26)
      ..lineTo(s * 0.18, s * 0.70)
      ..cubicTo(s * 0.18, s * 0.82, s * 0.58, s * 0.82, s * 0.58, s * 0.70)
      ..lineTo(s * 0.58, s * 0.26);
    canvas.drawPath(body, paint);

    // Handle — rounded C on the right
    final handle = Path()
      ..moveTo(s * 0.58, s * 0.36)
      ..cubicTo(s * 0.78, s * 0.36, s * 0.78, s * 0.60, s * 0.58, s * 0.60);
    canvas.drawPath(handle, paint);

    // Steam — two wavy wisps
    final steam1 = Path()
      ..moveTo(s * 0.32, s * 0.22)
      ..cubicTo(s * 0.30, s * 0.16, s * 0.34, s * 0.12, s * 0.32, s * 0.08);
    canvas.drawPath(steam1, paint);
    final steam2 = Path()
      ..moveTo(s * 0.44, s * 0.22)
      ..cubicTo(s * 0.42, s * 0.16, s * 0.46, s * 0.12, s * 0.44, s * 0.08);
    canvas.drawPath(steam2, paint);
  }

  @override
  bool shouldRepaint(_CupPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// FLAG — rounded flag on a pole
// ─────────────────────────────────────────────────────────────────────────────

class _FlagPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _FlagPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide;

    // Pole
    canvas.drawLine(Offset(s * 0.22, s * 0.14), Offset(s * 0.22, s * 0.86), paint);

    // Flag — rounded flowing shape
    final flag = Path()
      ..moveTo(s * 0.22, s * 0.18)
      ..cubicTo(s * 0.44, s * 0.12, s * 0.60, s * 0.28, s * 0.80, s * 0.22)
      ..cubicTo(s * 0.80, s * 0.34, s * 0.80, s * 0.42, s * 0.80, s * 0.48)
      ..cubicTo(s * 0.60, s * 0.54, s * 0.44, s * 0.38, s * 0.22, s * 0.52);
    canvas.drawPath(flag, paint);
  }

  @override
  bool shouldRepaint(_FlagPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

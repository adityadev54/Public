import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import 'kin_button.dart';

/// Modern HSV color picker with fluid spring physics.
///
/// Supports saturation-brightness area, hue ring or hue strip mode,
/// optional opacity slider, and responsive landscape layout.
/// Haptic feedback removed from drag interactions; only button taps
/// produce haptics.
class KinColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color>? onConfirm;
  final VoidCallback? onCancel;
  final bool showOpacity;

  /// When true, shows a circular hue ring instead of the linear hue strip.
  final bool useHueRing;
  final String title;
  final String confirmLabel;
  final String cancelLabel;

  const KinColorPicker({
    super.key,
    this.initialColor = const Color(0xFFE84141),
    this.onConfirm,
    this.onCancel,
    this.showOpacity = false,
    this.useHueRing = false,
    this.title = 'Color Picker',
    this.confirmLabel = 'Select',
    this.cancelLabel = 'Cancel',
  });

  static Future<Color?> show({
    required BuildContext context,
    Color initialColor = const Color(0xFFE84141),
    bool showOpacity = false,
    bool useHueRing = false,
    String title = 'Color Picker',
    String confirmLabel = 'Select',
    String cancelLabel = 'Cancel',
  }) {
    return showGeneralDialog<Color>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x88000000),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = KinMotion.fluidEnter.transform(animation.value.clamp(0.0, 1.0));
            final slide = 0.12 * (1.0 - t);
            final scale = 0.92 + 0.08 * t;
            return Transform.translate(
              offset: Offset(0, slide * MediaQuery.sizeOf(context).height),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  opacity: animation.value.clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            );
          },
          child: SafeArea(
            child: _KinPickerLayout(
              child: KinColorPicker(
                initialColor: initialColor,
                showOpacity: showOpacity,
                useHueRing: useHueRing,
                title: title,
                confirmLabel: confirmLabel,
                cancelLabel: cancelLabel,
                onConfirm: (color) => Navigator.pop(ctx, color),
                onCancel: () => Navigator.pop(ctx),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  State<KinColorPicker> createState() => _KinColorPickerState();
}

class _KinColorPickerState extends State<KinColorPicker>
    with SingleTickerProviderStateMixin {
  late HSVColor _hsv;
  late double _opacity;
  late AnimationController _springCtrl;
  double _thumbScale = 1.0;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
    _opacity = widget.initialColor.a;
    _springCtrl = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  Color get _currentColor => _hsv.toColor().withValues(alpha: _opacity);

  String get _hexString {
    final c = _hsv.toColor();
    final r = (c.r * 255.0).round().clamp(0, 255);
    final g = (c.g * 255.0).round().clamp(0, 255);
    final b = (c.b * 255.0).round().clamp(0, 255);
    final a = (_opacity * 255.0).round().clamp(0, 255);
    if (widget.showOpacity && a < 255) {
      return '#${a.toRadixString(16).padLeft(2, '0')}'
          '${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}'
              .toUpperCase();
    }
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'
            .toUpperCase();
  }

  void _animateThumbPress() {
    _springCtrl.animateWith(SpringSimulation(
      KinMotion.fluidBounce, 1.0, 1.25, 0,
    ));
    _springCtrl.addListener(_thumbListener);
  }

  void _thumbListener() {
    if (mounted) setState(() => _thumbScale = _springCtrl.value);
    if (_springCtrl.isCompleted) _springCtrl.removeListener(_thumbListener);
  }

  void _animateThumbRelease() {
    _springCtrl.animateWith(SpringSimulation(
      KinMotion.fluidSnap, _thumbScale, 1.0, 0,
    ));
    _springCtrl.addListener(_thumbListener);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = KinTheme.of(context);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.85)
        : theme.surfaceVariant;

    return ClipRRect(
      borderRadius: KinRadius.xlAll,
      child: BackdropFilter(
        filter: isDark
            ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isLandscape ? 680 : 360,
              maxHeight: isLandscape ? 340 : double.infinity,
            ),
            width: double.infinity,
            padding: EdgeInsets.all(isLandscape ? KinSpacing.md : KinSpacing.lg),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: KinRadius.xlAll,
              boxShadow: isDark
                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)]
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: isLandscape ? _buildLandscape(theme) : _buildPortrait(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildPortrait(KinTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KinText.titleLarge(widget.title, color: theme.onSurface),
        const SizedBox(height: KinSpacing.md),
        if (widget.useHueRing) ...[
          Center(child: _hueRingWithSatBright(size: 220)),
        ] else ...[
          _satBrightArea(height: 180),
          const SizedBox(height: KinSpacing.md),
          _hueSlider(theme),
        ],
        if (widget.showOpacity) ...[
          const SizedBox(height: KinSpacing.sm),
          _opacitySlider(theme),
        ],
        const SizedBox(height: KinSpacing.md),
        _previewRow(theme),
        const SizedBox(height: KinSpacing.lg),
        _actionButtons(),
      ],
    );
  }

  Widget _buildLandscape(KinTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available height to size the ring, leaving room for padding
        final availH = constraints.maxHeight > 0 ? constraints.maxHeight : 280.0;
        final ringSize = widget.useHueRing
            ? (availH - 16).clamp(160.0, 320.0)
            : 170.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.useHueRing
                ? _hueRingWithSatBright(size: ringSize)
                : Expanded(flex: 3, child: _satBrightArea(height: 170)),
            const SizedBox(width: KinSpacing.lg),
            Expanded(
              flex: widget.useHueRing ? 1 : 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _previewRow(theme),
                  const SizedBox(height: KinSpacing.sm),
                  if (!widget.useHueRing) _hueSlider(theme),
                  if (widget.showOpacity) ...[
                    const SizedBox(height: KinSpacing.sm),
                    _opacitySlider(theme),
                  ],
                  const SizedBox(height: KinSpacing.md),
                  _actionButtons(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Hue Ring + central Sat/Bright square ──

  Widget _hueRingWithSatBright({required double size}) {
    const ringWidth = 26.0;
    final innerSize = size - ringWidth * 2 - 8;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _HueRing(
            hue: _hsv.hue,
            size: size,
            ringWidth: ringWidth,
            thumbScale: _thumbScale,
            onChanged: (hue) => setState(() => _hsv = _hsv.withHue(hue)),
            onDragStart: _animateThumbPress,
            onDragEnd: _animateThumbRelease,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: innerSize,
              height: innerSize,
              child: _SatBrightArea(
                hue: _hsv.hue,
                saturation: _hsv.saturation,
                value: _hsv.value,
                onChanged: (sat, val) {
                  setState(() => _hsv = _hsv.withSaturation(sat).withValue(val));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _satBrightArea({required double height}) {
    return ClipRRect(
      borderRadius: KinRadius.mdAll,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: _SatBrightArea(
          hue: _hsv.hue,
          saturation: _hsv.saturation,
          value: _hsv.value,
          onChanged: (sat, val) {
            setState(() => _hsv = _hsv.withSaturation(sat).withValue(val));
          },
        ),
      ),
    );
  }

  Widget _hueSlider(KinTheme theme) {
    return _KinColorTrack(
      value: _hsv.hue / 360.0,
      onChanged: (v) => setState(() => _hsv = _hsv.withHue(v * 360.0)),
      trackGradient: LinearGradient(
        colors: List.generate(7, (i) => HSVColor.fromAHSV(1, i * 60.0, 1, 1).toColor()),
      ),
      thumbColor: HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor(),
    );
  }

  Widget _opacitySlider(KinTheme theme) {
    final solidColor = _hsv.toColor();
    return _KinColorTrack(
      value: _opacity,
      onChanged: (v) => setState(() => _opacity = v),
      trackGradient: LinearGradient(
        colors: [solidColor.withValues(alpha: 0.0), solidColor],
      ),
      thumbColor: _currentColor,
      showCheckerboard: true,
    );
  }

  Widget _previewRow(KinTheme theme) {
    return Row(
      children: [
        TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: _currentColor),
          duration: const Duration(milliseconds: 200),
          curve: KinMotion.fluidEnter,
          builder: (context, color, _) => Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,

            ),
          ),
        ),
        const SizedBox(width: KinSpacing.md),
        Expanded(
          child: KinText.bodyLarge(_hexString, color: theme.onSurface),
        ),
        if (widget.showOpacity)
          KinText(
            '${(_opacity * 100).round()}%',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            color: theme.onSurfaceVariant,
          ),
      ],
    );
  }

  Widget _actionButtons() {
    return Row(
      spacing: KinSpacing.sm,
      children: [
        Expanded(
          child: KinButton(
            label: widget.cancelLabel,
            variant: KinButtonVariant.secondary,
            onTap: widget.onCancel,
          ),
        ),
        Expanded(
          child: KinButton(
            label: widget.confirmLabel,
            onTap: () => widget.onConfirm?.call(_currentColor),
          ),
        ),
      ],
    );
  }
}

// ── Hue Ring ──

class _HueRing extends StatelessWidget {
  final double hue;
  final double size;
  final double ringWidth;
  final double thumbScale;
  final ValueChanged<double> onChanged;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  const _HueRing({
    required this.hue,
    required this.size,
    required this.ringWidth,
    required this.thumbScale,
    required this.onChanged,
    required this.onDragStart,
    required this.onDragEnd,
  });

  void _handleInteraction(Offset localPosition) {
    final center = Offset(size / 2, size / 2);
    final angle = math.atan2(
      localPosition.dy - center.dy,
      localPosition.dx - center.dx,
    );
    var degrees = angle * 180 / math.pi + 90;
    if (degrees < 0) degrees += 360;
    onChanged(degrees % 360);
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    return GestureDetector(
      onPanStart: (d) {
        onDragStart();
        _handleInteraction(d.localPosition);
      },
      onPanUpdate: (d) => _handleInteraction(d.localPosition),
      onPanEnd: (_) => onDragEnd(),
      child: CustomPaint(
        size: Size(size, size),
        painter: _HueRingPainter(ringWidth: ringWidth),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned(
                left: size / 2 +
                    (size / 2 - ringWidth / 2) * math.cos((hue - 90) * math.pi / 180) -
                    ringWidth / 2,
                top: size / 2 +
                    (size / 2 - ringWidth / 2) * math.sin((hue - 90) * math.pi / 180) -
                    ringWidth / 2,
                child: Transform.scale(
                  scale: thumbScale,
                  child: Container(
                    width: ringWidth,
                    height: ringWidth,
                    decoration: BoxDecoration(
                      color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFFFFF), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: theme.onSurface.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HueRingPainter extends CustomPainter {
  final double ringWidth;
  _HueRingPainter({required this.ringWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - ringWidth / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: List.generate(361, (i) => HSVColor.fromAHSV(1, i.toDouble(), 1, 1).toColor()),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _HueRingPainter old) => ringWidth != old.ringWidth;
}

// ── Fluid color track slider ──

class _KinColorTrack extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final LinearGradient trackGradient;
  final Color thumbColor;
  final bool showCheckerboard;

  const _KinColorTrack({
    required this.value,
    required this.onChanged,
    required this.trackGradient,
    required this.thumbColor,
    this.showCheckerboard = false,
  });

  @override
  State<_KinColorTrack> createState() => _KinColorTrackState();
}

class _KinColorTrackState extends State<_KinColorTrack>
    with SingleTickerProviderStateMixin {
  bool _dragging = false;
  late AnimationController _scaleCtrl;
  double _thumbScale = 1.0;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController.unbounded(vsync: this, value: 1.0);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _update(double localX, double width) {
    widget.onChanged((localX / width).clamp(0.0, 1.0));
  }

  void _onDragStart() {
    _dragging = true;
    _scaleCtrl.animateWith(SpringSimulation(KinMotion.fluidBounce, 1.0, 1.3, 0));
    _scaleCtrl.addListener(_scaleListener);
  }

  void _onDragEnd() {
    _dragging = false;
    _scaleCtrl.animateWith(SpringSimulation(KinMotion.fluidSnap, _thumbScale, 1.0, 0));
    _scaleCtrl.addListener(_scaleListener);
  }

  void _scaleListener() {
    if (mounted) setState(() => _thumbScale = _scaleCtrl.value);
    if (_scaleCtrl.isCompleted) _scaleCtrl.removeListener(_scaleListener);
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        const trackHeight = 28.0;
        const thumbRadius = 10.0;
        return GestureDetector(
          onHorizontalDragStart: (d) {
            _onDragStart();
            _update(d.localPosition.dx, trackWidth);
          },
          onHorizontalDragUpdate: (d) => _update(d.localPosition.dx, trackWidth),
          onHorizontalDragEnd: (_) => _onDragEnd(),
          onTapDown: (d) => _update(d.localPosition.dx, trackWidth),
          child: SizedBox(
            height: trackHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: KinRadius.pillAll,
                  child: SizedBox(
                    height: trackHeight,
                    width: trackWidth,
                    child: CustomPaint(
                      painter: _GradientTrackPainter(
                        gradient: widget.trackGradient,
                        showCheckerboard: widget.showCheckerboard,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: _dragging ? Duration.zero : KinMotion.fast,
                  curve: KinMotion.fluidEnter,
                  left: widget.value * (trackWidth - thumbRadius * 2),
                  child: Transform.scale(
                    scale: _thumbScale,
                    child: Container(
                      width: thumbRadius * 2,
                      height: thumbRadius * 2,
                      decoration: BoxDecoration(
                        color: widget.thumbColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFFFFF), width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: theme.onSurface.withValues(alpha: 0.15),
                            blurRadius: _dragging ? 8 : 3,
                            offset: const Offset(0, 1),
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
      },
    );
  }
}

class _GradientTrackPainter extends CustomPainter {
  final LinearGradient gradient;
  final bool showCheckerboard;
  _GradientTrackPainter({required this.gradient, this.showCheckerboard = false});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (showCheckerboard) {
      const cs = 6.0;
      final lp = Paint()..color = const Color(0xFFFFFFFF);
      final dp = Paint()..color = const Color(0xFFCCCCCC);
      for (double y = 0; y < size.height; y += cs) {
        for (double x = 0; x < size.width; x += cs) {
          canvas.drawRect(Rect.fromLTWH(x, y, cs, cs),
              ((x ~/ cs) + (y ~/ cs)) % 2 == 0 ? lp : dp);
        }
      }
    }
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant _GradientTrackPainter old) => gradient != old.gradient;
}

// ── Layout helper ──

class _KinPickerLayout extends StatelessWidget {
  final Widget child;
  const _KinPickerLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    final sp = MediaQuery.paddingOf(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          left: KinSpacing.sm + sp.left,
          right: KinSpacing.sm + sp.right,
          bottom: KinSpacing.xs,
        ),
        child: child,
      ),
    );
  }
}

// ── Saturation-Brightness 2D area ──

class _SatBrightArea extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final void Function(double saturation, double value) onChanged;

  const _SatBrightArea({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  void _handle(Offset pos, Size size) {
    final sat = (pos.dx / size.width).clamp(0.0, 1.0);
    final val = 1.0 - (pos.dy / size.height).clamp(0.0, 1.0);
    onChanged(sat, val);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanStart: (d) => _handle(d.localPosition, size),
          onPanUpdate: (d) => _handle(d.localPosition, size),
          child: CustomPaint(
            size: size,
            painter: _SatBrightPainter(hue: hue, saturation: saturation, value: value),
          ),
        );
      },
    );
  }
}

class _SatBrightPainter extends CustomPainter {
  final double hue, saturation, value;
  _SatBrightPainter({required this.hue, required this.saturation, required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = HSVColor.fromAHSV(1, hue, 1, 1).toColor());
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
    ).createShader(rect));
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x00000000), Color(0xFF000000)],
    ).createShader(rect));

    final dx = saturation * size.width;
    final dy = (1.0 - value) * size.height;
    canvas.drawCircle(Offset(dx, dy), 10, Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);
    canvas.drawCircle(Offset(dx, dy), 7.5,
        Paint()..color = HSVColor.fromAHSV(1, hue, saturation, value).toColor());
  }

  @override
  bool shouldRepaint(_SatBrightPainter old) =>
      old.hue != hue || old.saturation != saturation || old.value != value;
}

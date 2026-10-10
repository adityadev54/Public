import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_spacing.dart';
import '../core/kin_radius.dart';

/// Value holder for a range slider.
class KinRangeValues {
  final double start;
  final double end;

  const KinRangeValues(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KinRangeValues && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// A themed range slider with two draggable thumbs.
class KinRangeSlider extends StatefulWidget {
  final KinRangeValues values;
  final ValueChanged<KinRangeValues> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final bool enabled;

  const KinRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.enabled = true,
  });

  @override
  State<KinRangeSlider> createState() => _KinRangeSliderState();
}

enum _ActiveThumb { none, start, end }

class _KinRangeSliderState extends State<KinRangeSlider> {
  _ActiveThumb _active = _ActiveThumb.none;

  double get _startFrac {
    final range = widget.max - widget.min;
    if (range == 0) return 0.0;
    return ((widget.values.start - widget.min) / range).clamp(0.0, 1.0);
  }

  double get _endFrac {
    final range = widget.max - widget.min;
    if (range == 0) return 0.0;
    return ((widget.values.end - widget.min) / range).clamp(0.0, 1.0);
  }

  double _snap(double value) {
    if (widget.divisions != null && widget.divisions! > 0) {
      final step = (widget.max - widget.min) / widget.divisions!;
      value = (value / step).roundToDouble() * step;
    }
    return value.clamp(widget.min, widget.max);
  }

  double _valueAt(double localX, double trackWidth) {
    final raw = (localX / trackWidth).clamp(0.0, 1.0);
    return _snap(widget.min + raw * (widget.max - widget.min));
  }

  void _onDragStart(DragStartDetails d, double trackWidth) {
    if (!widget.enabled) return;
    final x = d.localPosition.dx;
    final startX = _startFrac * trackWidth;
    final endX = _endFrac * trackWidth;
    final distStart = (x - startX).abs();
    final distEnd = (x - endX).abs();

    setState(() {
      _active = distStart <= distEnd ? _ActiveThumb.start : _ActiveThumb.end;
    });
    _updateValue(x, trackWidth);
  }

  void _onDragUpdate(DragUpdateDetails d, double trackWidth) {
    if (!widget.enabled || _active == _ActiveThumb.none) return;
    _updateValue(d.localPosition.dx, trackWidth);
  }

  void _onDragEnd(DragEndDetails _) {
    setState(() => _active = _ActiveThumb.none);
  }

  void _onTap(TapDownDetails d, double trackWidth) {
    if (!widget.enabled) return;
    final x = d.localPosition.dx;
    final startX = _startFrac * trackWidth;
    final endX = _endFrac * trackWidth;
    final distStart = (x - startX).abs();
    final distEnd = (x - endX).abs();

    final thumb = distStart <= distEnd ? _ActiveThumb.start : _ActiveThumb.end;
    setState(() => _active = thumb);
    _updateValue(x, trackWidth);
    setState(() => _active = _ActiveThumb.none);
  }

  void _updateValue(double localX, double trackWidth) {
    final val = _valueAt(localX, trackWidth);
    if (_active == _ActiveThumb.start) {
      final clamped = val.clamp(widget.min, widget.values.end);
      widget.onChanged(KinRangeValues(_snap(clamped), widget.values.end));
    } else if (_active == _ActiveThumb.end) {
      final clamped = val.clamp(widget.values.start, widget.max);
      widget.onChanged(KinRangeValues(widget.values.start, _snap(clamped)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final opacity = widget.enabled ? 1.0 : 0.4;

    const trackHeight = 4.0;
    const thumbW = 24.0;
    const thumbH = 18.0;
    const thumbDragExtra = 4.0;

    return Opacity(
      opacity: opacity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final isDraggingStart = _active == _ActiveThumb.start;
          final isDraggingEnd = _active == _ActiveThumb.end;
          final isDragging = _active != _ActiveThumb.none;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: widget.enabled
                ? (d) => _onDragStart(d, trackWidth)
                : null,
            onHorizontalDragUpdate: widget.enabled
                ? (d) => _onDragUpdate(d, trackWidth)
                : null,
            onHorizontalDragEnd: widget.enabled ? _onDragEnd : null,
            onTapDown: widget.enabled
                ? (d) => _onTap(d, trackWidth)
                : null,
            child: SizedBox(
              height: thumbH + KinSpacing.sm * 2,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Inactive track
                  Container(
                    height: trackHeight,
                    decoration: BoxDecoration(
                      color: theme.outline,
                      borderRadius: BorderRadius.circular(KinRadius.pill),
                    ),
                  ),

                  // Active track (between thumbs)
                  AnimatedPositioned(
                    duration: isDragging ? Duration.zero : KinMotion.fast,
                    curve: KinMotion.enter,
                    left: _startFrac * trackWidth,
                    top: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: isDragging ? Duration.zero : KinMotion.fast,
                        curve: KinMotion.enter,
                        height: trackHeight,
                        width: (_endFrac - _startFrac) * trackWidth,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: BorderRadius.circular(KinRadius.pill),
                        ),
                      ),
                    ),
                  ),

                  // Start thumb
                  AnimatedPositioned(
                    duration: isDragging ? Duration.zero : KinMotion.fast,
                    curve: KinMotion.enter,
                    left: _startFrac * trackWidth - thumbW / 2,
                    child: AnimatedContainer(
                      duration: KinMotion.fast,
                      width: isDraggingStart ? thumbW + thumbDragExtra : thumbW,
                      height: isDraggingStart ? thumbH + 2 : thumbH,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          (isDraggingStart ? thumbH + 2 : thumbH) / 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: 0.25),
                            blurRadius: isDraggingStart ? 8 : 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // End thumb
                  AnimatedPositioned(
                    duration: isDragging ? Duration.zero : KinMotion.fast,
                    curve: KinMotion.enter,
                    left: _endFrac * trackWidth - thumbW / 2,
                    child: AnimatedContainer(
                      duration: KinMotion.fast,
                      width: isDraggingEnd ? thumbW + thumbDragExtra : thumbW,
                      height: isDraggingEnd ? thumbH + 2 : thumbH,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          (isDraggingEnd ? thumbH + 2 : thumbH) / 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: 0.25),
                            blurRadius: isDraggingEnd ? 8 : 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

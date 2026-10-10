import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_spacing.dart';
import '../core/kin_radius.dart';

/// A custom slider with themed track and animated thumb.
class KinSlider extends StatefulWidget {
  final bool nativeAppearance;
  final Color? activeColor;
  final Color? inactiveColor;
  final ValueChanged<double>? onChangeEnd;
  final ValueChanged<double>? onChangeStart;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final bool enabled;

  const KinSlider({
    super.key,
    this.nativeAppearance = false,
    this.activeColor,
    this.inactiveColor,
    this.onChangeEnd,
    this.onChangeStart,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.enabled = true,
  });

  @override
  State<KinSlider> createState() => _KinSliderState();
}

class _KinSliderState extends State<KinSlider>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;

  double get _fraction {
    final range = widget.max - widget.min;
    if (range == 0) return 0.0;
    return ((widget.value - widget.min) / range).clamp(0.0, 1.0);
  }

  double _valueFromPosition(double localX, double trackWidth) {
    final raw = (localX / trackWidth).clamp(0.0, 1.0);
    double value = widget.min + raw * (widget.max - widget.min);
    if (widget.divisions != null && widget.divisions! > 0) {
      final step = (widget.max - widget.min) / widget.divisions!;
      value = widget.min + ((value - widget.min) / step).roundToDouble() * step;
    }
    return value.clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nativeAppearance) {
      return Slider(
        value: widget.value,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        onChanged: widget.enabled ? widget.onChanged : null,
        onChangeStart: widget.onChangeStart,
        onChangeEnd: widget.onChangeEnd,
        activeColor: widget.activeColor,
        inactiveColor: widget.inactiveColor,
      );
    }
    final theme = KinTheme.of(context);
    final opacity = widget.enabled ? 1.0 : 0.4;

    const trackHeight = 4.0;
    const thumbWidth = 24.0;
    const thumbHeight = 18.0;
    const thumbDragExtra = 4.0;

    return Opacity(
      opacity: opacity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: widget.enabled
                ? (d) {
                    setState(() => _isDragging = true);
                    final val = _valueFromPosition(
                      d.localPosition.dx,
                      trackWidth,
                    );
                    widget.onChanged(val);
                  }
                : null,
            onHorizontalDragUpdate: widget.enabled
                ? (d) {
                    final val = _valueFromPosition(
                      d.localPosition.dx,
                      trackWidth,
                    );
                    widget.onChanged(val);
                  }
                : null,
            onHorizontalDragEnd: widget.enabled
                ? (_) => setState(() => _isDragging = false)
                : null,
            onTapDown: widget.enabled
                ? (d) {
                    final val = _valueFromPosition(
                      d.localPosition.dx,
                      trackWidth,
                    );
                    widget.onChanged(val);
                  }
                : null,
            child: SizedBox(
              height: thumbHeight + KinSpacing.sm * 2,
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

                  // Active track
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: _isDragging ? Duration.zero : KinMotion.fast,
                      curve: KinMotion.enter,
                      height: trackHeight,
                      width: _fraction * trackWidth,
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(KinRadius.pill),
                      ),
                    ),
                  ),

                  // Thumb — horizontal pill matching toggle design
                  AnimatedPositioned(
                    duration: _isDragging ? Duration.zero : KinMotion.fast,
                    curve: KinMotion.enter,
                    left: _fraction * trackWidth - thumbWidth / 2,
                    child: AnimatedContainer(
                      duration: KinMotion.fast,
                      width: _isDragging
                          ? thumbWidth + thumbDragExtra
                          : thumbWidth,
                      height: _isDragging ? thumbHeight + 2 : thumbHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          (_isDragging ? thumbHeight + 2 : thumbHeight) / 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: 0.25),
                            blurRadius: _isDragging ? 8 : 4,
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

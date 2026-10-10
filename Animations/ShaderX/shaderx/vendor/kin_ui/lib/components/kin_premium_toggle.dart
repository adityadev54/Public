import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';

/// Pill-shaped animated toggle with spring physics and clean minimal design.
///
/// The thumb is a rounded pill (not a circle), matching KinUI's pill-first
/// design language. No icons, no inner content — just shape, color, and motion.
class KinPremiumToggle extends StatefulWidget {
  /// Whether the toggle is in the "on" state.
  final bool nativeAppearance;
  final Color? activeColor;
  final Color? activeTrackColor;
  final MaterialTapTargetSize? materialTapTargetSize;
  final bool value;

  /// Called when the toggle state changes.
  final ValueChanged<bool>? onChanged;

  /// Whether the toggle accepts interactions.
  final bool enabled;

  /// Optional label displayed to the right of toggle.
  final String? label;

  /// Size variant.
  final KinToggleSize size;

  const KinPremiumToggle({
    super.key,
    this.nativeAppearance = false,
    this.activeColor,
    this.activeTrackColor,
    this.materialTapTargetSize,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.label,
    this.size = KinToggleSize.medium,
  });

  @override
  State<KinPremiumToggle> createState() => _KinPremiumToggleState();
}

enum KinToggleSize { small, medium, large }

class _KinPremiumToggleState extends State<KinPremiumToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _position; // 0 = left, 1 = right
  late Animation<double> _thumbStretch; // widens during motion

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: KinMotion.normal, vsync: this);
    _buildAnimations();
    if (widget.value) _controller.value = 1.0;
  }

  void _buildAnimations() {
    // Main slide — spring overshoot for a bouncy landing
    _position = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Stretch: ramps up gently (soft inside), peaks, then snaps back
    // sharply (hard outside). The asymmetric weights create that feel.
    _thumbStretch = TweenSequence<double>([
      // Slow, gentle ramp up — soft internal feel
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutSine)),
        weight: 30,
      ),
      // Hold peak briefly
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 10),
      // Fast snap back — hard outer feel
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInQuart)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(KinPremiumToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  void _handleTap() {
    if (!widget.enabled) return;
    HapticFeedback.lightImpact();
    widget.onChanged?.call(!widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nativeAppearance) {
      return Switch.adaptive(
        value: widget.value,
        onChanged: widget.enabled ? widget.onChanged : null,
        activeColor: widget.activeColor,
        activeTrackColor: widget.activeTrackColor,
        materialTapTargetSize: widget.materialTapTargetSize,
      );
    }
    final theme = KinTheme.of(context);
    final d = _dimensions;

    return AnimatedOpacity(
      duration: KinMotion.fast,
      opacity: widget.enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: _handleTap,
        onTapDown: widget.enabled
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: widget.enabled
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: widget.enabled
            ? () => setState(() => _isPressed = false)
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Track + Thumb ──
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _position.value.clamp(0.0, 1.0);
                final stretch = _thumbStretch.value;

                // Track color: outline → primary
                final trackColor = Color.lerp(theme.outline, theme.primary, t)!;

                // Horizontal pill stretches wider during slide
                final thumbW = d.thumbWidth + (d.stretchExtra * stretch);
                final thumbH = d.thumbHeight;

                // Keep thumb inside the track at all times
                final maxLeft = d.trackWidth - thumbW - d.inset;
                final travel = maxLeft - d.inset;
                final thumbLeft = (d.inset + travel * t).clamp(
                  d.inset,
                  maxLeft,
                );

                return AnimatedScale(
                  duration: KinMotion.fast,
                  scale: _isPressed ? KinMotion.pressScale : 1.0,
                  child: Container(
                    width: d.trackWidth,
                    height: d.trackHeight,
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(d.trackHeight / 2),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: thumbLeft,
                          top:
                              (d.trackHeight - thumbH) /
                              2, // vertically centered
                          child: Container(
                            width: thumbW,
                            height: thumbH,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(thumbH / 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 4,
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

            // ── Optional label ──
            if (widget.label != null) ...[
              SizedBox(width: d.labelGap),
              Flexible(
                child: Text(
                  widget.label!,
                  style: TextStyle(
                    color: widget.enabled
                        ? theme.onSurface
                        : theme.onSurfaceVariant,
                    fontSize: d.labelSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _Dims get _dimensions => switch (widget.size) {
    // Horizontal pill: thumbWidth > thumbHeight, thin gap to track edge
    KinToggleSize.small => const _Dims(
      trackWidth: 50,
      trackHeight: 24,
      thumbWidth: 24,
      thumbHeight: 18,
      stretchExtra: 8,
      inset: 3,
      labelGap: 8,
      labelSize: 12,
    ),
    KinToggleSize.medium => const _Dims(
      trackWidth: 60,
      trackHeight: 28,
      thumbWidth: 34,
      thumbHeight: 24,
      stretchExtra: 10,
      inset: 3,
      labelGap: 10,
      labelSize: 14,
    ),
    KinToggleSize.large => const _Dims(
      trackWidth: 60,
      trackHeight: 30,
      thumbWidth: 35,
      thumbHeight: 24,
      stretchExtra: 12,
      inset: 3,
      labelGap: 12,
      labelSize: 16,
    ),
  };
}

class _Dims {
  final double trackWidth;
  final double trackHeight;
  final double thumbWidth; // resting width
  final double thumbHeight;
  final double stretchExtra; // extra width added at peak motion
  final double inset; // padding inside track
  final double labelGap;
  final double labelSize;

  const _Dims({
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbWidth,
    required this.thumbHeight,
    required this.stretchExtra,
    required this.inset,
    required this.labelGap,
    required this.labelSize,
  });
}

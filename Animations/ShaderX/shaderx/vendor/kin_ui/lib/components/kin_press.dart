import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../core/kin_motion.dart';

/// Wraps a child with spring-driven scale press animation and optional haptic feedback.
class KinPress extends StatefulWidget {
  final HitTestBehavior behavior;
  final bool haptics;
  final double disabledOpacity;
  final bool buttonSemantics;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double scale;

  const KinPress({
    super.key,
    this.behavior = HitTestBehavior.opaque,
    this.haptics = true,
    this.disabledOpacity = 0.4,
    this.buttonSemantics = false,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.scale = KinMotion.pressScale,
  });

  @override
  State<KinPress> createState() => _KinPressState();
}

class _KinPressState extends State<KinPress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isInteractive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  /// Tight spring for press-down, bouncier for release.
  static final _pressSpring = SpringDescription(
    mass: 1.0,
    stiffness: 500.0,
    damping: 30.0,
  );
  static final _releaseSpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 18.0,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!_isInteractive || MediaQuery.disableAnimationsOf(context)) return;
    _controller.animateWith(
      SpringSimulation(_pressSpring, _controller.value, widget.scale, 0),
    );
  }

  void _onTapUp(TapUpDetails _) {
    if (!_isInteractive || MediaQuery.disableAnimationsOf(context)) return;
    _controller.animateWith(
      SpringSimulation(_releaseSpring, _controller.value, 1.0, 0),
    );
  }

  void _onTapCancel() {
    if (!_isInteractive || MediaQuery.disableAnimationsOf(context)) return;
    _controller.animateWith(
      SpringSimulation(_releaseSpring, _controller.value, 1.0, 0),
    );
  }

  void _onTap() {
    if (!_isInteractive) return;
    if (widget.haptics) HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.buttonSemantics ? true : null,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: _isInteractive ? _onTapDown : null,
        onTapUp: _isInteractive ? _onTapUp : null,
        onTapCancel: _isInteractive ? _onTapCancel : null,
        onTap: widget.enabled && widget.onTap != null ? _onTap : null,
        onLongPress: widget.enabled && widget.onLongPress != null
            ? () {
                if (widget.haptics) HapticFeedback.mediumImpact();
                widget.onLongPress?.call();
              }
            : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: _controller.value.clamp(widget.scale - 0.05, 1.05),
            child: child,
          ),
          child: Opacity(
            opacity: _isInteractive ? 1.0 : widget.disabledOpacity,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

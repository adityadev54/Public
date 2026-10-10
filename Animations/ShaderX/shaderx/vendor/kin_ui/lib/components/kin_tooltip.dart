import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Tooltip placement relative to the child.
enum KinTooltipPosition { above, below, left, right }

/// A themed tooltip that shows on long-press with iOS 18 blur + spring animation.
class KinTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final Widget? content;
  final KinTooltipPosition position;
  final Duration duration;
  final bool haptic;

  const KinTooltip({
    super.key,
    required this.child,
    required this.message,
    this.content,
    this.position = KinTooltipPosition.above,
    this.duration = const Duration(seconds: 2),
    this.haptic = true,
  });

  @override
  State<KinTooltip> createState() => _KinTooltipState();
}

class _KinTooltipState extends State<KinTooltip>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _entry;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hide();
    _controller.dispose();
    super.dispose();
  }

  void _show() {
    if (_entry != null) return;
    if (widget.haptic) HapticFeedback.lightImpact();

    final renderBox = context.findRenderObject() as RenderBox;
    final childSize = renderBox.size;
    final childGlobal = renderBox.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context);
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _entry = OverlayEntry(
      builder: (ctx) {
        return _TooltipOverlay(
          childGlobal: childGlobal,
          childSize: childSize,
          position: widget.position,
          message: widget.message,
          content: widget.content,
          theme: theme,
          isDark: isDark,
          scaleAnimation: _scaleAnimation,
          fadeAnimation: _fadeAnimation,
          onDismiss: _hide,
        );
      },
    );

    overlay.insert(_entry!);
    _controller.forward(from: 0.0);

    _hideTimer?.cancel();
    _hideTimer = Timer(widget.duration, _hide);
  }

  void _hide() {
    _hideTimer?.cancel();
    if (_entry == null) return;
    _controller.reverse().then((_) {
      _entry?.remove();
      _entry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _show,
      onTap: _hide,
      child: widget.child,
    );
  }
}

class _TooltipOverlay extends StatelessWidget {
  final Offset childGlobal;
  final Size childSize;
  final KinTooltipPosition position;
  final String message;
  final Widget? content;
  final KinTheme theme;
  final bool isDark;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final VoidCallback onDismiss;

  const _TooltipOverlay({
    required this.childGlobal,
    required this.childSize,
    required this.position,
    required this.message,
    this.content,
    required this.theme,
    required this.isDark,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, _) {
              return CustomSingleChildLayout(
                delegate: _TooltipPositionDelegate(
                  childGlobal: childGlobal,
                  childSize: childSize,
                  position: position,
                  screenSize: screenSize,
                ),
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: ScaleTransition(
                    scale: scaleAnimation,
                    alignment: _originAlignment(),
                    child: _buildBubble(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Alignment _originAlignment() => switch (position) {
    KinTooltipPosition.above => Alignment.bottomCenter,
    KinTooltipPosition.below => Alignment.topCenter,
    KinTooltipPosition.left => Alignment.centerRight,
    KinTooltipPosition.right => Alignment.centerLeft,
  };

  Widget _buildBubble() {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(
        horizontal: KinSpacing.sm + 2,
        vertical: KinSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? theme.surfaceVariant.withValues(alpha: 0.92)
            : theme.onSurface.withValues(alpha: 0.88),
        borderRadius: KinRadius.mdAll,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: content ?? Text(
        message,
        style: KinTypography.bodySmall.copyWith(
          color: isDark ? theme.onSurface : Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );

    if (isDark) {
      return ClipRRect(
        borderRadius: KinRadius.mdAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: bubble,
        ),
      );
    }
    return bubble;
  }
}

class _TooltipPositionDelegate extends SingleChildLayoutDelegate {
  final Offset childGlobal;
  final Size childSize;
  final KinTooltipPosition position;
  final Size screenSize;

  _TooltipPositionDelegate({
    required this.childGlobal,
    required this.childSize,
    required this.position,
    required this.screenSize,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize2) {
    const gap = 8.0;
    final cx = childGlobal.dx + childSize.width / 2 - childSize2.width / 2;

    return switch (position) {
      KinTooltipPosition.above => Offset(
          cx.clamp(8, screenSize.width - childSize2.width - 8),
          childGlobal.dy - childSize2.height - gap,
        ),
      KinTooltipPosition.below => Offset(
          cx.clamp(8, screenSize.width - childSize2.width - 8),
          childGlobal.dy + childSize.height + gap,
        ),
      KinTooltipPosition.left => Offset(
          childGlobal.dx - childSize2.width - gap,
          childGlobal.dy + childSize.height / 2 - childSize2.height / 2,
        ),
      KinTooltipPosition.right => Offset(
          childGlobal.dx + childSize.width + gap,
          childGlobal.dy + childSize.height / 2 - childSize2.height / 2,
        ),
    };
  }

  @override
  bool shouldRelayout(_TooltipPositionDelegate old) => true;
}

import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_typography.dart';

/// Dot or count badge overlaid on a child widget.
///
/// Animates in/out with spring scale and smoothly transitions count changes.
class KinBadge extends StatelessWidget {
  final int? count;
  final Widget child;
  final Color? color;
  final bool show;
  final Alignment alignment;

  const KinBadge({
    super.key,
    this.count,
    required this.child,
    this.color,
    this.show = true,
    this.alignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final badgeColor = color ?? theme.destructive;

    final dx = alignment == Alignment.topLeft ? -4.0 : null;
    final dxR = alignment == Alignment.topRight ? -4.0 : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          left: dx,
          right: dxR,
          child: AnimatedScale(
            scale: show ? 1.0 : 0.0,
            duration: KinMotion.fast,
            curve: KinMotion.enter,
            child: AnimatedSwitcher(
              duration: KinMotion.fast,
              switchInCurve: KinMotion.enter,
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: count != null
                  ? Container(
                      key: ValueKey(count),
                      height: 18,
                      constraints: const BoxConstraints(minWidth: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count! > 99 ? '99+' : count.toString(),
                        style: KinTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    )
                  : Container(
                      key: const ValueKey('dot'),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

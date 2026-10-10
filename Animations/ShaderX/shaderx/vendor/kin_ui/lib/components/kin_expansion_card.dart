import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kin_press.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// A tappable card that smoothly reveals or hides its body content.
class KinExpansionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget child;
  final bool initiallyExpanded;

  const KinExpansionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<KinExpansionCard> createState() => _KinExpansionCardState();
}

class _KinExpansionCardState extends State<KinExpansionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotationAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: KinMotion.enter),
    );
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: KinRadius.lgAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          KinPress(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KinSpacing.md,
                vertical: KinSpacing.md,
              ),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: KinSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: KinTypography.titleMedium.copyWith(
                            color: theme.onSurface,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: KinTypography.bodyMedium.copyWith(
                              color: theme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: theme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              children: [
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: theme.outline.withValues(alpha: 0.3),
                ),
                Padding(
                  padding: const EdgeInsets.all(KinSpacing.md),
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

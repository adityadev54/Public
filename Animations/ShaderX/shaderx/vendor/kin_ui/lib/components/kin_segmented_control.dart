import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Pill-shaped segmented control with fluid spring-driven sliding indicator.
class KinSegmentedControl extends StatefulWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const KinSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<KinSegmentedControl> createState() => _KinSegmentedControlState();
}

class _KinSegmentedControlState extends State<KinSegmentedControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late double _slidePosition;

  @override
  void initState() {
    super.initState();
    _slidePosition = widget.selectedIndex.toDouble();
    _slideCtrl = AnimationController.unbounded(
      vsync: this,
      value: _slidePosition,
    );
  }

  @override
  void didUpdateWidget(KinSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _slideCtrl.animateWith(SpringSimulation(
        KinMotion.fluidSnap,
        _slidePosition,
        widget.selectedIndex.toDouble(),
        0,
      ));
      _slideCtrl.addListener(_slideListener);
    }
  }

  void _slideListener() {
    if (mounted) setState(() => _slidePosition = _slideCtrl.value);
    if (_slideCtrl.isCompleted) _slideCtrl.removeListener(_slideListener);
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: KinRadius.pillAll,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / widget.segments.length;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Spring-driven sliding pill
              Positioned(
                left: _slidePosition * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: KinRadius.pillAll,
                  ),
                ),
              ),
              // Labels
              Row(
                children: List.generate(widget.segments.length, (i) {
                  final isSelected = i == widget.selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onChanged(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: KinSpacing.sm),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: KinMotion.fast,
                            curve: KinMotion.fluidEnter,
                            style: KinTypography.labelLarge.copyWith(
                              color: isSelected ? Colors.white : theme.onSurfaceVariant,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                            child: Text(widget.segments[i]),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

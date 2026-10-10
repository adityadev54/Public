import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

/// Independent tool rail and floating inspector, with compact/expanded controls.
class StudioControlCard extends StatefulWidget {
  final int index;
  final ValueChanged<int> onTool;
  final String title;
  final Widget controls, transport;
  const StudioControlCard({
    super.key,
    required this.index,
    required this.onTool,
    required this.title,
    required this.controls,
    required this.transport,
  });
  @override
  State<StudioControlCard> createState() => _StudioControlCardState();
}

class _StudioControlCardState extends State<StudioControlCard> {
  int detent = 0;
  double drag = 0;
  void snap(int value) => setState(() => detent = value.clamp(0, 2));
  static const names = ['Stack', 'Fuse', 'Shape', 'Flow'];
  static const icons = [
    HeroiconsOutline.square3Stack3d,
    HeroiconsOutline.swatch,
    HeroiconsOutline.arrowsPointingOut,
    HeroiconsOutline.play,
  ];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    return KinCard(
      border: const Border(),
      material: const KinMaterial.glass(thickness: KinGlassThickness.thick),
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: detent == 0
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragStart: (_) => drag = 0,
                            onVerticalDragUpdate: (event) =>
                                drag += event.delta.dy,
                            onVerticalDragEnd: (_) {
                              if (drag.abs() > 20) {
                                snap(detent + (drag < 0 ? 1 : -1));
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  icons[widget.index],
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.title,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: 'Close controls',
                                  onPressed: () => snap(0),
                                  icon: const Icon(
                                    HeroiconsOutline.xMark,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          widget.transport,
                          const Divider(height: 16),
                          widget.controls,
                        ],
                      ),
                    ),
                  ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (detent == 0) widget.transport,
                  Row(
                    children: [
                      for (var index = 0; index < names.length; index++)
                        Expanded(
                          child: Semantics(
                            selected: widget.index == index && detent > 0,
                            child: KinPress(
                              buttonSemantics: true,
                              onTap: () {
                                if (widget.index == index) {
                                  snap(detent == 0 ? 1 : 0);
                                } else {
                                  widget.onTool(index);
                                  snap(detent == 0 ? 1 : detent);
                                }
                              },
                              child: SizedBox(
                                height: 52,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      icons[index],
                                      size: 21,
                                      color: widget.index == index && detent > 0
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      names[index],
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 11,
                                            color:
                                                widget.index == index &&
                                                    detent > 0
                                                ? theme.colorScheme.primary
                                                : theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    AnimatedContainer(
                                      duration: duration,
                                      width: widget.index == index && detent > 0
                                          ? 14
                                          : 0,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

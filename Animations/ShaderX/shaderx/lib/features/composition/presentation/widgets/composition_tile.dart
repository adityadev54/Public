import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import '../../domain/composition.dart';
import '../../../../rendering/shader_runtime.dart';
import '../../../../rendering/shader_viewport.dart';

class CompositionTile extends StatelessWidget {
  final Composition recipe;
  final ShaderRuntime runtime;
  final VoidCallback onOpen;
  final VoidCallback? onLongPress;
  final double aspectRatio;
  final bool captionBelow;
  const CompositionTile({
    super.key,
    required this.recipe,
    required this.runtime,
    required this.onOpen,
    this.onLongPress,
    this.aspectRatio = .8,
    this.captionBelow = false,
  });
  @override
  Widget build(BuildContext context) {
    if (captionBelow) {
      return KinPress(
        buttonSemantics: true,
        onTap: onOpen,
        onLongPress: onLongPress,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.08,
                  child: LayoutBuilder(
                    builder: (context, box) => ShaderViewport(
                      recipe: recipe,
                      runtime: runtime,
                      cornerRadius: 0,
                      height: box.maxHeight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                        ),
                      ),
                      if (onLongPress != null)
                        PopupMenuButton<String>(
                          tooltip: 'Composition options',
                          icon: const Icon(
                            HeroiconsOutline.ellipsisHorizontal,
                            size: 20,
                          ),
                          onSelected: (_) => onLongPress!(),
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text('Remove'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: recipe.name,
      button: true,
      child: KinPress(
        onTap: onOpen,
        onLongPress: onLongPress,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: LayoutBuilder(
              builder: (context, box) => Stack(
                fit: StackFit.expand,
                children: [
                  ShaderViewport(
                    key: ValueKey(recipe.id),
                    recipe: recipe,
                    runtime: runtime,
                    cornerRadius: 0,
                    height: box.maxHeight,
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 100,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xCC000000)],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

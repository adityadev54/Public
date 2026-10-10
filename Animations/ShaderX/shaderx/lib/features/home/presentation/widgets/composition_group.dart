import 'package:flutter/material.dart';
import 'swipe_delete_tile.dart';
import '../../../composition/presentation/widgets/composition_identity.dart';

import '../../../../rendering/shader_runtime.dart';
import '../../../../rendering/shader_viewport.dart';
import '../../../composition/domain/composition.dart';

class CompositionGroup extends StatelessWidget {
  final List<Composition> items;
  final ShaderRuntime runtime;
  final ValueChanged<Composition> onOpen, onRemove;
  const CompositionGroup({
    super.key,
    required this.items,
    required this.runtime,
    required this.onOpen,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(26),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) const Divider(height: 1, indent: 88, endIndent: 16),
          SwipeDeleteTile(
            onDelete: () => onRemove(items[index]),
            key: ValueKey('swipe-${items[index].id}'),
            child: ListTile(
              key: ValueKey('older-${items[index].id}'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ShaderViewport(
                      recipe: items[index],
                      runtime: runtime,
                      animate: false,
                      height: 56,
                      cornerRadius: 16,
                    ),
                    Positioned(
                      right: -3,
                      bottom: -3,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(items[index].colorValue),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          CompositionIdentity.icon(items[index].iconId),
                          size: 13,
                          color: CompositionIdentity.foreground(
                            Color(items[index].colorValue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                items[index].name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: items[index].description.isEmpty
                  ? null
                  : Text(
                      items[index].description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: () => onOpen(items[index]),
            ),
          ),
        ],
      ],
    ),
  );
}

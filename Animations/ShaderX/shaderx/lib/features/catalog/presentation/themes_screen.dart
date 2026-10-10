import 'package:flutter/material.dart';

import '../../../app/studio_session.dart';
import '../../../core/layout/content_frame.dart';
import '../../../core/layout/gallery_grid.dart';
import '../../../core/ui/floating_controls.dart';
import '../../composition/domain/composition.dart';
import '../../composition/domain/component_instance.dart';
import '../../composition/presentation/widgets/composition_tile.dart';
import '../domain/shader_component.dart';
import '../data/component_catalog.dart';

class ThemesScreen extends StatelessWidget {
  final StudioSession session;
  final VoidCallback onMenu;
  final VoidCallback? onSettings;
  final ValueChanged<ShaderComponent> onOpen;
  const ThemesScreen({
    super.key,
    required this.session,
    required this.onMenu,
    this.onSettings,
    required this.onOpen,
  });
  @override
  Widget build(BuildContext context) {
    final components = ComponentCatalog.components;
    return PageFrame(
      title: 'Themes',
      onMenu: onMenu,
      onSettings: onSettings,
      child: ContentFrame(
        maxWidth: 1000,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            GalleryGrid(
              count: components.length,
              builder: (index, ratio) {
                final component = components[index];
                return CompositionTile(
                  key: ValueKey(component.id),
                  recipe: Composition(
                    id: component.id,
                    name: component.name,
                    layers: [
                      ComponentInstance(
                        id: component.id,
                        componentId: component.id,
                        parameters: component.defaults,
                      ),
                    ],
                  ),
                  runtime: session.runtime,
                  aspectRatio: ratio,
                  onOpen: () => onOpen(component),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

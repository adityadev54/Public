import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

import '../../../app/studio_session.dart';
import '../../../core/layout/content_frame.dart';
import '../../../core/ui/kin_components.dart';
import '../../../core/ui/floating_controls.dart';
import '../../../rendering/shader_viewport.dart';
import '../../composition/domain/composition.dart';
import '../../composition/domain/component_instance.dart';
import '../domain/shader_component.dart';

class ComponentDetailScreen extends StatefulWidget {
  final ShaderComponent component;
  final StudioSession session;
  final ValueChanged<Map<String, double>> onAdd;
  final bool animate;
  final VoidCallback? onSettings;
  const ComponentDetailScreen({
    super.key,
    required this.component,
    required this.session,
    required this.onAdd,
    this.onSettings,
    required this.animate,
  });
  @override
  State<ComponentDetailScreen> createState() => _ComponentDetailScreenState();
}

class _ComponentDetailScreenState extends State<ComponentDetailScreen> {
  late Map<String, double> parameters = widget.component.defaults;
  bool playing = true;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: PageFrame(
      title: widget.component.name,
      onMenu: () => Navigator.pop(context),
      onSettings: widget.onSettings,
      leadingIcon: HeroiconsOutline.chevronLeft,
      leadingTooltip: 'Back to themes',
      immersive: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderViewport(
            recipe: Composition(
              id: widget.component.id,
              name: widget.component.name,
              layers: [
                ComponentInstance(
                  id: 'detail',
                  componentId: widget.component.id,
                  parameters: parameters,
                ),
              ],
            ),
            runtime: widget.session.runtime,
            animate: widget.animate && playing,
            cornerRadius: 0,
            height: (MediaQuery.sizeOf(context).height * .66).clamp(360, 680),
          ),
          ContentFrame(
            maxWidth: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.catalog
                            .theme(widget.component.themeId)
                            .name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.component.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.component.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: widget.session.composition.canAdd
                            ? 'Open studio'
                            : 'Six-layer limit reached',
                        onPressed: widget.session.composition.canAdd
                            ? () => widget.onAdd(parameters)
                            : null,
                        primary: true,
                        icon: HeroiconsOutline.cubeTransparent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

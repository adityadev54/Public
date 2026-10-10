import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import '../../../../app/studio_session.dart';
import '../../../../core/ui/kin_components.dart';
import '../../domain/master_tool.dart';

class ToolPanel extends StatefulWidget {
  final StudioSession session;
  final MasterTool tool;
  final VoidCallback onAdd;
  const ToolPanel({
    super.key,
    required this.session,
    required this.tool,
    required this.onAdd,
  });
  @override
  State<ToolPanel> createState() => _ToolPanelState();
}

class _ToolPanelState extends State<ToolPanel> {
  final optionsAnchor = GlobalKey();
  int page = 0;
  bool surface = false;
  @override
  void didUpdateWidget(ToolPanel old) {
    super.didUpdateWidget(old);
    if (old.tool != widget.tool) page = 0;
  }

  Widget tabs(List<String> names, int selected, ValueChanged<int> onSelect) =>
      Row(
        children: [
          for (var i = 0; i < names.length; i++)
            Expanded(
              child: KinPress(
                buttonSemantics: true,
                onTap: () => onSelect(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    names[i],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: selected == i
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: selected == i
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
  Future<void> options() async {
    final controller = widget.session.composition,
        layer = widget.session.composition.selected;
    final anchor =
        optionsAnchor.currentContext?.findRenderObject() as RenderBox?;
    if (layer == null || anchor == null) return;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final rect =
        anchor.localToGlobal(Offset.zero, ancestor: overlay) & anchor.size;
    await KinPopupMenu.show(
      context: context,
      position: RelativeRect.fromRect(rect, Offset.zero & overlay.size),
      items: [
        if (controller.recipe.layers.last.id != layer.id)
          KinPopupMenuItem(
            label: 'Move layer up',
            leading: const Icon(HeroiconsOutline.arrowUp, size: 18),
            onTap: () => controller.reorder(layer.id, 1),
          ),
        if (controller.recipe.layers.first.id != layer.id)
          KinPopupMenuItem(
            label: 'Move layer down',
            leading: const Icon(HeroiconsOutline.arrowDown, size: 18),
            onTap: () => controller.reorder(layer.id, -1),
          ),
        KinPopupMenuItem(
          label: 'Remove layer',
          isDestructive: true,
          leading: const Icon(HeroiconsOutline.trash, size: 18),
          onTap: () => controller.remove(layer.id),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.session.composition,
        layer = widget.session.composition.selected;
    final component = layer == null
        ? null
        : widget.session.catalog.component(layer.componentId);
    Widget slider(
      String label,
      double value,
      ValueChanged<double> change, [
      double min = 0,
      double max = 1,
    ]) => AppSlider(
      nativeAppearance: false,
      label: label,
      value: value,
      min: min,
      max: max,
      onChanged: change,
      onChangeStart: (_) => controller.beginEdit(),
      onChangeEnd: (_) => controller.endEdit(),
    );
    final controls = <(String, Widget)>[];
    if (widget.tool == MasterTool.stack && surface && component != null) {
      for (final p in component.parameters) {
        controls.add((
          p.label,
          slider(
            p.label,
            layer!.parameters[p.id]!,
            (v) => controller.parameter(p.id, v),
            p.minimum,
            p.maximum,
          ),
        ));
      }
    } else if (widget.tool == MasterTool.flow) {
      controls.add((
        'Speed',
        slider(
          'Playback speed',
          controller.recipe.speed,
          (v) => controller.timing(speed: v),
          0,
          2,
        ),
      ));
      controls.add((
        'Cycle',
        slider(
          'Cycle length · seconds',
          controller.recipe.duration,
          (v) => controller.timing(duration: v),
          4,
          40,
        ),
      ));
      if (layer != null) {
        controls.add((
          'Phase',
          slider(
            'Selected layer phase',
            layer.phase,
            (v) => controller.update(layer.copyWith(phase: v)),
          ),
        ));
      }
    } else if (widget.tool == MasterTool.fuse && layer != null) {
      controls.add((
        'Blend',
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final blend in LayerBlend.values)
              KinPress(
                buttonSemantics: true,
                onTap: () => controller.update(layer.copyWith(blend: blend)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: layer.blend == blend
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .12)
                        : Colors.transparent,
                  ),
                  child: Text(
                    blend.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ));
      controls.add((
        'Opacity',
        slider(
          'Layer opacity',
          layer.opacity,
          (v) => controller.update(layer.copyWith(opacity: v)),
        ),
      ));
    } else if (widget.tool == MasterTool.shape && layer != null) {
      controls.add((
        'Scale',
        slider(
          'Scale',
          layer.scale,
          (v) => controller.update(layer.copyWith(scale: v)),
          .4,
          2,
        ),
      ));
      controls.add((
        'Rotation',
        slider(
          'Rotation · radians',
          layer.rotation,
          (v) => controller.update(layer.copyWith(rotation: v)),
          -3.14,
          3.14,
        ),
      ));
      controls.add((
        'Distortion',
        slider(
          'Domain distortion',
          layer.warp,
          (v) => controller.update(layer.copyWith(warp: v)),
        ),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.tool == MasterTool.stack)
          tabs(
            ['Layers', 'Particles'],
            surface ? 1 : 0,
            (index) => setState(() {
              surface = index == 1;
              page = 0;
            }),
          ),
        if (widget.tool == MasterTool.stack && !surface) ...[
          if (layer != null)
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous layer',
                  onPressed: () {
                    final index = controller.recipe.layers.indexWhere(
                      (item) => item.id == layer.id,
                    );
                    controller.select(
                      controller
                          .recipe
                          .layers[(index -
                                  1 +
                                  controller.recipe.layers.length) %
                              controller.recipe.layers.length]
                          .id,
                    );
                  },
                  icon: const Icon(HeroiconsOutline.chevronLeft, size: 18),
                ),
                Expanded(
                  child: Text(
                    component!.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                  ),
                ),
                IconButton(
                  tooltip: 'Next layer',
                  onPressed: () {
                    final index = controller.recipe.layers.indexWhere(
                      (item) => item.id == layer.id,
                    );
                    controller.select(
                      controller
                          .recipe
                          .layers[(index + 1) % controller.recipe.layers.length]
                          .id,
                    );
                  },
                  icon: const Icon(HeroiconsOutline.chevronRight, size: 18),
                ),
              ],
            ),
          Row(
            children: [
              if (layer != null)
                IconButton(
                  tooltip: layer.visible ? 'Hide layer' : 'Show layer',
                  onPressed: () => controller.update(
                    layer.copyWith(visible: !layer.visible),
                  ),
                  icon: Icon(
                    layer.visible
                        ? HeroiconsOutline.eye
                        : HeroiconsOutline.eyeSlash,
                    size: 18,
                  ),
                ),
              Text(
                '${controller.recipe.layers.length} / 6',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Add component',
                onPressed: controller.canAdd ? widget.onAdd : null,
                icon: const Icon(HeroiconsOutline.plus, size: 20),
              ),
              IconButton(
                key: optionsAnchor,
                tooltip: 'Layer options',
                onPressed: layer == null ? null : options,
                icon: const Icon(HeroiconsOutline.ellipsisHorizontal, size: 20),
              ),
            ],
          ),
        ] else if (controls.isNotEmpty) ...[
          tabs(
            controls.map((item) => item.$1).toList(),
            page.clamp(0, controls.length - 1),
            (value) => setState(() => page = value),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(
              key: ValueKey('${widget.tool}-$surface-$page'),
              child: controls[page.clamp(0, controls.length - 1)].$2,
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Add a layer to begin.'),
          ),
      ],
    );
  }
}

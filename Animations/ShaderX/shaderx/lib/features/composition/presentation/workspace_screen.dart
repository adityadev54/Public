import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

import '../../../app/studio_session.dart';
import 'package:kin_ui/kin_ui.dart';
import '../../../core/ui/floating_controls.dart';
import '../../../core/ui/app_dialog.dart';
import '../../../rendering/shader_viewport.dart';
import '../domain/master_tool.dart';
import 'widgets/tool_panel.dart';
import 'widgets/studio_control_card.dart';

class WorkspaceScreen extends StatefulWidget {
  final StudioSession session;
  final VoidCallback onBack, onAdd;
  final VoidCallback? onSettings;
  final bool animate;
  const WorkspaceScreen({
    super.key,
    required this.session,
    required this.onBack,
    this.onSettings,
    required this.onAdd,
    required this.animate,
  });
  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final moreAnchor = GlobalKey();
  MasterTool tool = MasterTool.stack;
  bool playing = true, focused = false;
  Future<void> save() async {
    final name = await askName(context, widget.session.composition.recipe.name);
    if (name == null || !mounted) return;
    widget.session.composition.rename(name);
    final ok = await widget.session.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 180),
        content: Text(
          ok
              ? 'Composition saved'
              : widget.session.error ?? 'Could not save composition',
        ),
      ),
    );
  }

  Future<void> more() async {
    final anchor = moreAnchor.currentContext?.findRenderObject() as RenderBox?;
    if (anchor == null) return;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final rect =
        anchor.localToGlobal(Offset.zero, ancestor: overlay) & anchor.size;
    await KinPopupMenu.show(
      context: context,
      position: RelativeRect.fromRect(rect, Offset.zero & overlay.size),
      items: [
        KinPopupMenuItem(
          label: widget.session.composition.recipe.name,
          selectable: false,
        ),
        const KinPopupMenuDivider(),
        if (widget.session.composition.recipe.layers.isNotEmpty &&
            !widget.session.busy)
          KinPopupMenuItem(
            label: 'Save composition',
            leading: const Icon(HeroiconsOutline.bookmark, size: 20),
            onTap: save,
          ),
        if (widget.session.composition.canAdd)
          KinPopupMenuItem(
            label: 'Add component',
            leading: const Icon(HeroiconsOutline.plus, size: 20),
            onTap: widget.onAdd,
          ),
        if (widget.onSettings != null)
          KinPopupMenuItem(
            label: 'Settings',
            leading: const Icon(HeroiconsOutline.cog6Tooth, size: 20),
            onTap: widget.onSettings,
          ),
      ],
    );
  }

  Widget action(
    String label,
    IconData icon,
    VoidCallback? onTap, {
    bool selected = false,
  }) => Tooltip(
    message: label,
    child: Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      child: KinPress(
        onTap: onTap,
        enabled: onTap != null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: .14)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 21,
            color: selected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final controller = widget.session.composition;
    return LayoutBuilder(
      builder: (context, box) => Stack(
        children: [
          Positioned.fill(
            child: ShaderViewport(
              key: ValueKey(controller.recipe.id),
              recipe: controller.recipe,
              interactive: true,
              onDoubleTap: () => setState(() => focused = !focused),
              runtime: widget.session.runtime,
              animate: widget.animate && playing,
              cornerRadius: 0,
              height: box.maxHeight,
            ),
          ),
          if (!focused)
            FloatingControls(
              progress: 0,
              onMenu: widget.onBack,
              icon: HeroiconsOutline.chevronLeft,
              tooltip: 'Back from studio',
              onSettings: more,
              trailingKey: moreAnchor,
              trailingIcon: HeroiconsOutline.ellipsisVertical,
              trailingTooltip: 'Studio options',
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Visibility(
                      visible: !focused,
                      maintainState: true,
                      child: StudioControlCard(
                        index: tool.index,
                        title: tool.label,
                        onTool: (index) =>
                            setState(() => tool = MasterTool.values[index]),
                        transport: Row(
                          children: [
                            action(
                              playing
                                  ? 'Pause composition'
                                  : 'Play composition',
                              playing
                                  ? HeroiconsOutline.pause
                                  : HeroiconsOutline.play,
                              () => setState(() => playing = !playing),
                            ),
                            action(
                              'Undo edit',
                              HeroiconsOutline.arrowUturnLeft,
                              controller.canUndo ? controller.undo : null,
                            ),
                            action(
                              'Redo edit',
                              HeroiconsOutline.arrowUturnRight,
                              controller.canRedo ? controller.redo : null,
                            ),
                            const Spacer(),
                            action(
                              'Save composition',
                              HeroiconsOutline.bookmark,
                              controller.recipe.layers.isEmpty ||
                                      widget.session.busy
                                  ? null
                                  : save,
                            ),
                          ],
                        ),
                        controls: ToolPanel(
                          session: widget.session,
                          tool: tool,
                          onAdd: widget.onAdd,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

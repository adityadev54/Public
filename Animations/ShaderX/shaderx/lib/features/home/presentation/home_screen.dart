import 'package:flutter/material.dart';

import '../../../app/studio_session.dart';
import '../../../core/layout/content_frame.dart';
import '../../../core/ui/floating_controls.dart';
import '../../../core/brand/shaderx_mark.dart';
import '../../../core/ui/kin_components.dart';
import '../../../core/ui/app_dialog.dart';
import '../../composition/domain/composition.dart';
import '../domain/composition_sections.dart';
import 'widgets/new_composition_card.dart';
import 'widgets/composition_group.dart';

class HomeScreen extends StatelessWidget {
  final StudioSession session;
  final VoidCallback onMenu, onWorkspace, onNew;
  final VoidCallback? onSettings;
  const HomeScreen({
    super.key,
    required this.session,
    required this.onMenu,
    this.onSettings,
    required this.onWorkspace,
    required this.onNew,
  });
  Future<void> remove(BuildContext context, Composition recipe) async {
    final confirmed = await showAppDialog<bool>(
      context,
      Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remove ${recipe.name}?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'The saved copy will be removed. Your open draft stays available.',
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Keep'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) await session.remove(recipe.id);
  }

  void open(Composition recipe) {
    session.composition.open(recipe);
    onWorkspace();
  }

  @override
  Widget build(BuildContext context) {
    final sections = CompositionSections.from(session.library);
    return PageFrame(
      title: 'Compositions',
      topSpacing: 84,
      onMenu: onMenu,
      onSettings: onSettings,
      child: ContentFrame(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: ShaderXMark()),
            const SizedBox(height: 55),
            NewCompositionCard(onNew: onNew),
            const SizedBox(height: 28),
            AppText(
              'Your compositions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (session.library.isEmpty)
              AppText(
                'No saved compositions yet.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            for (final group in sections.groups.entries) ...[
              if (group.key != 'This week') ...[
                const SizedBox(height: 24),
                AppText(
                  group.key,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
              ],
              CompositionGroup(
                items: group.value,
                runtime: session.runtime,
                onOpen: open,
                onRemove: (recipe) => remove(context, recipe),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

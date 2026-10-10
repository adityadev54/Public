import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';

import '../../../core/layout/content_frame.dart';
import '../../../core/ui/floating_controls.dart';
import '../../../core/ui/kin_components.dart';
import '../application/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController settings;
  final VoidCallback onMenu;
  final VoidCallback? onSettings;
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onMenu,
    this.onSettings,
  });
  Future<void> change(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preference could not be saved.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Settings',
    onMenu: onMenu,
    onSettings: onSettings,
    child: ContentFrame(
      maxWidth: 700,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ThemeMode>(
              key: ValueKey(settings.themeMode),
              initialValue: settings.themeMode,
              decoration: const InputDecoration(labelText: 'Theme'),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Follow system'),
                ),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              ],
              onChanged: (value) {
                if (value != null) {
                  change(context, () => settings.setTheme(value));
                }
              },
            ),
            const Divider(height: 40),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Animate the workspace',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      const AppText(
                        'Catalog previews stay still. System reduced motion is respected.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                KinPremiumToggle(
                  nativeAppearance: true,
                  value: settings.animate,
                  onChanged: (v) =>
                      change(context, () => settings.setAnimate(v)),
                ),
              ],
            ),
            const Divider(height: 40),
            AppText(
              'On this device',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const AppText(
              'Recipes and preferences are stored locally. A working draft resumes between sessions.',
            ),
            const SizedBox(height: 20),
            AppText(
              'ShaderX · development foundation',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}

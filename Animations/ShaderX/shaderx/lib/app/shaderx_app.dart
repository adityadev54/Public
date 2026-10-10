import 'package:flutter/material.dart';
import 'studio_session.dart';
import 'navigation/app_shell.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/application/settings_controller.dart';

class ShaderXApp extends StatelessWidget {
  final StudioSession session;
  final SettingsController settings;
  const ShaderXApp({super.key, required this.session, required this.settings});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: settings,
    builder: (context, _) => MaterialApp(
      title: 'ShaderX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: settings.themeMode,
      home: AppShell(session: session, settings: settings),
    ),
  );
}

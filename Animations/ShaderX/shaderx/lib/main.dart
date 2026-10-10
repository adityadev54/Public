import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/shaderx_app.dart';
import 'app/studio_session.dart';
import 'features/catalog/data/component_catalog.dart';
import 'features/library/data/local_composition_repository.dart';
import 'features/settings/application/settings_controller.dart';
import 'rendering/shader_runtime.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final session = StudioSession(
    catalog: ComponentCatalog(),
    repository: LocalCompositionRepository(preferences),
    runtime: ShaderRuntime(),
  );
  await session.initialize();
  runApp(
    ShaderXApp(session: session, settings: SettingsController(preferences)),
  );
}

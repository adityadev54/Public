import 'package:flutter/material.dart';

import '../../features/catalog/domain/shader_component.dart';
import '../../features/catalog/presentation/component_detail_screen.dart';
import '../studio_session.dart';

enum AppDestination { home, themes, workspace, settings }

abstract final class AppRoutes {
  static Future<void> component(
    BuildContext context, {
    required StudioSession session,
    required ShaderComponent component,
    required VoidCallback onAdded,
    VoidCallback? onSettings,
    required bool animate,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (routeContext) => ComponentDetailScreen(
        component: component,
        session: session,
        animate: animate,
        onSettings: onSettings == null
            ? null
            : () {
                Navigator.pop(routeContext);
                onSettings();
              },
        onAdd: (parameters) {
          session.composition.add(component);
          session.composition.update(
            session.composition.selected!.copyWith(parameters: parameters),
          );
          Navigator.pop(routeContext);
          onAdded();
        },
      ),
    ),
  );
}

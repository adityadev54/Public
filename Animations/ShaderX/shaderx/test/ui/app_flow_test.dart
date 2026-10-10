import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shaderx/app/shaderx_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:shaderx/app/studio_session.dart';
import 'package:shaderx/features/catalog/data/component_catalog.dart';
import 'package:shaderx/features/library/data/local_composition_repository.dart';
import 'package:shaderx/features/settings/application/settings_controller.dart';
import 'package:shaderx/rendering/shader_runtime.dart';

void main() {
  testWidgets(
    'Discover a component, create and save a recipe, reopen from home',
    (tester) async {
      SharedPreferences.setMockInitialValues({'shaderx.animate': false});
      final prefs = await SharedPreferences.getInstance();
      final session = StudioSession(
        catalog: ComponentCatalog(),
        repository: LocalCompositionRepository(prefs),
        runtime: ShaderRuntime(),
      );
      final settings = SettingsController(prefs);
      await session.initialize();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 1100);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ShaderXApp(session: session, settings: settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New composition').hitTestable());
      await tester.pumpAndSettle();
      expect(
        ModalRoute.of(tester.element(find.byTooltip('Create composition'))),
        isA<CupertinoSheetRoute>(),
      );
      expect(find.byType(BottomSheet), findsNothing);
      await tester.enterText(find.byType(TextField).first, 'Light study');
      await tester.enterText(
        find.byType(TextField).last,
        'Layered light and material.',
      );
      await tester.ensureVisible(find.byTooltip('Prism'));
      await tester.tap(find.byTooltip('Prism'));
      await tester.ensureVisible(find.byTooltip('Rose'));
      await tester.tap(find.byTooltip('Rose'));
      await tester.ensureVisible(find.text('24 fps'));
      await tester.tap(find.text('24 fps'));
      await tester.tap(find.byTooltip('Create composition'));
      await tester.pumpAndSettle();
      expect(session.composition.recipe.name, 'Light study');
      expect(session.composition.recipe.iconId, 'prism');
      expect(session.composition.recipe.colorValue, 0xFFC98090);
      expect(session.composition.recipe.frameRate, 24);
      expect(
        session.composition.recipe.description,
        'Layered light and material.',
      );
      await tester.tap(find.byTooltip('Open settings'));
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);
      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsNothing);
      await tester.tap(find.text('Themes').hitTestable());
      await tester.pumpAndSettle();
      expect(find.text('Kinetic sculpture'), findsOneWidget);
      await tester.tap(find.text('Kinetic sculpture').first);
      await tester.pumpAndSettle();
      expect(find.text('Open studio'), findsOneWidget);
      expect(find.byType(Slider), findsNothing);
      await tester.ensureVisible(find.text('Open studio'));
      await tester.tap(find.text('Open studio'));
      await tester.pumpAndSettle();
      expect(find.text('Particle count'), findsNothing);
      await tester.tapAt(const Offset(150, 180));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tapAt(const Offset(150, 180));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Back from studio'), findsNothing);
      expect(find.byTooltip('Save composition'), findsNothing);
      await tester.tapAt(const Offset(150, 180));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byTooltip('Back from studio'), findsNothing);
      await tester.tapAt(const Offset(150, 180));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tapAt(const Offset(150, 180));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Back from studio'), findsOneWidget);
      await tester.tap(find.text('Stack'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Layer options'));
      await tester.pumpAndSettle();
      expect(find.text('Remove layer'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Particles'));
      await tester.pumpAndSettle();
      final previewSlider = tester.widget<KinSlider>(
        find.byType(KinSlider).first,
      );
      previewSlider.onChanged(.83);
      await tester.pumpAndSettle();
      expect(session.composition.recipe.layers, hasLength(1));
      expect(
        session.composition.recipe.layers.first.parameters['density'],
        .83,
      );
      expect(find.text('Stack'), findsWidgets);
      expect(find.text('Fuse'), findsOneWidget);
      await tester.tap(find.byTooltip('Save composition'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'A film study');
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      expect(session.library, hasLength(1));
      expect(session.library.first.name, 'A film study');
      expect(find.byTooltip('Open navigation'), findsNothing);
      expect(find.byTooltip('Open settings'), findsNothing);
      await tester.tap(find.byTooltip('Studio options'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back from studio'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Open navigation').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Compositions'));
      await tester.pumpAndSettle();
      expect(find.text('Library'), findsNothing);
      expect(find.text('Your compositions'), findsOneWidget);
      expect(session.library.first.frameRate, 24);
      expect(session.library.first.iconId, 'prism');
      expect(session.library.first.description, 'Layered light and material.');
      expect(find.byTooltip('Composition options'), findsNothing);
      expect(find.text('Delete').hitTestable(), findsNothing);
      await tester.drag(
        find.byKey(ValueKey('swipe-${session.library.first.id}')),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').hitTestable());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep'));
      await tester.pumpAndSettle();
      expect(session.library, hasLength(1));
      await tester.tap(find.text('A film study').first);
      await tester.pumpAndSettle();
      expect(session.composition.recipe.name, 'A film study');
      expect(find.byTooltip('Save composition'), findsOneWidget);
      for (final size in [const Size(390, 844), const Size(320, 700)]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (find.byTooltip('Close controls').evaluate().isNotEmpty) {
          await tester.tap(find.byTooltip('Close controls'));
          await tester.pumpAndSettle();
        }
        for (final tool in ['Stack', 'Fuse', 'Shape', 'Flow']) {
          await tester.tap(find.text(tool).last);
          await tester.pumpAndSettle();
          expect(
            find.byTooltip('Close controls'),
            findsOneWidget,
            reason: '$tool at $size',
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(SingleChildScrollView), findsNothing);
          await tester.tap(find.byTooltip('Close controls'));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      }
      await session.flushDraft();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      session.dispose();
      settings.dispose();
    },
  );
}

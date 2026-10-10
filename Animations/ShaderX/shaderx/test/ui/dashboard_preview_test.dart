import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shaderx/app/shaderx_app.dart';
import 'package:shaderx/app/studio_session.dart';
import 'package:shaderx/features/catalog/data/component_catalog.dart';
import 'package:shaderx/features/composition/domain/master_tool.dart';
import 'package:shaderx/features/composition/domain/composition.dart';
import 'package:shaderx/features/library/data/local_composition_repository.dart';
import 'package:shaderx/features/settings/application/settings_controller.dart';
import 'package:shaderx/rendering/shader_runtime.dart';

void main() {
  testWidgets(
    'Home and themes grids are readable across dark/light and mobile/desktop',
    (tester) async {
      await tester.runAsync(() async {
        final systemFont = File('/System/Library/Fonts/SFNS.ttf');
        if (Platform.isMacOS && await systemFont.exists()) {
          final bytes = await systemFont.readAsBytes();
          for (final family in [
            'Roboto',
            '.SF UI Text',
            '.SF UI Display',
            'CupertinoSystemText',
            'CupertinoSystemDisplay',
          ]) {
            final loader = FontLoader(family)
              ..addFont(Future.value(ByteData.sublistView(bytes)));
            await loader.load();
          }
        }
        final iconLoader =
            FontLoader('packages/heroicons_flutter/Heroicons Outline')..addFont(
              rootBundle.load(
                'packages/heroicons_flutter/assets/fonts/heroicons-outline.ttf',
              ),
            );
        await iconLoader.load();
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      SharedPreferences.setMockInitialValues({'shaderx.animate': false});
      final prefs = await SharedPreferences.getInstance();
      final runtime = ShaderRuntime();
      await tester.runAsync(() async {
        for (final component in ComponentCatalog.components) {
          await runtime.load(component.id);
        }
      });
      final session = StudioSession(
        catalog: ComponentCatalog(),
        repository: LocalCompositionRepository(prefs),
        runtime: runtime,
      );
      final settings = SettingsController(prefs);
      await session.initialize();
      session.composition.add(ComponentCatalog.components.first);
      session.composition.add(ComponentCatalog.components[1]);
      session.composition.update(
        session.composition.selected!.copyWith(
          opacity: .35,
          blend: LayerBlend.screen,
        ),
      );
      session.composition.rename('Surface study');
      await session.save();
      session.composition.newComposition();
      session.composition.add(ComponentCatalog.components[1]);
      session.composition.rename('Copper fold');
      await session.save();
      final template = session.composition.recipe;
      for (var i = 0; i < 5; i++) {
        await session.repository.save(
          Composition(
            id: 'older-$i',
            name: [
              'Amber drift',
              'Quiet contour',
              'Soft refraction',
              'Membrane study',
              'First light',
            ][i],
            layers: template.layers,
            updatedAt: DateTime.now().subtract(Duration(days: 10 + i * 16)),
          ),
        );
      }
      await session.initialize();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 1100);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: ShaderXApp(session: session, settings: settings),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Open navigation').first);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsNothing);
      final bars = tester
          .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.byKey(const ValueKey('app-system-bars')),
          )
          .value;
      expect(bars.statusBarIconBrightness, Brightness.light);
      expect(bars.statusBarBrightness, Brightness.dark);
      expect(
        Theme.of(tester.element(find.text('Compositions'))).brightness,
        Brightness.dark,
      );
      await tester.tap(find.text('Compositions'));
      await tester.pumpAndSettle();
      expect(find.text('This week'), findsNothing);
      expect(find.byKey(const ValueKey('shaderx-mark')), findsOneWidget);
      for (final sample in [
        ('desktop', const Size(1200, 1100), ThemeMode.dark),
        ('phone', const Size(390, 844), ThemeMode.dark),
        ('phone-light', const Size(390, 844), ThemeMode.light),
        ('small-phone', const Size(320, 700), ThemeMode.light),
      ]) {
        tester.view.physicalSize = sample.$2;
        tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
        await settings.setTheme(sample.$3);
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/qa').create(recursive: true);
          await File(
            'build/qa/home-${sample.$1}.png',
          ).writeAsBytes(png!.buffer.asUint8List());
          image.dispose();
        });
      }
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      final draftBeforeSetup = session.composition.recipe.id;
      await tester.tap(find.text('New composition').hitTestable());
      await tester.pumpAndSettle();
      expect(find.text('Composition name'), findsOneWidget);
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'build/qa/composition-setup-phone.png',
        ).writeAsBytes(png!.buffer.asUint8List());
        image.dispose();
      });
      await tester.tap(find.byTooltip('Close setup'));
      await tester.pumpAndSettle();
      expect(session.composition.recipe.id, draftBeforeSetup);
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'build/qa/home-older-phone.png',
        ).writeAsBytes(png!.buffer.asUint8List());
        image.dispose();
      });
      await tester.tap(find.text('Quiet contour').hitTestable());
      await tester.pumpAndSettle();
      expect(session.composition.recipe.name, 'Quiet contour');
      expect(find.byTooltip('Save composition'), findsOneWidget);
      await tester.tap(find.byTooltip('Back from studio'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Themes').hitTestable());
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'build/qa/themes-phone.png',
        ).writeAsBytes(png!.buffer.asUint8List());
        image.dispose();
      });
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -470),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'build/qa/themes-more-phone.png',
        ).writeAsBytes(png!.buffer.asUint8List());
        image.dispose();
      });
      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'build/qa/drawer-phone.png',
        ).writeAsBytes(png!.buffer.asUint8List());
        image.dispose();
      });
      await session.flushDraft();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      session.dispose();
      settings.dispose();
      debugDefaultTargetPlatformOverride = null;
    },
  );
}

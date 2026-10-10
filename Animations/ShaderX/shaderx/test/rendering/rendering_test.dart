import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaderx/features/catalog/data/component_catalog.dart';
import 'package:shaderx/features/composition/domain/composition.dart';
import 'package:shaderx/features/composition/domain/component_instance.dart';
import 'package:shaderx/features/composition/domain/master_tool.dart';
import 'package:shaderx/rendering/shader_runtime.dart';
import 'package:shaderx/rendering/shader_viewport.dart';
import 'package:shaderx/rendering/composition_renderer.dart';
import 'package:shaderx/rendering/particle_sculpture.dart';

void main() {
  testWidgets(
    'All registered shaders render, and blend/shape edits alter pixels',
    (tester) async {
      final runtime = ShaderRuntime();
      final shaders = <String, ui.FragmentShader>{};
      await tester.runAsync(() async {
        for (final component in ComponentCatalog.components) {
          shaders[component.id] = (await runtime.load(
            component.id,
          )).fragmentShader();
        }
      });
      final key = GlobalKey();
      double playTime = 0;
      Future<ui.Image> render(Composition recipe, {double touch = 0}) async {
        final formations = <String, ParticleSculpture>{};
        for (final layer in recipe.layers.where(
          (layer) => layer.componentId.startsWith('formation_'),
        )) {
          final field = ParticleSculpture(kind: layer.componentId);
          for (var i = 0; i <= (playTime * 60).round(); i++) {
            field.step(
              time: i / 60,
              count: layer.parameters['density']!,
              form: layer.parameters['gather']!,
              aspect: 360 / 280,
            );
          }
          formations[layer.id] = field;
        }
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 360,
                  height: 280,
                  child: CustomPaint(
                    painter: CompositionRenderer(
                      recipe: recipe,
                      particleFields: formations,
                      shaders: shaders,
                      time: () => playTime,
                      touch: touch,
                      pointer: const Offset(.8, .6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        return (await tester.runAsync(
          () =>
              (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
                  .toImage(),
        ))!;
      }

      final layers = ComponentCatalog.components
          .map(
            (c) => ComponentInstance(
              id: c.id,
              componentId: c.id,
              parameters: c.defaults,
            ),
          )
          .toList();
      for (final layer in layers) {
        final image = await render(
          Composition(id: 'test', name: 'Test', layers: [layer]),
        );
        final bytes = (await tester.runAsync(() => image.toByteData()))!;
        expect(bytes.lengthInBytes, 360 * 280 * 4);
        expect(bytes.buffer.asUint8List().toSet().length, greaterThan(30));
        if (layers.indexOf(layer) >= 3) {
          final original = bytes.buffer.asUint8List();
          final changed = await render(
            Composition(
              id: 'test',
              name: 'Test',
              layers: [
                layer.copyWith(
                  parameters: {
                    for (final key in layer.parameters.keys) key: .9,
                  },
                ),
              ],
            ),
          );
          final changedBytes = (await tester.runAsync(
            () => changed.toByteData(),
          ))!;
          expect(
            original,
            isNot(orderedEquals(changedBytes.buffer.asUint8List())),
            reason: '${layer.componentId} responds to controls',
          );
          changed.dispose();
          playTime = 4;
          final animated = await render(
            Composition(id: 'test', name: 'Test', layers: [layer]),
          );
          final animatedBytes = (await tester.runAsync(
            () => animated.toByteData(),
          ))!;
          expect(
            original,
            isNot(orderedEquals(animatedBytes.buffer.asUint8List())),
            reason: '${layer.componentId} animates',
          );
          animated.dispose();
          playTime = 0;
        }
        if (layer.componentId.startsWith('emitter_') ||
            layer.componentId == 'vortex_depth.v1' ||
            layer.componentId == 'glass_tide.v1') {
          final disturbed = await render(
            Composition(id: 'touch', name: 'Touch', layers: [layer]),
            touch: 1,
          );
          final disturbedBytes = (await tester.runAsync(
            () => disturbed.toByteData(),
          ))!.buffer.asUint8List();
          expect(
            bytes.buffer.asUint8List(),
            isNot(orderedEquals(disturbedBytes)),
            reason: '${layer.componentId} changes its surface under touch',
          );
          disturbed.dispose();
          await tester.runAsync(() async {
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            await Directory('build/qa').create(recursive: true);
            await File(
              'build/qa/${layer.componentId}.png',
            ).writeAsBytes(png!.buffer.asUint8List());
          });
        }
        image.dispose();
      }
      final base = Composition(
        id: 'test',
        name: 'Test',
        layers: [
          layers[0],
          layers[1].copyWith(opacity: .4, blend: LayerBlend.screen),
        ],
      );
      final first = await render(base);
      final firstBytes = (await tester.runAsync(
        () => first.toByteData(),
      ))!.buffer.asUint8List();
      final second = await render(
        base.copyWith(
          layers: [
            layers[0],
            layers[1].copyWith(
              opacity: .8,
              blend: LayerBlend.difference,
              warp: .8,
            ),
          ],
        ),
      );
      final secondBytes = (await tester.runAsync(
        () => second.toByteData(),
      ))!.buffer.asUint8List();
      expect(firstBytes, isNot(orderedEquals(secondBytes)));
      await tester.runAsync(() async {
        final png = await first.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build/qa').create(recursive: true);
        await File(
          'build/qa/composition.png',
        ).writeAsBytes(png!.buffer.asUint8List());
      });
      first.dispose();
      second.dispose();
      await tester.pumpWidget(const SizedBox());
      for (final shader in shaders.values) {
        shader.dispose();
      }
    },
  );
  testWidgets('Live preview publishes frames at the selected rate', (
    tester,
  ) async {
    final runtime = ShaderRuntime();
    final component = ComponentCatalog.components.first;
    await tester.runAsync(() => runtime.load(component.id));
    for (final fps in [24, 60]) {
      final recipe = Composition(
        id: 'fps-$fps',
        name: 'Frame test',
        frameRate: fps,
        layers: [
          ComponentInstance(
            id: 'test',
            componentId: component.id,
            parameters: component.defaults,
          ),
        ],
      );
      Widget preview(bool animate) => MaterialApp(
        home: Center(
          child: SizedBox(
            width: 64,
            height: 64,
            child: ShaderViewport(
              key: ValueKey(fps),
              recipe: recipe,
              runtime: runtime,
              animate: animate,
              height: 64,
            ),
          ),
        ),
      );
      await tester.pumpWidget(preview(false));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(preview(true));
      final paint = tester
          .widget<CustomPaint>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is CustomPaint &&
                  widget.painter is CompositionRenderer,
            ),
          )
          .painter!;
      var updates = 0;
      void count() => updates++;
      paint.addListener(count);
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(updates, closeTo(fps * .8, 2), reason: '$fps fps preview updates');
      paint.removeListener(count);
      await tester.pumpWidget(const SizedBox());
    }
  });
  testWidgets('Canvas drag changes the live particle field', (tester) async {
    final runtime = ShaderRuntime();
    final component = ComponentCatalog.components.last;
    await tester.runAsync(() => runtime.load(component.id));
    await tester.pumpWidget(
      MaterialApp(
        home: ShaderViewport(
          interactive: true,
          recipe: Composition(
            id: 'touch',
            name: 'Touch',
            layers: [
              ComponentInstance(
                id: 'vortex',
                componentId: component.id,
                parameters: component.defaults,
              ),
            ],
          ),
          runtime: runtime,
          height: 400,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.dragFrom(const Offset(200, 100), const Offset(80, 60));
    await tester.pump();
    final paint =
        tester
                .widgetList<CustomPaint>(find.byType(CustomPaint))
                .firstWhere((widget) => widget.painter is CompositionRenderer)
                .painter
            as CompositionRenderer;
    expect(paint.touchValue!(), greaterThan(0));
    await tester.pump(const Duration(seconds: 1));
    expect(paint.touchValue!(), 0);
    expect(paint.pointer, isNot(const Offset(.5, .5)));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

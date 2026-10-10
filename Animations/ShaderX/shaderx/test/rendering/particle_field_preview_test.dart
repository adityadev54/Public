import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaderx/features/catalog/data/component_catalog.dart';
import 'package:shaderx/features/composition/domain/composition.dart';
import 'package:shaderx/features/composition/domain/component_instance.dart';
import 'package:shaderx/rendering/composition_renderer.dart';
import 'package:shaderx/rendering/particle_sculpture.dart';

void main() {
  testWidgets(
    'Retained particle themes render distinct full-screen fields and finishes',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final captures = <List<int>>[];
      for (final id in [
        'particle_storm.v1',
        'particle_rain.v1',
        'ember_flock.v1',
        'orbital_dust.v1',
        'sculpture_knot.v1',
        'sculpture_ribbon.v1',
      ]) {
        final component = ComponentCatalog().component(id);
        final field = ParticleSculpture(kind: id);
        final form = component.defaults.values.last;
        for (var i = 0; i <= 120; i++) {
          field.step(
            time: i / 60,
            count: component.defaults['density']!,
            form: form,
            aspect: 390 / 844,
            pointer: const Offset(.65, .6),
            touch: i > 90 ? 1 : 0,
          );
        }
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            home: RepaintBoundary(
              key: key,
              child: CustomPaint(
                painter: CompositionRenderer(
                  recipe: Composition(
                    id: id,
                    name: component.name,
                    layers: [
                      ComponentInstance(
                        id: id,
                        componentId: id,
                        parameters: component.defaults,
                      ),
                    ],
                  ),
                  particleFields: {id: field},
                  shaders: const {},
                  time: () => 2,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final image = (await tester.runAsync(
          () =>
              (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
                  .toImage(),
        ))!;
        final bytes = (await tester.runAsync(
          () => image.toByteData(),
        ))!.buffer.asUint8List().toList();
        expect(bytes.toSet().length, greaterThan(30));
        captures.add(bytes);
        await tester.runAsync(() async {
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/qa').create(recursive: true);
          await File(
            'build/qa/$id.png',
          ).writeAsBytes(png!.buffer.asUint8List());
        });
        image.dispose();
      }
      for (var i = 1; i < captures.length; i++) {
        expect(captures[i], isNot(orderedEquals(captures[i - 1])));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

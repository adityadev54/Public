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
  test('Formation morph preserves particles and moves them gradually', () {
    for (final kind in [
      'formation_crane.v1',
      'formation_butterfly.v1',
      'formation_botanical.v1',
    ]) {
      final field = ParticleSculpture(kind: kind);
      final storage = field.positions;
      field.step(time: 0, count: 1, form: 0, aspect: .46);
      final before = field.positions.toList();
      field.step(time: 1 / 60, count: 1, form: 1, aspect: .46);
      expect(identical(storage, field.positions), isTrue);
      expect(field.positions, isNot(orderedEquals(before)));
      var maxStep = 0.0;
      for (var i = 0; i < before.length; i++) {
        final delta = (field.positions[i] - before[i]).abs();
        if (delta > maxStep) maxStep = delta;
      }
      expect(
        maxStep,
        lessThan(.04),
        reason: 'Morph uses momentum, not a position swap',
      );
      for (var i = 2; i <= 300; i++) {
        field.step(time: i / 60, count: 1, form: 1, aspect: .46);
      }
      expect(field.positions.every((v) => v.isFinite), isTrue);
    }
  });
  testWidgets(
    'Assembly endpoints show recognizable objects and distinct transformations',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final id in [
        'formation_crane.v1',
        'formation_butterfly.v1',
        'formation_botanical.v1',
      ]) {
        final component = ComponentCatalog().component(id);
        final captures = <List<int>>[];
        for (final form in [0.0, 1.0]) {
          final field = ParticleSculpture(kind: id);
          field.step(time: 0, count: .85, form: 0, aspect: 390 / 844);
          for (var i = 1; i <= 240; i++) {
            field.step(time: i / 60, count: .85, form: form, aspect: 390 / 844);
          }
          final key = GlobalKey();
          final params = {'density': .85, 'gather': form};
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
                          parameters: params,
                        ),
                      ],
                    ),
                    particleFields: {id: field},
                    shaders: const {},
                    time: () => 4,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          final image = (await tester.runAsync(
            () =>
                (key.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage(),
          ))!;
          final bytes = (await tester.runAsync(
            () => image.toByteData(),
          ))!.buffer.asUint8List().toList();
          expect(bytes.toSet().length, greaterThan(30));
          captures.add(bytes);
          await tester.runAsync(() async {
            await Directory('build/qa').create(recursive: true);
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            await File(
              'build/qa/$id-${form.toInt()}.png',
            ).writeAsBytes(png!.buffer.asUint8List());
          });
          image.dispose();
        }
        expect(captures[0], isNot(orderedEquals(captures[1])));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

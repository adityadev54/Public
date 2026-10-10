import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaderx_vortex/shaderx_vortex.dart';

void main() {
  testWidgets(
    'Standalone vortex fills the screen and responds to touch without rotating',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: key,
            child: const VortexBackground(animate: false),
          ),
        ),
      );
      await tester.runAsync(() async {
        await ui.FragmentProgram.fromAsset(VortexBackground.shaderAsset);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(VortexBackground)),
        const Size(390, 844),
      );
      Future<List<int>> capture(String name) async {
        final image = (await tester.runAsync(
          () =>
              (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
                  .toImage(),
        ))!;
        final bytes = (await tester.runAsync(
          () => image.toByteData(),
        ))!.buffer.asUint8List().toList();
        await tester.runAsync(() async {
          await Directory('build/qa').create(recursive: true);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'build/qa/vortex-$name.png',
          ).writeAsBytes(png!.buffer.asUint8List());
        });
        image.dispose();
        return bytes;
      }

      final original = await capture('full-screen');
      expect(original.toSet().length, greaterThan(30));
      final gesture = await tester.startGesture(const Offset(195, 422));
      await gesture.moveBy(const Offset(85, -60));
      await tester.pump();
      final disturbed = await capture('touch');
      expect(disturbed, isNot(orderedEquals(original)));
      await gesture.up();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      final recovered = await capture('released');
      expect(recovered, orderedEquals(original));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

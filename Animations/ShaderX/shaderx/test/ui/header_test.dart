import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaderx/core/ui/floating_controls.dart';
import 'package:shaderx/core/theme/app_theme.dart';

void main() {
  testWidgets('Navigation stays fixed while the body scrolls', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var menus = 0, settings = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(top: 59),
          ),
          child: Scaffold(
            body: PageFrame(
              title: 'ShaderX',
              onMenu: () => menus++,
              onSettings: () => settings++,
              child: const SizedBox(height: 1800),
            ),
          ),
        ),
      ),
    );
    final circle = find.byKey(const ValueKey('menu-circle'));
    expect(tester.getSize(circle), const Size(48, 48));
    expect(tester.getTopLeft(circle).dy, greaterThanOrEqualTo(59));
    expect(find.text('ShaderX'), findsNothing);
    await tester.tap(find.byTooltip('Open settings'));
    expect(settings, 1);
    await tester.tap(find.byTooltip('Open navigation'));
    expect(menus, 1);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(tester.getSize(circle), const Size(48, 48));
    final header = tester.widget<FloatingControls>(
      find.byType(FloatingControls),
    );
    expect(header.progress, 1);

    expect(find.byType(StatusFade), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

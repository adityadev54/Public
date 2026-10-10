import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaderx/features/catalog/data/component_catalog.dart';
import 'package:shaderx/features/composition/application/composition_controller.dart';
import 'package:shaderx/features/composition/domain/composition.dart';
import 'package:shaderx/features/composition/domain/master_tool.dart';

void main() {
  test('Layer operations and tool settings survive recipe serialization', () {
    final controller = CompositionController(ComponentCatalog());
    addTearDown(controller.dispose);
    controller.add(ComponentCatalog.legacyComponents.first);
    final first = controller.selected!.id;
    controller.add(ComponentCatalog.components[1]);
    controller.update(
      controller.selected!.copyWith(
        opacity: .42,
        scale: 1.4,
        rotation: .6,
        warp: .33,
        phase: .2,
        blend: LayerBlend.screen,
      ),
    );
    controller.timing(speed: 1.2, duration: 24);
    controller.reorder(first, 1);
    final roundTrip = Composition.fromJson(
      jsonDecode(jsonEncode(controller.recipe.toJson()))
          as Map<String, dynamic>,
    );
    controller.validate(roundTrip);
    expect(roundTrip.layers.last.id, first);
    expect(roundTrip.layers.first.blend, LayerBlend.screen);
    expect(roundTrip.layers.first.opacity, .42);
    expect(
      roundTrip.layers.first.parameters,
      ComponentCatalog.components[1].defaults,
    );
    expect(roundTrip.speed, 1.2);
    expect(roundTrip.duration, 24);
    controller.open(roundTrip);
    expect(controller.recipe.toJson(), roundTrip.toJson());
  });
  test(
    'Title and description survive edits, serialization, and legacy recipes',
    () {
      final controller = CompositionController(ComponentCatalog());
      addTearDown(controller.dispose);
      controller.newComposition(
        title: 'Amber study',
        description: 'Soft light through folded material.',
        iconId: 'prism',
        colorValue: 0xFFC88463,
        frameRate: 24,
      );
      controller.add(ComponentCatalog.legacyComponents.first);
      controller.parameter('thickness', .8);
      final decoded = Composition.fromJson(controller.recipe.toJson());
      expect(decoded.name, 'Amber study');
      expect(decoded.iconId, 'prism');
      expect(decoded.colorValue, 0xFFC88463);
      expect(decoded.frameRate, 24);
      expect(decoded.description, 'Soft light through folded material.');
      expect(
        decoded.copyWith(name: 'Renamed').description,
        decoded.description,
      );
      final legacy = controller.recipe.toJson()
        ..remove('description')
        ..remove('icon')
        ..remove('color')
        ..remove('frameRate');
      expect(Composition.fromJson(legacy).description, isEmpty);
      expect(Composition.fromJson(legacy).frameRate, 30);
      expect(Composition.fromJson(legacy).iconId, 'layers');
      final invalid = controller.recipe.toJson()..['frameRate'] = 0;
      expect(() => Composition.fromJson(invalid), throwsFormatException);
    },
  );
  test('A slider gesture is one undo step; redo restores its final state', () {
    final controller = CompositionController(ComponentCatalog());
    addTearDown(controller.dispose);
    controller.add(ComponentCatalog.legacyComponents.first);
    controller.beginEdit();
    controller.parameter('thickness', .2);
    controller.parameter('thickness', .4);
    controller.parameter('thickness', .8);
    controller.endEdit();
    controller.undo();
    expect(controller.selected!.parameters['thickness'], .46);
    controller.redo();
    expect(controller.selected!.parameters['thickness'], .8);
    controller.remove(controller.selected!.id);
    expect(controller.recipe.layers, isEmpty);
    controller.undo();
    expect(controller.recipe.layers, hasLength(1));
  });
  test('Unknown schema and invalid values cannot enter the saved recipe', () {
    final controller = CompositionController(ComponentCatalog());
    addTearDown(controller.dispose);
    controller.add(ComponentCatalog.legacyComponents.first);
    final json = controller.recipe.toJson();
    json['schema'] = 100;
    expect(() => Composition.fromJson(json), throwsFormatException);
    json['schema'] = 1;
    (json['layers'] as List).first['opacity'] = -1;
    expect(() => Composition.fromJson(json), throwsFormatException);
  });
  test('Layer capacity is enforced without replacing existing layers', () {
    final controller = CompositionController(ComponentCatalog());
    addTearDown(controller.dispose);
    for (var i = 0; i < 7; i++) {
      controller.add(ComponentCatalog.legacyComponents.first);
    }
    expect(controller.recipe.layers, hasLength(6));
    expect(controller.canAdd, isFalse);
    expect(controller.recipe.layers.map((l) => l.id).toSet(), hasLength(6));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shaderx/features/catalog/data/component_catalog.dart';
import 'package:shaderx/features/composition/application/composition_controller.dart';
import 'package:shaderx/features/library/data/local_composition_repository.dart';

void main() {
  test(
    'Save updates one recipe; drafts and saved copies are independent',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalCompositionRepository(prefs);
      final controller = CompositionController(ComponentCatalog());
      addTearDown(controller.dispose);
      controller.add(ComponentCatalog.legacyComponents.first);
      controller.rename('Film study');
      await repository.save(controller.recipe);
      controller.rename('Second version');
      await repository.save(controller.recipe);
      expect(await repository.load(), hasLength(1));
      expect((await repository.load()).first.name, 'Second version');
      controller.parameter('thickness', .9);
      await repository.saveDraft(controller.recipe);
      final reopened = LocalCompositionRepository(
        await SharedPreferences.getInstance(),
      );
      expect(
        (await reopened.loadDraft())!.layers.first.parameters['thickness'],
        .9,
      );
      expect(
        (await reopened.load()).first.layers.first.parameters['thickness'],
        .46,
      );
      await repository.delete(controller.recipe.id);
      expect(await repository.load(), isEmpty);
      expect(await repository.loadDraft(), isNotNull);
    },
  );
  test(
    'Unreadable storage surfaces an error without erasing the data',
    () async {
      SharedPreferences.setMockInitialValues({'shaderx.library.v1': 'broken'});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalCompositionRepository(prefs);
      await expectLater(repository.load(), throwsFormatException);
      expect(prefs.getString('shaderx.library.v1'), 'broken');
    },
  );
}

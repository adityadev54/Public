# ShaderX architecture proposal

Organize ShaderX around catalog discovery, composition editing, and saved work. Keep the domain recipe independent of the Flutter interface and the GPU runtime so new components and the four master tools can evolve without turning screen widgets into the product engine.

This is a proposed structure. The four tools, first theme, component catalog, output formats, and final rendering strategy are not selected here.

## Folder structure

```text
shaderx/
  docs/
    product_brief.md
    gita_reference.md
    architecture.md
  lib/
    main.dart
    app/
      shaderx_app.dart
      navigation/
        app_shell.dart
        app_routes.dart
    core/
      theme/
        app_theme.dart
        app_tokens.dart
      layout/
        responsive.dart
        content_frame.dart
      ui/
        kin_components.dart
        floating_controls.dart
        app_dialog.dart
        app_sheet_route.dart
    features/
      catalog/
        domain/
          shader_theme.dart
          shader_component.dart
          component_parameters.dart
        data/
          component_catalog.dart
        presentation/
          themes_screen.dart
          component_detail_screen.dart
          widgets/
      composition/
        domain/
          composition.dart
          component_instance.dart
          master_tool.dart
        application/
          composition_controller.dart
        presentation/
          workspace_screen.dart
          widgets/
      home/
        presentation/
          home_screen.dart
      library/
        domain/
          composition_repository.dart
        data/
          local_composition_repository.dart
        presentation/
          library_screen.dart
      settings/
        application/
          settings_controller.dart
        presentation/
          settings_screen.dart
    rendering/
      component_registry.dart
      shader_runtime.dart
      composition_renderer.dart
      shader_viewport.dart
  shaders/
    common/
    components/
  assets/
    brand/
    catalog/
  test/
    catalog/
    composition/
    library/
    rendering/
    ui/
  integration_test/
```

Create folders as their responsibilities are implemented. Do not populate the project with empty classes, invented tool implementations, or unused frameworks merely to match the tree.

## Ownership boundaries

- **App** owns startup, navigation, and the shared shell. `main.dart` performs startup and launches the app.
- **Core** owns reusable interface foundations. It contains no catalog subjects, tool logic, or saved composition rules.
- **Catalog** describes themes and components through stable identifiers and component-specific parameter definitions. Display order must not become a persisted identifier.
- **Composition domain** describes the editable recipe. The tool model remains neutral until the four tools are defined. The recipe must support their actual behavior instead of assuming four normalized floats or exactly two layers.
- **Composition controller** owns edit state and coordinates actions. Undo and redo can be added if required by the defined workflow; screen widgets should not duplicate recipe state.
- **Library** owns persistence through a repository contract. A saved recipe needs a schema version and enough state to reproduce the intended result. Thumbnails are previews of that recipe, not its source of truth.
- **Rendering** maps a recipe to GPU resources. Component uniforms, shader loading, animation time, resource disposal, and render scheduling belong here, outside persistence and screen layout.

## Dependency direction

The workspace sends user actions to the composition controller. The controller updates a domain recipe. The renderer reads that recipe and resolves component IDs through its registry. The library repository saves and loads the recipe. The interface displays catalog metadata without learning shader uniform offsets.

Domain models should not import widget classes, canvas objects, or preference storage. Rendering should not choose navigation destinations or write saved work. Components should expose parameter contracts instead of relying on one global set of controls to mean the same thing for every subject.

## Gita compatibility

Use Gita’s separation of themes, responsive helpers, shared controls, screens, models, and services as a foundation. Feature folders give ShaderX’s catalog, editor, and renderer clearer boundaries as complexity grows. This proposal adapts Gita’s architecture; it does not claim that Gita already uses this exact tree.

Keep Kin in the interface layer and retain relevant compatibility behavior. Use the existing Flutter approach and observable controllers unless requirements justify a different state library. Existing Gita dependency choices do not require ShaderX to inherit unrelated backend or media services.

## Rendering decisions to defer

The four tools may require effects beyond color interpolation. Their definitions must determine whether shader stages, textures, masks, or multiple passes are needed. Avoid one giant fragment shader selected by hardcoded numeric branches as the catalog’s permanent extension mechanism.

Once the tool contracts are clear, prove one component and the required composition behavior on the primary platform. Establish limits for simultaneously animated previews, pause work when obscured or backgrounded, isolate frame updates from the catalog UI, and honor reduced motion. Verify real shader output on a target device as well as UI tests.

## Acceptance before rebuilding

A coherent rebuild should demonstrate a theme-to-component discovery path, a workspace where all four tools have defined purposes, reproducible saved work, and Gita-derived navigation behavior. It should also demonstrate that adding a component does not require editing the home screen, storage implementation, and renderer in the same place.

Brand approval and the chosen output destination should precede the final visual treatment and export implementation. The rejected draft’s catalog, palette, tool names, and crossfade are not requirements for the rebuild.

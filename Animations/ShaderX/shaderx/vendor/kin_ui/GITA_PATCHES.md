# Kin UI 1.7.1 compatibility changes

This directory contains the MIT-licensed `lib`, `pubspec.yaml`, and `LICENSE` from
Kin UI 1.7.1, published at https://pub.dev/packages/kin_ui/versions/1.7.1.
The application declares Kin UI 1.7.1 and overrides it with this local copy.
Do not remove the override until upstream supports these compatibility options.

Gita keeps its existing layout, typography, colors, assets, native keyboard
handling, accessibility semantics and control geometry. The stock Kin defaults
would redesign those screens. `lib/widgets/kin_components.dart` adapts Gita's
existing calls to the following Kin components:

- KinText, including a rich-text constructor for inline verse references.
- KinPress for tap targets, respecting reduced motion and avoiding duplicate
  haptics or long-press recognizers where no long-press action exists.
- KinButton with an optional native appearance child. The native Material
  control retains focus, keyboard, ripple, semantics, disabled state and styles;
  Kin provides spring press motion without handling its action a second time.
- KinTextField with optional InputDecoration and native text configuration.
  Controller and FocusNode replacements correctly detach listeners; externally
  supplied objects remain owned by the caller. GitaTextFormField integrates
  validation, programmatic edits, reset and controller ownership with Form.
- KinSlider, KinPremiumToggle, KinProgress and KinDivider offer an optional
  native appearance mode to honor existing inherited themes and dimensions.
  KinPremiumToggle is the package's toggle name, with no subscription behavior.

The fork removes its unused Lucide dependency. Gita uses the static
`heroicons_flutter` outline glyphs, retaining native IconTheme sizing and colors.
KinButton's spring listener is registered once rather than repeatedly per tap.
Slider snapping in the stock renderer now respects a nonzero minimum.
Native-decoration fields skip unnecessary focus/character-count rebuilds.

Flutter layout, scrolling hosts, Navigator routes, Scaffold, modal sheet/dialog
shells, SnackBar hosts, rich-text spans, existing icon glyphs and drag recognizers
remain Flutter primitives. Custom cards retain their decoration/layout and use
KinPress for interaction. No templates or Kin navigation scaffolds replace
Gita's established screen structure. The data, model and service layers are
outside this migration.

When upgrading Kin, compare this copy against the new published source and
reapply/reassess these changes. Run `flutter test test/kin_components_test.dart`,
static analysis and a platform build. Tests compare resting component pixels
against the prior Material implementation across light/dark/high-contrast themes
and text scaling, and exercise input validation and interaction contracts.

- KinListTile supports optional title/subtitle styles and line limits so compact grouped rows retain Gita typography without changing package defaults.

- KinPopupMenuItem.selectable=false presents static details without press feedback or dismiss-on-row-tap; the default preserves existing selectable menus.

- KinChip accepts optional padding and borderRadius so search chips can share 8 px corners and filter sizing; defaults remain unchanged.

- KinDialog.contentOnly allows existing forms and their actions to use the Kin dialog surface without duplicate headers or confirm buttons. Gita presents these dialogs centered, with keyboard-aware bounds and typed route results.

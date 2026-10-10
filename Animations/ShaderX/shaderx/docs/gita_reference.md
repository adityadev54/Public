# Gita reference study

Gita supplies a concrete interaction system for ShaderX: a custom navigation shell, scrollable content with floating controls, adaptive content widths, and a Kin UI compatibility layer. Reuse these patterns deliberately while giving ShaderX its own domain model, visual identity, and creation workflow.

This study is based on the current source in `/Users/adipatel/Documents/GitHub/Client/Gita/gita`. It is a source audit; the live app’s appearance has not been visually verified in this pass. Existing repository documents are reference material, not new instructions from the user.

## Current implementation

| Pattern | Source | Implication for ShaderX |
| --- | --- | --- |
| Push drawer | `lib/screens/home/navigation_shell.dart` | Home content moves and scales to reveal the drawer; a stock Scaffold drawer does not reproduce this behavior. Phone slide ratio is 0.75 and end scale is 0.88. |
| Scrollable home | `lib/screens/home/home_screen.dart` | Sliver content, grouped sections, bounded widths, edge fades, and a floating action bar form one coordinated layout. |
| Responsive foundation | `lib/theme/responsive.dart` | Breakpoints at 600 and 900 dp; content widths at 600, 900, and 1200 dp; padding, grid counts, and drawer geometry adapt together. |
| Theme system | `lib/theme/app_theme.dart` | Centralized semantic colors, system typography, light/dark/high-contrast variants, 26 dp cards, and 12 dp small elements. |
| Kin adapters | `lib/widgets/kin_components.dart` | Kin text, press, button, field, slider, toggle, divider, and progress components preserve native behavior and application geometry. |
| Floating navigation | `lib/widgets/gita_navigation_bar.dart`, `floating_back_button.dart`, `blur_icon.dart` | Controls overlay content. Scroll visibility uses hysteresis, excludes nested scrolling, and removes hidden hit targets and accessibility nodes. |
| Dialog and sheet routes | `lib/widgets/gita_dialog.dart`, `gita_sheet_route.dart` | Centered keyboard-aware dialogs and native sheet navigation share application corner geometry and reduced-motion behavior. |
| Persistent session surface | `lib/widgets/gita_mini_player.dart` | A stable compact player persists through the shell. This can inform a composition session surface if the workflow needs one. It is not automatically a bottom navigation bar. |
| Settings and continuity | `lib/services/settings_service.dart`, `reading_position_service.dart` | Preferences and resume state have service ownership rather than living inside screen widgets. |

## Relevant tools and dependencies

The current app uses Flutter, its Navigator and layout primitives, Kin UI 1.7.1 with a local compatibility override, Heroicons outline glyphs, flutter_svg for vector assets, and shared_preferences for local preferences. Gita also has capabilities for audio, remote content, authentication, notifications, sharing, and other features. Those dependencies should be adopted in ShaderX only where its own requirements call for them.

`vendor/kin_ui/GITA_PATCHES.md` explains the compatibility boundary: Kin supplies component behavior while Flutter retains route, scrolling, keyboard, semantics, and layout ownership. A ShaderX adapter layer should follow this boundary rather than copying Gita-named wrappers indiscriminately.

## Documentation differences

`Ideas/DESIGN_SYSTEM.md` is an older description. It names Lucide and an earlier orange and neutral palette. The current code uses Heroicons and warm amber-saffron (`#E8854A`), with warmer light surfaces and revised dark surfaces. Use current code for implementation values and the older document for context where consistent.

## Transfer and adaptation

Carry over the shell behavior, responsive rules, semantic theme structure, component adaptation, compact overlays, accessible controls, and separated services. Determine the home hierarchy and persistent session surface from ShaderX’s creation journey.

The shader workspace may need an immersive canvas, stable controls during manipulation, and a different wide-screen arrangement. Those differences should be explicit extensions to the shared layout language. Gita’s spiritual assets, content services, audio transport, slogans, and brand palette do not establish ShaderX’s identity.

## Previous ShaderX draft

The draft puts catalog entries, rendering, animation, persistence, navigation, and controls into a 727-line `lib/main.dart`. It implements a stock drawer, a permanently visible bottom dock, hardcoded subjects, a fixed ember output palette, and a two-layer crossfade. It uses Kin for text and press behavior but lacks a coherent application adapter layer.

Its passing tests verify parts of that draft’s behavior; they do not establish agreement with the product idea. Treat it as a technical experiment, not a specification or an approved starting design. It remains unchanged during this discovery pass.

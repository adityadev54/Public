# ShaderX vortex

A full-bleed Flutter background with layered spiral filaments, a dark funnel, local touch forces and configurable color. No Kin UI, ShaderX navigation or composition dependencies.

Copy this package folder into your app and add a path dependency:

```yaml
dependencies:
  shaderx_vortex:
    path: packages/shaderx_vortex
```

```dart
import 'package:shaderx_vortex/shaderx_vortex.dart';

Scaffold(
  body: VortexBackground(
    color: Color(0xFFF05E29),
    pull: .65,
    density: .6,
    speed: .7,
    frameRate: 30,
    child: SafeArea(child: YourScreen()),
  ),
);
```

Use `Positioned.fill` in a Stack for an edge-to-edge backdrop, including behind status bars. Place foreground content inside SafeArea, not the effect. Drag bends nearby currents and pulls the center; pinch changes funnel scale; release fades the force. Foreground interactive widgets retain their gestures. `interactive: false` makes a decorative background. `animate: false` freezes the flow while allowing touch interaction.

The shader is packaged and compiled through Flutter's shader asset pipeline. Animation respects app lifecycle, TickerMode and reduced-motion settings. Frame rate defaults to 30 and is configurable up to 60; performance still needs profiling on target devices. This is a procedural visual field, not a fluid simulation. Integration targets Flutter apps; other frameworks need a GLSL/uniform adapter.

Uniform order: size (2), time, scale, rotation, warp, pull, density, opacity, pointer (2), touch, color (3). Time completes a cycle at 16 seconds.

Shader asset packaging follows [Flutter fragment shader documentation](https://docs.flutter.dev/ui/design/graphics/fragment-shaders).

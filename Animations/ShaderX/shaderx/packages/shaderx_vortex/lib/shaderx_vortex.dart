import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

/// Reusable full-bleed background. Place in bounded constraints, for example
/// Positioned.fill or Scaffold.body. Foreground children retain their gestures.
class VortexBackground extends StatefulWidget {
  static const shaderAsset = 'packages/shaderx_vortex/shaders/vortex.frag';
  final Widget? child;
  final Color color;
  final double pull, density, speed;
  final int frameRate;
  final bool interactive, animate;
  const VortexBackground({
    super.key,
    this.child,
    this.color = const Color(0xFFF05E29),
    this.pull = .65,
    this.density = .6,
    this.speed = 1,
    this.frameRate = 30,
    this.interactive = true,
    this.animate = true,
  }) : assert(pull >= 0 && pull <= 1),
       assert(density >= 0 && density <= 1),
       assert(speed >= 0 && speed <= 4),
       assert(frameRate >= 1 && frameRate <= 60);
  @override
  State<VortexBackground> createState() => _VortexBackgroundState();
}

class _VortexBackgroundState extends State<VortexBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static Future<ui.FragmentProgram>? program;
  ui.FragmentShader? shader;
  late final Ticker ticker;
  final frames = ValueNotifier<int>(0);
  Duration previous = Duration.zero, published = Duration.zero;
  double time = 0, touch = 0, scale = 1, startScale = 1;
  Offset pointer = const Offset(.5, .5);
  bool pressing = false, active = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ticker = createTicker((elapsed) {
      final dt = math.min((elapsed - previous).inMicroseconds / 1e6, .05);
      previous = elapsed;
      if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
        time = (time + dt * widget.speed) % 16;
      }
      if (!pressing) touch = math.max(0, touch - dt * 1.5);
      if ((elapsed - published).inMicroseconds >= 1e6 / widget.frameRate) {
        published = elapsed;
        frames.value++;
        sync();
      }
    });
    load();
  }

  Future<void> load() async {
    try {
      final loaded = await (program ??= ui.FragmentProgram.fromAsset(
        VortexBackground.shaderAsset,
      ));
      if (mounted) setState(() => shader = loaded.fragmentShader());
    } catch (error, stack) {
      program = null;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'shaderx_vortex',
        ),
      );
    }
  }

  void sync() {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final run =
        active &&
        TickerMode.valuesOf(context).enabled &&
        ((widget.animate && !reduced) || touch > 0);
    if (run && !ticker.isActive) {
      previous = published = Duration.zero;
      ticker.start();
    } else if (!run && ticker.isActive) {
      ticker.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sync();
  }

  @override
  void didUpdateWidget(VortexBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    active = state == AppLifecycleState.resumed;
    sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ticker.dispose();
    frames.dispose();
    shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      void update(Offset local) {
        pointer = Offset(
          (local.dx / bounds.maxWidth).clamp(0, 1),
          (local.dy / bounds.maxHeight).clamp(0, 1),
        );
        touch = 1;
        frames.value++;
        sync();
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: widget.interactive
            ? (event) {
                pressing = true;
                startScale = scale;
                update(event.localFocalPoint);
              }
            : null,
        onScaleUpdate: widget.interactive
            ? (event) {
                scale = (startScale * event.scale).clamp(.5, 2);
                update(event.localFocalPoint);
              }
            : null,
        onScaleEnd: widget.interactive
            ? (_) {
                pressing = false;
                sync();
              }
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(painter: _VortexPainter(this, frames)),
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      );
    },
  );
}

class _VortexPainter extends CustomPainter {
  final _VortexBackgroundState state;
  _VortexPainter(this.state, Listenable repaint) : super(repaint: repaint);
  @override
  void paint(Canvas canvas, Size size) {
    final shader = state.shader;
    final widget = state.widget;
    if (shader == null) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFF09050D),
      );
      return;
    }
    final values = [
      size.width,
      size.height,
      state.time,
      state.scale,
      0.0,
      0.0,
      widget.pull,
      widget.density,
      1.0,
      state.pointer.dx,
      state.pointer.dy,
      state.touch,
      widget.color.r,
      widget.color.g,
      widget.color.b,
    ];
    for (var i = 0; i < values.length; i++) {
      shader.setFloat(i, values[i]);
    }
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_VortexPainter oldDelegate) => true;
}

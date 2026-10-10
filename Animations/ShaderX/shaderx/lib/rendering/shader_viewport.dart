import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../features/composition/domain/composition.dart';
import 'shader_runtime.dart';
import 'composition_renderer.dart';
import 'particle_sculpture.dart';

class ShaderViewport extends StatefulWidget {
  final VoidCallback? onDoubleTap;
  final bool interactive;
  final Composition recipe;
  final ShaderRuntime runtime;
  final bool animate;
  final double height;
  final double cornerRadius;
  const ShaderViewport({
    super.key,
    this.interactive = false,
    this.onDoubleTap,
    required this.recipe,
    required this.runtime,
    this.animate = false,
    this.height = 280,
    this.cornerRadius = 26,
  });
  @override
  State<ShaderViewport> createState() => _ShaderViewportState();
}

class _ShaderViewportState extends State<ShaderViewport>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final Map<String, ui.FragmentShader> shaders = {};
  final particleFields = <String, ParticleSculpture>{};
  final frame = ValueNotifier<double>(0);
  late final Ticker ticker;
  int generation = 0;
  Duration last = Duration.zero, lastPublished = Duration.zero;
  ui.Offset pointer = const ui.Offset(.5, .5);
  double touch = 0, gestureScale = 1, startScale = 1;
  double elapsed = 0;
  String? error;
  bool active = true, touching = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    elapsed = widget.recipe.playhead;
    ticker = createTicker((delta) {
      final dt = (delta - last).inMicroseconds / 1000000;
      last = delta;
      if (widget.animate) {
        elapsed = (elapsed + dt * widget.recipe.speed) % widget.recipe.duration;
      }
      if (!touching && touch > 0) {
        touch = (touch - dt * 1.5).clamp(0.0, 1.0);
      }
      final interval = (1000000 / widget.recipe.frameRate).round();
      if ((delta - lastPublished).inMicroseconds >= interval) {
        lastPublished = Duration(
          microseconds: (delta.inMicroseconds ~/ interval) * interval,
        );
        frame.value += 1;
        if (!widget.animate && touch == 0) syncTicker();
      }
    });
    load();
  }

  void syncTicker() {
    final run =
        (widget.animate || touch > 0) &&
        active &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled &&
        widget.recipe.layers.isNotEmpty;
    if (run && !ticker.isActive) {
      last = Duration.zero;
      lastPublished = Duration.zero;
      ticker.start();
    }
    if (!run && ticker.isActive) ticker.stop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    active = state == AppLifecycleState.resumed;
    syncTicker();
  }

  @override
  void didUpdateWidget(ShaderViewport old) {
    super.didUpdateWidget(old);
    if (old.recipe.id != widget.recipe.id) elapsed = widget.recipe.playhead;
    syncTicker();
    load();
  }

  Future<void> load() async {
    final token = ++generation;
    final keep = widget.recipe.layers.map((l) => l.id).toSet();
    particleFields.removeWhere((id, _) => !keep.contains(id));
    for (final layer in widget.recipe.layers) {
      if (ParticleSculpture.supports(layer.componentId)) {
        particleFields.putIfAbsent(
          layer.id,
          () => ParticleSculpture(kind: layer.componentId),
        );
      }
    }
    final discarded = shaders.keys.where((id) => !keep.contains(id)).toList();
    for (final id in discarded) {
      shaders.remove(id)?.dispose();
    }
    try {
      for (final layer in widget.recipe.layers) {
        if (shaders.containsKey(layer.id)) continue;
        final program = await widget.runtime.load(layer.componentId);
        if (!mounted || token != generation) return;
        shaders[layer.id] = program.fragmentShader();
      }
      if (mounted && token == generation) setState(() => error = null);
    } catch (_) {
      if (mounted && token == generation) {
        setState(() => error = 'This component could not render.');
      }
    }
  }

  @override
  void dispose() {
    generation++;
    ticker.dispose();
    frame.dispose();
    WidgetsBinding.instance.removeObserver(this);
    for (final shader in shaders.values) {
      shader.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Composition preview with ${widget.recipe.layers.length} layers',
    image: true,
    child: SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.cornerRadius),
        child: RepaintBoundary(
          child: LayoutBuilder(
            builder: (context, box) => GestureDetector(
              key: const ValueKey('shader-play-canvas'),
              onDoubleTap: widget.onDoubleTap,
              onScaleEnd: widget.interactive
                  ? (_) {
                      touching = false;
                      syncTicker();
                    }
                  : null,
              onScaleStart: widget.interactive
                  ? (event) {
                      startScale = gestureScale;
                      touching = true;
                      touch = 1;
                      pointer = ui.Offset(
                        (event.localFocalPoint.dx / box.maxWidth).clamp(0, 1),
                        (event.localFocalPoint.dy / box.maxHeight).clamp(0, 1),
                      );
                      syncTicker();
                      setState(() {});
                    }
                  : null,
              onScaleUpdate: widget.interactive
                  ? (event) {
                      pointer = ui.Offset(
                        (event.localFocalPoint.dx / box.maxWidth).clamp(0, 1),
                        (event.localFocalPoint.dy / box.maxHeight).clamp(0, 1),
                      );
                      touch = 1;
                      gestureScale = (startScale * event.scale).clamp(.5, 2);
                      setState(() {});
                    }
                  : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: CompositionRenderer(
                      recipe: widget.recipe,
                      particleFields: particleFields,
                      pointer: pointer,
                      touch: touch,
                      touchValue: () => touch,
                      gestureScale: gestureScale,
                      shaders: Map.of(shaders),
                      time: () => elapsed,
                      repaint: frame,
                    ),
                  ),
                  if (widget.recipe.layers.isEmpty)
                    const Center(
                      child: Text(
                        'Your canvas starts here.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  if (error != null)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            error!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              for (final layer in widget.recipe.layers) {
                                widget.runtime.retry(layer.componentId);
                              }
                              load();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

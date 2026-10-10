//
//  DEPRECTAED COMPONENT -- SOON TO BE DELETED
//


// import 'dart:math' as math;
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // PUBLIC API
// // ─────────────────────────────────────────────────────────────────────────────

// /// Preset moods that define unique colour palettes.
// ///
// /// Every palette was designed to feel *unexpected* — colours that break the
// /// typical AI blue/purple cliché and instead evoke something organic, living,
// /// and otherworldly.
// enum KinAIGradientMood {
//   /// Deep oceanic bioluminescence — midnight teal → electric cyan → warm coral.
//   abyss,

//   /// Volcanic aurora — molten amber → magenta → ultraviolet.
//   ember,

//   /// Alien botany — chartreuse → turquoise → lilac → blush.
//   flora,

//   /// Cosmic dust — dusty rose → burnt sienna → slate blue → champagne.
//   nebula,

//   /// Arctic mirage — pearl white → icy mint → soft lavender → warm peach.
//   frost,

//   /// Solar flare — living gold → tangerine → fuchsia → deep indigo.
//   solar,

//   /// Deep forest mycelium — moss → warm brown → bioluminescent green → violet.
//   mycelium,

//   /// Iridescent oil-spill — shifting teal → magenta → gold → emerald.
//   iridescent,
// }

// /// Animation behaviour for the gradient.
// enum KinAIGradientAnimation {
//   /// Colours slowly breathe and shift.
//   breathe,

//   /// Fluid blobs orbit and merge.
//   orbit,

//   /// Gentle wave ripple across the surface.
//   wave,

//   /// Idle shimmer — minimal movement, elegant glow.
//   shimmer,

//   /// Energetic pulse — reactive, fast.
//   pulse,

//   /// No animation — static gradient.
//   none,
// }

// /// A fluid, animated AI gradient surface.
// ///
// /// Drop it anywhere — full-screen background, card decoration, avatar ring,
// /// small indicator dot. It adapts to any size and aspect ratio.
// ///
// /// ```dart
// /// KinAIGradient(
// ///   mood: KinAIGradientMood.ember,
// ///   animation: KinAIGradientAnimation.orbit,
// ///   child: Center(child: Text('Hello AI')),
// /// )
// /// ```
// class KinAIGradient extends StatefulWidget {
//   /// Colour mood preset.
//   final KinAIGradientMood mood;

//   /// Animation style.
//   final KinAIGradientAnimation animation;

//   /// Custom colours — overrides [mood] when provided.
//   final List<Color>? colors;

//   /// Animation speed multiplier (1.0 = default).
//   final double speed;

//   /// Blur radius for the fluid blobs (higher = softer).
//   final double blur;

//   /// Overall intensity / saturation boost (0.0–2.0).
//   final double intensity;

//   /// Shape: if non-null clips to this shape.
//   final BoxShape? shape;

//   /// Border radius when [shape] is null.
//   final BorderRadius? borderRadius;

//   /// Fixed size. If null, expands to parent constraints.
//   final Size? size;

//   /// Optional child widget rendered on top of the gradient.
//   final Widget? child;

//   /// Opacity of the gradient layer (0.0–1.0).
//   final double opacity;

//   /// Enable touch interaction — drag to attract blobs, tap to ripple.
//   final bool interactive;

//   /// How strongly touch attracts blobs (0.0–1.0).
//   final double touchInfluence;

//   const KinAIGradient({
//     super.key,
//     this.mood = KinAIGradientMood.abyss,
//     this.animation = KinAIGradientAnimation.breathe,
//     this.colors,
//     this.speed = 1.0,
//     this.blur = 60.0,
//     this.intensity = 1.0,
//     this.shape,
//     this.borderRadius,
//     this.size,
//     this.child,
//     this.opacity = 1.0,
//     this.interactive = true,
//     this.touchInfluence = 0.6,
//   });

//   @override
//   State<KinAIGradient> createState() => _KinAIGradientState();
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // PALETTES
// // ─────────────────────────────────────────────────────────────────────────────

// List<Color> _paletteFor(KinAIGradientMood mood) => switch (mood) {
//       KinAIGradientMood.abyss => const [
//           Color(0xFF0B2027),
//           Color(0xFF0A4D5C),
//           Color(0xFF00E5CC),
//           Color(0xFFFF6F61),
//           Color(0xFF1B3A4B),
//         ],
//       KinAIGradientMood.ember => const [
//           Color(0xFF1A0A2E),
//           Color(0xFFFF6B2B),
//           Color(0xFFE040A0),
//           Color(0xFF7B2FBE),
//           Color(0xFFFFAA33),
//         ],
//       KinAIGradientMood.flora => const [
//           Color(0xFF0D1F0D),
//           Color(0xFFA8E06C),
//           Color(0xFF3DD6C8),
//           Color(0xFFB68AE5),
//           Color(0xFFF5A6C8),
//         ],
//       KinAIGradientMood.nebula => const [
//           Color(0xFF1A1423),
//           Color(0xFFD4889C),
//           Color(0xFFC07040),
//           Color(0xFF5C6B9C),
//           Color(0xFFE8D5B5),
//         ],
//       KinAIGradientMood.frost => const [
//           Color(0xFFF0EDE8),
//           Color(0xFFE0F7F4),
//           Color(0xFFCBC3E3),
//           Color(0xFFFFD5C2),
//           Color(0xFFB8E6D0),
//         ],
//       KinAIGradientMood.solar => const [
//           Color(0xFF0F0A1A),
//           Color(0xFFFFD700),
//           Color(0xFFFF6B35),
//           Color(0xFFFF1493),
//           Color(0xFF2D1B69),
//         ],
//       KinAIGradientMood.mycelium => const [
//           Color(0xFF0A0F0A),
//           Color(0xFF4A6741),
//           Color(0xFF8B6E4E),
//           Color(0xFF39FF85),
//           Color(0xFF7B4FBF),
//         ],
//       KinAIGradientMood.iridescent => const [
//           Color(0xFF0D1117),
//           Color(0xFF00C9B7),
//           Color(0xFFE040FB),
//           Color(0xFFFFD54F),
//           Color(0xFF00E676),
//         ],
//     };

// // ─────────────────────────────────────────────────────────────────────────────
// // STATE
// // ─────────────────────────────────────────────────────────────────────────────

// class _KinAIGradientState extends State<KinAIGradient>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late AnimationController _rippleController;

//   /// Normalised touch position (0–1 in both axes). Null when not touching.
//   Offset? _touch;

//   /// Ripple centre (normalised) from last tap.
//   Offset? _rippleCenter;

//   @override
//   void initState() {
//     super.initState();
//     final duration = switch (widget.animation) {
//       KinAIGradientAnimation.pulse => const Duration(milliseconds: 1800),
//       KinAIGradientAnimation.shimmer => const Duration(milliseconds: 6000),
//       KinAIGradientAnimation.wave => const Duration(milliseconds: 4000),
//       KinAIGradientAnimation.orbit => const Duration(milliseconds: 8000),
//       KinAIGradientAnimation.breathe => const Duration(milliseconds: 10000),
//       KinAIGradientAnimation.none => const Duration(milliseconds: 10000),
//     };

//     _controller = AnimationController(vsync: this, duration: duration);
//     _rippleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );

//     if (widget.animation != KinAIGradientAnimation.none) {
//       _controller.repeat();
//     }
//   }

//   @override
//   void didUpdateWidget(KinAIGradient old) {
//     super.didUpdateWidget(old);
//     if (widget.animation == KinAIGradientAnimation.none) {
//       _controller.stop();
//     } else if (!_controller.isAnimating) {
//       _controller.repeat();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _rippleController.dispose();
//     super.dispose();
//   }

//   void _onPointerDown(PointerDownEvent e, Size size) {
//     if (!widget.interactive || size == Size.zero) return;
//     setState(() {
//       _touch = Offset(
//         (e.localPosition.dx / size.width).clamp(0, 1),
//         (e.localPosition.dy / size.height).clamp(0, 1),
//       );
//       _rippleCenter = _touch;
//     });
//     _rippleController.forward(from: 0);
//     HapticFeedback.lightImpact();
//   }

//   void _onPointerMove(PointerMoveEvent e, Size size) {
//     if (!widget.interactive || size == Size.zero) return;
//     setState(() {
//       _touch = Offset(
//         (e.localPosition.dx / size.width).clamp(0, 1),
//         (e.localPosition.dy / size.height).clamp(0, 1),
//       );
//     });
//   }

//   void _onPointerUp(PointerUpEvent e) {
//     if (!widget.interactive) return;
//     setState(() => _touch = null);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = widget.colors ?? _paletteFor(widget.mood);

//     // Sizing must wrap before LayoutBuilder so constraints are bounded.
//     Widget result = LayoutBuilder(
//       builder: (context, constraints) {
//         final w = constraints.maxWidth.isFinite
//             ? constraints.maxWidth
//             : (widget.size?.width ?? 200);
//         final h = constraints.maxHeight.isFinite
//             ? constraints.maxHeight
//             : (widget.size?.height ?? 200);
//         final paintSize = Size(w, h);

//         return Listener(
//           onPointerDown: (e) => _onPointerDown(e, paintSize),
//           onPointerMove: (e) => _onPointerMove(e, paintSize),
//           onPointerUp: _onPointerUp,
//           behavior: HitTestBehavior.opaque,
//           child: AnimatedBuilder(
//             animation: Listenable.merge([_controller, _rippleController]),
//             builder: (context, _) {
//               return CustomPaint(
//                 painter: _FluidGradientPainter(
//                   colors: colors,
//                   t: _controller.value,
//                   animation: widget.animation,
//                   speed: widget.speed,
//                   blur: widget.blur,
//                   intensity: widget.intensity,
//                   touchNorm: _touch,
//                   touchInfluence: widget.touchInfluence,
//                   rippleCenter: _rippleCenter,
//                   rippleT: _rippleController.value,
//                 ),
//                 size: paintSize,
//               );
//             },
//           ),
//         );
//       },
//     );

//     result = Opacity(opacity: widget.opacity.clamp(0.0, 1.0), child: result);

//     if (widget.child != null) {
//       result = Stack(
//         fit: StackFit.passthrough,
//         children: [result, widget.child!],
//       );
//     }

//     // Sizing first so LayoutBuilder gets bounded constraints.
//     if (widget.size != null) {
//       result = SizedBox.fromSize(size: widget.size, child: result);
//     }

//     // Clipping last.
//     if (widget.shape == BoxShape.circle) {
//       result = ClipOval(child: result);
//     } else if (widget.borderRadius != null) {
//       result = ClipRRect(
//         borderRadius: widget.borderRadius!,
//         child: result,
//       );
//     }

//     return result;
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // PAINTER — the magic
// // ─────────────────────────────────────────────────────────────────────────────

// class _FluidGradientPainter extends CustomPainter {
//   final List<Color> colors;
//   final double t;
//   final KinAIGradientAnimation animation;
//   final double speed;
//   final double blur;
//   final double intensity;
//   final Offset? touchNorm;
//   final double touchInfluence;
//   final Offset? rippleCenter;
//   final double rippleT;

//   _FluidGradientPainter({
//     required this.colors,
//     required this.t,
//     required this.animation,
//     required this.speed,
//     required this.blur,
//     required this.intensity,
//     this.touchNorm,
//     this.touchInfluence = 0.6,
//     this.rippleCenter,
//     this.rippleT = 0.0,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (colors.isEmpty) return;
//     final rect = Offset.zero & size;

//     // Draw base fill (darkest colour).
//     canvas.drawRect(rect, Paint()..color = colors.first);

//     // Save so we can apply blur globally.
//     canvas.saveLayer(rect, Paint());

//     final blobCount = colors.length - 1; // first colour is background
//     final time = t * speed;

//     for (var i = 0; i < blobCount; i++) {
//       final color = colors[i + 1];
//       final phase = i / blobCount;
//       final boosted = _boostColor(color, intensity);

//       final center = _blobCenter(i, blobCount, phase, time, size);
//       final radius = _blobRadius(i, blobCount, time, size);

//       // Apply touch attraction — lerp blob towards touch point
//       Offset drawCenter = center;
//       if (touchNorm != null) {
//         final touchPx = Offset(touchNorm!.dx * size.width, touchNorm!.dy * size.height);
//         drawCenter = Offset.lerp(center, touchPx, touchInfluence * 0.5)!;
//       }

//       final gradient = ui.Gradient.radial(
//         drawCenter,
//         radius,
//         [
//           boosted.withValues(alpha: (0.85 * intensity).clamp(0.0, 1.0)),
//           boosted.withValues(alpha: 0.0),
//         ],
//         [0.0, 1.0],
//       );

//       canvas.drawCircle(
//         drawCenter,
//         radius,
//         Paint()
//           ..shader = gradient
//           ..blendMode = BlendMode.plus
//           ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
//       );
//     }

//     // Ripple ring on tap
//     if (rippleCenter != null && rippleT > 0 && rippleT < 1) {
//       final rCenter = Offset(
//         rippleCenter!.dx * size.width,
//         rippleCenter!.dy * size.height,
//       );
//       final maxR = math.max(size.width, size.height) * 0.6;
//       final rRadius = maxR * Curves.easeOut.transform(rippleT);
//       final rOpacity = (1.0 - rippleT) * 0.35;
//       canvas.drawCircle(
//         rCenter,
//         rRadius,
//         Paint()
//           ..color = Colors.white.withValues(alpha: rOpacity)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 3.0 * (1.0 - rippleT)
//           ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
//       );
//     }

//     canvas.restore();
//   }

//   Offset _blobCenter(int i, int count, double phase, double time, Size size) {
//     final cx = size.width * 0.5;
//     final cy = size.height * 0.5;
//     final maxDrift = math.min(size.width, size.height) * 0.35;

//     switch (animation) {
//       case KinAIGradientAnimation.breathe:
//         // Gentle breathing — blobs drift slightly from centre.
//         final angle = phase * math.pi * 2 + time * math.pi * 2;
//         final r = maxDrift * 0.5 * (0.6 + 0.4 * math.sin(time * math.pi * 2 + i));
//         return Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r);

//       case KinAIGradientAnimation.orbit:
//         // Blobs orbit the centre in staggered ellipses.
//         final angle = phase * math.pi * 2 + time * math.pi * 2;
//         final rx = maxDrift * (0.6 + 0.3 * math.sin(time * math.pi * 4 + i * 1.5));
//         final ry = maxDrift * (0.4 + 0.3 * math.cos(time * math.pi * 3 + i * 2.0));
//         return Offset(cx + math.cos(angle) * rx, cy + math.sin(angle) * ry);

//       case KinAIGradientAnimation.wave:
//         // Horizontal wave motion.
//         final xOff = size.width * 0.3 * math.sin(time * math.pi * 2 + phase * math.pi * 3);
//         final yOff = size.height * 0.15 * math.cos(time * math.pi * 3 + i * 1.7);
//         final baseX = size.width * (0.2 + 0.6 * (i / math.max(count - 1, 1)));
//         return Offset(baseX + xOff, cy + yOff);

//       case KinAIGradientAnimation.shimmer:
//         // Slow, minimal drift — almost static but alive.
//         final angle = phase * math.pi * 2 + time * math.pi;
//         final r = maxDrift * 0.25 * (0.5 + 0.5 * math.sin(time * math.pi + i * 2));
//         return Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r);

//       case KinAIGradientAnimation.pulse:
//         // Fast radial pulse from centre.
//         final angle = phase * math.pi * 2;
//         final pulseR = maxDrift * (0.3 + 0.7 * _pingPong(time * 2 + phase * 0.5));
//         return Offset(cx + math.cos(angle) * pulseR, cy + math.sin(angle) * pulseR);

//       case KinAIGradientAnimation.none:
//         // Static positions evenly distributed.
//         final angle = phase * math.pi * 2;
//         return Offset(cx + math.cos(angle) * maxDrift * 0.5,
//             cy + math.sin(angle) * maxDrift * 0.5);
//     }
//   }

//   double _blobRadius(int i, int count, double time, Size size) {
//     final base = math.min(size.width, size.height) * 0.45;

//     switch (animation) {
//       case KinAIGradientAnimation.breathe:
//         return base * (0.7 + 0.3 * math.sin(time * math.pi * 2 + i * 1.3));
//       case KinAIGradientAnimation.orbit:
//         return base * (0.6 + 0.25 * math.sin(time * math.pi * 3 + i * 2));
//       case KinAIGradientAnimation.wave:
//         return base * (0.65 + 0.2 * math.cos(time * math.pi * 2 + i));
//       case KinAIGradientAnimation.shimmer:
//         return base * (0.75 + 0.15 * math.sin(time * math.pi * 1.5 + i * 1.8));
//       case KinAIGradientAnimation.pulse:
//         return base * (0.5 + 0.5 * _pingPong(time * 2 + i * 0.3));
//       case KinAIGradientAnimation.none:
//         return base * 0.7;
//     }
//   }

//   Color _boostColor(Color c, double intensity) {
//     if (intensity == 1.0) return c;
//     final hsl = HSLColor.fromColor(c);
//     return hsl
//         .withSaturation((hsl.saturation * intensity).clamp(0.0, 1.0))
//         .withLightness((hsl.lightness * (0.5 + intensity * 0.5)).clamp(0.0, 1.0))
//         .toColor();
//   }

//   double _pingPong(double t) {
//     final v = t % 1.0;
//     return v < 0.5 ? v * 2 : 2 - v * 2;
//   }

//   @override
//   bool shouldRepaint(_FluidGradientPainter old) =>
//       old.t != t ||
//       old.animation != animation ||
//       old.speed != speed ||
//       old.blur != blur ||
//       old.intensity != intensity ||
//       old.colors != colors ||
//       old.touchNorm != touchNorm ||
//       old.rippleT != rippleT;
// }

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

/// Retained particle state; CPU integration and batched GPU-rasterized points.
/// Unlike a procedural pixel field, displacement and velocity survive each frame.
class ParticleSculpture {
  final String kind;
  ParticleSculpture({this.kind = 'particle_sphere.v1'});
  static bool supports(String id) =>
      id == 'particle_sphere.v1' ||
      id.startsWith('sculpture_') ||
      id.startsWith('formation_') ||
      [
        'ember_flock.v1',
        'orbital_dust.v1',
        'particle_storm.v1',
        'particle_rain.v1',
      ].contains(id);
  bool get isField => [
    'ember_flock.v1',
    'orbital_dust.v1',
    'particle_storm.v1',
    'particle_rain.v1',
  ].contains(kind);
  static const capacity = 2400;
  final positions = Float64List(capacity * 3);
  final velocities = Float64List(capacity * 3);
  double? lastTime;
  bool initialized = false;
  double lastAspect = 1, visualTime = 0;
  double? lastForm;
  void step({
    required double time,
    required double count,
    required double form,
    ui.Offset pointer = const ui.Offset(.5, .5),
    double touch = 0,
    double aspect = 1,
  }) {
    final dt = lastTime == null
        ? 0.0
        : ((time - lastTime!) < 0 ? 1 / 60 : time - lastTime!).clamp(0.0, .04);
    lastTime = time;
    visualTime = time;
    if (isField) {
      stepField(dt, time, count, form, pointer, touch, aspect);
      return;
    }
    final active = (500 + count * (capacity - 500)).round();
    final formChanged = lastForm != form;
    lastForm = form;
    final turn = kind.startsWith('formation_') ? 0.0 : time * .28;
    for (var i = 0; i < capacity; i++) {
      final f = (i + .5) / capacity;
      final a = i * 2.399963229728653;
      final z = 1 - 2 * f;
      final radius = math.sqrt(1 - z * z);
      final sphereX = math.cos(a) * radius * .68;
      final sphereY = z * .68;
      final sphereZ = math.sin(a) * radius * .68;
      final ringAngle = a;
      final tube = f * math.pi * 2;
      final ringR = .49 + .20 * math.cos(tube);
      var tx = sphereX * (1 - form) + ringR * math.cos(ringAngle) * form;
      var ty = sphereY * (1 - form) + .20 * math.sin(tube) * form;
      var tz = sphereZ * (1 - form) + ringR * math.sin(ringAngle) * form;
      if (kind == 'sculpture_knot.v1') {
        final u = f * math.pi * 2, thickness = .035 + form * .09;
        tx =
            (math.sin(u) + 2 * math.sin(2 * u)) * .20 + math.cos(a) * thickness;
        ty =
            (math.cos(u) - 2 * math.cos(2 * u)) * .20 + math.sin(a) * thickness;
        tz = -math.sin(3 * u) * .20 + math.cos(a) * thickness;
      } else if (kind == 'sculpture_shell.v1') {
        final u = f * math.pi * 5;
        final growth = .10 + f * .48, chamber = growth * (.25 + form * .35);
        tx = math.cos(u) * (growth + math.cos(a) * chamber);
        ty = math.sin(u) * (growth + math.cos(a) * chamber);
        tz = math.sin(a) * chamber + (f - .5) * .32;
      } else if (kind == 'sculpture_ribbon.v1') {
        final u = a;
        final width = (f - .5) * (.15 + form * .52);
        tx = (.55 + width * math.cos(u * .5)) * math.cos(u);
        ty = (.55 + width * math.cos(u * .5)) * math.sin(u);
        tz = width * math.sin(u * .5);
      }
      if (kind.startsWith('formation_')) {
        final target = formationTarget(i, form, time, aspect);
        tx = target.$1;
        ty = target.$2;
        tz = target.$3;
      }
      final breath = 1 + .025 * math.sin(time * 1.3 + f * 12);
      tx *= breath;
      ty *= breath;
      tz *= breath;
      final targetX = tx * math.cos(turn) + tz * math.sin(turn);
      final targetY = kind.startsWith('formation_')
          ? ty
          : ty * math.cos(.45) - tz * math.sin(.45);
      final targetZ = tz * math.cos(turn) - tx * math.sin(turn);
      final index = i * 3;
      if (!initialized || (dt == 0 && formChanged)) {
        velocities[index] = velocities[index + 1] = velocities[index + 2] = 0;
        positions[index] = targetX;
        positions[index + 1] = targetY;
        positions[index + 2] = targetZ;
      }
      if (i >= active || dt == 0) continue;
      final dx = positions[index] - (pointer.dx - .5) * 2;
      final dy = positions[index + 1] - (pointer.dy - .5) * 2;
      final distance = dx * dx + dy * dy + .003;
      final force = touch * math.exp(-distance * 18) * 12;
      final damping = math.exp(-dt * 4.5);
      final targets = [targetX, targetY, targetZ];
      for (var axis = 0; axis < 3; axis++) {
        final impulse = axis == 0
            ? dx * force - dy * force * .4
            : axis == 1
            ? dy * force + dx * force * .4
            : force * .16;
        velocities[index + axis] =
            (velocities[index + axis] +
                ((targets[axis] - positions[index + axis]) * 16 + impulse) *
                    dt) *
            damping;
        positions[index + axis] += velocities[index + axis] * dt;
      }
    }
    initialized = true;
  }

  static double seed(int i, double salt) =>
      (math.sin(i * 127.1 + salt) * 43758.5453) % 1;
  (double, double, double) formationTarget(
    int i,
    double form,
    double time,
    double aspect,
  ) {
    final u = seed(i, 17), v = seed(i, 49);
    final mix = form * form * (3 - 2 * form);
    double x, y, z;
    if (kind == 'formation_crane.v1') {
      const triangles = [
        [-.28, .08, 0.0, .22, .24, 0.0, .1, -.08, .08],
        [-.2, .08, .01, -.6, -.62, .07, .18, -.09, .12],
        [.05, -.09, .13, .62, -.52, -.04, .3, .22, .02],
        [.22, .24, 0.0, .68, .52, .02, .25, .05, 0.0],
        [-.28, .08, 0.0, -.44, -.32, 0.0, -.29, -.2, .03],
        [-.44, -.32, 0.0, -.67, -.28, 0.0, -.4, -.17, .04],
      ];
      final triangle = triangles[i % triangles.length];
      final a = math.sqrt(u), b = v;
      double sample(int axis) =>
          triangle[axis] * (1 - a) +
          triangle[axis + 3] * a * (1 - b) +
          triangle[axis + 6] * a * b;
      x = sample(0);
      y = sample(1);
      z = sample(2);
    } else if (kind == 'formation_butterfly.v1') {
      final side = i.isEven ? -1.0 : 1.0;
      final upper = i % 4 < 2;
      final angle = v * math.pi * 2, radius = math.sqrt(u);
      x =
          side *
          ((upper ? .29 : .22) + math.cos(angle) * radius * (upper ? .27 : .2));
      y = (upper ? -.2 : .24) + math.sin(angle) * radius * (upper ? .34 : .24);
      final flap = .25 * math.sin(time * 1.6);
      z = x.abs() * math.sin(flap);
      x *= math.cos(flap);
      if (i % 20 == 0) {
        x = (u - .5) * .04;
        y = (v - .5) * .75;
        z = .03;
      }
      if (i % 60 == 1 || i % 60 == 2) {
        x = side * (.02 + u * .13);
        y = -.38 - u * .2;
        z = 0;
      }
    } else {
      final leafY = u * 1.5 - .75;
      final leafX = (v * 2 - 1) * .36 * math.pow(math.sin(u * math.pi), .7);
      final angle = u * math.pi * 2;
      final radius = math.sqrt(v) * (.43 + .18 * math.cos(angle * 5));
      x = leafX * (1 - mix) + math.cos(angle) * radius * mix;
      y = leafY * (1 - mix) + math.sin(angle) * radius * mix;
      z =
          .08 * math.sin(u * math.pi) * (1 - mix) +
          .16 * math.cos(angle * 5) * radius * mix;
      return (x, y, z);
    }
    final scatterX = (seed(i, 83) * 2 - 1) * .88;
    final scatterY = (seed(i, 97) * 2 - 1) * math.max(1.0, 1 / aspect) * .75;
    final scatterZ = (seed(i, 113) * 2 - 1) * .4;
    return (
      scatterX * (1 - mix) + x * mix,
      scatterY * (1 - mix) + y * mix,
      scatterZ * (1 - mix) + z * mix,
    );
  }

  void stepField(
    double dt,
    double time,
    double count,
    double form,
    ui.Offset pointer,
    double touch,
    double aspect,
  ) {
    final ex = math.max(1.0, aspect), ey = math.max(1.0, 1 / aspect);
    final active = (500 + count * (capacity - 500)).round();
    if (lastAspect != aspect) initialized = false;
    lastAspect = aspect;
    for (var i = 0; i < capacity; i++) {
      final j = i * 3;
      if (!initialized) {
        positions[j] =
            (((math.sin((i + 1) * 127.1) * 43758.5453) % 1) * 2 - 1) * ex;
        positions[j + 1] =
            (((math.sin(i * 311.7 + 17) * 43758.5453) % 1) * 2 - 1) * ey;
        if (kind == 'ember_flock.v1') {
          positions[j + 1] =
              math.sin(positions[j] * 1.7) * .3 +
              ((i % 3) - 1) * ey * .6 +
              positions[j + 1] * .12;
        } else if (kind == 'orbital_dust.v1') {
          if (i.isEven) {
            positions[j + 1] = ((i % 7) - 3) * ey / 3.4;
          } else {
            positions[j] = ((i % 7) - 3) * ex / 3.4;
          }
        }
        positions[j + 2] = kind == 'orbital_dust.v1'
            ? (i.isEven ? -.1 : .1)
            : math.sin(i * 2.39996) * .7;
      }
      if (i >= active) continue;
      final x = positions[j], y = positions[j + 1];
      double vx, vy;
      if (kind == 'particle_rain.v1') {
        vx = math.sin(y * 2 + time * .7) * .07;
        vy = .45 + form * 1.2 + (i % 7) * .025;
      } else if (kind == 'orbital_dust.v1') {
        if (i.isEven) {
          final line = ((i % 7) - 3) * ey / 3.4;
          vx = .18;
          vy = (line + math.sin(x * 3 + time * .4) * (1 - form) * .12 - y) * 2;
        } else {
          final line = ((i % 7) - 3) * ex / 3.4;
          vx = (line + math.sin(y * 3 + time * .4) * (1 - form) * .12 - x) * 2;
          vy = -.18;
        }
      } else if (kind == 'ember_flock.v1') {
        vx = .2 + .12 * math.cos(y * 2 + time * .3);
        vy = math.sin(x * 2 + time * .4) * (.08 + form * .14);
      } else {
        vx = .15 + math.sin(y * (1.5 + form * 2) + time * .3) * .2;
        vy = math.sin(time * .4 + i * .17) * .07;
      }
      final dx = x - (pointer.dx - .5) * 2, dy = y - (pointer.dy - .5) * 2;
      final force = touch * math.exp(-(dx * dx + dy * dy) * 5);
      vx += dx * 4 * force;
      vy += dy * 4 * force;
      if (!initialized) {
        velocities[j] = vx;
        velocities[j + 1] = vy;
      }
      if (dt == 0) continue;
      velocities[j] += (vx - velocities[j]) * math.min(1.0, dt * 4);
      velocities[j + 1] += (vy - velocities[j + 1]) * math.min(1.0, dt * 4);
      positions[j] += velocities[j] * dt;
      positions[j + 1] += velocities[j + 1] * dt;
      if (positions[j] > ex + .08) positions[j] = -ex;
      if (positions[j] < -ex - .08) positions[j] = ex;
      if (positions[j + 1] > ey + .08) positions[j + 1] = -ey;
      if (positions[j + 1] < -ey - .08) positions[j + 1] = ey;
    }
    initialized = true;
  }

  void paint(
    ui.Canvas canvas,
    ui.Size size, {
    required double count,
    required double scale,
    required double rotation,
    required double opacity,
  }) {
    final buckets = List.generate(6, (_) => <ui.Offset>[]);
    final trails = List.generate(6, (_) => <ui.Offset>[]);
    final shards = List.generate(6, (_) => ui.Path());
    final active = (500 + count * (capacity - 500)).round();
    final unit =
        math.min(size.width, size.height) * (isField ? .5 : .62) * scale;
    final c = math.cos(rotation), s = math.sin(rotation);
    for (var i = 0; i < active; i++) {
      final index = i * 3, z = positions[i * 3 + 2];
      final perspective = 2.5 / (2.5 - z);
      final x = positions[index] * c - positions[index + 1] * s;
      final y = positions[index] * s + positions[index + 1] * c;
      final depth = ((z + 1) * 3).floor().clamp(0, 5);
      final point = ui.Offset(
        size.width * .5 + x * unit * perspective,
        size.height * .5 + y * unit * perspective,
      );
      final vx = velocities[index] * c - velocities[index + 1] * s;
      final vy = velocities[index] * s + velocities[index + 1] * c;
      if (isField || vx * vx + vy * vy > .01) {
        final tail = ui.Offset(vx * unit * .055, vy * unit * .055);
        trails[depth].addAll([point - tail, point]);
      }
      if (kind == 'particle_rain.v1') {
        final w = 1.0 + depth * .25, h = 3.0 + depth * .7;
        shards[depth].moveTo(point.dx, point.dy - h);
        shards[depth].lineTo(point.dx + w, point.dy);
        shards[depth].lineTo(point.dx, point.dy + h);
        shards[depth].lineTo(point.dx - w, point.dy);
        shards[depth].close();
      } else {
        buckets[depth].add(point);
      }
    }
    final (low, high) = switch (kind) {
      'formation_crane.v1' => (
        const ui.Color(0xFF8D7463),
        const ui.Color(0xFFFFF1DB),
      ),
      'formation_butterfly.v1' => (
        const ui.Color(0xFF923B52),
        const ui.Color(0xFFFFCAAE),
      ),
      'formation_botanical.v1' => (
        const ui.Color(0xFF687548),
        const ui.Color(0xFFF1D9A9),
      ),
      'sculpture_knot.v1' => (
        const ui.Color(0xFF8E304C),
        const ui.Color(0xFFFFBC95),
      ),
      'sculpture_shell.v1' => (
        const ui.Color(0xFF82704D),
        const ui.Color(0xFFFFF0CB),
      ),
      'sculpture_ribbon.v1' => (
        const ui.Color(0xFF683B77),
        const ui.Color(0xFFE9C5FF),
      ),
      'particle_sphere.v1' => (
        const ui.Color(0xFF74747A),
        const ui.Color(0xFFF4ECE1),
      ),
      'orbital_dust.v1' => (
        const ui.Color(0xFF68703B),
        const ui.Color(0xFFF3F3BA),
      ),
      'ember_flock.v1' => (
        const ui.Color(0xFF7A2540),
        const ui.Color(0xFFFFC49B),
      ),
      'particle_rain.v1' => (
        const ui.Color(0xFF6F4A86),
        const ui.Color(0xFFF2D1E9),
      ),
      _ => (const ui.Color(0xFF9F3720), const ui.Color(0xFFFFD995)),
    };
    for (var depth = 0; depth < 6; depth++) {
      final color = ui.Color.lerp(low, high, depth / 5)!;
      final flicker = .9 + .1 * math.sin(visualTime * 1.7 + depth);
      canvas.drawPoints(
        ui.PointMode.lines,
        trails[depth],
        ui.Paint()
          ..color = color.withValues(alpha: opacity * .22)
          ..strokeWidth = .7 + depth * .18
          ..strokeCap = ui.StrokeCap.round,
      );
      canvas.drawPoints(
        ui.PointMode.points,
        buckets[depth],
        ui.Paint()
          ..color = color.withValues(alpha: opacity * .09)
          ..strokeWidth = 3.5 + depth * .5
          ..strokeCap = ui.StrokeCap.round
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.5),
      );
      canvas.drawPoints(
        ui.PointMode.points,
        buckets[depth],
        ui.Paint()
          ..color = color.withValues(
            alpha: opacity * (.22 + depth * .14) * flicker,
          )
          ..strokeWidth = .7 + depth * .26
          ..strokeCap = ui.StrokeCap.round,
      );
      canvas.drawPath(
        shards[depth],
        ui.Paint()
          ..color = color.withValues(alpha: opacity * (.25 + depth * .12)),
      );
    }
  }
}

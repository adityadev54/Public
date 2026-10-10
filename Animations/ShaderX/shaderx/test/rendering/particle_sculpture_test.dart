import 'package:flutter_test/flutter_test.dart';
import 'package:shaderx/rendering/particle_sculpture.dart';

void main() {
  test('Particles retain momentum and recover after a touch force ends', () {
    final field = ParticleSculpture(), baseline = ParticleSculpture();
    for (var i = 0; i < 90; i++) {
      final time = i / 60;
      baseline.step(time: time, count: .7, form: .5);
      field.step(
        time: time,
        count: .7,
        form: .5,
        pointer: const Offset(.65, .5),
        touch: i < 30 ? 1 : 0,
      );
    }
    double distance() {
      double sum = 0;
      for (var i = 0; i < field.positions.length; i++) {
        sum += (field.positions[i] - baseline.positions[i]).abs();
      }
      return sum;
    }

    final disturbed = distance();
    expect(disturbed, greaterThan(0));
    for (var i = 90; i < 300; i++) {
      baseline.step(time: i / 60, count: .7, form: .5);
      field.step(time: i / 60, count: .7, form: .5);
    }
    expect(distance(), lessThan(disturbed));
    expect(field.positions.every((value) => value.isFinite), isTrue);
  });
  test('Full-screen fields preserve forces and have distinct motion', () {
    final results = <List<double>>[];
    for (final kind in [
      'ember_flock.v1',
      'orbital_dust.v1',
      'particle_storm.v1',
      'particle_rain.v1',
    ]) {
      final field = ParticleSculpture(kind: kind),
          baseline = ParticleSculpture(kind: kind);
      for (var i = 0; i < 120; i++) {
        baseline.step(time: i / 60, count: .7, form: .6, aspect: .46);
        field.step(
          time: i / 60,
          count: .7,
          form: .6,
          aspect: .46,
          touch: i < 60 ? 1 : 0,
          pointer: const Offset(.6, .6),
        );
      }
      expect(field.positions.every((v) => v.isFinite), isTrue);
      expect(field.positions, isNot(orderedEquals(baseline.positions)));
      results.add(baseline.positions.toList());
    }
    for (var i = 1; i < results.length; i++) {
      expect(results[i], isNot(orderedEquals(results[i - 1])));
    }
  });
  test('New sculptures have distinct finite target geometry', () {
    final outputs = <List<double>>[];
    for (final kind in [
      'sculpture_knot.v1',
      'sculpture_shell.v1',
      'sculpture_ribbon.v1',
    ]) {
      final field = ParticleSculpture(kind: kind);
      field.step(time: 0, count: .8, form: .6);
      expect(field.positions.every((value) => value.isFinite), isTrue);
      outputs.add(field.positions.toList());
    }
    expect(outputs[0], isNot(orderedEquals(outputs[1])));
    expect(outputs[1], isNot(orderedEquals(outputs[2])));
  });
}

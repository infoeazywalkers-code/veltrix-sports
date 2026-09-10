import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/workout.dart';
import 'package:veltrix_sports/services/activity/workout_execution_service.dart';

void main() {
  group('WorkoutExecutionService - long-running timer coverage', () {
    late Workout testWorkout;

    setUp(() {
      testWorkout = Workout(
        id: 'long_w1',
        planId: 'p1',
        sport: Sport.run,
        title: 'Long Run',
        duration: '2h',
        distanceKm: 20.0,
        tss: 90,
        scheduledFor: DateTime(2026, 9, 5),
      );
    });

    test('formattedTime includes hours after one hour of elapsed time', () {
      fakeAsync((async) {
        final engine = WorkoutExecutionService(workout: testWorkout);
        expect(engine.formattedTime, '00:00');

        engine.start();
        async.elapse(const Duration(hours: 1, minutes: 2, seconds: 3));

        expect(engine.formattedTime, '01:02:03');
        engine.dispose();
      });
    });

    test('formattedTime pads minutes and seconds correctly', () {
      fakeAsync((async) {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        async.elapse(const Duration(minutes: 1, seconds: 5));
        expect(engine.formattedTime, '01:05');
        engine.dispose();
      });
    });

    test('currentPace computes a real pace after distance accumulates', () {
      fakeAsync((async) {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        async.elapse(const Duration(minutes: 10));

        expect(engine.distanceKm, greaterThan(0.01));
        expect(engine.currentPace, isNot('0:00 /km'));
        expect(engine.currentPace, contains('/km'));
        engine.dispose();
      });
    });

    test('calculatedTss grows above zero after enough elapsed time', () {
      fakeAsync((async) {
        final engine = WorkoutExecutionService(workout: testWorkout);
        expect(engine.calculatedTss, 0);

        engine.start();
        async.elapse(const Duration(hours: 1));
        // TSS = (3600/3600) * 65 = 65
        expect(engine.calculatedTss, greaterThanOrEqualTo(65));
        expect(engine.calculatedTss, lessThan(66));
        engine.dispose();
      });
    });

    test('distance accumulates proportionally to simulated pace', () {
      fakeAsync((async) {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        async.elapse(const Duration(minutes: 60));
        // 3600 seconds * 0.0032 km/s = 11.52 km
        expect(engine.distanceKm, closeTo(11.52, 0.05));
        engine.dispose();
      });
    });

    test('heart rate simulation stays within expected demo range', () {
      fakeAsync((async) {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        async.elapse(const Duration(seconds: 30));
        expect(engine.currentHeartRate, greaterThanOrEqualTo(135));
        expect(engine.currentHeartRate, lessThanOrEqualTo(159));
        engine.dispose();
      });
    });

    test('cadence simulation stays within realistic spm range', () {
      fakeAsync((async) {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        async.elapse(const Duration(seconds: 15));
        expect(engine.currentCadence, greaterThanOrEqualTo(168));
        expect(engine.currentCadence, lessThanOrEqualTo(176));
        engine.dispose();
      });
    });

    test('currentZone stays at 1 when no personalized zones are provided', () {
      fakeAsync((async) {
        final engine = WorkoutExecutionService(workout: testWorkout);
        final zones = <int>{};
        engine.start();
        for (var i = 0; i < 25; i++) {
          async.elapse(const Duration(seconds: 1));
          zones.add(engine.currentZone);
        }
        expect(zones, {1});
        engine.dispose();
      });
    });
  });
}

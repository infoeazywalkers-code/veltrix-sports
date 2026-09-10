import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/workout.dart';
import 'package:veltrix_sports/services/activity/workout_execution_service.dart';

void main() {
  group('WorkoutExecutionService - Extended', () {
    late Workout testWorkout;

    setUp(() {
      testWorkout = Workout(
        id: 'test_ext_w1',
        planId: 'p1',
        sport: Sport.run,
        title: 'Extended Test Run',
        description: 'Extended coverage test',
        duration: '1h',
        distanceKm: 10.0,
        tss: 70,
        scheduledFor: DateTime(2026, 9, 5),
      );
    });

    group('formattedTime edge cases', () {
      test('formats 0 seconds as 00:00', () {
        final engine = WorkoutExecutionService(workout: testWorkout);
        expect(engine.formattedTime, '00:00');
        engine.dispose();
      });

      test('start and let timer tick a few seconds', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        await Future.delayed(const Duration(seconds: 2));
        expect(engine.elapsedSeconds, greaterThanOrEqualTo(1));
        expect(engine.formattedTime, isNot('00:00'));
        engine.pause();
        engine.dispose();
      });
    });

    group('currentZone edge cases', () {
      test('zone is between 1 and 5', () {
        final engine = WorkoutExecutionService(workout: testWorkout);
        expect(engine.currentZone, greaterThanOrEqualTo(1));
        expect(engine.currentZone, lessThanOrEqualTo(5));
        engine.dispose();
      });
    });

    group('currentPace edge cases', () {
      test('returns 0:00 /km when distance is zero', () {
        final engine = WorkoutExecutionService(workout: testWorkout);
        expect(engine.currentPace, '0:00 /km');
        engine.dispose();
      });
    });

    group('calculatedTss', () {
      test('starts at 0', () {
        final engine = WorkoutExecutionService(workout: testWorkout);
        expect(engine.calculatedTss, 0);
        engine.dispose();
      });
    });

    group('timer behavior', () {
      test('start begins periodic timer', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        await Future.delayed(const Duration(seconds: 3));
        expect(engine.elapsedSeconds, greaterThanOrEqualTo(2));
        expect(engine.distanceKm, greaterThan(0));
        engine.pause();
        engine.dispose();
      });

      test('pause stops timer', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        await Future.delayed(const Duration(seconds: 2));
        engine.pause();
        final elapsedAfterPause = engine.elapsedSeconds;
        await Future.delayed(const Duration(seconds: 2));
        expect(engine.elapsedSeconds, elapsedAfterPause);
        engine.dispose();
      });

      test('resume continues timer from where it paused', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        await Future.delayed(const Duration(seconds: 2));
        engine.pause();
        final pausedAt = engine.elapsedSeconds;
        engine.start(); // resume
        await Future.delayed(const Duration(seconds: 2));
        expect(engine.elapsedSeconds, greaterThan(pausedAt));
        engine.pause();
        engine.dispose();
      });

      test('distance increases during running state', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        await Future.delayed(const Duration(seconds: 3));
        final dist = engine.distanceKm;
        expect(dist, greaterThan(0.0));
        engine.pause();
        engine.dispose();
      });

      test('heart rate changes during running state (no BLE)', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        final initialHR = engine.currentHeartRate;
        engine.start();
        await Future.delayed(const Duration(seconds: 5));
        expect(engine.currentHeartRate, isNot(equals(initialHR)));
        engine.pause();
        engine.dispose();
      });

      test('cadence changes during running state (no BLE)', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        await Future.delayed(const Duration(seconds: 5));
        // Cadence varies between 168-176
        expect(engine.currentCadence, greaterThanOrEqualTo(168));
        expect(engine.currentCadence, lessThanOrEqualTo(176));
        engine.pause();
        engine.dispose();
      });
    });

    group('recordLap edge cases', () {
      test('multiple rapid laps', () {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        engine.recordLap();
        engine.recordLap();
        engine.recordLap();
        engine.recordLap();
        engine.recordLap();
        expect(engine.laps.length, 5);
        expect(engine.laps.last.lapIndex, 5);
        engine.pause();
        engine.dispose();
      });

      test('lap contains pace and HR data', () {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        engine.recordLap();
        final lap = engine.laps.first;
        expect(lap.pace, isNotEmpty);
        expect(lap.avgHeartRate, greaterThanOrEqualTo(0));
        expect(lap.duration, isNotEmpty);
        engine.pause();
        engine.dispose();
      });

      test('laps are independent snapshots', () {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        engine.recordLap();
        engine.recordLap();
        final firstLap = engine.laps[0];
        final secondLap = engine.laps[1];
        expect(firstLap.lapIndex, 1);
        expect(secondLap.lapIndex, 2);
        engine.pause();
        engine.dispose();
      });
    });

    group('finish() edge cases', () {
      test('finish from running state', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        await Future.delayed(const Duration(seconds: 1));
        await engine.finish();
        expect(engine.state, WorkoutExecutionState.completed);
        engine.dispose();
      });

      test('finish stops timer even after running', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        await Future.delayed(const Duration(seconds: 1));
        await engine.finish();
        final elapsedAfterFinish = engine.elapsedSeconds;
        await Future.delayed(const Duration(seconds: 2));
        expect(engine.elapsedSeconds, elapsedAfterFinish);
        engine.dispose();
      });

      test('can call finish multiple times', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.start();
        await engine.finish();
        await engine.finish(); // should not throw
        expect(engine.state, WorkoutExecutionState.completed);
        engine.dispose();
      });
    });

    group('dispose', () {
      test('dispose when not started does not throw', () {
        final engine = WorkoutExecutionService(workout: testWorkout);
        engine.dispose();
      });
    });

    group('WorkoutExecutionState enum', () {
      test('enum values are in expected order', () {
        expect(WorkoutExecutionState.initial.index, 0);
        expect(WorkoutExecutionState.running.index, 1);
        expect(WorkoutExecutionState.paused.index, 2);
        expect(WorkoutExecutionState.completed.index, 3);
      });

      test('enum names are correct', () {
        expect(WorkoutExecutionState.initial.name, 'initial');
        expect(WorkoutExecutionState.running.name, 'running');
        expect(WorkoutExecutionState.paused.name, 'paused');
        expect(WorkoutExecutionState.completed.name, 'completed');
      });
    });

    group('LapSplit edge cases', () {
      test('LapSplit with zero HR', () {
        const lap = LapSplit(
          lapIndex: 0,
          duration: '00:00',
          pace: '0:00 /km',
          avgHeartRate: 0,
        );
        expect(lap.avgHeartRate, 0);
      });

      test('LapSplit with high HR', () {
        const lap = LapSplit(
          lapIndex: 10,
          duration: '01:00:00',
          pace: '3:30 /km',
          avgHeartRate: 200,
        );
        expect(lap.avgHeartRate, 200);
        expect(lap.lapIndex, 10);
      });
    });

    group('state machine transitions', () {
      test(
        'initial -> running -> paused -> running -> paused -> completed',
        () async {
          final engine = WorkoutExecutionService(workout: testWorkout);
          expect(engine.state, WorkoutExecutionState.initial);

          engine.start();
          expect(engine.state, WorkoutExecutionState.running);

          engine.pause();
          expect(engine.state, WorkoutExecutionState.paused);

          engine.start();
          expect(engine.state, WorkoutExecutionState.running);

          engine.pause();
          expect(engine.state, WorkoutExecutionState.paused);

          await engine.finish();
          expect(engine.state, WorkoutExecutionState.completed);
          engine.dispose();
        },
      );

      test('initial -> completed directly', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        await engine.finish();
        expect(engine.state, WorkoutExecutionState.completed);
        engine.dispose();
      });

      test('start after completed restarts', () async {
        final engine = WorkoutExecutionService(workout: testWorkout);
        await engine.finish();
        engine.start();
        expect(engine.state, WorkoutExecutionState.running);
        engine.pause();
        engine.dispose();
      });
    });

    group('isDemoMode', () {
      test('isDemoMode is bool in test (debug) without BLE', () {
        final engine = WorkoutExecutionService(workout: testWorkout);
        expect(engine.isDemoMode, isA<bool>());
        engine.dispose();
      });
    });
  });
}

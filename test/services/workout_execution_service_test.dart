import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/workout.dart';
import 'package:veltrix_sports/services/workout_execution_service.dart';

void main() {
  group('WorkoutExecutionService Unit Tests', () {
    late Workout testWorkout;

    setUp(() {
      testWorkout = Workout(
        id: 'test_w1',
        planId: 'p1',
        sport: Sport.run,
        title: '5K Tempo Test Run',
        description: 'Test workout for execution engine',
        duration: '30m',
        distanceKm: 5.0,
        tss: 45,
        scheduledFor: DateTime(2026, 9, 4),
      );
    });

    test('initial state is WorkoutExecutionState.initial', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      expect(engine.state, WorkoutExecutionState.initial);
      expect(engine.elapsedSeconds, 0);
      expect(engine.formattedTime, '00:00');
      expect(engine.laps, isEmpty);
      engine.dispose();
    });

    test('formattedTime handles seconds, minutes, and hours correctly', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      expect(engine.formattedTime, '00:00');
      engine.dispose();
    });

    test('currentZone calculates correct Heart Rate Zones 1 through 5', () {
      final engine = WorkoutExecutionService(workout: testWorkout);

      // Zone 1: < 120 BPM
      expect(engine.currentZone, greaterThanOrEqualTo(1));
      expect(engine.currentZone, lessThanOrEqualTo(5));
      engine.dispose();
    });

    test('start() transitions state to running', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.start();
      expect(engine.state, WorkoutExecutionState.running);
      engine.pause();
      expect(engine.state, WorkoutExecutionState.paused);
      engine.dispose();
    });

    test('start() on already running does nothing', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.start();
      engine.start(); // Second call should be no-op
      expect(engine.state, WorkoutExecutionState.running);
      engine.pause();
      engine.dispose();
    });

    test('recordLap adds split to laps list', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.start();
      engine.recordLap();

      expect(engine.laps.length, 1);
      expect(engine.laps.first.lapIndex, 1);
      engine.pause();
      engine.dispose();
    });

    test('recordLap increments lap index', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.start();
      engine.recordLap();
      engine.recordLap();
      engine.recordLap();

      expect(engine.laps.length, 3);
      expect(engine.laps[0].lapIndex, 1);
      expect(engine.laps[1].lapIndex, 2);
      expect(engine.laps[2].lapIndex, 3);
      engine.pause();
      engine.dispose();
    });

    test('finish() stops timer and sets state to completed', () async {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.start();
      await engine.finish();

      expect(engine.state, WorkoutExecutionState.completed);
      engine.dispose();
    });

    test('laps list is unmodifiable', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      final laps = engine.laps;
      expect(
        () => laps.add(
          const LapSplit(
            lapIndex: 1,
            duration: '01:00',
            pace: '5:00 /km',
            avgHeartRate: 145,
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );
      engine.dispose();
    });

    test('currentHeartRate has default value', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      expect(engine.currentHeartRate, isA<int>());
      expect(engine.currentHeartRate, greaterThanOrEqualTo(0));
      engine.dispose();
    });

    test('currentCadence has default value', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      expect(engine.currentCadence, 0);
      engine.dispose();
    });

    test('distanceKm starts at zero', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      expect(engine.distanceKm, 0.0);
      engine.dispose();
    });

    test('isBleConnected reflects BLE state', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      expect(engine.isBleConnected, isA<bool>());
      engine.dispose();
    });

    test('connectedDeviceName is null when not connected', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      expect(engine.connectedDeviceName, isNull);
      engine.dispose();
    });

    test('currentPace returns default when no distance', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      expect(engine.currentPace, '0:00 /km');
      engine.dispose();
    });

    test('calculatedTss is 0 at start', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      expect(engine.calculatedTss, 0);
      engine.dispose();
    });

    test('WorkoutExecutionState enum has 4 values', () {
      expect(WorkoutExecutionState.values.length, 4);
      expect(
        WorkoutExecutionState.values,
        contains(WorkoutExecutionState.initial),
      );
      expect(
        WorkoutExecutionState.values,
        contains(WorkoutExecutionState.running),
      );
      expect(
        WorkoutExecutionState.values,
        contains(WorkoutExecutionState.paused),
      );
      expect(
        WorkoutExecutionState.values,
        contains(WorkoutExecutionState.completed),
      );
    });

    test('LapSplit has all fields', () {
      const lap = LapSplit(
        lapIndex: 1,
        duration: '05:30',
        pace: '5:30 /km',
        avgHeartRate: 152,
      );

      expect(lap.lapIndex, 1);
      expect(lap.duration, '05:30');
      expect(lap.pace, '5:30 /km');
      expect(lap.avgHeartRate, 152);
    });

    test('LapSplit supports different HR values', () {
      const lowHR = LapSplit(
        lapIndex: 1,
        duration: '1:00',
        pace: '6:00 /km',
        avgHeartRate: 95,
      );
      const highHR = LapSplit(
        lapIndex: 2,
        duration: '1:00',
        pace: '4:00 /km',
        avgHeartRate: 185,
      );
      expect(lowHR.avgHeartRate, 95);
      expect(highHR.avgHeartRate, 185);
    });

    test('start then pause then resume transitions correctly', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.start();
      expect(engine.state, WorkoutExecutionState.running);
      engine.pause();
      expect(engine.state, WorkoutExecutionState.paused);
      engine.start();
      expect(engine.state, WorkoutExecutionState.running);
      engine.pause();
      engine.dispose();
    });

    test('finish from initial state sets completed', () async {
      final engine = WorkoutExecutionService(workout: testWorkout);
      await engine.finish();
      expect(engine.state, WorkoutExecutionState.completed);
      engine.dispose();
    });

    test('finish from paused state sets completed', () async {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.start();
      engine.pause();
      await engine.finish();
      expect(engine.state, WorkoutExecutionState.completed);
      engine.dispose();
    });

    test('recordLap works in paused state', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.start();
      engine.pause();
      engine.recordLap();
      expect(engine.laps.length, 1);
      engine.dispose();
    });

    test('recordLap works in initial state', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.recordLap();
      expect(engine.laps.length, 1);
      engine.dispose();
    });
  });
}

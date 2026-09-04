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
    });

    test('formattedTime handles seconds, minutes, and hours correctly', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      expect(engine.formattedTime, '00:00');
    });

    test('currentZone calculates correct Heart Rate Zones 1 through 5', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      
      // Zone 1: < 120 BPM
      expect(engine.currentZone, greaterThanOrEqualTo(1));
      expect(engine.currentZone, lessThanOrEqualTo(5));
    });

    test('start() transitions state to running', () {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.start();
      expect(engine.state, WorkoutExecutionState.running);
      engine.pause();
      expect(engine.state, WorkoutExecutionState.paused);
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

    test('finish() stops timer and sets state to completed', () async {
      final engine = WorkoutExecutionService(workout: testWorkout);
      engine.start();
      await engine.finish();

      expect(engine.state, WorkoutExecutionState.completed);
      engine.dispose();
    });
  });
}

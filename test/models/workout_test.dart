import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/workout.dart';

void main() {
  group('Workout', () {
    test('fromMap creates correct Workout', () {
      final map = {
        'planId': 'plan1',
        'sport': 'run',
        'title': 'Easy run',
        'description': 'Recovery',
        'duration': '30 min',
        'distanceKm': 5.0,
        'tss': 30,
        'targetPace': '6:00/km',
        'scheduledFor': null,
        'progress': 0.5,
        'completed': false,
        'segments': [
          {'label': 'Warm up', 'duration': '5 min'},
        ],
      };

      final workout = Workout.fromMap('id1', map);

      expect(workout.id, 'id1');
      expect(workout.planId, 'plan1');
      expect(workout.sport, Sport.run);
      expect(workout.title, 'Easy run');
      expect(workout.duration, '30 min');
      expect(workout.distanceKm, 5.0);
      expect(workout.tss, 30);
      expect(workout.segments.length, 1);
      expect(workout.segments[0].label, 'Warm up');
    });

    test('toMap returns correct map', () {
      final workout = Workout(
        id: 'id1',
        planId: 'plan1',
        sport: Sport.bike,
        title: 'Tempo ride',
        duration: '1h',
        scheduledFor: DateTime(2026, 1, 1),
      );

      final map = workout.toMap();

      expect(map['planId'], 'plan1');
      expect(map['sport'], 'bike');
      expect(map['title'], 'Tempo ride');
      expect(map['completed'], false);
    });
  });

  group('WorkoutSegment', () {
    test('fromMap creates correct segment', () {
      final segment = WorkoutSegment.fromMap({'label': 'Cool down', 'duration': '10 min'});
      expect(segment.label, 'Cool down');
      expect(segment.duration, '10 min');
    });
  });
}

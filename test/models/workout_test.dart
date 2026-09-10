import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/workout.dart';

void main() {
  group('Workout', () {
    test('fromMap creates correct Workout with all fields', () {
      final timestamp = Timestamp.fromDate(DateTime(2026, 9, 1, 7, 0));
      final map = {
        'userId': 'user1',
        'planId': 'plan1',
        'sport': 'run',
        'title': 'Easy run',
        'description': 'Recovery',
        'duration': '30 min',
        'distanceKm': 5.0,
        'tss': 30,
        'targetPace': '6:00/km',
        'scheduledFor': timestamp,
        'progress': 0.5,
        'completed': true,
        'segments': [
          {'label': 'Warm up', 'duration': '5 min'},
          {'label': 'Cool down', 'duration': '5 min'},
        ],
      };

      final workout = Workout.fromMap('id1', map);

      expect(workout.id, 'id1');
      expect(workout.userId, 'user1');
      expect(workout.planId, 'plan1');
      expect(workout.sport, Sport.run);
      expect(workout.title, 'Easy run');
      expect(workout.description, 'Recovery');
      expect(workout.duration, '30 min');
      expect(workout.distanceKm, 5.0);
      expect(workout.tss, 30);
      expect(workout.targetPace, '6:00/km');
      expect(workout.scheduledFor, timestamp.toDate());
      expect(workout.progress, 0.5);
      expect(workout.completed, true);
      expect(workout.segments.length, 2);
    });

    test('fromMap handles missing optional fields with defaults', () {
      final map = <String, dynamic>{
        'planId': 'plan2',
        'sport': 'bike',
        'title': 'Ride',
        'duration': '1h',
        'scheduledFor': null,
      };

      final workout = Workout.fromMap('id2', map);

      expect(workout.userId, '');
      expect(workout.description, '');
      expect(workout.distanceKm, isNull);
      expect(workout.tss, isNull);
      expect(workout.targetPace, isNull);
      expect(workout.progress, 0);
      expect(workout.completed, false);
      expect(workout.segments, isEmpty);
      expect(workout.scheduledFor, isA<DateTime>());
    });

    test('fromMap handles completely empty map', () {
      final workout = Workout.fromMap('id3', {});

      expect(workout.id, 'id3');
      expect(workout.userId, '');
      expect(workout.planId, '');
      expect(workout.sport, Sport.run); // default
      expect(workout.title, '');
      expect(workout.description, '');
      expect(workout.duration, '');
      expect(workout.distanceKm, isNull);
      expect(workout.tss, isNull);
      expect(workout.targetPace, isNull);
      expect(workout.progress, 0);
      expect(workout.completed, false);
      expect(workout.segments, isEmpty);
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{
        'userId': null,
        'planId': null,
        'sport': null,
        'title': null,
        'description': null,
        'duration': null,
        'distanceKm': null,
        'tss': null,
        'targetPace': null,
        'scheduledFor': null,
        'progress': null,
        'completed': null,
        'segments': null,
      };

      final workout = Workout.fromMap('id4', map);

      expect(workout.userId, '');
      expect(workout.planId, '');
      expect(workout.sport, Sport.run);
      expect(workout.title, '');
      expect(workout.description, '');
      expect(workout.duration, '');
      expect(workout.distanceKm, isNull);
      expect(workout.tss, isNull);
      expect(workout.targetPace, isNull);
      expect(workout.progress, 0);
      expect(workout.completed, false);
      expect(workout.segments, isEmpty);
    });

    test('fromMap maps all Sport enum values correctly', () {
      for (final sport in Sport.values) {
        final map = <String, dynamic>{
          'planId': 'p',
          'sport': sport.name,
          'title': 't',
          'duration': 'd',
        };
        final workout = Workout.fromMap('id', map);
        expect(workout.sport, sport);
      }
    });

    test('fromMap defaults to Sport.run for unknown sport string', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'unknown_sport',
        'title': 't',
        'duration': 'd',
      };
      final workout = Workout.fromMap('id', map);
      expect(workout.sport, Sport.run);
    });

    test('fromMap handles integer values for numeric fields', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 't',
        'duration': '30m',
        'distanceKm': 10,
        'tss': 50,
        'progress': 1,
      };

      final workout = Workout.fromMap('id', map);
      expect(workout.distanceKm, 10.0);
      expect(workout.tss, 50);
      expect(workout.progress, 1.0);
    });

    test('toMap returns correct map', () {
      final scheduled = DateTime(2026, 1, 1);
      final workout = Workout(
        id: 'id5',
        planId: 'plan5',
        sport: Sport.bike,
        title: 'Tempo ride',
        description: 'Hard effort',
        duration: '1h',
        distanceKm: 30.0,
        tss: 75,
        targetPace: '30km/h',
        scheduledFor: scheduled,
        progress: 0.8,
        completed: false,
        segments: const [WorkoutSegment(label: 'Warm up', duration: '10 min')],
      );

      final map = workout.toMap();

      expect(map['userId'], '');
      expect(map['planId'], 'plan5');
      expect(map['sport'], 'bike');
      expect(map['title'], 'Tempo ride');
      expect(map['description'], 'Hard effort');
      expect(map['duration'], '1h');
      expect(map['distanceKm'], 30.0);
      expect(map['tss'], 75);
      expect(map['targetPace'], '30km/h');
      expect(map['scheduledFor'], scheduled);
      expect(map['progress'], 0.8);
      expect(map['completed'], false);
      expect(map['segments'], isA<List>());
      expect((map['segments'] as List).length, 1);
    });

    test('toMap with null optional fields', () {
      final workout = Workout(
        id: 'id6',
        planId: 'plan6',
        sport: Sport.swim,
        title: 'Swim',
        duration: '45m',
        scheduledFor: DateTime(2026),
      );

      final map = workout.toMap();
      expect(map['distanceKm'], isNull);
      expect(map['tss'], isNull);
      expect(map['targetPace'], isNull);
      expect(map['segments'], isEmpty);
    });

    test('constructor defaults', () {
      final workout = Workout(
        id: 'id7',
        planId: 'plan7',
        sport: Sport.strength,
        title: 'Strength',
        duration: '30m',
        scheduledFor: DateTime(2026),
      );

      expect(workout.userId, '');
      expect(workout.description, '');
      expect(workout.distanceKm, isNull);
      expect(workout.tss, isNull);
      expect(workout.targetPace, isNull);
      expect(workout.progress, 0);
      expect(workout.completed, false);
      expect(workout.segments, isEmpty);
    });

    test('fromMap and toMap roundtrip preserves data', () {
      final scheduled = Timestamp.fromDate(DateTime(2026, 7, 4));
      final originalMap = <String, dynamic>{
        'userId': 'rt_user',
        'planId': 'rt_plan',
        'sport': 'swim',
        'title': 'Open water',
        'description': 'Lakeside swim',
        'duration': '1h 15m',
        'distanceKm': 3.5,
        'tss': 55,
        'targetPace': '2:45/100m',
        'scheduledFor': scheduled,
        'progress': 0.75,
        'completed': true,
        'segments': [
          {'label': 'Warm up', 'duration': '10 min'},
          {'label': 'Main set', 'duration': '50 min'},
        ],
      };

      final workout = Workout.fromMap('rt1', originalMap);
      final roundtripped = workout.toMap();

      expect(roundtripped['userId'], 'rt_user');
      expect(roundtripped['planId'], 'rt_plan');
      expect(roundtripped['sport'], 'swim');
      expect(roundtripped['title'], 'Open water');
      expect(roundtripped['distanceKm'], 3.5);
      expect(roundtripped['tss'], 55);
      expect(roundtripped['completed'], true);
      expect((roundtripped['segments'] as List).length, 2);
    });

    test('Sport enum has 5 values', () {
      expect(Sport.values.length, 5);
      expect(Sport.values, contains(Sport.run));
      expect(Sport.values, contains(Sport.bike));
      expect(Sport.values, contains(Sport.swim));
      expect(Sport.values, contains(Sport.strength));
      expect(Sport.values, contains(Sport.rest));
    });
  });

  group('WorkoutSegment', () {
    test('fromMap creates correct segment', () {
      final segment = WorkoutSegment.fromMap({
        'label': 'Cool down',
        'duration': '10 min',
      });
      expect(segment.label, 'Cool down');
      expect(segment.duration, '10 min');
    });

    test('fromMap handles missing fields with defaults', () {
      final segment = WorkoutSegment.fromMap({});
      expect(segment.label, '');
      expect(segment.duration, '');
    });

    test('fromMap handles null values', () {
      final segment = WorkoutSegment.fromMap({'label': null, 'duration': null});
      expect(segment.label, '');
      expect(segment.duration, '');
    });

    test('toMap returns correct map', () {
      const segment = WorkoutSegment(label: 'Interval', duration: '20 min');
      final map = segment.toMap();
      expect(map['label'], 'Interval');
      expect(map['duration'], '20 min');
    });

    test('constructor requires label and duration', () {
      const segment = WorkoutSegment(label: 'Test', duration: '5m');
      expect(segment.label, 'Test');
      expect(segment.duration, '5m');
    });

    test('fromMap and toMap roundtrip', () {
      final original = {'label': 'Sprint', 'duration': '30s'};
      final segment = WorkoutSegment.fromMap(original);
      final roundtripped = segment.toMap();
      expect(roundtripped['label'], 'Sprint');
      expect(roundtripped['duration'], '30s');
    });

    test('handles empty string values', () {
      const segment = WorkoutSegment(label: '', duration: '');
      final map = segment.toMap();
      expect(map['label'], '');
      expect(map['duration'], '');
    });

    test('handles special characters in label', () {
      final segment = WorkoutSegment.fromMap({
        'label': '4x 1km @ Threshold (90s rest)',
        'duration': '35 min',
      });
      expect(segment.label, '4x 1km @ Threshold (90s rest)');
    });
  });

  group('Workout with multiple segments', () {
    test('fromMap handles multiple segments', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'Intervals',
        'duration': '1h',
        'scheduledFor': null,
        'segments': [
          {'label': 'Warm up', 'duration': '10 min'},
          {'label': '4x800m', 'duration': '20 min'},
          {'label': 'Cool down', 'duration': '10 min'},
        ],
      };

      final workout = Workout.fromMap('id', map);
      expect(workout.segments.length, 3);
      expect(workout.segments[0].label, 'Warm up');
      expect(workout.segments[1].label, '4x800m');
      expect(workout.segments[2].label, 'Cool down');
    });

    test('toMap serializes multiple segments', () {
      final workout = Workout(
        id: 'id',
        planId: 'p',
        sport: Sport.run,
        title: 'Intervals',
        duration: '1h',
        scheduledFor: DateTime(2026),
        segments: const [
          WorkoutSegment(label: 'A', duration: '10m'),
          WorkoutSegment(label: 'B', duration: '20m'),
          WorkoutSegment(label: 'C', duration: '30m'),
        ],
      );

      final map = workout.toMap();
      final segments = map['segments'] as List;
      expect(segments.length, 3);
      expect(segments[0]['label'], 'A');
      expect(segments[1]['label'], 'B');
      expect(segments[2]['label'], 'C');
    });
  });
}

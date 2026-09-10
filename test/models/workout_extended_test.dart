import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/workout.dart';

void main() {
  group('Workout - Extended', () {
    test('fromMap with integer distanceKm', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'T',
        'duration': '30m',
        'distanceKm': 10,
      };
      final w = Workout.fromMap('id', map);
      expect(w.distanceKm, 10.0);
    });

    test('fromMap with double distanceKm', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'T',
        'duration': '30m',
        'distanceKm': 10.5,
      };
      final w = Workout.fromMap('id', map);
      expect(w.distanceKm, 10.5);
    });

    test('fromMap with negative progress', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'T',
        'duration': '30m',
        'progress': -0.5,
      };
      final w = Workout.fromMap('id', map);
      expect(w.progress, -0.5);
    });

    test('fromMap with progress > 1', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'T',
        'duration': '30m',
        'progress': 1.5,
      };
      final w = Workout.fromMap('id', map);
      expect(w.progress, 1.5);
    });

    test('fromMap with completed true', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'T',
        'duration': '30m',
        'completed': true,
      };
      final w = Workout.fromMap('id', map);
      expect(w.completed, true);
    });

    test('toMap with all Sport enum values', () {
      for (final sport in Sport.values) {
        final w = Workout(
          id: 'id',
          planId: 'p',
          sport: sport,
          title: 'T',
          duration: '30m',
          scheduledFor: DateTime(2026),
        );
        final map = w.toMap();
        expect(map['sport'], sport.name);
      }
    });

    test('Sport enum has 5 values', () {
      expect(Sport.values.length, 5);
      expect(Sport.values, contains(Sport.run));
      expect(Sport.values, contains(Sport.bike));
      expect(Sport.values, contains(Sport.swim));
      expect(Sport.values, contains(Sport.strength));
      expect(Sport.values, contains(Sport.rest));
    });

    test('Sport enum names are correct', () {
      expect(Sport.run.name, 'run');
      expect(Sport.bike.name, 'bike');
      expect(Sport.swim.name, 'swim');
      expect(Sport.strength.name, 'strength');
      expect(Sport.rest.name, 'rest');
    });

    test('toMap preserves all fields', () {
      final scheduled = DateTime(2026, 9, 5);
      final w = Workout(
        id: 'full',
        userId: 'u1',
        planId: 'p1',
        sport: Sport.bike,
        title: 'Endurance Ride',
        description: 'Long ride',
        duration: '3h',
        distanceKm: 80.0,
        tss: 120,
        targetPace: '27 km/h',
        scheduledFor: scheduled,
        progress: 0.75,
        completed: false,
        segments: const [
          WorkoutSegment(label: 'Warm up', duration: '15 min'),
          WorkoutSegment(label: 'Main', duration: '2h 30m'),
          WorkoutSegment(label: 'Cool down', duration: '15 min'),
        ],
      );
      final map = w.toMap();
      expect(map['userId'], 'u1');
      expect(map['planId'], 'p1');
      expect(map['sport'], 'bike');
      expect(map['title'], 'Endurance Ride');
      expect(map['description'], 'Long ride');
      expect(map['duration'], '3h');
      expect(map['distanceKm'], 80.0);
      expect(map['tss'], 120);
      expect(map['targetPace'], '27 km/h');
      expect(map['scheduledFor'], scheduled);
      expect(map['progress'], 0.75);
      expect(map['completed'], false);
      expect((map['segments'] as List).length, 3);
    });

    test('fromMap with empty segments list', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'T',
        'duration': '30m',
        'segments': [],
      };
      final w = Workout.fromMap('id', map);
      expect(w.segments, isEmpty);
    });

    test('fromMap with invalid segment data', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'T',
        'duration': '30m',
        'segments': ['not_a_map'],
      };
      expect(() => Workout.fromMap('id', map), throwsA(isA<TypeError>()));
    });

    test('fromMap with very large TSS', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'T',
        'duration': '30m',
        'tss': 99999,
      };
      final w = Workout.fromMap('id', map);
      expect(w.tss, 99999);
    });

    test('fromMap with zero TSS', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'T',
        'duration': '30m',
        'tss': 0,
      };
      final w = Workout.fromMap('id', map);
      expect(w.tss, 0);
    });

    test('fromMap with very long targetPace', () {
      final map = <String, dynamic>{
        'planId': 'p',
        'sport': 'run',
        'title': 'T',
        'duration': '30m',
        'targetPace': 'P' * 500,
      };
      final w = Workout.fromMap('id', map);
      expect(w.targetPace!.length, 500);
    });
  });

  group('WorkoutSegment - Extended', () {
    test('constructor with empty label and duration', () {
      const seg = WorkoutSegment(label: '', duration: '');
      expect(seg.label, '');
      expect(seg.duration, '');
    });

    test('fromMap with extra fields ignores them', () {
      final seg = WorkoutSegment.fromMap({
        'label': 'Warm up',
        'duration': '10 min',
        'extra': 'ignored',
      });
      expect(seg.label, 'Warm up');
      expect(seg.duration, '10 min');
    });

    test('toMap only includes label and duration', () {
      const seg = WorkoutSegment(label: 'A', duration: 'B');
      final map = seg.toMap();
      expect(map.length, 2);
      expect(map.containsKey('label'), true);
      expect(map.containsKey('duration'), true);
    });

    test('fromMap with very long label', () {
      final seg = WorkoutSegment.fromMap({
        'label': 'L' * 1000,
        'duration': '30 min',
      });
      expect(seg.label.length, 1000);
    });

    test('fromMap with special characters', () {
      final seg = WorkoutSegment.fromMap({
        'label': '4x 1km @ 100% HR (90s rest) <threshold>',
        'duration': '35:00',
      });
      expect(seg.label, '4x 1km @ 100% HR (90s rest) <threshold>');
      expect(seg.duration, '35:00');
    });
  });
}

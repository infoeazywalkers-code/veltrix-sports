import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/performance/performance_snapshot.dart';

void main() {
  group('PerformanceSnapshot', () {
    test('fromMap creates correct snapshot with all fields', () {
      final timestamp = Timestamp.fromDate(DateTime(2026, 6, 15));
      final map = {
        'userId': 'user1',
        'fitness': 54.0,
        'fatigue': 61.0,
        'form': -7.0,
        'weeklyTss': 286.0,
        'weeklyWorkouts': 5,
        'weeklyDuration': '4h 35m',
        'recordedAt': timestamp,
      };

      final snapshot = PerformanceSnapshot.fromMap('snap1', map);

      expect(snapshot.id, 'snap1');
      expect(snapshot.userId, 'user1');
      expect(snapshot.fitness, 54.0);
      expect(snapshot.fatigue, 61.0);
      expect(snapshot.form, -7.0);
      expect(snapshot.weeklyTss, 286.0);
      expect(snapshot.weeklyWorkouts, 5);
      expect(snapshot.weeklyDuration, '4h 35m');
      expect(snapshot.recordedAt, timestamp.toDate());
    });

    test('fromMap handles missing optional fields with defaults', () {
      final map = <String, dynamic>{
        'userId': 'user2',
        'fitness': 40.0,
        'fatigue': 50.0,
        'form': 0.0,
      };

      final snapshot = PerformanceSnapshot.fromMap('snap2', map);

      expect(snapshot.weeklyTss, 0);
      expect(snapshot.weeklyWorkouts, 0);
      expect(snapshot.weeklyDuration, '');
      expect(snapshot.recordedAt, isA<DateTime>());
    });

    test('fromMap handles completely empty map', () {
      final snapshot = PerformanceSnapshot.fromMap('snap3', {});

      expect(snapshot.id, 'snap3');
      expect(snapshot.userId, '');
      expect(snapshot.fitness, 0);
      expect(snapshot.fatigue, 0);
      expect(snapshot.form, 0);
      expect(snapshot.weeklyTss, 0);
      expect(snapshot.weeklyWorkouts, 0);
      expect(snapshot.weeklyDuration, '');
      expect(snapshot.recordedAt, isA<DateTime>());
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{
        'userId': null,
        'fitness': null,
        'fatigue': null,
        'form': null,
        'weeklyTss': null,
        'weeklyWorkouts': null,
        'weeklyDuration': null,
        'recordedAt': null,
      };

      final snapshot = PerformanceSnapshot.fromMap('snap4', map);

      expect(snapshot.userId, '');
      expect(snapshot.fitness, 0);
      expect(snapshot.fatigue, 0);
      expect(snapshot.form, 0);
      expect(snapshot.weeklyTss, 0);
      expect(snapshot.weeklyWorkouts, 0);
      expect(snapshot.weeklyDuration, '');
    });

    test('fromMap handles integer values for double fields', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'fitness': 54,
        'fatigue': 61,
        'form': -7,
        'weeklyTss': 286,
        'weeklyWorkouts': 5,
      };

      final snapshot = PerformanceSnapshot.fromMap('snap5', map);

      expect(snapshot.fitness, 54.0);
      expect(snapshot.fatigue, 61.0);
      expect(snapshot.form, -7.0);
      expect(snapshot.weeklyTss, 286.0);
      expect(snapshot.weeklyWorkouts, 5);
    });

    test('toMap returns correct map', () {
      final now = DateTime(2026, 8, 10);
      final snapshot = PerformanceSnapshot(
        id: 'snap6',
        userId: 'user6',
        fitness: 72.5,
        fatigue: 45.3,
        form: 27.2,
        weeklyTss: 320.0,
        weeklyWorkouts: 6,
        weeklyDuration: '5h 10m',
        recordedAt: now,
      );

      final map = snapshot.toMap();

      expect(map['userId'], 'user6');
      expect(map['fitness'], 72.5);
      expect(map['fatigue'], 45.3);
      expect(map['form'], 27.2);
      expect(map['weeklyTss'], 320.0);
      expect(map['weeklyWorkouts'], 6);
      expect(map['weeklyDuration'], '5h 10m');
      expect(map['recordedAt'], now);
    });

    test('constructor defaults for optional fields', () {
      final snapshot = PerformanceSnapshot(
        id: 'snap7',
        userId: 'u7',
        fitness: 30.0,
        fatigue: 20.0,
        form: 10.0,
        recordedAt: DateTime(2026),
      );

      expect(snapshot.weeklyTss, 0);
      expect(snapshot.weeklyWorkouts, 0);
      expect(snapshot.weeklyDuration, '');
    });

    test('fromMap and toMap roundtrip preserves data', () {
      final recordedAt = DateTime(2026, 5, 20, 14, 30);
      final originalMap = <String, dynamic>{
        'userId': 'roundtrip_user',
        'fitness': 65.7,
        'fatigue': 48.2,
        'form': 17.5,
        'weeklyTss': 350.0,
        'weeklyWorkouts': 4,
        'weeklyDuration': '4h 15m',
        'recordedAt': Timestamp.fromDate(recordedAt),
      };

      final snapshot = PerformanceSnapshot.fromMap('rt1', originalMap);
      final roundtrippedMap = snapshot.toMap();

      expect(roundtrippedMap['userId'], 'roundtrip_user');
      expect(roundtrippedMap['fitness'], 65.7);
      expect(roundtrippedMap['fatigue'], 48.2);
      expect(roundtrippedMap['form'], 17.5);
      expect(roundtrippedMap['weeklyTss'], 350.0);
      expect(roundtrippedMap['weeklyWorkouts'], 4);
      expect(roundtrippedMap['weeklyDuration'], '4h 15m');
    });

    test('handles negative fitness and fatigue values', () {
      final snapshot = PerformanceSnapshot(
        id: 'neg',
        userId: 'u',
        fitness: -10.5,
        fatigue: -5.2,
        form: -15.7,
        recordedAt: DateTime(2026),
      );

      expect(snapshot.fitness, -10.5);
      expect(snapshot.fatigue, -5.2);
      expect(snapshot.form, -15.7);
    });

    test('handles zero values for all numeric fields', () {
      final snapshot = PerformanceSnapshot(
        id: 'zero',
        userId: 'u',
        fitness: 0,
        fatigue: 0,
        form: 0,
        weeklyTss: 0,
        weeklyWorkouts: 0,
        recordedAt: DateTime(2026),
      );

      expect(snapshot.fitness, 0);
      expect(snapshot.fatigue, 0);
      expect(snapshot.form, 0);
      expect(snapshot.weeklyTss, 0);
      expect(snapshot.weeklyWorkouts, 0);
    });

    test('handles large numeric values', () {
      final snapshot = PerformanceSnapshot(
        id: 'large',
        userId: 'u',
        fitness: 9999.99,
        fatigue: 9999.99,
        form: 9999.99,
        weeklyTss: 99999.99,
        weeklyWorkouts: 9999,
        recordedAt: DateTime(2026),
      );

      final map = snapshot.toMap();
      expect(map['fitness'], 9999.99);
      expect(map['weeklyWorkouts'], 9999);
    });
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/performance/performance_snapshot.dart';

void main() {
  group('PerformanceSnapshot - Extended', () {
    test('fromMap with string userId that is not a String throws', () {
      final map = <String, dynamic>{
        'userId': 123,
        'fitness': 50.0,
        'fatigue': 40.0,
        'form': 10.0,
      };
      expect(
        () => PerformanceSnapshot.fromMap('id', map),
        throwsA(isA<TypeError>()),
      );
    });

    test('fromMap with very large numeric values', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'fitness': 1e10,
        'fatigue': 1e10,
        'form': -1e10,
        'weeklyTss': 1e10,
        'weeklyWorkouts': 1e10,
      };
      final snap = PerformanceSnapshot.fromMap('id', map);
      expect(snap.fitness, 1e10);
      expect(snap.fatigue, 1e10);
      expect(snap.form, -1e10);
    });

    test('fromMap with very small values', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'fitness': 0.001,
        'fatigue': 0.001,
        'form': 0.001,
        'weeklyTss': 0.001,
      };
      final snap = PerformanceSnapshot.fromMap('id', map);
      expect(snap.fitness, 0.001);
    });

    test('toMap does not include id', () {
      final snap = PerformanceSnapshot(
        id: 'no_id',
        userId: 'u',
        fitness: 50,
        fatigue: 40,
        form: 10,
        recordedAt: DateTime(2026),
      );
      final map = snap.toMap();
      expect(map.containsKey('id'), false);
    });

    test('constructor with all fields', () {
      final now = DateTime(2026);
      final snap = PerformanceSnapshot(
        id: 'all',
        userId: 'u',
        fitness: 60,
        fatigue: 50,
        form: 10,
        weeklyTss: 300,
        weeklyWorkouts: 5,
        weeklyDuration: '5h 30m',
        recordedAt: now,
      );
      expect(snap.id, 'all');
      expect(snap.userId, 'u');
      expect(snap.fitness, 60);
      expect(snap.fatigue, 50);
      expect(snap.form, 10);
      expect(snap.weeklyTss, 300);
      expect(snap.weeklyWorkouts, 5);
      expect(snap.weeklyDuration, '5h 30m');
      expect(snap.recordedAt, now);
    });

    test('fromMap with empty weeklyDuration', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'fitness': 50,
        'fatigue': 40,
        'form': 10,
        'weeklyDuration': '',
      };
      final snap = PerformanceSnapshot.fromMap('id', map);
      expect(snap.weeklyDuration, '');
    });

    test('fromMap with long weeklyDuration', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'fitness': 50,
        'fatigue': 40,
        'form': 10,
        'weeklyDuration': 'D' * 200,
      };
      final snap = PerformanceSnapshot.fromMap('id', map);
      expect(snap.weeklyDuration.length, 200);
    });

    test('toMap roundtrip preserves all data via Timestamp', () {
      final now = DateTime(2026, 5, 10, 14, 30);
      final original = PerformanceSnapshot(
        id: 'rt',
        userId: 'roundtrip',
        fitness: 65.7,
        fatigue: 48.2,
        form: 17.5,
        weeklyTss: 350.0,
        weeklyWorkouts: 4,
        weeklyDuration: '4h 15m',
        recordedAt: now,
      );

      final map = original.toMap();
      // fromMap expects Timestamp for recordedAt, but toMap puts DateTime
      final tsMap = Map<String, dynamic>.from(map);
      tsMap['recordedAt'] = Timestamp.fromDate(now);
      final restored = PerformanceSnapshot.fromMap('rt', tsMap);

      expect(restored.userId, 'roundtrip');
      expect(restored.fitness, 65.7);
      expect(restored.fatigue, 48.2);
      expect(restored.form, 17.5);
      expect(restored.weeklyTss, 350.0);
      expect(restored.weeklyWorkouts, 4);
      expect(restored.weeklyDuration, '4h 15m');
    });

    test('handles NaN gracefully via num conversion', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'fitness': double.nan,
        'fatigue': double.nan,
        'form': double.nan,
      };
      final snap = PerformanceSnapshot.fromMap('id', map);
      expect(snap.fitness.isNaN, isTrue);
    });

    test('handles infinity values', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'fitness': double.infinity,
        'fatigue': double.negativeInfinity,
        'form': 0,
      };
      final snap = PerformanceSnapshot.fromMap('id', map);
      expect(snap.fitness, double.infinity);
      expect(snap.fatigue, double.negativeInfinity);
    });
  });
}

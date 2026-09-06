import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/training_plan.dart';

void main() {
  group('TrainingPlan - Extended', () {
    test('fromMap with string coachId', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'name': 'Plan',
        'description': 'D',
        'sport': 'Running',
        'durationWeeks': 8,
        'difficulty': 'Beginner',
        'targetGoal': 'G',
        'price': 10,
        'coachId': 'coach_1',
      };
      final plan = TrainingPlan.fromMap('id', map);
      expect(plan.coachId, 'coach_1');
    });

    test('fromMap with null startDate', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'name': 'Plan',
        'description': 'D',
        'sport': 'Running',
        'durationWeeks': 8,
        'difficulty': 'Beginner',
        'targetGoal': 'G',
        'price': 10,
        'startDate': null,
      };
      final plan = TrainingPlan.fromMap('id', map);
      expect(plan.startDate, isNull);
    });

    test('fromMap with null endDate', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'name': 'Plan',
        'description': 'D',
        'sport': 'Running',
        'durationWeeks': 8,
        'difficulty': 'Beginner',
        'targetGoal': 'G',
        'price': 10,
        'endDate': null,
      };
      final plan = TrainingPlan.fromMap('id', map);
      expect(plan.endDate, isNull);
    });

    test('fromMap with null createdAt', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'name': 'Plan',
        'description': 'D',
        'sport': 'Running',
        'durationWeeks': 8,
        'difficulty': 'Beginner',
        'targetGoal': 'G',
        'price': 10,
        'createdAt': null,
      };
      final plan = TrainingPlan.fromMap('id', map);
      expect(plan.createdAt, isNull);
    });

    test('fromMap with integer totalDistanceKm', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'name': 'Plan',
        'description': 'D',
        'sport': 'Running',
        'durationWeeks': 8,
        'difficulty': 'Beginner',
        'targetGoal': 'G',
        'price': 10,
        'totalDistanceKm': 500,
      };
      final plan = TrainingPlan.fromMap('id', map);
      expect(plan.totalDistanceKm, 500.0);
    });

    test('fromMap with zero durationWeeks', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'name': 'Plan',
        'description': 'D',
        'sport': 'Running',
        'durationWeeks': 0,
        'difficulty': 'Beginner',
        'targetGoal': 'G',
        'price': 10,
      };
      final plan = TrainingPlan.fromMap('id', map);
      expect(plan.durationWeeks, 0);
    });

    test('toMap fromMap roundtrip with all optional fields via Timestamps', () {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 6, 30);
      final created = DateTime(2025, 12, 1);
      final plan = TrainingPlan(
        id: 'rt',
        userId: 'u',
        coachId: 'c',
        name: 'Full Plan',
        description: 'Complete plan',
        sport: 'Cycling',
        durationWeeks: 16,
        difficulty: 'Advanced',
        targetGoal: 'FTP 280W',
        price: 49.99,
        eventName: 'Tour de France',
        startDate: start,
        endDate: end,
        totalDistanceKm: 1200.0,
        status: 'completed',
        createdAt: created,
      );

      final map = plan.toMap();
      // fromMap expects Timestamps for date fields, but toMap puts DateTime
      final tsMap = Map<String, dynamic>.from(map);
      tsMap['startDate'] = Timestamp.fromDate(start);
      tsMap['endDate'] = Timestamp.fromDate(end);
      tsMap['createdAt'] = Timestamp.fromDate(created);
      final restored = TrainingPlan.fromMap('rt', tsMap);

      expect(restored.userId, 'u');
      expect(restored.coachId, 'c');
      expect(restored.name, 'Full Plan');
      expect(restored.description, 'Complete plan');
      expect(restored.sport, 'Cycling');
      expect(restored.durationWeeks, 16);
      expect(restored.difficulty, 'Advanced');
      expect(restored.targetGoal, 'FTP 280W');
      expect(restored.price, 49.99);
      expect(restored.eventName, 'Tour de France');
      expect(restored.startDate, start);
      expect(restored.endDate, end);
      expect(restored.totalDistanceKm, 1200.0);
      expect(restored.status, 'completed');
    });

    test('status variations in fromMap', () {
      for (final status in ['active', 'completed', 'paused', 'draft']) {
        final map = <String, dynamic>{
          'userId': 'u',
          'name': 'P',
          'description': 'D',
          'sport': 'Running',
          'durationWeeks': 4,
          'difficulty': 'Beginner',
          'targetGoal': 'G',
          'price': 0,
          'status': status,
        };
        final plan = TrainingPlan.fromMap('id', map);
        expect(plan.status, status);
      }
    });

    test('handles negative durationWeeks', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'name': 'P',
        'description': 'D',
        'sport': 'Running',
        'durationWeeks': -1,
        'difficulty': 'Beginner',
        'targetGoal': 'G',
        'price': 0,
      };
      final plan = TrainingPlan.fromMap('id', map);
      expect(plan.durationWeeks, -1);
    });

    test('handles very long name and description', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'name': 'N' * 500,
        'description': 'D' * 1000,
        'sport': 'Running',
        'durationWeeks': 8,
        'difficulty': 'Beginner',
        'targetGoal': 'G',
        'price': 0,
      };
      final plan = TrainingPlan.fromMap('id', map);
      expect(plan.name.length, 500);
      expect(plan.description.length, 1000);
    });
  });
}

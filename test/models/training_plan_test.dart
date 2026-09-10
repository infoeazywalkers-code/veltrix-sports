import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/training/training_plan.dart';

void main() {
  group('TrainingPlan', () {
    test('fromMap creates correct plan with all fields', () {
      final startTimestamp = Timestamp.fromDate(DateTime(2026, 1, 1));
      final endTimestamp = Timestamp.fromDate(DateTime(2026, 4, 1));
      final createdTimestamp = Timestamp.fromDate(DateTime(2025, 12, 15));
      final map = {
        'userId': 'user1',
        'coachId': 'coach1',
        'name': 'Marathon Plan',
        'description': '12-week marathon training',
        'sport': 'Running',
        'durationWeeks': 12,
        'difficulty': 'Advanced',
        'targetGoal': 'Sub-3:00 Marathon',
        'price': 29.99,
        'eventName': 'Mumbai Marathon',
        'startDate': startTimestamp,
        'endDate': endTimestamp,
        'totalDistanceKm': 800.0,
        'status': 'active',
        'createdAt': createdTimestamp,
      };

      final plan = TrainingPlan.fromMap('plan1', map);

      expect(plan.id, 'plan1');
      expect(plan.userId, 'user1');
      expect(plan.coachId, 'coach1');
      expect(plan.name, 'Marathon Plan');
      expect(plan.description, '12-week marathon training');
      expect(plan.sport, 'Running');
      expect(plan.durationWeeks, 12);
      expect(plan.difficulty, 'Advanced');
      expect(plan.targetGoal, 'Sub-3:00 Marathon');
      expect(plan.price, 29.99);
      expect(plan.eventName, 'Mumbai Marathon');
      expect(plan.startDate, startTimestamp.toDate());
      expect(plan.endDate, endTimestamp.toDate());
      expect(plan.totalDistanceKm, 800.0);
      expect(plan.status, 'active');
      expect(plan.createdAt, createdTimestamp.toDate());
    });

    test('fromMap handles missing optional fields with defaults', () {
      final map = <String, dynamic>{
        'userId': 'user2',
        'name': 'Basic Plan',
        'description': 'Getting started',
        'sport': 'Cycling',
        'durationWeeks': 8,
        'difficulty': 'Beginner',
        'targetGoal': 'Complete century',
        'price': 19.99,
      };

      final plan = TrainingPlan.fromMap('plan2', map);

      expect(plan.coachId, isNull);
      expect(plan.eventName, isNull);
      expect(plan.startDate, isNull);
      expect(plan.endDate, isNull);
      expect(plan.totalDistanceKm, isNull);
      expect(plan.status, 'active');
      expect(plan.createdAt, isNull);
    });

    test('fromMap handles completely empty map', () {
      final plan = TrainingPlan.fromMap('plan3', {});

      expect(plan.id, 'plan3');
      expect(plan.userId, '');
      expect(plan.coachId, isNull);
      expect(plan.name, '');
      expect(plan.description, '');
      expect(plan.sport, 'Running'); // default
      expect(plan.durationWeeks, 8); // default
      expect(plan.difficulty, 'Intermediate'); // default
      expect(plan.targetGoal, '');
      expect(plan.price, 0.0);
      expect(plan.eventName, isNull);
      expect(plan.startDate, isNull);
      expect(plan.endDate, isNull);
      expect(plan.totalDistanceKm, isNull);
      expect(plan.status, 'active');
      expect(plan.createdAt, isNull);
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{
        'userId': null,
        'coachId': null,
        'name': null,
        'description': null,
        'sport': null,
        'durationWeeks': null,
        'difficulty': null,
        'targetGoal': null,
        'price': null,
        'eventName': null,
        'startDate': null,
        'endDate': null,
        'totalDistanceKm': null,
        'status': null,
        'createdAt': null,
      };

      final plan = TrainingPlan.fromMap('plan4', map);

      expect(plan.userId, '');
      expect(plan.coachId, isNull);
      expect(plan.name, '');
      expect(plan.description, '');
      expect(plan.sport, 'Running');
      expect(plan.durationWeeks, 8);
      expect(plan.difficulty, 'Intermediate');
      expect(plan.targetGoal, '');
      expect(plan.price, 0.0);
      expect(plan.status, 'active');
    });

    test('fromMap handles integer values for numeric fields', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'name': 'Plan',
        'description': 'Desc',
        'sport': 'Running',
        'durationWeeks': 16,
        'difficulty': 'Hard',
        'targetGoal': 'Goal',
        'price': 30,
      };

      final plan = TrainingPlan.fromMap('id', map);
      expect(plan.durationWeeks, 16);
      expect(plan.price, 30.0);
    });

    test('toMap returns correct map', () {
      final start = DateTime(2026, 6, 1);
      final end = DateTime(2026, 9, 1);
      final created = DateTime(2026, 5, 15);
      final plan = TrainingPlan(
        id: 'plan5',
        userId: 'user5',
        coachId: 'coach5',
        name: 'Triathlon Plan',
        description: 'Sprint triathlon prep',
        sport: 'Triathlon',
        durationWeeks: 10,
        difficulty: 'Intermediate',
        targetGoal: 'Complete Sprint Tri',
        price: 24.99,
        eventName: 'Pune Triathlon',
        startDate: start,
        endDate: end,
        totalDistanceKm: 25.0,
        status: 'active',
        createdAt: created,
      );

      final map = plan.toMap();

      expect(map['userId'], 'user5');
      expect(map['coachId'], 'coach5');
      expect(map['name'], 'Triathlon Plan');
      expect(map['description'], 'Sprint triathlon prep');
      expect(map['sport'], 'Triathlon');
      expect(map['durationWeeks'], 10);
      expect(map['difficulty'], 'Intermediate');
      expect(map['targetGoal'], 'Complete Sprint Tri');
      expect(map['price'], 24.99);
      expect(map['eventName'], 'Pune Triathlon');
      expect(map['startDate'], start);
      expect(map['endDate'], end);
      expect(map['totalDistanceKm'], 25.0);
      expect(map['status'], 'active');
      expect(map['createdAt'], created);
    });

    test('toMap includes null values for optional fields', () {
      final plan = TrainingPlan(
        id: 'plan6',
        userId: 'u6',
        name: 'Minimal',
        description: 'Basic',
        sport: 'Running',
        durationWeeks: 4,
        difficulty: 'Beginner',
        targetGoal: 'Finish',
        price: 0,
        status: 'active',
        createdAt: DateTime(2026),
      );

      final map = plan.toMap();
      expect(map['coachId'], isNull);
      expect(map['eventName'], isNull);
      expect(map['startDate'], isNull);
      expect(map['endDate'], isNull);
      expect(map['totalDistanceKm'], isNull);
    });

    test('constructor defaults', () {
      final plan = TrainingPlan(
        id: 'plan7',
        userId: 'u7',
        name: 'Plan',
        description: 'Desc',
        sport: 'Running',
        durationWeeks: 8,
        difficulty: 'Intermediate',
        targetGoal: 'Goal',
        price: 10.0,
        createdAt: DateTime(2026),
      );

      expect(plan.coachId, isNull);
      expect(plan.eventName, isNull);
      expect(plan.startDate, isNull);
      expect(plan.endDate, isNull);
      expect(plan.totalDistanceKm, isNull);
      expect(plan.status, 'active');
    });

    test('fromMap and toMap roundtrip preserves data', () {
      final start = Timestamp.fromDate(DateTime(2026, 3, 1));
      final end = Timestamp.fromDate(DateTime(2026, 6, 1));
      final created = Timestamp.fromDate(DateTime(2026, 2, 15));
      final originalMap = <String, dynamic>{
        'userId': 'rt_user',
        'coachId': 'rt_coach',
        'name': 'Roundtrip Plan',
        'description': 'Test roundtrip',
        'sport': 'Cycling',
        'durationWeeks': 16,
        'difficulty': 'Advanced',
        'targetGoal': 'FTP 280W',
        'price': 49.99,
        'eventName': 'Tour de Veltrix',
        'startDate': start,
        'endDate': end,
        'totalDistanceKm': 1200.0,
        'status': 'completed',
        'createdAt': created,
      };

      final plan = TrainingPlan.fromMap('rt1', originalMap);
      final roundtripped = plan.toMap();

      expect(roundtripped['userId'], 'rt_user');
      expect(roundtripped['coachId'], 'rt_coach');
      expect(roundtripped['name'], 'Roundtrip Plan');
      expect(roundtripped['sport'], 'Cycling');
      expect(roundtripped['durationWeeks'], 16);
      expect(roundtripped['difficulty'], 'Advanced');
      expect(roundtripped['targetGoal'], 'FTP 280W');
      expect(roundtripped['price'], 49.99);
      expect(roundtripped['eventName'], 'Tour de Veltrix');
      expect(roundtripped['status'], 'completed');
    });

    test('handles zero and negative prices', () {
      final freePlan = TrainingPlan(
        id: 'free',
        userId: 'u',
        name: 'Free',
        description: 'd',
        sport: 'Running',
        durationWeeks: 4,
        difficulty: 'Beginner',
        targetGoal: 'g',
        price: 0,
        createdAt: DateTime(2026),
      );
      expect(freePlan.price, 0);

      final expensivePlan = TrainingPlan(
        id: 'exp',
        userId: 'u',
        name: 'Premium',
        description: 'd',
        sport: 'Running',
        durationWeeks: 52,
        difficulty: 'Expert',
        targetGoal: 'g',
        price: 999.99,
        createdAt: DateTime(2026),
      );
      expect(expensivePlan.price, 999.99);
    });

    test('handles status variations', () {
      final active = TrainingPlan(
        id: 'a',
        userId: 'u',
        name: 'A',
        description: 'd',
        sport: 'Running',
        durationWeeks: 4,
        difficulty: 'Beginner',
        targetGoal: 'g',
        price: 0,
        status: 'active',
        createdAt: DateTime(2026),
      );
      expect(active.status, 'active');

      final completed = TrainingPlan(
        id: 'c',
        userId: 'u',
        name: 'C',
        description: 'd',
        sport: 'Running',
        durationWeeks: 4,
        difficulty: 'Beginner',
        targetGoal: 'g',
        price: 0,
        status: 'completed',
        createdAt: DateTime(2026),
      );
      expect(completed.status, 'completed');

      final paused = TrainingPlan(
        id: 'p',
        userId: 'u',
        name: 'P',
        description: 'd',
        sport: 'Running',
        durationWeeks: 4,
        difficulty: 'Beginner',
        targetGoal: 'g',
        price: 0,
        status: 'paused',
        createdAt: DateTime(2026),
      );
      expect(paused.status, 'paused');
    });
  });
}

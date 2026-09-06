import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/training_plan_service.dart';
import 'package:veltrix_sports/models/training_plan.dart';

void main() {
  group('TrainingPlanService.demoPlans', () {
    test('contains exactly 3 demo plans', () {
      expect(TrainingPlanService.demoPlans.length, 3);
    });

    test('first plan is Marathon Training Pro', () {
      final plan = TrainingPlanService.demoPlans[0];
      expect(plan.id, 'marathon_pro');
      expect(plan.name, 'Marathon Training Pro');
      expect(plan.userId, 'demo');
      expect(plan.sport, 'Running');
      expect(plan.durationWeeks, 16);
      expect(plan.difficulty, 'Intermediate');
      expect(plan.targetGoal, 'Sub-3:45 Marathon');
      expect(plan.price, 29.99);
      expect(plan.status, 'active');
    });

    test('second plan is Cycling Performance Builder', () {
      final plan = TrainingPlanService.demoPlans[1];
      expect(plan.id, 'cycling_performance');
      expect(plan.name, 'Cycling Performance Builder');
      expect(plan.sport, 'Cycling');
      expect(plan.durationWeeks, 12);
      expect(plan.difficulty, 'Advanced');
      expect(plan.targetGoal, 'FTP 250W+');
      expect(plan.price, 24.99);
    });

    test('third plan is Triathlon Base Builder', () {
      final plan = TrainingPlanService.demoPlans[2];
      expect(plan.id, 'triathlon_base');
      expect(plan.name, 'Triathlon Base Builder');
      expect(plan.sport, 'Triathlon');
      expect(plan.durationWeeks, 8);
      expect(plan.difficulty, 'Beginner');
      expect(plan.targetGoal, 'Complete First Triathlon');
      expect(plan.price, 19.99);
    });

    test('all demo plans have userId demo', () {
      for (final plan in TrainingPlanService.demoPlans) {
        expect(plan.userId, 'demo');
      }
    });

    test('all demo plans have status active', () {
      for (final plan in TrainingPlanService.demoPlans) {
        expect(plan.status, 'active');
      }
    });

    test('all demo plans have non-empty names', () {
      for (final plan in TrainingPlanService.demoPlans) {
        expect(plan.name, isNotEmpty);
      }
    });

    test('all demo plans have non-empty descriptions', () {
      for (final plan in TrainingPlanService.demoPlans) {
        expect(plan.description, isNotEmpty);
      }
    });

    test('all demo plans have positive prices', () {
      for (final plan in TrainingPlanService.demoPlans) {
        expect(plan.price, greaterThan(0));
      }
    });

    test('all demo plans have unique IDs', () {
      final ids = TrainingPlanService.demoPlans.map((p) => p.id).toSet();
      expect(ids.length, TrainingPlanService.demoPlans.length);
    });

    test('all demo plans have createdAt set', () {
      for (final plan in TrainingPlanService.demoPlans) {
        expect(plan.createdAt, isNotNull);
      }
    });

    test('all demo plans have null optional fields', () {
      for (final plan in TrainingPlanService.demoPlans) {
        expect(plan.coachId, isNull);
        expect(plan.eventName, isNull);
        expect(plan.startDate, isNull);
        expect(plan.endDate, isNull);
        expect(plan.totalDistanceKm, isNull);
      }
    });

    test('demoPlans getter returns new list each time (not cached)', () {
      final list1 = TrainingPlanService.demoPlans;
      final list2 = TrainingPlanService.demoPlans;
      expect(identical(list1, list2), isFalse);
      expect(list1.length, list2.length);
    });
  });

  group('TrainingPlanService instantiation', () {
    test('TrainingPlanService class exists and can be referenced', () {
      // TrainingPlanService requires Firestore - verify class structure
      expect(TrainingPlanService, isA<Type>());
    });
  });
}

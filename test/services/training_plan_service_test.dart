import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/training_plan.dart';
import 'package:veltrix_sports/services/training_plan_service.dart';

void main() {
  group('TrainingPlanService', () {
    late FakeFirebaseFirestore firestore;
    late TrainingPlanService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = TrainingPlanService(db: firestore);
    });

    test('class exists and can be instantiated', () {
      expect(service, isA<TrainingPlanService>());
    });

    group('getFeaturedPlans', () {
      test('returns empty list when Firestore is empty', () async {
        final plans = await service.getFeaturedPlans();
        expect(plans, isEmpty);
      });

      test('returns featured plans when they exist', () async {
        await firestore.collection('training_plans').doc('plan1').set({
          'userId': 'u1',
          'name': 'Featured Plan',
          'description': 'A great plan',
          'sport': 'Running',
          'durationWeeks': 12,
          'difficulty': 'Intermediate',
          'targetGoal': 'Marathon',
          'price': 29.99,
          'status': 'active',
          'isFeatured': true,
        });

        final plans = await service.getFeaturedPlans();
        expect(plans.length, 1);
        expect(plans.first.name, 'Featured Plan');
      });

      test('does not return non-featured plans', () async {
        await firestore.collection('training_plans').doc('plan1').set({
          'userId': 'u1',
          'name': 'Regular Plan',
          'description': 'Not featured',
          'sport': 'Running',
          'durationWeeks': 8,
          'difficulty': 'Beginner',
          'targetGoal': '5K',
          'price': 9.99,
          'status': 'active',
          'isFeatured': false,
        });

        final plans = await service.getFeaturedPlans();
        expect(plans, isEmpty);
      });

      test('returns at most 10 featured plans', () async {
        for (var i = 0; i < 15; i++) {
          await firestore.collection('training_plans').doc('plan$i').set({
            'userId': 'u1',
            'name': 'Plan $i',
            'description': 'Plan $i description',
            'sport': 'Running',
            'durationWeeks': 8,
            'difficulty': 'Intermediate',
            'targetGoal': 'Goal $i',
            'price': 19.99,
            'status': 'active',
            'isFeatured': true,
          });
        }

        final plans = await service.getFeaturedPlans();
        expect(plans.length, 10);
      });
    });

    group('create and get', () {
      test('create stores plan and get retrieves it', () async {
        final plan = const TrainingPlan(
          id: 'test_plan',
          userId: 'u1',
          name: 'Test Plan',
          description: 'A test plan',
          sport: 'Cycling',
          durationWeeks: 4,
          difficulty: 'Beginner',
          targetGoal: 'Base Fitness',
          price: 14.99,
        );

        await service.create(plan);
        final retrieved = await service.get('test_plan');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'Test Plan');
        expect(retrieved.sport, 'Cycling');
      });

      test('get returns null for nonexistent plan', () async {
        final retrieved = await service.get('nonexistent');
        expect(retrieved, isNull);
      });
    });

    group('getByUserId', () {
      test('returns empty list when user has no plans', () async {
        final plans = await service.getByUserId('unknown_user');
        expect(plans, isEmpty);
      });

      test('returns plans for specific user', () async {
        await firestore.collection('training_plans').doc('p1').set({
          'userId': 'u1',
          'name': 'Plan 1',
          'description': 'Desc',
          'sport': 'Running',
          'durationWeeks': 8,
          'difficulty': 'Intermediate',
          'targetGoal': 'Goal',
          'price': 19.99,
          'status': 'active',
        });

        final plans = await service.getByUserId('u1');
        expect(plans.length, 1);
        expect(plans.first.name, 'Plan 1');
      });
    });
  });
}

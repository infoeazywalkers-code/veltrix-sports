import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/training/training_plan.dart';
import 'package:veltrix_sports/services/activity/workout_service.dart';
import 'package:veltrix_sports/services/training/plan_templates.dart';
import 'package:veltrix_sports/services/training/training_plan_service.dart';

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

    group('enrollFromMarketplace', () {
      test('creates an active user-owned plan and returns its id', () async {
        final template = kPlanTemplates['1']!;
        final planId = await service.enrollFromMarketplace(
          userId: 'buyer1',
          catalogId: '1',
          name: template.name,
          description: template.description,
          sport: template.sport,
          durationWeeks: template.durationWeeks,
          difficulty: template.difficulty,
          price: 39.99,
          startDate: DateTime(2026, 9, 14),
        );

        expect(planId, isNotEmpty);
        final stored =
            await firestore.collection('training_plans').doc(planId).get();
        expect(stored.exists, isTrue);
        final data = stored.data()!;
        expect(data['userId'], 'buyer1');
        expect(data['name'], template.name);
        expect(data['status'], 'active');
        expect(data['durationWeeks'], template.durationWeeks);
        expect(data['price'], 39.99);
      });

      test('enroll then materialize schedules week 1 workouts', () async {
        final template = kPlanTemplates['5']!;
        final startMonday = DateTime(2026, 9, 14);
        final planId = await service.enrollFromMarketplace(
          userId: 'buyer2',
          catalogId: '5',
          name: template.name,
          description: template.description,
          sport: template.sport,
          durationWeeks: template.durationWeeks,
          difficulty: template.difficulty,
          startDate: startMonday,
        );

        final count = await service.materializeWeeklyWorkouts(
          userId: 'buyer2',
          planId: planId,
          startMonday: startMonday,
          template: template.workouts,
        );

        expect(count, template.durationWeeks * template.workouts.length);
        final workoutService = WorkoutService(db: firestore);
        final week1 = await workoutService.getByPlanId('buyer2', planId);
        expect(week1.length, count);
        // Every week-1 workout is dated within the first 7 days.
        final firstWeek =
            week1
                .where((w) => w.scheduledFor.difference(startMonday).inDays < 7)
                .toList();
        expect(firstWeek.length, template.workouts.length);
      });
    });

    group('watchByPlanId ordering', () {
      test('emits plan workouts ordered by scheduledFor', () async {
        final workoutService = WorkoutService(db: firestore);
        final dates = [
          DateTime(2026, 9, 20),
          DateTime(2026, 9, 14),
          DateTime(2026, 9, 17),
        ];
        for (var i = 0; i < dates.length; i++) {
          await firestore.collection('workouts').doc('ord$i').set({
            'userId': 'u9',
            'planId': 'plan_ord',
            'sport': 'run',
            'title': 'Workout $i',
            'duration': '30 min',
            'scheduledFor': Timestamp.fromDate(dates[i]),
            'progress': 0.0,
            'completed': false,
          });
        }
        // A workout from another plan must not leak in.
        await firestore.collection('workouts').doc('other').set({
          'userId': 'u9',
          'planId': 'other_plan',
          'sport': 'run',
          'title': 'Other',
          'duration': '30 min',
          'scheduledFor': Timestamp.fromDate(DateTime(2026, 9, 10)),
          'progress': 0.0,
          'completed': false,
        });

        final emitted =
            await workoutService.watchByPlanId('u9', 'plan_ord').first;
        expect(emitted.length, 3);
        for (var i = 1; i < emitted.length; i++) {
          expect(
            !emitted[i].scheduledFor.isBefore(emitted[i - 1].scheduledFor),
            isTrue,
          );
        }
        expect(emitted.first.scheduledFor, DateTime(2026, 9, 14));
      });
    });
  });
}

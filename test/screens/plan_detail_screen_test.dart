import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/workout.dart';
import 'package:veltrix_sports/models/training/training_plan.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/screens/training/plan_detail_screen.dart';
import 'package:veltrix_sports/services/training/training_plan_service.dart';

TrainingPlan makePlan() => TrainingPlan(
  id: 'p1',
  userId: 'u1',
  name: 'Gran Fondo 200km',
  description: 'Endurance plan',
  sport: 'bike',
  durationWeeks: 12,
  difficulty: 'Intermediate',
  targetGoal: 'Gran Fondo',
  price: 39.99,
  status: 'active',
  startDate: DateTime(2026, 9, 14),
  endDate: DateTime(2026, 12, 7),
);

Workout makeWorkout({
  required String id,
  required String title,
  required DateTime scheduledFor,
  bool completed = false,
}) => Workout(
  id: id,
  userId: 'u1',
  planId: 'p1',
  sport: Sport.bike,
  title: title,
  duration: '60 min',
  scheduledFor: scheduledFor,
  completed: completed,
);

Widget wrapDetail({
  List<Override> extraOverrides = const [],
  String planId = 'p1',
}) => ProviderScope(
  overrides: [
    currentUserProvider.overrideWithValue(MockUser(uid: 'u1')),
    activePlansProvider.overrideWith((ref) => Stream.value([makePlan()])),
    planWorkoutsProvider.overrideWith((ref, args) => Stream.value(const [])),
    planProgressProvider.overrideWith((ref, args) => Stream.value(0.0)),
    ...extraOverrides,
  ],
  child: MaterialApp(home: PlanDetailScreen(planId: planId)),
);

void main() {
  group('PlanDetailScreen', () {
    testWidgets('shows header and live progress bar', (tester) async {
      await tester.pumpWidget(
        wrapDetail(
          extraOverrides: [
            planProgressProvider.overrideWith((ref, args) => Stream.value(0.5)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gran Fondo 200km'), findsOneWidget);
      expect(find.textContaining('12 weeks'), findsOneWidget);
      expect(find.text('50% complete'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('empty plan shows No workouts yet', (tester) async {
      await tester.pumpWidget(wrapDetail());
      await tester.pumpAndSettle();

      expect(find.text('No workouts yet'), findsOneWidget);
    });

    testWidgets('groups workouts by week', (tester) async {
      final workouts = [
        makeWorkout(
          id: 'w1',
          title: 'Tuesday Intervals',
          scheduledFor: DateTime(2026, 9, 15, 7),
        ),
        makeWorkout(
          id: 'w2',
          title: 'Saturday Long Ride',
          scheduledFor: DateTime(2026, 9, 19, 7),
        ),
        makeWorkout(
          id: 'w3',
          title: 'Week Two Intervals',
          scheduledFor: DateTime(2026, 9, 22, 7),
        ),
      ];
      await tester.pumpWidget(
        wrapDetail(
          extraOverrides: [
            planWorkoutsProvider.overrideWith(
              (ref, args) => Stream.value(workouts),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Week 1'), findsOneWidget);
      expect(find.text('Week 2'), findsOneWidget);
      expect(find.text('Tuesday Intervals'), findsOneWidget);
      expect(find.text('Week Two Intervals'), findsOneWidget);
    });

    testWidgets('shows View in Calendar and Cancel plan actions', (
      tester,
    ) async {
      await tester.pumpWidget(wrapDetail());
      await tester.pumpAndSettle();

      expect(find.text('View in Calendar'), findsOneWidget);
      expect(find.text('Cancel plan'), findsWidgets);
    });

    testWidgets('cancel plan asks for confirmation then cancels', (
      tester,
    ) async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('training_plans').doc('p1').set({
        'userId': 'u1',
        'name': 'Gran Fondo 200km',
        'description': 'Endurance plan',
        'sport': 'bike',
        'durationWeeks': 12,
        'difficulty': 'Intermediate',
        'targetGoal': 'Gran Fondo',
        'price': 39.99,
        'status': 'active',
      });
      final service = TrainingPlanService(db: firestore);

      await tester.pumpWidget(
        wrapDetail(
          extraOverrides: [
            trainingPlanServiceProvider.overrideWithValue(service),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel plan').first);
      await tester.pumpAndSettle();
      expect(find.text('Cancel plan?'), findsOneWidget);

      await tester.tap(find.text('Cancel plan').last);
      await tester.pumpAndSettle();

      final stored = await firestore
          .collection('training_plans')
          .doc('p1')
          .get();
      expect(stored.data()?['status'], 'cancelled');
      expect(find.byType(PlanDetailScreen), findsNothing);
    });

    testWidgets('unknown plan id shows Plan not found', (tester) async {
      await tester.pumpWidget(wrapDetail(planId: 'missing'));
      await tester.pumpAndSettle();

      expect(find.text('Plan not found'), findsOneWidget);
    });
  });
}

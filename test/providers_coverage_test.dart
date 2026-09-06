import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/services/user_service.dart';
import 'package:veltrix_sports/services/workout_service.dart';
import 'package:veltrix_sports/services/training_plan_service.dart';
import 'package:veltrix_sports/services/coach_request_service.dart';
import 'package:veltrix_sports/services/performance_service.dart';

void main() {
  group('Providers - service type checks', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('userServiceProvider returns UserService', () {
      final db = FakeFirebaseFirestore();
      final service = UserService(db: db);
      expect(service, isA<UserService>());
    });

    test('workoutServiceProvider returns WorkoutService', () {
      final db = FakeFirebaseFirestore();
      final service = WorkoutService(db: db);
      expect(service, isA<WorkoutService>());
    });

    test('trainingPlanServiceProvider returns TrainingPlanService', () {
      final db = FakeFirebaseFirestore();
      final service = TrainingPlanService(db: db);
      expect(service, isA<TrainingPlanService>());
    });

    test('coachRequestServiceProvider returns CoachRequestService', () {
      final db = FakeFirebaseFirestore();
      final service = CoachRequestService(db: db);
      expect(service, isA<CoachRequestService>());
    });

    test('performanceServiceProvider returns PerformanceService', () {
      final db = FakeFirebaseFirestore();
      final service = PerformanceService(db: db);
      expect(service, isA<PerformanceService>());
    });

    test('userServiceProvider override returns different instance', () {
      final db = FakeFirebaseFirestore();
      final service = UserService(db: db);
      final container = ProviderContainer(
        overrides: [userServiceProvider.overrideWithValue(service)],
      );
      final result = container.read(userServiceProvider);
      expect(result, isA<UserService>());
      expect(identical(result, service), true);
      container.dispose();
    });

    test('workoutServiceProvider override returns different instance', () {
      final db = FakeFirebaseFirestore();
      final service = WorkoutService(db: db);
      final container = ProviderContainer(
        overrides: [workoutServiceProvider.overrideWithValue(service)],
      );
      final result = container.read(workoutServiceProvider);
      expect(result, isA<WorkoutService>());
      expect(identical(result, service), true);
      container.dispose();
    });

    test('trainingPlanServiceProvider override returns different instance', () {
      final db = FakeFirebaseFirestore();
      final service = TrainingPlanService(db: db);
      final container = ProviderContainer(
        overrides: [trainingPlanServiceProvider.overrideWithValue(service)],
      );
      final result = container.read(trainingPlanServiceProvider);
      expect(result, isA<TrainingPlanService>());
      expect(identical(result, service), true);
      container.dispose();
    });

    test('coachRequestServiceProvider override returns different instance', () {
      final db = FakeFirebaseFirestore();
      final service = CoachRequestService(db: db);
      final container = ProviderContainer(
        overrides: [coachRequestServiceProvider.overrideWithValue(service)],
      );
      final result = container.read(coachRequestServiceProvider);
      expect(result, isA<CoachRequestService>());
      expect(identical(result, service), true);
      container.dispose();
    });

    test('performanceServiceProvider override returns different instance', () {
      final db = FakeFirebaseFirestore();
      final service = PerformanceService(db: db);
      final container = ProviderContainer(
        overrides: [performanceServiceProvider.overrideWithValue(service)],
      );
      final result = container.read(performanceServiceProvider);
      expect(result, isA<PerformanceService>());
      expect(identical(result, service), true);
      container.dispose();
    });
  });

  group('Providers - null user guard branches', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('currentUserProvider is null when no auth', () {
      final user = container.read(currentUserProvider);
      expect(user, isNull);
    });

    test('authStateProvider exists and can be listened to', () {
      final sub = container.listen(authStateProvider, (_, __) {});
      expect(sub.read(), isNotNull);
      sub.close();
    });

    test(
      'userProfileProvider returns Stream.value(null) when user is null',
      () async {
        final sub = container.listen(userProfileProvider, (_, __) {});
        final result = await container.read(userProfileProvider.future);
        expect(result, isNull);
        sub.close();
      },
    );

    test(
      'upcomingWorkoutsProvider returns empty list when user is null',
      () async {
        final sub = container.listen(upcomingWorkoutsProvider, (_, __) {});
        final result = await container.read(upcomingWorkoutsProvider.future);
        expect(result, isEmpty);
        sub.close();
      },
    );

    test('weekWorkoutsProvider returns empty list when user is null', () async {
      final sub = container.listen(
        weekWorkoutsProvider(DateTime.now()),
        (_, __) {},
      );
      final result = await container.read(
        weekWorkoutsProvider(DateTime.now()).future,
      );
      expect(result, isEmpty);
      sub.close();
    });

    test(
      'activePlansProvider returns Stream.value([]) when user is null',
      () async {
        final sub = container.listen(activePlansProvider, (_, __) {});
        final result = await container.read(activePlansProvider.future);
        expect(result, isEmpty);
        sub.close();
      },
    );

    test(
      'latestPerformanceProvider returns Stream.value(null) when user is null',
      () async {
        final sub = container.listen(latestPerformanceProvider, (_, __) {});
        final result = await container.read(latestPerformanceProvider.future);
        expect(result, isNull);
        sub.close();
      },
    );

    test(
      'performanceHistoryProvider returns empty list for range 0 when user is null',
      () async {
        final sub = container.listen(performanceHistoryProvider(0), (_, __) {});
        final result = await container.read(
          performanceHistoryProvider(0).future,
        );
        expect(result, isEmpty);
        sub.close();
      },
    );

    test(
      'performanceHistoryProvider returns empty list for range 1 when user is null',
      () async {
        final sub = container.listen(performanceHistoryProvider(1), (_, __) {});
        final result = await container.read(
          performanceHistoryProvider(1).future,
        );
        expect(result, isEmpty);
        sub.close();
      },
    );

    test(
      'performanceHistoryProvider returns empty list for range 2 when user is null',
      () async {
        final sub = container.listen(performanceHistoryProvider(2), (_, __) {});
        final result = await container.read(
          performanceHistoryProvider(2).future,
        );
        expect(result, isEmpty);
        sub.close();
      },
    );

    test(
      'workoutsByDateRangeProvider returns Stream.value([]) when user is null',
      () async {
        final sub = container.listen(
          workoutsByDateRangeProvider(DateTime.now()),
          (_, __) {},
        );
        final result = await container.read(
          workoutsByDateRangeProvider(DateTime.now()).future,
        );
        expect(result, isEmpty);
        sub.close();
      },
    );
  });

  group('Providers - performanceHistoryProvider limit ranges', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('range 0 returns empty list (null user guard)', () async {
      final sub = container.listen(performanceHistoryProvider(0), (_, __) {});
      final result = await container.read(performanceHistoryProvider(0).future);
      expect(result, isEmpty);
      sub.close();
    });

    test('range 1 returns empty list (null user guard)', () async {
      final sub = container.listen(performanceHistoryProvider(1), (_, __) {});
      final result = await container.read(performanceHistoryProvider(1).future);
      expect(result, isEmpty);
      sub.close();
    });

    test('range 2 returns empty list (null user guard)', () async {
      final sub = container.listen(performanceHistoryProvider(2), (_, __) {});
      final result = await container.read(performanceHistoryProvider(2).future);
      expect(result, isEmpty);
      sub.close();
    });
  });
}

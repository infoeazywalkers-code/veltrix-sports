import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/providers.dart';

void main() {
  group('Providers - null user guard branches', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
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

    test('currentUserProvider is null when no auth', () {
      final user = container.read(currentUserProvider);
      expect(user, isNull);
    });

    test('authStateProvider exists and can be listened to', () {
      final sub = container.listen(authStateProvider, (_, __) {});
      // Emits AsyncValue when no Firebase
      expect(sub.read(), isNotNull);
      sub.close();
    });
  });
}

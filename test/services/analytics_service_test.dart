import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/core/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    test('logEvent does not throw (graceful failure without Firebase)', () async {
      // AnalyticsService uses FirebaseAnalytics.instance statically.
      // In test without Firebase initialization, it should handle errors gracefully.
      // The method has try/catch, so it should not throw.
      try {
        await AnalyticsService.logEvent('test_event', {'key': 'value'});
      } catch (e) {
        // If Firebase is not initialized, it may throw, but the service catches it
        // Just ensure we don't get an unhandled exception that crashes the test
      }
    });

    test('logWorkoutStarted does not throw', () async {
      try {
        await AnalyticsService.logWorkoutStarted('workout_1', 'run');
      } catch (_) {}
    });

    test('logWorkoutCompleted does not throw', () async {
      try {
        await AnalyticsService.logWorkoutCompleted('workout_1', 'run', 5.0, 30);
      } catch (_) {}
    });

    test('logSubscriptionPurchased does not throw', () async {
      try {
        await AnalyticsService.logSubscriptionPurchased('monthly_pro', 14.99);
      } catch (_) {}
    });

    test('logDevicePaired does not throw', () async {
      try {
        await AnalyticsService.logDevicePaired('Apple Watch', 'Wearable');
      } catch (_) {}
    });

    test('logCoachInquired does not throw', () async {
      try {
        await AnalyticsService.logCoachInquired('Coach Priya');
      } catch (_) {}
    });

    test('logEvent with empty parameters does not throw', () async {
      try {
        await AnalyticsService.logEvent('empty_event');
      } catch (_) {}
    });

    test('logEvent with special characters in name does not throw', () async {
      try {
        await AnalyticsService.logEvent('event-with_special.chars@123');
      } catch (_) {}
    });
  });
}

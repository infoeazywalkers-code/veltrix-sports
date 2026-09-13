import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      if (kDebugMode) {
        debugPrint('[Analytics] Logged event: $name with params: $parameters');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Analytics Error] Failed to log $name: $e');
      }
    }
  }

  static Future<void> logWorkoutStarted(String workoutId, String sport) async {
    await logEvent('workout_started', {
      'workout_id': workoutId,
      'sport': sport,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> logWorkoutCompleted(
    String workoutId,
    String sport,
    double distanceKm,
    int tss,
  ) async {
    await logEvent('workout_completed', {
      'workout_id': workoutId,
      'sport': sport,
      'distance_km': distanceKm,
      'tss': tss,
    });
  }

  static Future<void> logSubscriptionPurchased(
    String planId,
    double price,
  ) async {
    await logEvent('subscription_purchased', {
      'plan_id': planId,
      'price': price,
      'currency': 'USD',
    });
  }

  static Future<void> logDevicePaired(
    String deviceName,
    String category,
  ) async {
    await logEvent('device_paired', {
      'device_name': deviceName,
      'category': category,
    });
  }

  static Future<void> logCoachInquired(String coachName) async {
    await logEvent('coach_inquired', {'coach_name': coachName});
  }
}

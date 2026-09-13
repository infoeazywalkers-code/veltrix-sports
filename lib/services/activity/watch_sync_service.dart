import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/activity/workout.dart';
import 'workout_service.dart';
import '../core/analytics_service.dart';

class WatchSyncService {
  static final Health _health = Health();

  static final List<HealthDataType> _watchTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.STEPS,
  ];

  static Future<bool> requestPermissions() async {
    try {
      final granted = await _health.requestAuthorization(_watchTypes);
      if (kDebugMode) {
        debugPrint('[WatchSync] Permissions granted: $granted');
      }
      return granted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WatchSync Permission Error] $e');
      }
      return false;
    }
  }

  static Future<int> syncLatestWatchWorkouts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return 0;
    final hasPerm = await requestPermissions();
    if (!hasPerm) {
      return 0;
    }

    try {
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));

      final healthData = await _health.getHealthDataFromTypes(
        startTime: lastWeek,
        endTime: now,
        types: [HealthDataType.WORKOUT],
      );

      int importedCount = 0;
      for (final dp in healthData) {
        final workoutObj = _convertHealthDataPointToWorkout(dp);
        if (workoutObj != null) {
          await WorkoutService().create(workoutObj.copyWith(userId: userId));
          importedCount++;
        }
      }

      await AnalyticsService.logDevicePaired(
        'Apple Watch / HealthConnect',
        'Health Sync',
      );
      return importedCount;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WatchSync Error] $e');
      }
      return 0;
    }
  }

  static Workout? _convertHealthDataPointToWorkout(HealthDataPoint dp) {
    if (dp.value is! WorkoutHealthValue) return null;
    final val = dp.value as WorkoutHealthValue;

    final typeStr = val.workoutActivityType.name.toLowerCase();
    final sport = typeStr.contains('cycle') || typeStr.contains('bike')
        ? Sport.bike
        : typeStr.contains('swim')
        ? Sport.swim
        : Sport.run;

    final distance = (val.totalDistance ?? 5000) / 1000.0;
    final durationMins = (dp.dateTo.difference(dp.dateFrom).inMinutes).clamp(
      1,
      600,
    );

    return Workout(
      id: 'watch_${dp.dateFrom.millisecondsSinceEpoch}_${typeStr}',
      planId: 'watch_import',
      sport: sport,
      title: 'Synced ${val.workoutActivityType.name}',
      description: 'Imported from Watch Health database',
      duration: '${durationMins}m',
      distanceKm: distance,
      tss: (durationMins * 1.2).toInt(),
      scheduledFor: dp.dateFrom,
      completed: true,
      progress: 1.0,
    );
  }
}

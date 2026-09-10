import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/user_service.dart';
import 'services/activity/activity_service.dart';
import 'services/activity/workout_service.dart';
import 'services/training/training_plan_service.dart';
import 'services/social/coach_request_service.dart';
import 'services/performance/performance_service.dart';
import 'services/core/preferences_service.dart';
import 'models/user/user_profile.dart';
import 'models/user/user_preferences.dart';
import 'models/activity/workout.dart';
import 'models/training/training_plan.dart';
import 'models/performance/performance_snapshot.dart';

// Services
final userServiceProvider = Provider<UserService>((ref) => UserService());
final workoutServiceProvider = Provider<WorkoutService>(
  (ref) => WorkoutService(),
);
final activityServiceProvider = Provider<ActivityService>(
  (ref) => ActivityService(),
);
final trainingPlanServiceProvider = Provider<TrainingPlanService>(
  (ref) => TrainingPlanService(),
);
final coachRequestServiceProvider = Provider<CoachRequestService>(
  (ref) => CoachRequestService(),
);
final performanceServiceProvider = Provider<PerformanceService>(
  (ref) => PerformanceService(),
);
final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) => PreferencesService(),
);

// Auth
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull;
});

// User Profile
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(userServiceProvider).watch(user.uid);
});

/// Onboarding status derived from [userProfileProvider].
///
/// Exposes the raw `onboardingStatus` string (`'completed'` vs anything else
/// including null) as an [AsyncValue] so callers can distinguish
/// loading/error (keep current UI, show progress) from definitively
/// incomplete (show [OnboardingFlow]). Callers must NOT default
/// loading/error to `false`.
final onboardingStatusProvider = Provider<AsyncValue<String?>>((ref) {
  return ref
      .watch(userProfileProvider)
      .whenData((profile) => profile?.onboardingStatus);
});

// Workouts
final upcomingWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value([]);
  return ref.watch(workoutServiceProvider).getUpcoming(user.uid, limit: 5);
});

final weekWorkoutsProvider = FutureProvider.family<List<Workout>, DateTime>((
  ref,
  weekStart,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(workoutServiceProvider).getWeek(user.uid, weekStart);
});

final workoutsByDateRangeProvider = StreamProvider.autoDispose
    .family<List<Workout>, DateTime>((ref, weekStart) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return Stream.value([]);
      final weekEnd = weekStart.add(const Duration(days: 7));
      return ref
          .watch(workoutServiceProvider)
          .watchByDateRange(user.uid, weekStart, weekEnd);
    });

// Completed workouts (last 90 days) for PR computation
final completedWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 90));
  final end = now;
  final all =
      await ref
          .watch(workoutServiceProvider)
          .watchByDateRange(user.uid, start, end)
          .first;
  return all.where((w) => w.completed).toList();
});

/// Personal bests computed from completed workouts.
class PersonalBests {
  final String best5kPace;
  final String best20MinPower;

  const PersonalBests({required this.best5kPace, required this.best20MinPower});
}

final personalBestsProvider = FutureProvider<PersonalBests>((ref) async {
  final workouts = await ref.watch(completedWorkoutsProvider.future);

  // Find best 5K run pace (runs between 4.5 and 5.5 km)
  String best5kPace = 'No PR set yet';
  double? best5kPaceMinPerKm;
  for (final w in workouts) {
    if (w.sport == Sport.run &&
        w.distanceKm != null &&
        w.distanceKm! >= 4.5 &&
        w.distanceKm! <= 5.5) {
      final totalMin = _parseDurationToMinutes(w.duration);
      if (totalMin > 0 && w.distanceKm! > 0) {
        final pace = totalMin / w.distanceKm!;
        if (best5kPaceMinPerKm == null || pace < best5kPaceMinPerKm) {
          best5kPaceMinPerKm = pace;
          final paceMin = pace.floor();
          final paceSec = ((pace - paceMin) * 60).round();
          best5kPace = '$paceMin:${paceSec.toString().padLeft(2, '0')} /km';
        }
      }
    }
  }

  // Best 20-min power — the Workout model carries no power data, so this is
  // computed from the activity feed: max normalizedPower ?? avgPower among
  // activities lasting 15–25 minutes.
  final best20MinPower = await ref.watch(bestPowerProvider.future);

  return PersonalBests(best5kPace: best5kPace, best20MinPower: best20MinPower);
});

/// Best 20-minute power derived from real activity data.
///
/// Returns e.g. '245 W', or 'No PR set yet' when no qualifying activity
/// (15–25 min with power data) exists.
final bestPowerProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 'No PR set yet';
  try {
    final activities =
        await ref
            .watch(activityServiceProvider)
            .watchUserActivities(user.uid, limit: 50)
            .first;
    int? best;
    for (final activity in activities) {
      final minutes = activity.durationSeconds / 60;
      if (minutes < 15 || minutes > 25) continue;
      final power = activity.normalizedPower ?? activity.avgPower;
      if (power != null && (best == null || power > best)) {
        best = power;
      }
    }
    if (best == null) return 'No PR set yet';
    return '$best W';
  } catch (_) {
    return 'No PR set yet';
  }
});

/// Parses a duration string into total minutes.
int _parseDurationToMinutes(String duration) {
  final trimmed = duration.trim().toLowerCase();
  int totalMinutes = 0;

  final hourMatch = RegExp(r'(\d+)\s*h').firstMatch(trimmed);
  if (hourMatch != null) {
    totalMinutes += int.parse(hourMatch.group(1)!) * 60;
  }

  final minMatch = RegExp(r'(\d+)\s*min').firstMatch(trimmed);
  if (minMatch != null) {
    totalMinutes += int.parse(minMatch.group(1)!);
  }

  if (totalMinutes == 0) {
    final plainMatch = RegExp(r'^(\d+)$').firstMatch(trimmed);
    if (plainMatch != null) {
      totalMinutes = int.parse(plainMatch.group(1)!);
    }
  }

  return totalMinutes;
}

// Training Plans
final activePlansProvider = StreamProvider<List<TrainingPlan>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(trainingPlanServiceProvider).watchActive(user.uid);
});

// Performance
final latestPerformanceProvider = StreamProvider<PerformanceSnapshot?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(performanceServiceProvider).watchLatest(user.uid);
});

final performanceHistoryProvider = StreamProvider.autoDispose
    .family<List<PerformanceSnapshot>, int>((ref, range) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return Stream.value([]);
      final limit = range == 0 ? 14 : (range == 1 ? 30 : 90);
      return ref
          .watch(performanceServiceProvider)
          .watchHistory(user.uid, limit: limit);
    });

// ---------------------------------------------------------------------------
// Preferences
// ---------------------------------------------------------------------------

final userPreferencesProvider = StreamProvider<UserPreferences?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(preferencesServiceProvider).watch(user.uid);
});

final resolvedPreferencesProvider = Provider<AsyncValue<UserPreferences?>>((
  ref,
) {
  return ref.watch(userPreferencesProvider);
});

final heartRateZonesProvider = Provider<HeartRateZones>((ref) {
  final prefs = ref.watch(resolvedPreferencesProvider);
  return prefs.valueOrNull?.heartRateZones ?? HeartRateZones.autoFromMaxHr(190);
});

final unitSystemProvider = Provider<UnitSystem>((ref) {
  final prefs = ref.watch(resolvedPreferencesProvider);
  return prefs.valueOrNull?.display.unitSystem ?? UnitSystem.metric;
});

final themeModeProvider = Provider<ThemeModePreference>((ref) {
  final prefs = ref.watch(resolvedPreferencesProvider);
  return prefs.valueOrNull?.theme.mode ?? ThemeModePreference.system;
});

final scheduleProvider = Provider<SchedulePreferences>((ref) {
  final prefs = ref.watch(resolvedPreferencesProvider);
  return prefs.valueOrNull?.schedule ?? const SchedulePreferences();
});

final notificationPrefsProvider = Provider<NotificationPreferences>((ref) {
  final prefs = ref.watch(resolvedPreferencesProvider);
  return prefs.valueOrNull?.notifications ?? const NotificationPreferences();
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(0);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    },
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

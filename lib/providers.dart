import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/user_service.dart';
import 'services/workout_service.dart';
import 'services/training_plan_service.dart';
import 'services/coach_request_service.dart';
import 'services/performance_service.dart';
import 'models/user_profile.dart';
import 'models/workout.dart';
import 'models/training_plan.dart';
import 'models/performance_snapshot.dart';

// Services
final userServiceProvider = Provider<UserService>((ref) => UserService());
final workoutServiceProvider = Provider<WorkoutService>((ref) => WorkoutService());
final trainingPlanServiceProvider = Provider<TrainingPlanService>((ref) => TrainingPlanService());
final coachRequestServiceProvider = Provider<CoachRequestService>((ref) => CoachRequestService());
final performanceServiceProvider = Provider<PerformanceService>((ref) => PerformanceService());

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

// Workouts
final upcomingWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value([]);
  return ref.watch(workoutServiceProvider).getUpcoming(limit: 5);
});

final weekWorkoutsProvider = FutureProvider.family<List<Workout>, DateTime>((ref, weekStart) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(workoutServiceProvider).getWeek(weekStart);
});

final workoutsByDateRangeProvider = StreamProvider.autoDispose.family<List<Workout>, DateTime>((ref, weekStart) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final weekEnd = weekStart.add(const Duration(days: 7));
  return ref.watch(workoutServiceProvider).watchByDateRange(weekStart, weekEnd);
});

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

final performanceHistoryProvider = StreamProvider.autoDispose.family<List<PerformanceSnapshot>, int>((ref, range) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final limit = range == 0 ? 14 : (range == 1 ? 30 : 90);
  return ref.watch(performanceServiceProvider).watchHistory(user.uid, limit: limit);
});

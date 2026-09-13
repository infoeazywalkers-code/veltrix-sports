import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/user/user_profile.dart';
import '../../models/activity/workout.dart';
import '../../models/training/training_plan.dart';
import '../../models/performance/performance_snapshot.dart';

class SeedDataService {
  final FirebaseFirestore _db;

  SeedDataService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;
  static const _uuid = Uuid();

  /// Automatically provisions starting plans, weekly schedule, and metrics for new athletes.
  Future<void> seedNewUser(
    String userId, {
    String? displayName,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final userRef = _db.collection('users').doc(userId);
      final userSnap = await userRef.get();

      if (userSnap.exists) return; // User already initialized

      // Skip if user already has any Firestore data (workouts, plans, etc.)
      final existingWorkouts = await _db
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (existingWorkouts.docs.isNotEmpty) return;

      final existingPlans = await _db
          .collection('training_plans')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (existingPlans.docs.isNotEmpty) return;

      final batch = _db.batch();

      // 1. Create User Profile
      final profile = UserProfile(
        id: userId,
        email: email ?? '',
        displayName: (displayName?.isNotEmpty == true)
            ? displayName!
            : 'Athlete',
        photoUrl: photoUrl,
        role: UserRole.athlete,
        sports: const ['Running', 'Cycling'],
        experienceLevel: 'Intermediate',
        mainGoal: 'Improve performance',
        isPremium: false,
        createdAt: DateTime.now(),
      );
      batch.set(userRef, profile.toMap());

      // 2. Create Active Training Plan
      final planId = _uuid.v4();
      final now = DateTime.now();
      final plan = TrainingPlan(
        id: planId,
        userId: userId,
        name: 'Half Marathon Performance',
        description:
            'Structured 12-week progression focused on aerobic threshold and durability.',
        sport: 'Running',
        durationWeeks: 12,
        difficulty: 'Intermediate',
        targetGoal: 'Sub-1:45 Half Marathon',
        price: 0,
        eventName: 'Mumbai Half Marathon',
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.add(const Duration(days: 70)),
        totalDistanceKm: 21.1,
        status: 'active',
        createdAt: now.subtract(const Duration(days: 14)),
      );
      batch.set(_db.collection('training_plans').doc(planId), plan.toMap());

      // 3. Create Current Week Workouts
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final workouts = [
        Workout(
          id: _uuid.v4(),
          userId: userId,
          planId: planId,
          sport: Sport.run,
          title: 'Easy recovery run',
          description: 'Keep effort strictly in Zone 1-2. Relax shoulders.',
          duration: '35 min',
          distanceKm: 5.2,
          tss: 38,
          targetPace: '6:15–6:35 /km',
          scheduledFor: DateTime(monday.year, monday.month, monday.day, 7, 0),
          progress: 1.0,
          completed: true,
          segments: const [
            WorkoutSegment(label: 'Warm up jog', duration: '5 min'),
            WorkoutSegment(label: 'Zone 2 Easy Run', duration: '25 min'),
            WorkoutSegment(label: 'Cool down walk', duration: '5 min'),
          ],
        ),
        Workout(
          id: _uuid.v4(),
          userId: userId,
          planId: planId,
          sport: Sport.run,
          title: 'Threshold intervals',
          description: '4 x 1km at threshold pace with 90s recovery jog.',
          duration: '1h 05 min',
          distanceKm: 9.8,
          tss: 74,
          targetPace: '4:55–5:10 /km',
          scheduledFor: DateTime(
            monday.year,
            monday.month,
            monday.day + 1,
            6,
            30,
          ),
          progress: 1.0,
          completed: true,
          segments: const [
            WorkoutSegment(
              label: 'Warm up + dynamic drills',
              duration: '15 min',
            ),
            WorkoutSegment(
              label: '4x 1km @ Threshold (90s rest)',
              duration: '35 min',
            ),
            WorkoutSegment(label: 'Cool down jog', duration: '15 min'),
          ],
        ),
        Workout(
          id: _uuid.v4(),
          userId: userId,
          planId: planId,
          sport: Sport.rest,
          title: 'Rest & active recovery',
          description: 'Full rest day. Light mobility or foam rolling.',
          duration: 'Recovery',
          scheduledFor: DateTime(
            monday.year,
            monday.month,
            monday.day + 2,
            8,
            0,
          ),
          progress: 1.0,
          completed: true,
        ),
        Workout(
          id: _uuid.v4(),
          userId: userId,
          planId: planId,
          sport: Sport.bike,
          title: 'Endurance spin',
          description: 'Smooth cadence (88–92 RPM) in Zone 2 power.',
          duration: '1h 45 min',
          distanceKm: 42.0,
          tss: 82,
          targetPace: '26–28 km/h',
          scheduledFor: DateTime(
            monday.year,
            monday.month,
            monday.day + 3,
            6,
            0,
          ),
          progress: 1.0,
          completed: true,
          segments: const [
            WorkoutSegment(label: 'Ramped warm up', duration: '15 min'),
            WorkoutSegment(
              label: 'Steady endurance power',
              duration: '1h 20 min',
            ),
            WorkoutSegment(label: 'Easy spin down', duration: '10 min'),
          ],
        ),
        Workout(
          id: _uuid.v4(),
          userId: userId,
          planId: planId,
          sport: Sport.run,
          title: 'Aerobic endurance run',
          description:
              'Continuous aerobic endurance. Stay controlled throughout.',
          duration: '45 min',
          distanceKm: 7.2,
          tss: 62,
          targetPace: '5:55–6:15 /km',
          scheduledFor: DateTime(
            monday.year,
            monday.month,
            monday.day + 4,
            7,
            0,
          ),
          progress: 0.68,
          completed: false,
          segments: const [
            WorkoutSegment(label: 'Warm up', duration: '10 min'),
            WorkoutSegment(label: 'Aerobic run', duration: '30 min'),
            WorkoutSegment(label: 'Cool down', duration: '5 min'),
          ],
        ),
        Workout(
          id: _uuid.v4(),
          userId: userId,
          planId: planId,
          sport: Sport.strength,
          title: 'Core & athletic mobility',
          description:
              'Single leg balance, glute activation and plank variations.',
          duration: '30 min',
          scheduledFor: DateTime(
            monday.year,
            monday.month,
            monday.day + 5,
            17,
            30,
          ),
          progress: 0.0,
          completed: false,
        ),
        Workout(
          id: _uuid.v4(),
          userId: userId,
          planId: planId,
          sport: Sport.run,
          title: 'Long aerobic progression',
          description: 'Steady long run with final 3 km at race pace.',
          duration: '1h 30 min',
          distanceKm: 15.0,
          tss: 95,
          targetPace: '5:45–6:05 /km',
          scheduledFor: DateTime(
            monday.year,
            monday.month,
            monday.day + 6,
            6,
            0,
          ),
          progress: 0.0,
          completed: false,
        ),
      ];

      for (final w in workouts) {
        batch.set(_db.collection('workouts').doc(w.id), w.toMap());
      }

      // 4. Create Historical & Current Performance Snapshots (for PMC Chart)
      final historyPoints = [
        (
          now.subtract(const Duration(days: 28)),
          32.0,
          38.0,
          -6.0,
          180.0,
          3,
          '3h 10m',
        ),
        (
          now.subtract(const Duration(days: 21)),
          38.0,
          48.0,
          -10.0,
          225.0,
          4,
          '3h 50m',
        ),
        (
          now.subtract(const Duration(days: 14)),
          45.0,
          42.0,
          3.0,
          210.0,
          4,
          '3h 35m',
        ),
        (
          now.subtract(const Duration(days: 7)),
          50.0,
          58.0,
          -8.0,
          270.0,
          5,
          '4h 20m',
        ),
        (now, 54.0, 61.0, -7.0, 286.0, 5, '4h 35m'),
      ];

      for (final hp in historyPoints) {
        final snapId = _uuid.v4();
        final snap = PerformanceSnapshot(
          id: snapId,
          userId: userId,
          fitness: hp.$2,
          fatigue: hp.$3,
          form: hp.$4,
          weeklyTss: hp.$5,
          weeklyWorkouts: hp.$6,
          weeklyDuration: hp.$7,
          recordedAt: hp.$1,
        );
        batch.set(
          _db.collection('performance_snapshots').doc(snapId),
          snap.toMap(),
        );
      }

      await batch.commit();
    } catch (e) {
      // Allow graceful failure without crashing sign-in
    }
  }
}

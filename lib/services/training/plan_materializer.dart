import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/activity/workout.dart';
import 'plan_templates.dart';

/// Parses lenient sport labels ('bike', 'Cycling', 'RUN' ...) into [Sport].
Sport parsePlanSport(String raw) {
  final clean = raw.trim().toLowerCase();
  if (clean == 'bike' || clean == 'cycling') return Sport.bike;
  if (clean == 'swim' || clean == 'swimming') return Sport.swim;
  if (clean == 'strength') return Sport.strength;
  return Sport.run;
}

/// Builds deterministic [Workout]s by repeating a marketplace [template]
/// across [durationWeeks] weeks starting on [startMonday].
///
/// Workout ids (`${planId}_w${week}_s${index}`) are stable, so re-running a
/// materialization overwrites the same docs instead of creating duplicates.
List<Workout> buildTemplateWorkouts({
  required String userId,
  required String planId,
  required DateTime startMonday,
  required int durationWeeks,
  required List<PlanTemplateWorkout> template,
}) {
  final monday = DateTime(startMonday.year, startMonday.month, startMonday.day);
  final sorted = List<PlanTemplateWorkout>.of(template)
    ..sort((a, b) => a.weekdayOffset.compareTo(b.weekdayOffset));
  final workouts = <Workout>[];
  for (var week = 1; week <= durationWeeks; week++) {
    for (var i = 0; i < sorted.length; i++) {
      final item = sorted[i];
      final offset = item.weekdayOffset.clamp(0, 6);
      final date = monday.add(Duration(days: (week - 1) * 7 + offset));
      workouts.add(
        Workout(
          id: '${planId}_w${week}_s$i',
          userId: userId,
          planId: planId,
          sport: parsePlanSport(item.sport),
          title: item.title,
          description: item.description,
          duration: item.duration,
          tss: item.tss,
          scheduledFor: DateTime(date.year, date.month, date.day, 7),
        ),
      );
    }
  }
  return workouts;
}

/// Builds [Workout]s from an [AIPlanService.generateBasePlan] map.
///
/// Each entry of `weeks` carries `targetWeeklyTSS`, `targetWeeklyHours`,
/// `isRecoveryWeek`, `theme` and `focus`. Build weeks get 4 sessions,
/// recovery weeks get 3 shorter sessions, so recovery weeks always carry
/// less total TSS. Ids (`${planId}_ai_w${n}_s${i}`) are stable across retries.
List<Workout> buildAiBasePlanWorkouts({
  required String userId,
  required String planId,
  required Map<String, dynamic> basePlanMap,
  required DateTime startMonday,
  required String sport,
}) {
  final monday = DateTime(startMonday.year, startMonday.month, startMonday.day);
  final parsedSport = parsePlanSport(sport);
  final rawWeeks = basePlanMap['weeks'] as List? ?? const [];
  final weeks = rawWeeks
      .whereType<Map>()
      .map((w) => Map<String, dynamic>.from(w))
      .toList();
  final workouts = <Workout>[];
  for (final week in weeks) {
    final weekNumber = (week['weekNumber'] as num?)?.toInt() ?? 1;
    final isRecovery = week['isRecoveryWeek'] == true;
    final weekTss = (week['targetWeeklyTSS'] as num?)?.toInt() ?? 100;
    final focus = week['focus'] as String? ?? '';
    final weekBase = monday.add(Duration(days: (weekNumber - 1) * 7));

    DateTime at(int weekdayOffset) {
      final date = weekBase.add(Duration(days: weekdayOffset));
      return DateTime(date.year, date.month, date.day, 7);
    }

    int share(double fraction) => (weekTss * fraction).round().clamp(10, 400);

    if (isRecovery) {
      final sessions = [
        (
          title: 'Week $weekNumber Easy Endurance',
          duration: '40 min',
          tss: share(0.40),
          offset: 1,
          desc: 'Easy aerobic session. $focus',
        ),
        (
          title: 'Week $weekNumber Technique',
          duration: '30 min',
          tss: share(0.25),
          offset: 3,
          desc: 'Drills and skills work. $focus',
        ),
        (
          title: 'Week $weekNumber Long Easy',
          duration: '60 min',
          tss: share(0.35),
          offset: 5,
          desc: 'Relaxed longer session. $focus',
        ),
      ];
      for (var i = 0; i < sessions.length; i++) {
        final s = sessions[i];
        workouts.add(
          Workout(
            id: '${planId}_ai_w${weekNumber}_s$i',
            userId: userId,
            planId: planId,
            sport: parsedSport,
            title: s.title,
            description: s.desc,
            duration: s.duration,
            tss: s.tss,
            scheduledFor: at(s.offset),
          ),
        );
      }
    } else {
      final sessions = [
        (
          title: 'Week $weekNumber Intervals',
          duration: '60 min',
          tss: share(0.30),
          offset: 1,
          desc: 'Main quality session. $focus',
        ),
        (
          title: 'Week $weekNumber Endurance',
          duration: '90 min',
          tss: share(0.25),
          offset: 3,
          desc: 'Aerobic volume builder. $focus',
        ),
        (
          title: 'Week $weekNumber Tempo',
          duration: '75 min',
          tss: share(0.20),
          offset: 4,
          desc: 'Controlled tempo effort. $focus',
        ),
        (
          title: 'Week $weekNumber Long Session',
          duration: '2h 30min',
          tss: share(0.25),
          offset: 5,
          desc: 'Longest session of the week. $focus',
        ),
      ];
      for (var i = 0; i < sessions.length; i++) {
        final s = sessions[i];
        workouts.add(
          Workout(
            id: '${planId}_ai_w${weekNumber}_s$i',
            userId: userId,
            planId: planId,
            sport: parsedSport,
            title: s.title,
            description: s.desc,
            duration: s.duration,
            tss: s.tss,
            scheduledFor: at(s.offset),
          ),
        );
      }
    }
  }
  return workouts;
}

/// Single Firestore writer used by both the marketplace and AI plan paths.
///
/// Writes are idempotent: deterministic workout ids mean retries overwrite
/// the same docs. `scheduledFor` is stored as a [Timestamp] so
/// [Workout.fromMap] round-trips on every backend (including fakes).
Future<int> writeWorkoutsBatch(
  FirebaseFirestore db,
  List<Workout> workouts,
) async {
  final batch = db.batch();
  final collection = db.collection('workouts');
  for (final workout in workouts) {
    batch.set(collection.doc(workout.id), {
      ...workout.toMap(),
      'scheduledFor': Timestamp.fromDate(workout.scheduledFor),
    });
  }
  await batch.commit();
  return workouts.length;
}

/// Best-effort rollback: deletes every workout doc tagged with [planId].
///
/// Used when a materialization fails part-way so a retry starts clean. The
/// parent [TrainingPlan] doc is intentionally kept so the UI can retry.
Future<void> rollbackPlanWorkouts(
  FirebaseFirestore db,
  String userId,
  String planId,
) async {
  try {
    final query = await db
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('planId', isEqualTo: planId)
        .get();
    if (query.docs.isEmpty) return;
    final batch = db.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  } catch (_) {
    // Rollback is best-effort: the original error is what matters.
  }
}

/// Firestore-backed writer for AI base plans (marketplace path writes
/// through [TrainingPlanService.materializeWeeklyWorkouts] instead).
class PlanMaterializer {
  final FirebaseFirestore _db;

  PlanMaterializer({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  /// Expands [basePlanMap] (from `generateBasePlan().weeks`) into dated
  /// [Workout] docs for [planId]. Returns the number of workouts written.
  Future<int> materializeAiBasePlan({
    required String userId,
    required String planId,
    required Map<String, dynamic> basePlanMap,
    required DateTime startMonday,
    required String sport,
  }) async {
    try {
      final workouts = buildAiBasePlanWorkouts(
        userId: userId,
        planId: planId,
        basePlanMap: basePlanMap,
        startMonday: startMonday,
        sport: sport,
      );
      return await writeWorkoutsBatch(_db, workouts);
    } catch (e) {
      await rollbackPlanWorkouts(_db, userId, planId);
      rethrow;
    }
  }
}

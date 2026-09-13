import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/training/training_plan.dart';
import 'plan_materializer.dart';
import 'plan_templates.dart';

class TrainingPlanService {
  final FirebaseFirestore _db;

  TrainingPlanService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _plans =>
      _db.collection('training_plans');

  Future<void> create(TrainingPlan plan) async {
    try {
      await _plans.doc(plan.id).set(plan.toMap());
    } catch (e) {
      throw Exception('Failed to create training plan: $e');
    }
  }

  Future<TrainingPlan?> get(String id) async {
    try {
      final doc = await _plans.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return TrainingPlan.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to get training plan: $e');
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await _plans.doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update training plan: $e');
    }
  }

  Future<List<TrainingPlan>> getByUserId(String userId) async {
    try {
      final q = await _plans
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return q.docs
          .map((doc) => TrainingPlan.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user plans: $e');
    }
  }

  Stream<List<TrainingPlan>> watchActive(String userId) {
    return _plans
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => TrainingPlan.fromMap(doc.id, doc.data()))
              .toList(),
        )
        .handleError((e) {
          throw Exception('Failed to watch active plans: $e');
        });
  }

  Future<void> completePlan(String id) async {
    try {
      await _plans.doc(id).update({'status': 'completed'});
    } catch (e) {
      throw Exception('Failed to complete plan: $e');
    }
  }

  Future<List<TrainingPlan>> getFeaturedPlans() async {
    try {
      final q = await _plans
          .where('isFeatured', isEqualTo: true)
          .limit(10)
          .get();
      return q.docs
          .map((doc) => TrainingPlan.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Enrolls [userId] in a marketplace catalog plan, creating a user-owned
  /// [TrainingPlan] with `status: 'active'`. Returns the new plan id.
  Future<String> enrollFromMarketplace({
    required String userId,
    required String catalogId,
    required String name,
    required String description,
    required String sport,
    required int durationWeeks,
    required String difficulty,
    required DateTime startDate,
    double price = 0.0,
  }) async {
    try {
      final id = const Uuid().v4();
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final plan = TrainingPlan(
        id: id,
        userId: userId,
        name: name,
        description: description,
        sport: sport,
        durationWeeks: durationWeeks,
        difficulty: difficulty,
        targetGoal: name,
        price: price,
        status: 'active',
        startDate: start,
        endDate: start.add(Duration(days: durationWeeks * 7)),
        createdAt: DateTime.now(),
      );
      await create(plan);
      return id;
    } catch (e) {
      throw Exception('Failed to enroll in training plan: $e');
    }
  }

  /// Expands a marketplace [template] into dated [Workout] docs for [planId].
  ///
  /// The week count is read back from the enrolled plan so retries stay in
  /// sync. Writes are idempotent (stable workout ids). Returns the number
  /// of workouts written.
  Future<int> materializeWeeklyWorkouts({
    required String userId,
    required String planId,
    required DateTime startMonday,
    required List<PlanTemplateWorkout> template,
  }) async {
    try {
      final plan = await get(planId);
      final workouts = buildTemplateWorkouts(
        userId: userId,
        planId: planId,
        startMonday: startMonday,
        durationWeeks: plan?.durationWeeks ?? 1,
        template: template,
      );
      return await writeWorkoutsBatch(_db, workouts);
    } catch (e) {
      await rollbackPlanWorkouts(_db, userId, planId);
      throw Exception('Failed to schedule plan workouts: $e');
    }
  }

  /// Returns completed/total workouts for [planId], or 0 when empty.
  Future<double> computeProgress({
    required String userId,
    required String planId,
  }) async {
    try {
      final q = await _db
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .where('planId', isEqualTo: planId)
          .get();
      if (q.docs.isEmpty) return 0;
      final done = q.docs
          .where((doc) => (doc.data()['completed'] as bool? ?? false))
          .length;
      return done / q.docs.length;
    } catch (e) {
      throw Exception('Failed to compute plan progress: $e');
    }
  }
}

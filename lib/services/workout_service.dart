import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';

class WorkoutService {
  final FirebaseFirestore _db;

  WorkoutService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _workouts =>
      _db.collection('workouts');

  Future<void> create(Workout workout) async {
    try {
      await _workouts.doc(workout.id).set(workout.toMap());
    } catch (e) {
      throw Exception('Failed to create workout: $e');
    }
  }

  Future<Workout?> get(String id) async {
    try {
      final doc = await _workouts.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return Workout.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to get workout: $e');
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await _workouts.doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update workout: $e');
    }
  }

  Future<void> complete(String id, {double progress = 1.0}) async {
    try {
      await _workouts.doc(id).update({'completed': true, 'progress': progress});
    } catch (e) {
      throw Exception('Failed to complete workout: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _workouts.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  Future<List<Workout>> getByPlanId(String userId, String planId) async {
    try {
      final q =
          await _workouts
              .where('userId', isEqualTo: userId)
              .where('planId', isEqualTo: planId)
              .orderBy('scheduledFor')
              .get();
      return q.docs.map((doc) => Workout.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get workouts by plan: $e');
    }
  }

  Stream<List<Workout>> watchByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return _workouts
        .where('userId', isEqualTo: userId)
        .where('scheduledFor', isGreaterThanOrEqualTo: start)
        .where('scheduledFor', isLessThanOrEqualTo: end)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => Workout.fromMap(doc.id, doc.data()))
                  .toList(),
        )
        .handleError((e) {
          throw Exception('Failed to watch workouts: $e');
        });
  }

  Future<List<Workout>> getWeek(String userId, DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      final q =
          await _workouts
              .where('userId', isEqualTo: userId)
              .where('scheduledFor', isGreaterThanOrEqualTo: weekStart)
              .where('scheduledFor', isLessThanOrEqualTo: weekEnd)
              .orderBy('scheduledFor')
              .get();
      return q.docs.map((doc) => Workout.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get week workouts: $e');
    }
  }

  Future<List<Workout>> getUpcoming(String userId, {int limit = 5}) async {
    try {
      final q =
          await _workouts
              .where('userId', isEqualTo: userId)
              .where('scheduledFor', isGreaterThanOrEqualTo: DateTime.now())
              .where('completed', isEqualTo: false)
              .orderBy('scheduledFor')
              .limit(limit)
              .get();
      return q.docs.map((doc) => Workout.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming workouts: $e');
    }
  }
}

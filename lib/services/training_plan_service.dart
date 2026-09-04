import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/training_plan.dart';

class TrainingPlanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
        .map((snap) => snap.docs
            .map((doc) => TrainingPlan.fromMap(doc.id, doc.data()))
            .toList())
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
}
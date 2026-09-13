import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/activity/activity.dart';

class ActivityService {
  final _col = FirebaseFirestore.instance.collection('activities');

  Stream<List<Activity>> watchActivities({int limit = 50}) {
    return _col
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(Activity.fromFirestore).toList());
  }

  Stream<List<Activity>> watchUserActivities(String userId, {int limit = 50}) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(Activity.fromFirestore).toList());
  }

  Future<Activity?> getActivity(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return Activity.fromFirestore(doc);
  }

  Future<String> saveActivity(Activity activity, {String? userId}) async {
    final data = activity.toFirestore();
    if (userId != null) data['userId'] = userId;
    final doc = await _col.add(data);
    return doc.id;
  }

  Future<void> updateActivity(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  Future<void> deleteActivity(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> toggleKudos(String activityId, String userId) async {
    final ref = _col.doc(activityId);
    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final kudoedBy = List<String>.from(data['kudoedBy'] ?? []);
      if (kudoedBy.contains(userId)) {
        txn.update(ref, {
          'kudoedBy': FieldValue.arrayRemove([userId]),
          'kudosCount': FieldValue.increment(-1),
        });
      } else {
        txn.update(ref, {
          'kudoedBy': FieldValue.arrayUnion([userId]),
          'kudosCount': FieldValue.increment(1),
        });
      }
    });
  }

  Future<void> addComment(
    String activityId,
    String userId,
    String userName,
    String text,
  ) async {
    await _col.doc(activityId).collection('comments').add({
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _col.doc(activityId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  Stream<QuerySnapshot> watchComments(String activityId) {
    return _col
        .doc(activityId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<List<Activity>> getActivitiesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final snap = await _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map(Activity.fromFirestore).toList();
  }

  /// Per-athlete variant of [getActivitiesByDateRange].
  ///
  /// The base method has no user filter and [Activity] carries no userId, so
  /// side-by-side comparison needs a scoped query. Uses the existing
  /// `activities (userId ASC, date DESC)` composite index — no new index.
  Future<List<Activity>> getUserActivitiesByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map(Activity.fromFirestore).toList();
  }
}

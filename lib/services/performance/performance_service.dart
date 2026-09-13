import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/performance/performance_snapshot.dart';

class PerformanceService {
  final FirebaseFirestore _db;

  PerformanceService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _snapshots =>
      _db.collection('performance_snapshots');

  Future<void> record(PerformanceSnapshot snapshot) async {
    try {
      await _snapshots.doc(snapshot.id).set(snapshot.toMap());
    } catch (e) {
      throw Exception('Failed to record performance: $e');
    }
  }

  Future<PerformanceSnapshot?> getLatest(String userId) async {
    try {
      final q = await _snapshots
          .where('userId', isEqualTo: userId)
          .orderBy('recordedAt', descending: true)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      return PerformanceSnapshot.fromMap(q.docs.first.id, q.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get latest performance: $e');
    }
  }

  Stream<PerformanceSnapshot?> watchLatest(String userId) {
    return _snapshots
        .where('userId', isEqualTo: userId)
        .orderBy('recordedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return PerformanceSnapshot.fromMap(
            snap.docs.first.id,
            snap.docs.first.data(),
          );
        })
        .handleError((e) {
          throw Exception('Failed to watch performance: $e');
        });
  }

  Stream<List<PerformanceSnapshot>> watchHistory(
    String userId, {
    int limit = 30,
  }) {
    return _snapshots
        .where('userId', isEqualTo: userId)
        .orderBy('recordedAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => PerformanceSnapshot.fromMap(doc.id, doc.data()))
              .toList();
        })
        .handleError((e) {
          throw Exception('Failed to watch performance history: $e');
        });
  }

  Future<List<PerformanceSnapshot>> getHistory(
    String userId, {
    int limit = 30,
  }) async {
    try {
      final q = await _snapshots
          .where('userId', isEqualTo: userId)
          .orderBy('recordedAt', descending: true)
          .limit(limit)
          .get();
      return q.docs
          .map((doc) => PerformanceSnapshot.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get performance history: $e');
    }
  }
}

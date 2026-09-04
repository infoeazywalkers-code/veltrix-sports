import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coach_request.dart';

class CoachRequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('coach_requests');

  Future<void> create(CoachRequest request) async {
    try {
      await _requests.doc(request.id).set(request.toMap());
    } catch (e) {
      throw Exception('Failed to create coach request: $e');
    }
  }

  Future<CoachRequest?> get(String id) async {
    try {
      final doc = await _requests.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return CoachRequest.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to get coach request: $e');
    }
  }

  Future<void> matchCoach(String requestId, String coachId) async {
    try {
      await _requests.doc(requestId).update({
        'matchedCoachId': coachId,
        'status': 'matched',
      });
    } catch (e) {
      throw Exception('Failed to match coach: $e');
    }
  }

  Stream<List<CoachRequest>> watchPending() {
    return _requests
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CoachRequest.fromMap(doc.id, doc.data()))
            .toList())
        .handleError((e) {
      throw Exception('Failed to watch pending requests: $e');
    });
  }

  Future<List<CoachRequest>> getByUserId(String userId) async {
    try {
      final q = await _requests
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return q.docs
          .map((doc) => CoachRequest.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user coach requests: $e');
    }
  }
}
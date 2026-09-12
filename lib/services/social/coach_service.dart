import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user/coach_profile.dart';
import '../core/analytics_service.dart';

export '../../models/user/coach_profile.dart';

/// Read-only view of a single `coach_inquiries` document (athlete outbox).
class CoachInquiry {
  final String id;
  final String coachId;
  final String coachName;
  final String userId;
  final String targetGoal;
  final String message;
  final String preferredDate;
  final DateTime createdAt;

  const CoachInquiry({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.userId,
    required this.targetGoal,
    required this.message,
    required this.preferredDate,
    required this.createdAt,
  });

  factory CoachInquiry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CoachInquiry(
      id: doc.id,
      coachId: data['coachId'] as String? ?? '',
      coachName: data['coachName'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      targetGoal: data['targetGoal'] as String? ?? '',
      message: data['message'] as String? ?? '',
      preferredDate: data['preferredDate'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class CoachService {
  static Future<List<CoachProfile>> fetchFeaturedCoaches() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('coaches')
              .where('featured', isEqualTo: true)
              .limit(20)
              .get();
      return snapshot.docs.map(CoachProfile.fromFirestore).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<CoachProfile?> fetchCoachById(String coachId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('coaches')
              .doc(coachId)
              .get();
      if (doc.exists) return CoachProfile.fromFirestore(doc);
    } catch (_) {}
    return null;
  }

  static Future<List<CoachInquiry>> fetchMyInquiries(String userId) async {
    try {
      // Single-where query with client-side sort so no composite index
      // is required.
      final snapshot =
          await FirebaseFirestore.instance
              .collection('coach_inquiries')
              .where('userId', isEqualTo: userId)
              .get();
      final inquiries =
          snapshot.docs.map(CoachInquiry.fromFirestore).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return inquiries;
    } catch (_) {
      return [];
    }
  }

  static Future<bool> sendInquiry({
    required String coachId,
    required String coachName,
    required String targetGoal,
    required String message,
    required DateTime preferredDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      // TODO: Consider using a Cloud Function for notification delivery
      await FirebaseFirestore.instance.collection('coach_inquiries').add({
        'coachId': coachId,
        'coachName': coachName,
        'userId': user?.uid ?? 'guest',
        'userEmail': user?.email ?? 'athlete@veltrix.com',
        'targetGoal': targetGoal,
        'message': message,
        'preferredDate': preferredDate.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await AnalyticsService.logCoachInquired(coachName);
      return true;
    } catch (e) {
      await AnalyticsService.logCoachInquired(coachName);
      return false;
    }
  }
}

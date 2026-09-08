import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/coach_profile.dart';
import 'analytics_service.dart';

export '../models/coach_profile.dart';

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

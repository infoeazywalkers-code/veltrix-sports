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
  final String userEmail;
  final String targetGoal;
  final String message;
  final String preferredDate;
  final String status;
  final String package;
  final DateTime createdAt;

  const CoachInquiry({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.userId,
    this.userEmail = '',
    required this.targetGoal,
    required this.message,
    required this.preferredDate,
    this.status = 'pending',
    this.package = '',
    required this.createdAt,
  });

  factory CoachInquiry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CoachInquiry(
      id: doc.id,
      coachId: data['coachId'] as String? ?? '',
      coachName: data['coachName'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      targetGoal: data['targetGoal'] as String? ?? '',
      message: data['message'] as String? ?? '',
      preferredDate: data['preferredDate'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      package: data['package'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Read-only view of a single `coaches/{coachId}/reviews` document.
class CoachReview {
  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String text;
  final DateTime createdAt;

  const CoachReview({
    required this.id,
    required this.userId,
    this.userName = '',
    required this.rating,
    this.text = '',
    required this.createdAt,
  });

  factory CoachReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CoachReview(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      text: data['text'] as String? ?? '',
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

  /// Live athlete outbox: `coach_inquiries` where userId == uid,
  /// newest first. Requires the (userId ASC + createdAt DESC) index.
  static Stream<List<CoachInquiry>> watchInquiriesForUser(String userUid) {
    return FirebaseFirestore.instance
        .collection('coach_inquiries')
        .where('userId', isEqualTo: userUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(CoachInquiry.fromFirestore).toList())
        .handleError((_) => <CoachInquiry>[]);
  }

  /// Live coach inbox: `coach_inquiries` where coachId == coach uid,
  /// newest first. Requires the (coachId ASC + createdAt DESC) index.
  static Stream<List<CoachInquiry>> watchInquiriesForCoach(String coachUid) {
    return FirebaseFirestore.instance
        .collection('coach_inquiries')
        .where('coachId', isEqualTo: coachUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(CoachInquiry.fromFirestore).toList())
        .handleError((_) => <CoachInquiry>[]);
  }

  static const _allowedInquiryStatuses = ['accepted', 'declined'];

  /// Coach-side status flip. Writes only `{status}` so the
  /// status-only rules clause permits it. History is preserved
  /// (no deletes).
  static Future<bool> updateInquiryStatus(
    String inquiryId,
    String status,
  ) async {
    if (!_allowedInquiryStatuses.contains(status)) return false;
    try {
      await FirebaseFirestore.instance
          .collection('coach_inquiries')
          .doc(inquiryId)
          .update({'status': status});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Live reviews for a coach, newest first.
  static Stream<List<CoachReview>> watchReviews(String coachId) {
    return FirebaseFirestore.instance
        .collection('coaches')
        .doc(coachId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(CoachReview.fromFirestore).toList())
        .handleError((_) => <CoachReview>[]);
  }

  /// Athlete review write. Rules enforce userId == auth uid and
  /// owner-only update/delete.
  static Future<bool> submitReview({
    required String coachId,
    required int rating,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final clamped = rating.clamp(1, 5);
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    try {
      await FirebaseFirestore.instance
          .collection('coaches')
          .doc(coachId)
          .collection('reviews')
          .add({
            'userId': user.uid,
            'userName': user.displayName ?? '',
            'rating': clamped,
            'text': trimmed,
            'createdAt': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> sendInquiry({
    required String coachId,
    required String coachName,
    required String targetGoal,
    required String message,
    required DateTime preferredDate,
    String package = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      // TODO: Consider using a Cloud Function for notification delivery
      await FirebaseFirestore.instance.collection('coach_inquiries').add({
        'coachId': coachId,
        'coachName': coachName,
        'userId': user?.uid ?? 'guest',
        'userEmail': user?.email ?? 'athlete@veltrix.com',
        'userName': user?.displayName ?? '',
        'targetGoal': targetGoal,
        'message': message,
        'preferredDate': preferredDate.toIso8601String(),
        'status': 'pending',
        'package': package,
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

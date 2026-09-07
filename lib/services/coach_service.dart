import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/coach_profile.dart';
import 'analytics_service.dart';

export '../models/coach_profile.dart';

class CoachService {
  // TODO: Replace this static list with a Firestore query:
  //   FirebaseFirestore.instance.collection('coaches')
  //       .where('featured', isEqualTo: true)
  //       .get()
  //   Then map results: snapshot.docs.map(CoachProfile.fromFirestore).toList()
  static const List<CoachProfile> featuredCoaches = [
    CoachProfile(
      id: 'coach_priya',
      name: 'Coach Priya Sharma',
      title: 'Head Endurance Coach \u2022 IRONMAN Certified',
      rating: '4.95 (48 reviews)',
      bio:
          'Specializing in marathon PRs, VO2max building, and triathlon race strategy for all levels.',
      image: 'assets/images/cyclist-coaching.png',
      monthlyFee: '\$149/mo',
      specialities: ['Marathon', 'Triathlon', 'Power Metrics'],
    ),
    CoachProfile(
      id: 'coach_amit',
      name: 'Coach Amit Patel',
      title: 'Elite Cycling & Power Performance Specialist',
      rating: '4.98 (62 reviews)',
      bio:
          'Former national cyclist helping athletes optimize FTP, cadence efficiency, and hill climbing speed.',
      image: 'assets/images/endurance-runner.png',
      monthlyFee: '\$179/mo',
      specialities: ['Cycling', 'FTP Training', 'Nutrition'],
    ),
    CoachProfile(
      id: 'coach_vikram',
      name: 'Coach Vikram Rao',
      title: 'Ultra-Marathon & Hybrid Strength Coach',
      rating: '4.91 (35 reviews)',
      bio:
          'Focuses on ultra trail running, injury resilience, and strength integration for endurance peak performance.',
      image: 'assets/images/endurance-runner.png',
      monthlyFee: '\$139/mo',
      specialities: ['Ultra Running', 'Strength Prehab', 'Mobility'],
    ),
  ];

  static Future<List<CoachProfile>> fetchFeaturedCoaches() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('coaches')
          .where('featured', isEqualTo: true)
          .limit(20)
          .get();
      if (snapshot.docs.isEmpty) return featuredCoaches;
      return snapshot.docs.map(CoachProfile.fromFirestore).toList();
    } catch (_) {
      return featuredCoaches;
    }
  }

  static Future<CoachProfile?> fetchCoachById(String coachId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('coaches').doc(coachId).get();
      if (doc.exists) return CoachProfile.fromFirestore(doc);
    } catch (_) {}
    for (final coach in featuredCoaches) {
      if (coach.id == coachId) return coach;
    }
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

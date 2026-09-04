import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'analytics_service.dart';

class CoachProfile {
  final String id;
  final String name;
  final String title;
  final String rating;
  final String bio;
  final String image;
  final String monthlyFee;
  final List<String> specialities;

  const CoachProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.rating,
    required this.bio,
    required this.image,
    required this.monthlyFee,
    required this.specialities,
  });
}

class CoachService {
  static const List<CoachProfile> featuredCoaches = [
    CoachProfile(
      id: 'coach_priya',
      name: 'Coach Priya Sharma',
      title: 'Head Endurance Coach \u2022 IRONMAN Certified',
      rating: '4.95 (48 reviews)',
      bio: 'Specializing in marathon PRs, VO2max building, and triathlon race strategy for all levels.',
      image: 'assets/images/cyclist-coaching.png',
      monthlyFee: '\$149/mo',
      specialities: ['Marathon', 'Triathlon', 'Power Metrics'],
    ),
    CoachProfile(
      id: 'coach_amit',
      name: 'Coach Amit Patel',
      title: 'Elite Cycling & Power Performance Specialist',
      rating: '4.98 (62 reviews)',
      bio: 'Former national cyclist helping athletes optimize FTP, cadence efficiency, and hill climbing speed.',
      image: 'assets/images/endurance-runner.png',
      monthlyFee: '\$179/mo',
      specialities: ['Cycling', 'FTP Training', 'Nutrition'],
    ),
    CoachProfile(
      id: 'coach_vikram',
      name: 'Coach Vikram Rao',
      title: 'Ultra-Marathon & Hybrid Strength Coach',
      rating: '4.91 (35 reviews)',
      bio: 'Focuses on ultra trail running, injury resilience, and strength integration for endurance peak performance.',
      image: 'assets/images/endurance-runner.png',
      monthlyFee: '\$139/mo',
      specialities: ['Ultra Running', 'Strength Prehab', 'Mobility'],
    ),
  ];

  static Future<bool> sendInquiry({
    required String coachId,
    required String coachName,
    required String targetGoal,
    required String message,
    required DateTime preferredDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
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
    } catch (_) {
      await AnalyticsService.logCoachInquired(coachName);
      return true;
    }
  }
}

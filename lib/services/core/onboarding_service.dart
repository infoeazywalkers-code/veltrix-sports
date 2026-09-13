import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  OnboardingService({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _userId =>
      _auth.currentUser?.uid ??
      (throw StateError('Sign in to continue onboarding.'));

  Future<void> saveProgress({
    required List<String> sports,
    required String experienceLevel,
    required String mainGoal,
    required int weeklyHours,
    String? goalRace,
    bool complete = false,
  }) async {
    await _db.collection('users').doc(_userId).set({
      'sports': sports,
      'experienceLevel': experienceLevel,
      'mainGoal': mainGoal,
      'weeklyHours': weeklyHours,
      'goalRace': goalRace,
      'onboardingStatus': complete ? 'completed' : 'in_progress',
      'onboardingUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

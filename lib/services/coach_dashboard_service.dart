import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Represents an athlete assigned to a coach for management.
class AssignedAthlete {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String primarySport;
  final String experienceLevel;
  final DateTime assignedAt;
  final String status; // 'active', 'paused', 'completed'

  const AssignedAthlete({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.primarySport = '',
    this.experienceLevel = '',
    required this.assignedAt,
    this.status = 'active',
  });

  factory AssignedAthlete.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AssignedAthlete(
      id: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      primarySport: data['primarySport'] as String? ?? '',
      experienceLevel: data['experienceLevel'] as String? ?? '',
      assignedAt:
          (data['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'email': email,
    'photoUrl': photoUrl,
    'primarySport': primarySport,
    'experienceLevel': experienceLevel,
    'assignedAt': Timestamp.fromDate(assignedAt),
    'status': status,
  };
}

/// Represents a summary of an athlete's training for coach overview.
class AthleteTrainingSummary {
  final String athleteId;
  final int weeklyWorkouts;
  final double weeklyTss;
  final String weeklyDuration;
  final double fitness;
  final double fatigue;
  final double form;

  const AthleteTrainingSummary({
    required this.athleteId,
    this.weeklyWorkouts = 0,
    this.weeklyTss = 0,
    this.weeklyDuration = '0h 0m',
    this.fitness = 0,
    this.fatigue = 0,
    this.form = 0,
  });

  factory AthleteTrainingSummary.fromMap(
    String athleteId,
    Map<String, dynamic> data,
  ) {
    return AthleteTrainingSummary(
      athleteId: athleteId,
      weeklyWorkouts: (data['weeklyWorkouts'] as num?)?.toInt() ?? 0,
      weeklyTss: (data['weeklyTss'] as num?)?.toDouble() ?? 0,
      weeklyDuration: data['weeklyDuration'] as String? ?? '0h 0m',
      fitness: (data['fitness'] as num?)?.toDouble() ?? 0,
      fatigue: (data['fatigue'] as num?)?.toDouble() ?? 0,
      form: (data['form'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Service for coaches to manage their assigned athletes.
class CoachDashboardService {
  final FirebaseFirestore _db;

  CoachDashboardService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  /// Streams the list of athletes assigned to the current coach.
  Stream<List<AssignedAthlete>> watchAssignedAthletes() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('coach_athletes')
        .where('coachId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) => snap.docs.map(AssignedAthlete.fromFirestore).toList())
        .handleError((e) {
          throw Exception('Failed to watch assigned athletes: $e');
        });
  }

  /// Fetches all athletes assigned to the current coach (one-shot).
  Future<List<AssignedAthlete>> fetchAssignedAthletes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final snap =
          await _db
              .collection('coach_athletes')
              .where('coachId', isEqualTo: user.uid)
              .get();
      return snap.docs.map(AssignedAthlete.fromFirestore).toList();
    } catch (e) {
      throw Exception('Failed to fetch assigned athletes: $e');
    }
  }

  /// Gets training summary for a specific athlete.
  Future<AthleteTrainingSummary> getAthleteSummary(String athleteId) async {
    try {
      final snap =
          await _db
              .collection('coach_athletes')
              .doc(athleteId)
              .collection('summary')
              .orderBy('recordedAt', descending: true)
              .limit(1)
              .get();

      if (snap.docs.isEmpty) {
        return AthleteTrainingSummary(athleteId: athleteId);
      }

      return AthleteTrainingSummary.fromMap(athleteId, snap.docs.first.data());
    } catch (e) {
      return AthleteTrainingSummary(athleteId: athleteId);
    }
  }

  /// Assigns an athlete to the current coach.
  Future<void> assignAthlete({
    required String athleteId,
    required String athleteName,
    required String athleteEmail,
    String primarySport = '',
    String experienceLevel = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Coach not authenticated');

    try {
      await _db.collection('coach_athletes').doc(athleteId).set({
        'coachId': user.uid,
        'coachName': user.displayName ?? 'Coach',
        'displayName': athleteName,
        'email': athleteEmail,
        'primarySport': primarySport,
        'experienceLevel': experienceLevel,
        'assignedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    } catch (e) {
      throw Exception('Failed to assign athlete: $e');
    }
  }

  /// Updates an athlete's assignment status.
  Future<void> updateAthleteStatus(String athleteId, String status) async {
    try {
      await _db.collection('coach_athletes').doc(athleteId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update athlete status: $e');
    }
  }

  /// Removes an athlete from the coach's roster.
  Future<void> removeAthlete(String athleteId) async {
    try {
      await updateAthleteStatus(athleteId, 'completed');
    } catch (e) {
      throw Exception('Failed to remove athlete: $e');
    }
  }
}

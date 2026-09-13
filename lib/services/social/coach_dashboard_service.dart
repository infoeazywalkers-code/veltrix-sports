import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../activity/workout_service.dart';
import '../performance/performance_service.dart';

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
  /// Single-where (coachId only) with client-side status filtering so no
  /// composite index is required.
  Stream<List<AssignedAthlete>> watchAssignedAthletes() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('coach_athletes')
        .where('coachId', isEqualTo: user.uid)
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
  /// Falls back to live computation from the athlete's last 7 days when no
  /// precomputed summary doc exists (nothing populates it yet).
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

      if (snap.docs.isNotEmpty) {
        return AthleteTrainingSummary.fromMap(
          athleteId,
          snap.docs.first.data(),
        );
      }
    } catch (_) {}

    try {
      final now = DateTime.now();
      final week =
          await WorkoutService(db: _db)
              .watchByDateRange(
                athleteId,
                now.subtract(const Duration(days: 7)),
                now,
              )
              .first;
      final done = week.where((w) => w.completed).toList();
      final tss = done.fold<int>(0, (sum, w) => sum + (w.tss ?? 0));
      final mins = done.fold<int>(
        0,
        (sum, w) => sum + _parseDurationMinutes(w.duration),
      );

      double fitness = 0, fatigue = 0, form = 0;
      try {
        final latest = await PerformanceService(db: _db).getLatest(athleteId);
        if (latest != null) {
          fitness = latest.fitness;
          fatigue = latest.fatigue;
          form = latest.form;
        }
      } catch (_) {}

      return AthleteTrainingSummary(
        athleteId: athleteId,
        weeklyWorkouts: done.length,
        weeklyTss: tss.toDouble(),
        weeklyDuration: '${mins ~/ 60}h ${mins % 60}m',
        fitness: fitness,
        fatigue: fatigue,
        form: form,
      );
    } catch (_) {
      return AthleteTrainingSummary(athleteId: athleteId);
    }
  }

  /// Parses workout duration strings like "1h 30min", "45min" or "45".
  int _parseDurationMinutes(String duration) {
    final trimmed = duration.trim().toLowerCase();
    int total = 0;
    final hourMatch = RegExp(r'(\d+)\s*h').firstMatch(trimmed);
    if (hourMatch != null) total += int.parse(hourMatch.group(1)!) * 60;
    final minMatch = RegExp(r'(\d+)\s*min').firstMatch(trimmed);
    if (minMatch != null) total += int.parse(minMatch.group(1)!);
    if (total == 0) {
      final plain = RegExp(r'^(\d+)$').firstMatch(trimmed);
      if (plain != null) total = int.parse(plain.group(1)!);
    }
    return total;
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

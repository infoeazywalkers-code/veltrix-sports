import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/activity/workout.dart';
import '../../models/user/user_preferences.dart';
import '../../models/performance/performance_snapshot.dart';

/// Represents a training recommendation based on athlete progress.
class TrainingRecommendation {
  final String type; // 'intensity_up', 'intensity_down', 'rest', 'focus_area'
  final String title;
  final String description;
  final String priority; // 'high', 'medium', 'low'
  final DateTime createdAt;

  const TrainingRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'title': title,
    'description': description,
    'priority': priority,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory TrainingRecommendation.fromMap(Map<String, dynamic> data) {
    return TrainingRecommendation(
      type: data['type'] as String? ?? 'general',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      priority: data['priority'] as String? ?? 'low',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Provides progress-based training recommendations by analyzing workout
/// completion, performance trends, and schedule adherence.
class AdaptiveTrainingService {
  final FirebaseFirestore _db;

  AdaptiveTrainingService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  /// Generates recommendations based on the athlete's recent performance
  /// and training patterns.
  ///
  /// [completedWorkouts] — recent completed workouts (last 14-30 days).
  /// [scheduledWorkouts] — workouts planned for the coming week.
  /// [performance] — latest performance snapshot (can be null for new users).
  /// [preferences] — user's training preferences (schedule, goals, etc.).
  List<TrainingRecommendation> generateRecommendations({
    required List<Workout> completedWorkouts,
    required List<Workout> scheduledWorkouts,
    PerformanceSnapshot? performance,
    UserPreferences? preferences,
  }) {
    final recommendations = <TrainingRecommendation>[];

    // Analyze completion rate
    final completionRec = _analyzeCompletionRate(completedWorkouts);
    if (completionRec != null) recommendations.add(completionRec);

    // Analyze training load trend
    final loadRec = _analyzeTrainingLoad(completedWorkouts);
    if (loadRec != null) recommendations.add(loadRec);

    // Analyze recovery status from performance snapshot
    final recoveryRec = _analyzeRecoveryStatus(performance);
    if (recoveryRec != null) recommendations.add(recoveryRec);

    // Check for sport variety
    final varietyRec = _analyzeSportVariety(completedWorkouts);
    if (varietyRec != null) recommendations.add(varietyRec);

    // Check upcoming schedule balance
    final balanceRec = _analyzeScheduleBalance(scheduledWorkouts);
    if (balanceRec != null) recommendations.add(balanceRec);

    return recommendations;
  }

  TrainingRecommendation? _analyzeCompletionRate(List<Workout> workouts) {
    if (workouts.length < 3) return null;

    final completed = workouts.where((w) => w.completed).length;
    final rate = completed / workouts.length;

    if (rate < 0.5) {
      return TrainingRecommendation(
        type: 'intensity_down',
        title: 'Reduce Training Load',
        description:
            'Your completion rate is ${(rate * 100).round()}%. Consider '
            'simplifying your plan or taking a recovery week to rebuild consistency.',
        priority: 'high',
        createdAt: DateTime.now(),
      );
    }

    if (rate > 0.9 && workouts.length >= 7) {
      return TrainingRecommendation(
        type: 'intensity_up',
        title: 'Ready for More',
        description:
            'You\'ve completed ${(rate * 100).round()}% of recent sessions. '
            'Your body may be ready for increased intensity or volume.',
        priority: 'medium',
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  TrainingRecommendation? _analyzeTrainingLoad(List<Workout> workouts) {
    if (workouts.length < 5) return null;

    final sorted = List<Workout>.from(workouts)
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));

    // Compare first half TSS to second half
    final mid = sorted.length ~/ 2;
    final firstHalfTss = sorted
        .sublist(0, mid)
        .fold<double>(0, (sum, w) => sum + (w.tss ?? 0));
    final secondHalfTss = sorted
        .sublist(mid)
        .fold<double>(0, (sum, w) => sum + (w.tss ?? 0));

    if (secondHalfTss > firstHalfTss * 1.3) {
      return TrainingRecommendation(
        type: 'intensity_down',
        title: 'Load Increasing Rapidly',
        description:
            'Your training stress has risen quickly. A step-back week '
            'with 20-30% less volume can help absorb the gains.',
        priority: 'high',
        createdAt: DateTime.now(),
      );
    }

    if (secondHalfTss < firstHalfTss * 0.6) {
      return TrainingRecommendation(
        type: 'intensity_up',
        title: 'Training Load Dropped',
        description:
            'Your recent sessions are lighter than usual. If you\'re '
            'feeling fresh, this may be a good time to add quality work.',
        priority: 'low',
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  TrainingRecommendation? _analyzeRecoveryStatus(PerformanceSnapshot? perf) {
    if (perf == null) return null;

    // High fatigue relative to fitness suggests overreaching
    if (perf.fatigue > perf.fitness * 1.2 && perf.form < -20) {
      return TrainingRecommendation(
        type: 'rest',
        title: 'Recovery Needed',
        description:
            'Your fatigue is elevated (${perf.fatigue.round()} TSB) and form '
            'is negative (${perf.form.round()}). Prioritize sleep and easy '
            'sessions for the next 2-3 days.',
        priority: 'high',
        createdAt: DateTime.now(),
      );
    }

    // Good form — ready for key sessions
    if (perf.form > 5 && perf.fitness > 30) {
      return TrainingRecommendation(
        type: 'focus_area',
        title: 'Peak Form Window',
        description:
            'Your form score is positive (${perf.form.round()}) with solid '
            'fitness (${perf.fitness.round()}). This is a great window for '
            'key workouts or race simulation.',
        priority: 'medium',
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  TrainingRecommendation? _analyzeSportVariety(List<Workout> workouts) {
    if (workouts.length < 5) return null;

    final sportCounts = <String, int>{};
    for (final w in workouts) {
      final sport = w.sport.name;
      sportCounts[sport] = (sportCounts[sport] ?? 0) + 1;
    }

    final dominantSport = sportCounts.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    if (dominantSport.value > workouts.length * 0.85 && workouts.length >= 6) {
      return TrainingRecommendation(
        type: 'focus_area',
        title: 'Add Cross-Training',
        description:
            '${(dominantSport.value / workouts.length * 100).round()}% of '
            'your recent sessions are ${dominantSport.key}. Adding mobility '
            'or strength work can improve resilience.',
        priority: 'low',
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  TrainingRecommendation? _analyzeScheduleBalance(List<Workout> scheduled) {
    if (scheduled.isEmpty) return null;

    // Check if rest days are scheduled
    final hasRestDay = scheduled.any(
      (w) =>
          w.title.toLowerCase().contains('rest') ||
          w.title.toLowerCase().contains('recovery'),
    );

    if (scheduled.length >= 6 && !hasRestDay) {
      return TrainingRecommendation(
        type: 'rest',
        title: 'Schedule a Rest Day',
        description:
            'You have ${scheduled.length} sessions planned this week '
            'with no dedicated rest day. Recovery is where adaptation happens.',
        priority: 'medium',
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  /// Saves a recommendation to Firestore for historical tracking.
  Future<void> saveRecommendation(
    String userId,
    TrainingRecommendation recommendation,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('recommendations')
          .add(recommendation.toMap());
    } catch (e) {
      // Silently fail — recommendations are non-critical
    }
  }

  /// Fetches recent recommendations for a user.
  Future<List<TrainingRecommendation>> getRecentRecommendations(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final snap =
          await _db
              .collection('users')
              .doc(userId)
              .collection('recommendations')
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get();

      return snap.docs
          .map((doc) => TrainingRecommendation.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

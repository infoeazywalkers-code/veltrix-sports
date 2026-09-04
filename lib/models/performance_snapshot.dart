import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceSnapshot {
  final String id;
  final String userId;
  final double fitness;
  final double fatigue;
  final double form;
  final double weeklyTss;
  final int weeklyWorkouts;
  final String weeklyDuration;
  final DateTime recordedAt;

  const PerformanceSnapshot({
    required this.id,
    required this.userId,
    required this.fitness,
    required this.fatigue,
    required this.form,
    this.weeklyTss = 0,
    this.weeklyWorkouts = 0,
    this.weeklyDuration = '',
    required this.recordedAt,
  });

  factory PerformanceSnapshot.fromMap(String id, Map<String, dynamic> map) {
    return PerformanceSnapshot(
      id: id,
      userId: map['userId'] as String? ?? '',
      fitness: (map['fitness'] as num?)?.toDouble() ?? 0,
      fatigue: (map['fatigue'] as num?)?.toDouble() ?? 0,
      form: (map['form'] as num?)?.toDouble() ?? 0,
      weeklyTss: (map['weeklyTss'] as num?)?.toDouble() ?? 0,
      weeklyWorkouts: (map['weeklyWorkouts'] as num?)?.toInt() ?? 0,
      weeklyDuration: map['weeklyDuration'] as String? ?? '',
      recordedAt: (map['recordedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'fitness': fitness,
        'fatigue': fatigue,
        'form': form,
        'weeklyTss': weeklyTss,
        'weeklyWorkouts': weeklyWorkouts,
        'weeklyDuration': weeklyDuration,
        'recordedAt': recordedAt,
      };
}
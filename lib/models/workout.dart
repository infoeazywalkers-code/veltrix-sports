import 'package:cloud_firestore/cloud_firestore.dart';

enum Sport { run, bike, swim, strength, rest }

class WorkoutSegment {
  final String label;
  final String duration;

  const WorkoutSegment({required this.label, required this.duration});

  factory WorkoutSegment.fromMap(Map<String, dynamic> map) => WorkoutSegment(
        label: map['label'] as String? ?? '',
        duration: map['duration'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {'label': label, 'duration': duration};
}

class Workout {
  final String id;
  final String planId;
  final Sport sport;
  final String title;
  final String description;
  final String duration;
  final double? distanceKm;
  final int? tss;
  final String? targetPace;
  final DateTime scheduledFor;
  final double progress;
  final bool completed;
  final List<WorkoutSegment> segments;

  const Workout({
    required this.id,
    required this.planId,
    required this.sport,
    required this.title,
    this.description = '',
    required this.duration,
    this.distanceKm,
    this.tss,
    this.targetPace,
    required this.scheduledFor,
    this.progress = 0,
    this.completed = false,
    this.segments = const [],
  });

  factory Workout.fromMap(String id, Map<String, dynamic> map) {
    return Workout(
      id: id,
      planId: map['planId'] as String? ?? '',
      sport: Sport.values.firstWhere(
        (s) => s.name == map['sport'],
        orElse: () => Sport.run,
      ),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      tss: (map['tss'] as num?)?.toInt(),
      targetPace: map['targetPace'] as String?,
      scheduledFor:
          (map['scheduledFor'] as Timestamp?)?.toDate() ?? DateTime.now(),
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      completed: map['completed'] as bool? ?? false,
      segments: (map['segments'] as List? ?? [])
          .map((s) => WorkoutSegment.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'planId': planId,
        'sport': sport.name,
        'title': title,
        'description': description,
        'duration': duration,
        'distanceKm': distanceKm,
        'tss': tss,
        'targetPace': targetPace,
        'scheduledFor': scheduledFor,
        'progress': progress,
        'completed': completed,
        'segments': segments.map((s) => s.toMap()).toList(),
      };
}
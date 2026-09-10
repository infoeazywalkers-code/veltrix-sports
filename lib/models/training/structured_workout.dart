class WorkoutInterval {
  final String phase;
  final int durationMinutes;
  final String targetZone;
  final String targetDescription;

  const WorkoutInterval({
    required this.phase,
    required this.durationMinutes,
    required this.targetZone,
    required this.targetDescription,
  });

  factory WorkoutInterval.fromMap(Map<String, dynamic> m) => WorkoutInterval(
    phase: m['phase'] ?? '',
    durationMinutes: m['durationMinutes'] ?? 0,
    targetZone: m['targetZone'] ?? '',
    targetDescription: m['targetDescription'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'phase': phase,
    'durationMinutes': durationMinutes,
    'targetZone': targetZone,
    'targetDescription': targetDescription,
  };
}

class StructuredWorkout {
  final String id;
  final String date; // YYYY-MM-DD
  final String title;
  final String sport;
  final int plannedDurationMinutes;
  final int plannedTSS;
  final String description;
  final List<WorkoutInterval> structure;
  final bool isCompleted;
  final String? completedActivityId;

  const StructuredWorkout({
    required this.id,
    required this.date,
    required this.title,
    required this.sport,
    required this.plannedDurationMinutes,
    required this.plannedTSS,
    required this.description,
    this.structure = const [],
    this.isCompleted = false,
    this.completedActivityId,
  });

  factory StructuredWorkout.fromMap(Map<String, dynamic> m) =>
      StructuredWorkout(
        id: m['id'] ?? '',
        date: m['date'] ?? '',
        title: m['title'] ?? '',
        sport: m['sport'] ?? 'cycling',
        plannedDurationMinutes: m['plannedDurationMinutes'] ?? 0,
        plannedTSS: m['plannedTSS'] ?? 0,
        description: m['description'] ?? '',
        structure:
            (m['structure'] as List?)
                ?.map((e) => WorkoutInterval.fromMap(e))
                .toList() ??
            [],
        isCompleted: m['isCompleted'] ?? false,
        completedActivityId: m['completedActivityId'],
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'title': title,
    'sport': sport,
    'plannedDurationMinutes': plannedDurationMinutes,
    'plannedTSS': plannedTSS,
    'description': description,
    'structure': structure.map((e) => e.toMap()).toList(),
    'isCompleted': isCompleted,
    'completedActivityId': completedActivityId,
  };
}

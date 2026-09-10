import '../activity/activity.dart';

enum ChallengeCategory { endurance, climbing, consistency, speed }

class SocialChallenge {
  final String id;
  final String title;
  final String description;
  final SportType sport;
  final double targetValue;
  final String unit;
  final double currentValue;
  final DateTime startDate;
  final DateTime endDate;
  final int participantsCount;
  final bool isJoined;
  final String badgeIcon;
  final String badgeColor;
  final ChallengeCategory category;

  const SocialChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.sport,
    required this.targetValue,
    required this.unit,
    required this.currentValue,
    required this.startDate,
    required this.endDate,
    required this.participantsCount,
    required this.isJoined,
    required this.badgeIcon,
    required this.badgeColor,
    required this.category,
  });

  factory SocialChallenge.fromMap(Map<String, dynamic> m) => SocialChallenge(
    id: m['id'] ?? '',
    title: m['title'] ?? '',
    description: m['description'] ?? '',
    sport: SportType.values.firstWhere(
      (e) => e.name == m['sport'],
      orElse: () => SportType.cycling,
    ),
    targetValue: (m['targetValue'] ?? 0).toDouble(),
    unit: m['unit'] ?? 'km',
    currentValue: (m['currentValue'] ?? 0).toDouble(),
    startDate: DateTime.tryParse(m['startDate'] ?? '') ?? DateTime.now(),
    endDate: DateTime.tryParse(m['endDate'] ?? '') ?? DateTime.now(),
    participantsCount: m['participantsCount'] ?? 0,
    isJoined: m['isJoined'] ?? false,
    badgeIcon: m['badgeIcon'] ?? '',
    badgeColor: m['badgeColor'] ?? '',
    category: ChallengeCategory.values.firstWhere(
      (e) => e.name == m['category'],
      orElse: () => ChallengeCategory.endurance,
    ),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'sport': sport.name,
    'targetValue': targetValue,
    'unit': unit,
    'currentValue': currentValue,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'participantsCount': participantsCount,
    'isJoined': isJoined,
    'badgeIcon': badgeIcon,
    'badgeColor': badgeColor,
    'category': category.name,
  };

  double get progressPercent =>
      targetValue > 0 ? (currentValue / targetValue * 100).clamp(0, 100) : 0;

  bool get isCompleted => currentValue >= targetValue;

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}

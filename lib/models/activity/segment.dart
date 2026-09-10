import 'activity.dart';

enum ClimbCategory { cat4, cat3, cat2, cat1, hc, sprint }

class Segment {
  final String id;
  final String name;
  final double distanceKm;
  final double avgGradePct;
  final double elevationGainMeters;
  final ClimbCategory climbCategory;
  final String komAthlete;
  final String komTime;
  final int? komWatts;
  final String? personalRecordTime;
  final int? personalRank;
  final int totalAttempts;
  final SportType sport;
  final List<List<double>> polylineCoords;

  const Segment({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.avgGradePct,
    required this.elevationGainMeters,
    required this.climbCategory,
    required this.komAthlete,
    required this.komTime,
    this.komWatts,
    this.personalRecordTime,
    this.personalRank,
    required this.totalAttempts,
    required this.sport,
    this.polylineCoords = const [],
  });

  factory Segment.fromMap(Map<String, dynamic> m) => Segment(
    id: m['id'] ?? '',
    name: m['name'] ?? '',
    distanceKm: (m['distanceKm'] ?? 0).toDouble(),
    avgGradePct: (m['avgGradePct'] ?? 0).toDouble(),
    elevationGainMeters: (m['elevationGainMeters'] ?? 0).toDouble(),
    climbCategory: ClimbCategory.values.firstWhere(
      (e) => e.name == m['climbCategory'],
      orElse: () => ClimbCategory.sprint,
    ),
    komAthlete: m['komAthlete'] ?? '',
    komTime: m['komTime'] ?? '',
    komWatts: m['komWatts'],
    personalRecordTime: m['personalRecordTime'],
    personalRank: m['personalRank'],
    totalAttempts: m['totalAttempts'] ?? 0,
    sport: SportType.values.firstWhere(
      (e) => e.name == m['sport'],
      orElse: () => SportType.cycling,
    ),
    polylineCoords:
        (m['polylineCoords'] as List?)
            ?.map((e) => List<double>.from(e))
            .toList() ??
        [],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'distanceKm': distanceKm,
    'avgGradePct': avgGradePct,
    'elevationGainMeters': elevationGainMeters,
    'climbCategory': climbCategory.name,
    'komAthlete': komAthlete,
    'komTime': komTime,
    if (komWatts != null) 'komWatts': komWatts,
    if (personalRecordTime != null) 'personalRecordTime': personalRecordTime,
    if (personalRank != null) 'personalRank': personalRank,
    'totalAttempts': totalAttempts,
    'sport': sport.name,
    'polylineCoords': polylineCoords,
  };

  String get climbCategoryLabel {
    switch (climbCategory) {
      case ClimbCategory.hc:
        return 'HC';
      case ClimbCategory.cat1:
        return 'Cat 1';
      case ClimbCategory.cat2:
        return 'Cat 2';
      case ClimbCategory.cat3:
        return 'Cat 3';
      case ClimbCategory.cat4:
        return 'Cat 4';
      case ClimbCategory.sprint:
        return 'Sprint';
    }
  }
}

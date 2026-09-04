import 'package:cloud_firestore/cloud_firestore.dart';
import 'workout.dart';

class TrainingPlan {
  final String id;
  final String userId;
  final String? coachId;
  final String name;
  final Sport sport;
  final String? eventName;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? totalDistanceKm;
  final String status;
  final DateTime createdAt;

  const TrainingPlan({
    required this.id,
    required this.userId,
    this.coachId,
    required this.name,
    required this.sport,
    this.eventName,
    this.startDate,
    this.endDate,
    this.totalDistanceKm,
    this.status = 'active',
    required this.createdAt,
  });

  factory TrainingPlan.fromMap(String id, Map<String, dynamic> map) {
    return TrainingPlan(
      id: id,
      userId: map['userId'] as String? ?? '',
      coachId: map['coachId'] as String?,
      name: map['name'] as String? ?? '',
      sport: Sport.values.firstWhere(
        (s) => s.name == map['sport'],
        orElse: () => Sport.run,
      ),
      eventName: map['eventName'] as String?,
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      totalDistanceKm: (map['totalDistanceKm'] as num?)?.toDouble(),
      status: map['status'] as String? ?? 'active',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'coachId': coachId,
        'name': name,
        'sport': sport.name,
        'eventName': eventName,
        'startDate': startDate,
        'endDate': endDate,
        'totalDistanceKm': totalDistanceKm,
        'status': status,
        'createdAt': createdAt,
      };
}
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingPlan {
  final String id;
  final String userId;
  final String? coachId;
  final String name;
  final String description;
  final String sport;
  final int durationWeeks;
  final String difficulty;
  final String targetGoal;
  final double price;
  final String? eventName;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? totalDistanceKm;
  final String status;
  final DateTime? createdAt;

  const TrainingPlan({
    required this.id,
    required this.userId,
    this.coachId,
    required this.name,
    required this.description,
    required this.sport,
    required this.durationWeeks,
    required this.difficulty,
    required this.targetGoal,
    required this.price,
    this.eventName,
    this.startDate,
    this.endDate,
    this.totalDistanceKm,
    this.status = 'active',
    this.createdAt,
  });

  factory TrainingPlan.fromMap(String id, Map<String, dynamic> map) {
    return TrainingPlan(
      id: id,
      userId: map['userId'] as String? ?? '',
      coachId: map['coachId'] as String?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      sport: (map['sport'] as String?) ?? 'Running',
      durationWeeks: (map['durationWeeks'] as num?)?.toInt() ?? 8,
      difficulty: map['difficulty'] as String? ?? 'Intermediate',
      targetGoal: map['targetGoal'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      eventName: map['eventName'] as String?,
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      totalDistanceKm: (map['totalDistanceKm'] as num?)?.toDouble(),
      status: map['status'] as String? ?? 'active',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'coachId': coachId,
        'name': name,
        'description': description,
        'sport': sport,
        'durationWeeks': durationWeeks,
        'difficulty': difficulty,
        'targetGoal': targetGoal,
        'price': price,
        'eventName': eventName,
        'startDate': startDate,
        'endDate': endDate,
        'totalDistanceKm': totalDistanceKm,
        'status': status,
        'createdAt': createdAt,
      };
}
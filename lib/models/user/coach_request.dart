import 'package:cloud_firestore/cloud_firestore.dart';

class CoachRequest {
  final String id;
  final String userId;
  final String sport;
  final String experience;
  final String goal;
  final String notes;
  final String status;
  final String? matchedCoachId;
  final String package;
  final DateTime createdAt;

  const CoachRequest({
    required this.id,
    required this.userId,
    required this.sport,
    required this.experience,
    required this.goal,
    this.notes = '',
    this.status = 'pending',
    this.matchedCoachId,
    this.package = '',
    required this.createdAt,
  });

  factory CoachRequest.fromMap(String id, Map<String, dynamic> map) {
    return CoachRequest(
      id: id,
      userId: map['userId'] as String? ?? '',
      sport: map['sport'] as String? ?? '',
      experience: map['experience'] as String? ?? '',
      goal: map['goal'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      matchedCoachId: map['matchedCoachId'] as String?,
      package: map['package'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'sport': sport,
    'experience': experience,
    'goal': goal,
    'notes': notes,
    'status': status,
    'matchedCoachId': matchedCoachId,
    'package': package,
    'createdAt': createdAt,
  };
}

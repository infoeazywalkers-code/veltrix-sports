import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a coach's public profile within the Veltrix platform.
///
/// This model supports both static seed data and Firestore-backed
/// dynamic profiles. Use [fromFirestore] / [toFirestore] for persistence.
class CoachProfile {
  final String id;
  final String name;
  final String title;
  final String rating;
  final String bio;
  final String image;
  final String monthlyFee;
  final List<String> specialities;

  const CoachProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.rating,
    required this.bio,
    required this.image,
    required this.monthlyFee,
    required this.specialities,
  });

  /// Creates a [CoachProfile] from a Firestore document snapshot.
  factory CoachProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CoachProfile(
      id: doc.id,
      name: data['name'] as String? ?? '',
      title: data['title'] as String? ?? '',
      rating: data['rating'] as String? ?? '0.0',
      bio: data['bio'] as String? ?? '',
      image: data['image'] as String? ?? '',
      monthlyFee: data['monthlyFee'] as String? ?? '\$0/mo',
      specialities: List<String>.from(data['specialities'] as List? ?? []),
    );
  }

  /// Creates a [CoachProfile] from a raw map (e.g., Firestore data or JSON).
  factory CoachProfile.fromMap(String id, Map<String, dynamic> map) {
    return CoachProfile(
      id: id,
      name: map['name'] as String? ?? '',
      title: map['title'] as String? ?? '',
      rating: map['rating'] as String? ?? '0.0',
      bio: map['bio'] as String? ?? '',
      image: map['image'] as String? ?? '',
      monthlyFee: map['monthlyFee'] as String? ?? '\$0/mo',
      specialities: List<String>.from(map['specialities'] as List? ?? []),
    );
  }

  /// Serializes this profile to a map suitable for Firestore writes.
  Map<String, dynamic> toMap() => {
    'name': name,
    'title': title,
    'rating': rating,
    'bio': bio,
    'image': image,
    'monthlyFee': monthlyFee,
    'specialities': specialities,
  };

  /// Returns a copy of this profile with optional field overrides.
  CoachProfile copyWith({
    String? id,
    String? name,
    String? title,
    String? rating,
    String? bio,
    String? image,
    String? monthlyFee,
    List<String>? specialities,
  }) {
    return CoachProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      rating: rating ?? this.rating,
      bio: bio ?? this.bio,
      image: image ?? this.image,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      specialities: specialities ?? this.specialities,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CoachProfile(id: $id, name: $name)';
}

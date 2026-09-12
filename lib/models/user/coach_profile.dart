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
  final String credentials;
  final String philosophy;
  final String avatarUrl;
  final List<String> sports;
  final int reviewCount;
  final double avgRating;
  final bool verified;
  final String coachUserId;

  const CoachProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.rating,
    required this.bio,
    required this.image,
    required this.monthlyFee,
    required this.specialities,
    this.credentials = '',
    this.philosophy = '',
    this.avatarUrl = '',
    this.sports = const [],
    this.reviewCount = 0,
    this.avgRating = 0.0,
    this.verified = false,
    this.coachUserId = '',
  });

  /// Prefers the aggregated [avgRating] when reviews exist,
  /// falling back to the legacy [rating] string for old docs.
  String get displayRating {
    if (reviewCount > 0 && avgRating > 0) {
      return avgRating.toStringAsFixed(1);
    }
    return rating;
  }

  /// Best available avatar: new [avatarUrl] first, legacy [image] fallback.
  String get displayAvatar => avatarUrl.isNotEmpty ? avatarUrl : image;

  /// Creates a [CoachProfile] from a Firestore document snapshot.
  factory CoachProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CoachProfile.fromMap(doc.id, data);
  }

  /// Creates a [CoachProfile] from a raw map (e.g., Firestore data or JSON).
  /// Old docs without the newer fields still parse via defaults.
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
      credentials: map['credentials'] as String? ?? '',
      philosophy: map['philosophy'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      sports: List<String>.from(map['sports'] as List? ?? []),
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      avgRating: (map['avgRating'] as num?)?.toDouble() ?? 0.0,
      verified: map['verified'] as bool? ?? false,
      coachUserId: map['coachUserId'] as String? ?? '',
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
    'credentials': credentials,
    'philosophy': philosophy,
    'avatarUrl': avatarUrl,
    'sports': sports,
    'reviewCount': reviewCount,
    'avgRating': avgRating,
    'verified': verified,
    'coachUserId': coachUserId,
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
    String? credentials,
    String? philosophy,
    String? avatarUrl,
    List<String>? sports,
    int? reviewCount,
    double? avgRating,
    bool? verified,
    String? coachUserId,
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
      credentials: credentials ?? this.credentials,
      philosophy: philosophy ?? this.philosophy,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      sports: sports ?? this.sports,
      reviewCount: reviewCount ?? this.reviewCount,
      avgRating: avgRating ?? this.avgRating,
      verified: verified ?? this.verified,
      coachUserId: coachUserId ?? this.coachUserId,
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

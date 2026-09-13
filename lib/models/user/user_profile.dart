import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { athlete, coach }

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final UserRole role;
  final List<String> sports;
  final String? experienceLevel;
  final String? mainGoal;
  final String? onboardingStatus;
  final bool isPremium;
  final String? subscriptionTier;
  final DateTime? subscriptionRenewsAt;
  final List<String> deviceIds;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    this.sports = const [],
    this.experienceLevel,
    this.mainGoal,
    this.onboardingStatus,
    this.isPremium = false,
    this.subscriptionTier,
    this.subscriptionRenewsAt,
    this.deviceIds = const [],
    required this.createdAt,
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    return UserProfile(
      id: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.athlete,
      ),
      sports: (map['sports'] as List? ?? []).cast<String>(),
      experienceLevel: map['experienceLevel'] as String?,
      mainGoal: map['mainGoal'] as String?,
      onboardingStatus: map['onboardingStatus'] as String?,
      isPremium: map['isPremium'] as bool? ?? false,
      subscriptionTier: map['subscriptionTier'] as String?,
      subscriptionRenewsAt: (map['subscriptionRenewsAt'] as Timestamp?)
          ?.toDate(),
      deviceIds: (map['deviceIds'] as List? ?? []).cast<String>(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'role': role.name,
    'sports': sports,
    'experienceLevel': experienceLevel,
    'mainGoal': mainGoal,
    'onboardingStatus': onboardingStatus,
    'isPremium': isPremium,
    'subscriptionTier': subscriptionTier,
    'subscriptionRenewsAt': subscriptionRenewsAt,
    'deviceIds': deviceIds,
    'createdAt': createdAt,
  };
}

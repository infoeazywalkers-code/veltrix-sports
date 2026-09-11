import 'package:cloud_firestore/cloud_firestore.dart';

/// Public athlete card stored in `athlete_directory/{uid}`.
///
/// Created only by the owner via [AthleteDirectoryService.ensureMyDirectory].
/// Cards with [showOnLeaderboards] == false are excluded from discovery.
class AthleteCard {
  final String uid;
  final String displayName;
  final String handle;
  final String location;
  final String team;
  final String? photoUrl;
  final List<String> sports;
  final bool showOnLeaderboards;
  final DateTime? updatedAt;

  const AthleteCard({
    required this.uid,
    required this.displayName,
    this.handle = '',
    this.location = '',
    this.team = '',
    this.photoUrl,
    this.sports = const [],
    this.showOnLeaderboards = true,
    this.updatedAt,
  });

  factory AthleteCard.fromMap(String uid, Map<String, dynamic> map) {
    return AthleteCard(
      uid: uid,
      displayName: map['displayName'] as String? ?? '',
      handle: map['handle'] as String? ?? '',
      location: map['location'] as String? ?? '',
      team: map['team'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      sports: (map['sports'] as List? ?? []).cast<String>(),
      showOnLeaderboards: map['showOnLeaderboards'] as bool? ?? true,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'handle': handle,
    'location': location,
    'team': team,
    'photoUrl': photoUrl,
    'sports': sports,
    'showOnLeaderboards': showOnLeaderboards,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

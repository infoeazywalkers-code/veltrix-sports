import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/social/athlete_card.dart';
import '../../models/user/user_profile.dart';

/// Reads/writes public athlete cards in `athlete_directory/{uid}`.
///
/// Directory docs are created only by the owner via [ensureMyDirectory];
/// reads require sign-in (see `firestore.rules`).
class AthleteDirectoryService {
  final FirebaseFirestore _db;

  AthleteDirectoryService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _directory =>
      _db.collection('athlete_directory');

  Future<AthleteCard?> get(String uid) async {
    try {
      final doc = await _directory.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return AthleteCard.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to load athlete card: $e');
    }
  }

  Stream<AthleteCard?> watchAthleteDirectory(String uid) {
    return _directory
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return AthleteCard.fromMap(doc.id, doc.data()!);
        })
        .handleError((e) {
          throw Exception('Failed to watch athlete card: $e');
        });
  }

  Stream<List<AthleteCard>> watchDirectory({int limit = 50}) {
    return _directory
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AthleteCard.fromMap(doc.id, doc.data()))
              .toList(),
        )
        .handleError((e) {
          throw Exception('Failed to watch athlete directory: $e');
        });
  }

  /// Publishes (or refreshes) the caller's own athlete card from their
  /// [UserProfile]. Uses merge-set so a previously saved
  /// `showOnLeaderboards: false` preference is preserved.
  Future<AthleteCard> ensureMyDirectory(String uid) async {
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception('Your profile could not be found.');
      }
      final profile = UserProfile.fromMap(userDoc.id, userDoc.data()!);
      final existing = await get(uid);
      final card = AthleteCard(
        uid: uid,
        displayName: profile.displayName.isNotEmpty
            ? profile.displayName
            : 'Athlete',
        handle: _handleFor(profile.displayName),
        location: existing?.location ?? '',
        team: existing?.team ?? '',
        photoUrl: profile.photoUrl,
        sports: profile.sports,
        showOnLeaderboards: existing?.showOnLeaderboards ?? true,
      );
      await _directory.doc(uid).set(card.toMap(), SetOptions(merge: true));
      return card;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to publish athlete card: $e');
    }
  }

  static String _handleFor(String displayName) {
    final cleaned = displayName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    if (cleaned.isEmpty) return '';
    return '@$cleaned';
  }
}

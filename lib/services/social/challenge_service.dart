import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/social/social_challenge.dart';

/// Per-user progress on one challenge, stored at
/// `users/{uid}/challenge_entries/{challengeId}`.
class ChallengeEntry {
  final double progress;
  final bool completed;

  const ChallengeEntry({this.progress = 0, this.completed = false});

  factory ChallengeEntry.fromMap(Map<String, dynamic> m) => ChallengeEntry(
    progress: (m['progress'] as num?)?.toDouble() ?? 0,
    completed: m['completed'] as bool? ?? false,
  );
}

/// Firestore access for joinable challenges (Phase 3).
///
/// Reads the `challenges` catalog (read-only client-side) and the
/// owner-scoped `users/{uid}/challenge_entries` subcollection.
/// No new top-level collections.
class ChallengeService {
  final FirebaseFirestore _db;

  ChallengeService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  /// Watches the challenge catalog (capped at [limit] docs).
  Stream<List<SocialChallenge>> watchChallenges({int limit = 30}) {
    try {
      return _db
          .collection('challenges')
          .limit(limit)
          .snapshots()
          .map(
            (snap) => snap.docs.map((doc) => _challengeFromDoc(doc)).toList(),
          )
          .handleError((Object e) {
            throw Exception('Failed to load challenges: $e');
          });
    } catch (e) {
      throw Exception('Failed to load challenges: $e');
    }
  }

  /// Joins [challengeId] for [uid] (idempotent, merge write).
  Future<void> joinChallenge(String uid, String challengeId) async {
    try {
      if (uid.isEmpty || challengeId.isEmpty) {
        throw Exception('User and challenge ids are required.');
      }
      await _db
          .collection('users')
          .doc(uid)
          .collection('challenge_entries')
          .doc(challengeId)
          .set({
            'joinedAt': FieldValue.serverTimestamp(),
            'progress': 0,
            'completed': false,
          }, SetOptions(merge: true));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to join challenge: $e');
    }
  }

  /// Leaves [challengeId] for [uid] by deleting the entry doc.
  Future<void> leaveChallenge(String uid, String challengeId) async {
    try {
      if (uid.isEmpty || challengeId.isEmpty) {
        throw Exception('User and challenge ids are required.');
      }
      await _db
          .collection('users')
          .doc(uid)
          .collection('challenge_entries')
          .doc(challengeId)
          .delete();
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to leave challenge: $e');
    }
  }

  /// Watches the signed-in user's entries as `{challengeId: entry}`.
  Stream<Map<String, ChallengeEntry>> watchMyEntries(String uid) {
    if (uid.isEmpty) return Stream.value(const <String, ChallengeEntry>{});
    try {
      return _db
          .collection('users')
          .doc(uid)
          .collection('challenge_entries')
          .snapshots()
          .map((snap) {
            final entries = <String, ChallengeEntry>{};
            for (final doc in snap.docs) {
              final data = doc.data();
              entries[doc.id] = ChallengeEntry.fromMap(data);
            }
            return entries;
          })
          .handleError((Object e) {
            throw Exception('Failed to load challenge entries: $e');
          });
    } catch (e) {
      throw Exception('Failed to load challenge entries: $e');
    }
  }
}

/// Maps a raw challenge doc to [SocialChallenge] without modifying the model.
///
/// Injects the doc id and normalizes Firestore [Timestamp] dates to the ISO
/// strings [SocialChallenge.fromMap] expects.
SocialChallenge _challengeFromDoc(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = Map<String, dynamic>.from(doc.data());
  data['id'] = doc.id;
  for (final key in <String>['startDate', 'endDate']) {
    final value = data[key];
    if (value is Timestamp) {
      data[key] = value.toDate().toIso8601String();
    }
  }
  return SocialChallenge.fromMap(data);
}

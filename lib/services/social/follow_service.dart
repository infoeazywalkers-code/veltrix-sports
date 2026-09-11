import 'package:cloud_firestore/cloud_firestore.dart';

/// Follow graph stored in the top-level `follows` collection.
///
/// Each document carries `{followerId, followingId, createdAt}`.
/// Reads/writes are constrained by `firestore.rules` (owner-only writes).
class FollowService {
  final FirebaseFirestore _db;

  FollowService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _follows =>
      _db.collection('follows');

  Future<void> follow(String followerId, String followingId) async {
    try {
      if (followerId.isEmpty || followingId.isEmpty) {
        throw Exception('Both follower and following ids are required.');
      }
      if (followerId == followingId) {
        throw Exception('You cannot follow yourself.');
      }
      final existing =
          await _follows
              .where('followerId', isEqualTo: followerId)
              .where('followingId', isEqualTo: followingId)
              .limit(1)
              .get();
      if (existing.docs.isNotEmpty) return;
      await _follows.add({
        'followerId': followerId,
        'followingId': followingId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to follow athlete: $e');
    }
  }

  Future<void> unfollow(String followerId, String followingId) async {
    try {
      final matches =
          await _follows
              .where('followerId', isEqualTo: followerId)
              .where('followingId', isEqualTo: followingId)
              .get();
      for (final doc in matches.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to unfollow athlete: $e');
    }
  }

  Stream<bool> isFollowing(String followerId, String followingId) {
    if (followerId.isEmpty || followingId.isEmpty) {
      return Stream.value(false);
    }
    return _follows
        .where('followerId', isEqualTo: followerId)
        .where('followingId', isEqualTo: followingId)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty)
        .handleError((e) {
          throw Exception('Failed to watch follow status: $e');
        });
  }

  Stream<int> followerCount(String uid) {
    return _follows
        .where('followingId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.size)
        .handleError((e) {
          throw Exception('Failed to watch follower count: $e');
        });
  }

  Stream<int> followingCount(String uid) {
    return _follows
        .where('followerId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.size)
        .handleError((e) {
          throw Exception('Failed to watch following count: $e');
        });
  }
}

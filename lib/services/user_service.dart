import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_profile.dart';

class UserService {
  final FirebaseFirestore _db;

  UserService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> create(UserProfile profile) async {
    try {
      await _users.doc(profile.id).set(profile.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserProfile?> get(String id) async {
    try {
      final doc = await _users.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<UserProfile?> getByEmail(String email) async {
    try {
      final q = await _users.where('email', isEqualTo: email).limit(1).get();
      if (q.docs.isEmpty) return null;
      final doc = q.docs.first;
      return UserProfile.fromMap(doc.id, doc.data());
    } catch (e) {
      throw Exception('Failed to lookup user by email: $e');
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await _users.doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Stream<UserProfile?> watch(String id) {
    return _users
        .doc(id)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return UserProfile.fromMap(doc.id, doc.data()!);
        })
        .handleError((e) {
          throw Exception('Failed to watch user: $e');
        });
  }

  Future<void> upsert(UserProfile profile) async {
    try {
      final doc = await _users.doc(profile.id).get();
      if (doc.exists) {
        await _users.doc(profile.id).update(profile.toMap());
      } else {
        await _users.doc(profile.id).set(profile.toMap());
      }
    } catch (e) {
      throw Exception('Failed to upsert user: $e');
    }
  }
}

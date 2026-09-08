import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_preferences.dart';

class PreferencesService {
  final FirebaseFirestore _db;

  PreferencesService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _mainDoc(String uid) =>
      _db.collection('users').doc(uid).collection('preferences').doc('main');

  /// Reads the user's preferences document. Returns `null` when absent.
  Future<UserPreferences?> get(String uid) async {
    try {
      final doc = await _mainDoc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserPreferences.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to read preferences: $e');
    }
  }

  /// Streams the user's preferences document in real-time.
  Stream<UserPreferences?> watch(String uid) {
    return _mainDoc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return UserPreferences.fromMap(doc.data()!);
        })
        .handleError((e) {
          throw Exception('Failed to watch preferences: $e');
        });
  }

  /// Merges [partial] fields into the existing preferences document.
  /// Creates the document if it does not exist.
  Future<void> update(String uid, Map<String, dynamic> partial) async {
    try {
      await _mainDoc(uid).set(partial, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  /// Updates a single field using Firestore dot-notation.
  Future<void> updateField(String uid, String path, dynamic value) async {
    try {
      await _mainDoc(uid).set({path: value}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update preference field: $e');
    }
  }

  /// Recalculates heart-rate zones from the physical profile.
  HeartRateZones recalculateZones(PhysicalProfile physical) {
    final maxHr = physical.calculatedMaxHr;
    return HeartRateZones.autoFromMaxHr(maxHr);
  }
}

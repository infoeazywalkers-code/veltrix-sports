import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/user_preferences.dart';

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
      await _mainDoc(
        uid,
      ).set(_expandDottedKeys(partial), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  /// Updates a single field using Firestore dot-notation.
  Future<void> updateField(String uid, String path, dynamic value) async {
    try {
      await _mainDoc(
        uid,
      ).set(_expandDottedKeys({path: value}), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update preference field: $e');
    }
  }

  /// Expands dotted keys (e.g. `{'theme.mode': 'dark'}`) into nested maps
  /// (e.g. `{'theme': {'mode': 'dark'}}`) because Firestore `set()` does
  /// not expand dots (only `update()` does). Deep-merges shared prefixes
  /// so `{'a.b': 1, 'a.c': 2}` becomes `{'a': {'b': 1, 'c': 2}}`.
  Map<String, dynamic> _expandDottedKeys(Map<String, dynamic> input) {
    final result = <String, dynamic>{};
    for (final entry in input.entries) {
      final parts = entry.key.split('.');
      if (parts.length == 1) {
        result[entry.key] = entry.value;
        continue;
      }
      var cursor = result;
      for (var i = 0; i < parts.length - 1; i++) {
        final part = parts[i];
        final existing = cursor[part];
        if (existing is Map<String, dynamic>) {
          cursor = existing;
        } else if (existing is Map) {
          final converted = Map<String, dynamic>.from(existing);
          cursor[part] = converted;
          cursor = converted;
        } else {
          final created = <String, dynamic>{};
          cursor[part] = created;
          cursor = created;
        }
      }
      cursor[parts.last] = entry.value;
    }
    return result;
  }

  /// Recalculates heart-rate zones from the physical profile.
  HeartRateZones recalculateZones(PhysicalProfile physical) {
    final maxHr = physical.calculatedMaxHr;
    return HeartRateZones.autoFromMaxHr(maxHr);
  }
}

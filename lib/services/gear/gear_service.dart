import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/activity/gear_item.dart';

class GearService {
  final FirebaseFirestore _db;

  GearService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('gear');

  /// Parses [snap] into gear items, skipping corrupt docs so one bad doc
  /// never fails the whole stream.
  List<GearItem> _parseAll(QuerySnapshot<Map<String, dynamic>> snap) {
    final items = <GearItem>[];
    for (final doc in snap.docs) {
      try {
        items.add(GearItem.fromFirestore(doc));
      } catch (e) {
        debugPrint('GearService: skipping corrupt gear doc ${doc.id}: $e');
      }
    }
    return items;
  }

  Stream<List<GearItem>> watchGear(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('isRetired')
        .snapshots()
        .map(_parseAll);
  }

  Future<String> addGear(GearItem gear, String userId) async {
    final data = gear.toFirestore();
    data['userId'] = userId;
    final doc = await _col.add(data);
    return doc.id;
  }

  Future<void> updateGear(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  Future<void> retireGear(String id) async {
    await _col.doc(id).update({'isRetired': true});
  }

  Future<void> restoreGear(String id) async {
    await _col.doc(id).update({'isRetired': false});
  }

  Future<void> deleteGear(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> addDistance(String id, double km) async {
    await _col.doc(id).update({'distanceKm': FieldValue.increment(km)});
  }

  Future<List<GearItem>> getActiveGear(String userId) async {
    final snap =
        await _col
            .where('userId', isEqualTo: userId)
            .where('isRetired', isEqualTo: false)
            .get();
    return _parseAll(snap);
  }
}

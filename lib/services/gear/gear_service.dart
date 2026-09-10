import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/activity/gear_item.dart';

class GearService {
  final _col = FirebaseFirestore.instance.collection('gear');

  Stream<List<GearItem>> watchGear(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('isRetired')
        .snapshots()
        .map((snap) => snap.docs.map(GearItem.fromFirestore).toList());
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

  Future<void> addDistance(String id, double km) async {
    await _col.doc(id).update({'distanceKm': FieldValue.increment(km)});
  }

  Future<List<GearItem>> getActiveGear(String userId) async {
    final snap =
        await _col
            .where('userId', isEqualTo: userId)
            .where('isRetired', isEqualTo: false)
            .get();
    return snap.docs.map(GearItem.fromFirestore).toList();
  }
}

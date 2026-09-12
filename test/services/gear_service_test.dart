import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/gear_item.dart';
import 'package:veltrix_sports/services/gear/gear_service.dart';

GearItem makeGear({
  String id = '',
  String name = 'Test Bike',
  GearType type = GearType.bike,
  double distanceKm = 100,
  double maxDistanceKm = 5000,
  bool isRetired = false,
}) => GearItem(
  id: id,
  name: name,
  type: type,
  brandModel: 'Brand X',
  distanceKm: distanceKm,
  maxDistanceKm: maxDistanceKm,
  isRetired: isRetired,
);

void main() {
  group('GearService (FakeFirestore)', () {
    late FakeFirebaseFirestore firestore;
    late GearService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = GearService(db: firestore);
    });

    test('addGear stores userId on the document', () async {
      final id = await service.addGear(makeGear(), 'u1');
      final doc = await firestore.collection('gear').doc(id).get();
      expect(doc.data()?['userId'], 'u1');
      expect(doc.data()?['name'], 'Test Bike');
    });

    test('watchGear emits active and retired docs', () async {
      await service.addGear(makeGear(name: 'Retired', isRetired: true), 'u1');
      await service.addGear(makeGear(name: 'Active'), 'u1');
      final items = await service.watchGear('u1').first;
      // Server-side isRetired ordering comes from the deployed composite
      // index (gear: userId ASC + isRetired ASC), which the fake does not
      // emulate for booleans — so assert contents, not order, here.
      expect(items.map((g) => g.name).toSet(), {'Active', 'Retired'});
    });

    test('watchGear filters to the owner only', () async {
      await service.addGear(makeGear(name: 'Mine'), 'u1');
      await service.addGear(makeGear(name: 'Theirs'), 'u2');
      final items = await service.watchGear('u1').first;
      expect(items.map((g) => g.name), ['Mine']);
    });

    test('addDistance increments distanceKm', () async {
      final id = await service.addGear(makeGear(distanceKm: 100), 'u1');
      await service.addDistance(id, 25);
      final doc = await firestore.collection('gear').doc(id).get();
      expect(doc.data()?['distanceKm'], 125);
    });

    test('retireGear flips isRetired to true', () async {
      final id = await service.addGear(makeGear(), 'u1');
      await service.retireGear(id);
      final doc = await firestore.collection('gear').doc(id).get();
      expect(doc.data()?['isRetired'], isTrue);
    });

    test('restoreGear flips isRetired back to false', () async {
      final id = await service.addGear(makeGear(isRetired: true), 'u1');
      await service.restoreGear(id);
      final doc = await firestore.collection('gear').doc(id).get();
      expect(doc.data()?['isRetired'], isFalse);
    });

    test('deleteGear removes the document', () async {
      final id = await service.addGear(makeGear(), 'u1');
      await service.deleteGear(id);
      final doc = await firestore.collection('gear').doc(id).get();
      expect(doc.exists, isFalse);
    });

    test('getActiveGear excludes retired gear', () async {
      await service.addGear(makeGear(name: 'Active'), 'u1');
      await service.addGear(makeGear(name: 'Old', isRetired: true), 'u1');
      final items = await service.getActiveGear('u1');
      expect(items.map((g) => g.name), ['Active']);
    });

    test('watchGear skips a corrupt doc instead of failing', () async {
      await service.addGear(makeGear(name: 'Good'), 'u1');
      await firestore.collection('gear').add({
        'userId': 'u1',
        'name': 'Corrupt',
        'type': 'bike',
        'brandModel': '',
        'distanceKm': 'not-a-number',
        'maxDistanceKm': 500,
        'isRetired': false,
      });
      final items = await service.watchGear('u1').first;
      expect(items.map((g) => g.name), ['Good']);
    });
  });
}

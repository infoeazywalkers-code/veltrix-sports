import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/gear_item.dart';

Future<GearItem> gearFromMap(
  FakeFirebaseFirestore firestore,
  String id,
  Map<String, dynamic> data,
) async {
  await firestore.collection('gear').doc(id).set(data);
  final doc = await firestore.collection('gear').doc(id).get();
  return GearItem.fromFirestore(doc);
}

void main() {
  group('GearItem.fromFirestore null guards', () {
    test('missing document (null data) yields defaults, no throw', () async {
      final firestore = FakeFirebaseFirestore();
      final doc = await firestore.collection('gear').doc('missing').get();
      final item = GearItem.fromFirestore(doc);
      expect(item.id, 'missing');
      expect(item.name, '');
      expect(item.type, GearType.bike);
      expect(item.brandModel, '');
      expect(item.distanceKm, 0);
      expect(item.maxDistanceKm, 0);
      expect(item.isRetired, isFalse);
    });

    test('empty map yields defaults, no throw', () async {
      final firestore = FakeFirebaseFirestore();
      final item = await gearFromMap(firestore, 'g1', {});
      expect(item.name, '');
      expect(item.type, GearType.bike);
      expect(item.isRetired, isFalse);
    });

    test('partial map fills missing fields with defaults', () async {
      final firestore = FakeFirebaseFirestore();
      final item = await gearFromMap(firestore, 'g2', {
        'name': '  Vaporflys  ',
        'distanceKm': 120,
      });
      expect(item.name, 'Vaporflys');
      expect(item.type, GearType.bike);
      expect(item.brandModel, '');
      expect(item.distanceKm, 120);
      expect(item.maxDistanceKm, 0);
      expect(item.isRetired, isFalse);
    });

    test('unknown type falls back to bike', () async {
      final firestore = FakeFirebaseFirestore();
      final item = await gearFromMap(firestore, 'g3', {
        'name': 'X',
        'type': 'hoverboard',
      });
      expect(item.type, GearType.bike);
    });

    test('known type parses', () async {
      final firestore = FakeFirebaseFirestore();
      final item = await gearFromMap(firestore, 'g4', {
        'name': 'Watch',
        'type': 'watch',
      });
      expect(item.type, GearType.watch);
    });
  });

  group('GearItem.usagePercent', () {
    const base = GearItem(
      id: 'x',
      name: 'x',
      type: GearType.bike,
      brandModel: '',
      distanceKm: 250,
      maxDistanceKm: 500,
    );

    test('computes 50% for half-used gear', () {
      expect(base.usagePercent, 50);
    });

    test('clamps above 100%', () {
      const over = GearItem(
        id: 'x',
        name: 'x',
        type: GearType.bike,
        brandModel: '',
        distanceKm: 600,
        maxDistanceKm: 500,
      );
      expect(over.usagePercent, 100);
    });

    test('zero max returns 0 instead of dividing', () {
      const zero = GearItem(
        id: 'x',
        name: 'x',
        type: GearType.bike,
        brandModel: '',
        distanceKm: 100,
        maxDistanceKm: 0,
      );
      expect(zero.usagePercent, 0);
    });
  });

  group('GearItem.needsReplacement 85% boundary', () {
    GearItem at(double distance) => GearItem(
      id: 'x',
      name: 'x',
      type: GearType.shoes,
      brandModel: '',
      distanceKm: distance,
      maxDistanceKm: 1000,
    );

    test('below 85% does not need replacement', () {
      expect(at(849).needsReplacement, isFalse);
    });

    test('exactly 85% needs replacement', () {
      expect(at(850).needsReplacement, isTrue);
    });

    test('above 85% needs replacement', () {
      expect(at(900).needsReplacement, isTrue);
    });
  });
}

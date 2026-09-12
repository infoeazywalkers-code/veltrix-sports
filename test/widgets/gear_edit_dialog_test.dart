import 'dart:async';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/gear_item.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/screens/gear/widgets/gear_edit_dialog.dart';
import 'package:veltrix_sports/services/gear/gear_service.dart';

class SpyGearService extends GearService {
  int addCalls = 0;
  int updateCalls = 0;
  Future<String> Function()? onAdd;

  SpyGearService() : super(db: FakeFirebaseFirestore());

  @override
  Future<String> addGear(GearItem gear, String userId) async {
    addCalls++;
    final fn = onAdd;
    if (fn != null) return fn();
    return 'spy-id';
  }

  @override
  Future<void> updateGear(String id, Map<String, dynamic> data) async {
    updateCalls++;
  }
}

Widget wrapDialog({GearItem? existing, required SpyGearService spy}) =>
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(MockUser(uid: 'u1')),
        gearServiceProvider.overrideWithValue(spy),
      ],
      child: MaterialApp(
        home: Scaffold(body: GearEditDialog(existing: existing)),
      ),
    );

/// Field order in the dialog: 0 name, 1 brand, 2 distance, 3 max.
Future<void> fillValid(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'Test Bike');
  await tester.enterText(find.byType(TextFormField).at(3), '500');
  await tester.pump();
}

void main() {
  group('GearEditDialog validation', () {
    testWidgets('type defaults to bike', (tester) async {
      await tester.pumpWidget(wrapDialog(spy: SpyGearService()));
      await tester.pumpAndSettle();
      final segmented = tester.widget<SegmentedButton<GearType>>(
        find.byType(SegmentedButton<GearType>),
      );
      expect(segmented.selected, {GearType.bike});
    });

    testWidgets('max distance of 0 is rejected with no write', (tester) async {
      final spy = SpyGearService();
      await tester.pumpWidget(wrapDialog(spy: spy));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Bike');
      await tester.enterText(find.byType(TextFormField).at(3), '0');
      await tester.tap(find.widgetWithText(FilledButton, 'Add gear'));
      await tester.pumpAndSettle();
      expect(find.text('Max distance must be more than 0'), findsOneWidget);
      expect(spy.addCalls, 0);
    });

    testWidgets('negative distance is rejected with no write', (tester) async {
      final spy = SpyGearService();
      await tester.pumpWidget(wrapDialog(spy: spy));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Bike');
      await tester.enterText(find.byType(TextFormField).at(2), '-5');
      await tester.enterText(find.byType(TextFormField).at(3), '500');
      await tester.tap(find.widgetWithText(FilledButton, 'Add gear'));
      await tester.pumpAndSettle();
      expect(find.text("Distance can't be negative"), findsOneWidget);
      expect(spy.addCalls, 0);
    });

    testWidgets('usage preview updates live', (tester) async {
      await tester.pumpWidget(wrapDialog(spy: SpyGearService()));
      await tester.pumpAndSettle();
      expect(find.text('Set a max distance to preview usage'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(2), '250');
      await tester.enterText(find.byType(TextFormField).at(3), '500');
      await tester.pump();
      expect(find.text('Usage 50%'), findsOneWidget);
    });

    testWidgets('double submit writes a single doc', (tester) async {
      final spy = SpyGearService();
      final gate = Completer<String>();
      spy.onAdd = () => gate.future;
      await tester.pumpWidget(wrapDialog(spy: spy));
      await tester.pumpAndSettle();
      await fillValid(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Add gear'));
      await tester.pump();
      // Second tap while saving: button is disabled, so no second write.
      await tester.tap(find.widgetWithText(FilledButton, 'Saving…'));
      await tester.pump();
      gate.complete('spy-id');
      await tester.pumpAndSettle();
      expect(spy.addCalls, 1);
      expect(find.byType(GearEditDialog), findsNothing);
    });
  });

  group('GearEditDialog edit mode', () {
    testWidgets('prefills fields and saves via updateGear', (tester) async {
      final spy = SpyGearService();
      const existing = GearItem(
        id: 'g1',
        name: 'Old Name',
        type: GearType.shoes,
        brandModel: 'Nike',
        distanceKm: 100,
        maxDistanceKm: 800,
      );
      await tester.pumpWidget(wrapDialog(existing: existing, spy: spy));
      await tester.pumpAndSettle();
      expect(find.text('Old Name'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Save changes'), findsOneWidget);
      final segmented = tester.widget<SegmentedButton<GearType>>(
        find.byType(SegmentedButton<GearType>),
      );
      expect(segmented.selected, {GearType.shoes});
      await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
      await tester.pumpAndSettle();
      expect(spy.updateCalls, 1);
      expect(spy.addCalls, 0);
      expect(find.byType(GearEditDialog), findsNothing);
    });
  });
}

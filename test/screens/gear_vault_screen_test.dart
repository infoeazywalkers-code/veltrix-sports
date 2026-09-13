import 'dart:async';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/gear_item.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/screens/gear/gear_vault_screen.dart';
import 'package:veltrix_sports/screens/gear/widgets/gear_edit_dialog.dart';
import 'package:veltrix_sports/services/gear/gear_service.dart';

class SpyGearService extends GearService {
  int addCalls = 0;
  int retireCalls = 0;

  SpyGearService() : super(db: FakeFirebaseFirestore());

  @override
  Future<String> addGear(GearItem gear, String userId) async {
    addCalls++;
    return 'spy-id';
  }

  @override
  Future<void> retireGear(String id) async {
    retireCalls++;
  }
}

GearItem makeGear({
  String id = 'g1',
  String name = 'Road Bike',
  GearType type = GearType.bike,
  double distanceKm = 200,
  double maxDistanceKm = 1000,
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

Widget wrapVault({List<Override> extra = const []}) => ProviderScope(
  overrides: [
    currentUserProvider.overrideWithValue(MockUser(uid: 'u1')),
    ...extra,
  ],
  child: const MaterialApp(home: Scaffold(body: GearVaultScreen())),
);

void main() {
  group('GearVaultScreen provider states', () {
    testWidgets('loading shows a spinner', (tester) async {
      await tester.pumpWidget(
        wrapVault(
          extra: [
            gearListProvider.overrideWith(
              (ref) => StreamController<List<GearItem>>().stream,
            ),
          ],
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error shows a message, no crash', (tester) async {
      await tester.pumpWidget(
        wrapVault(
          extra: [
            gearListProvider.overrideWith(
              (ref) => Stream<List<GearItem>>.error(Exception('nope')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining("Couldn't load gear"), findsOneWidget);
    });

    testWidgets('signed-out shows a prompt, no crash', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: Scaffold(body: GearVaultScreen())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sign in to view your gear'), findsOneWidget);
    });

    testWidgets('empty vault is honest, no fake rows', (tester) async {
      await tester.pumpWidget(
        wrapVault(
          extra: [
            gearListProvider.overrideWith((ref) => Stream.value(const [])),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Gear Vault is empty'), findsOneWidget);
      expect(find.text('Add Gear'), findsOneWidget);
    });

    testWidgets('two docs both render with totals', (tester) async {
      await tester.pumpWidget(
        wrapVault(
          extra: [
            gearListProvider.overrideWith(
              (ref) => Stream.value([
                makeGear(),
                makeGear(
                  id: 'g2',
                  name: 'Vaporflys',
                  type: GearType.shoes,
                  distanceKm: 150,
                  maxDistanceKm: 500,
                ),
              ]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Road Bike'), findsOneWidget);
      expect(find.text('Vaporflys'), findsOneWidget);
      expect(find.text('350 km'), findsOneWidget);
      expect(find.text('Active Gear'), findsOneWidget);
    });

    testWidgets('retired doc gets RETIRED styling', (tester) async {
      await tester.pumpWidget(
        wrapVault(
          extra: [
            gearListProvider.overrideWith(
              (ref) => Stream.value([makeGear(isRetired: true)]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Road Bike'), findsOneWidget);
      expect(find.text('RETIRED'), findsOneWidget);
    });
  });

  group('GearVaultScreen CRUD wiring', () {
    testWidgets('FAB opens the add dialog', (tester) async {
      await tester.pumpWidget(
        wrapVault(
          extra: [
            gearListProvider.overrideWith((ref) => Stream.value(const [])),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Gear'));
      await tester.pumpAndSettle();
      expect(find.byType(GearEditDialog), findsOneWidget);
    });

    testWidgets('empty name is blocked with no write', (tester) async {
      final spy = SpyGearService();
      await tester.pumpWidget(
        wrapVault(
          extra: [
            gearListProvider.overrideWith((ref) => Stream.value(const [])),
            gearServiceProvider.overrideWithValue(spy),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Gear'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Add gear'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a name'), findsOneWidget);
      expect(spy.addCalls, 0);
    });

    testWidgets('valid submit calls addGear once and closes', (tester) async {
      final spy = SpyGearService();
      await tester.pumpWidget(
        wrapVault(
          extra: [
            gearListProvider.overrideWith((ref) => Stream.value(const [])),
            gearServiceProvider.overrideWithValue(spy),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Gear'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Bike');
      await tester.enterText(find.byType(TextFormField).at(3), '500');
      await tester.tap(find.widgetWithText(FilledButton, 'Add gear'));
      await tester.pumpAndSettle();
      expect(spy.addCalls, 1);
      expect(find.byType(GearEditDialog), findsNothing);
    });

    testWidgets('retire affordance flips the flag', (tester) async {
      final spy = SpyGearService();
      await tester.pumpWidget(
        wrapVault(
          extra: [
            gearListProvider.overrideWith((ref) => Stream.value([makeGear()])),
            gearServiceProvider.overrideWithValue(spy),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Retire gear?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Retire'));
      await tester.pumpAndSettle();
      expect(spy.retireCalls, 1);
    });

    testWidgets('live retire moves one doc to retired styling', (tester) async {
      final fake = FakeFirebaseFirestore();
      for (final name in ['Bike A', 'Bike B']) {
        await fake.collection('gear').add({
          'userId': 'u1',
          'name': name,
          'type': 'bike',
          'brandModel': '',
          'distanceKm': 10,
          'maxDistanceKm': 1000,
          'isRetired': false,
        });
      }
      final service = GearService(db: fake);
      await tester.pumpWidget(
        wrapVault(extra: [gearServiceProvider.overrideWithValue(service)]),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bike A'), findsOneWidget);
      expect(find.text('Bike B'), findsOneWidget);
      expect(find.text('RETIRED'), findsNothing);

      final snap = await fake
          .collection('gear')
          .where('userId', isEqualTo: 'u1')
          .get();
      await service.retireGear(snap.docs.first.id);
      await tester.pumpAndSettle();
      expect(find.text('RETIRED'), findsOneWidget);
    });
  });
}

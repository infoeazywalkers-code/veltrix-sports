import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veltrix_sports/widgets/device_connect_dialog.dart';

class _FakeAuthPlatform extends FirebaseAuthPlatform {
  _FakeAuthPlatform() : super();
  @override
  UserPlatform? get currentUser => null;
  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) => this;
  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) => this;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAuthPlatform.instance = _FakeAuthPlatform();
  });
  Widget openDialog(Widget dialog) => MaterialApp(
    home: Builder(
      builder:
          (context) => Scaffold(
            body: ElevatedButton(
              onPressed:
                  () => showDialog(context: context, builder: (_) => dialog),
              child: const Text('Open'),
            ),
          ),
    ),
  );

  group('DeviceConnectDialog', () {
    testWidgets('renders with device name in title', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Apple Watch Series 9',
            category: 'Wearable',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Apple Watch Series 9'), findsWidgets);
    });

    testWidgets('shows category in content area', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Garmin Forerunner',
            category: 'Running Watch',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Running Watch'), findsOneWidget);
    });

    testWidgets('shows DISCONNECTED status when not connected', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Polar H10',
            category: 'Heart Rate',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('DISCONNECTED'), findsOneWidget);
    });

    testWidgets('shows CONNECTED status when connected', (tester) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Apple Watch': true,
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Apple Watch',
            category: 'Wearable',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('CONNECTED'), findsOneWidget);
    });

    testWidgets('shows Pair & Connect button when disconnected', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Wahoo TICKR',
            category: 'Heart Rate',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Pair & Connect'), findsOneWidget);
    });

    testWidgets('shows Disconnect Device button when connected', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Apple Watch': true,
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Apple Watch',
            category: 'Wearable',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Disconnect Device'), findsOneWidget);
    });

    testWidgets('close button dismisses dialog', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Test Device',
            category: 'Sensor',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Close'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows bluetooth_disabled icon when disconnected', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Test Sensor',
            category: 'Sensor',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);
    });

    testWidgets('shows bluetooth_connected icon when connected', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Apple Watch': true,
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Apple Watch',
            category: 'Wearable',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.bluetooth_connected), findsOneWidget);
    });

    testWidgets('shows pairing instruction text when disconnected', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Test Device',
            category: 'Sensor',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Pair this device to sync workouts directly from your wearable sensor.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows auto-sync text when connected', (tester) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Apple Watch': true,
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Apple Watch',
            category: 'Wearable',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Auto-sync is enabled. Veltrix will fetch heart rate, power, and GPS tracks automatically.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows Category label in info card', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Wahoo TICKR',
            category: 'Heart Rate',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });

    testWidgets('shows Last Sync row when connected', (tester) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Apple Watch': true,
        'device_sync_Apple Watch': DateTime.now().toIso8601String(),
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Apple Watch',
            category: 'Wearable',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Last Sync'), findsOneWidget);
    });

    testWidgets('does not show Last Sync row when disconnected', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Test Sensor',
            category: 'Sensor',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Last Sync'), findsNothing);
    });

    testWidgets('shows Sync HealthKit button for wearable devices', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Apple Watch': true,
        'device_sync_Apple Watch': DateTime.now().toIso8601String(),
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Apple Watch',
            category: 'Wearable',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Sync HealthKit'), findsOneWidget);
    });

    testWidgets('shows Sync HealthKit for devices with watch in name', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Samsung Galaxy Watch 6': true,
        'device_sync_Samsung Galaxy Watch 6': DateTime.now().toIso8601String(),
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Samsung Galaxy Watch 6',
            category: 'Smartwatch',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Sync HealthKit'), findsOneWidget);
    });

    testWidgets('shows Force Sync for connected non-wearable device', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Wahoo KICKR': true,
        'device_sync_Wahoo KICKR': DateTime.now().toIso8601String(),
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Wahoo KICKR',
            category: 'Trainer',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Force Sync'), findsOneWidget);
    });

    testWidgets('no extra sync button for disconnected non-wearable device', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Wahoo KICKR',
            category: 'Trainer',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Force Sync'), findsNothing);
      expect(find.text('Sync HealthKit'), findsNothing);
    });

    testWidgets('tapping pair button shows syncing indicator', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Polar H10',
            category: 'Heart Rate',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pair & Connect'));
      await tester.pump();
      expect(find.text('Communicating with sensor...'), findsOneWidget);
      // Advance past the 900ms timer and let the snackbar settle
      await tester.pump(const Duration(milliseconds: 4000));
    });

    testWidgets('tapping disconnect button shows syncing indicator', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Apple Watch': true,
        'device_sync_Apple Watch': DateTime.now().toIso8601String(),
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Apple Watch',
            category: 'Wearable',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Disconnect Device'));
      await tester.pump();
      expect(find.text('Communicating with sensor...'), findsOneWidget);
      // Advance past the 900ms timer so the test completes cleanly
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Sync HealthKit triggers sync flow', (tester) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Apple Watch': true,
        'device_sync_Apple Watch': DateTime.now().toIso8601String(),
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Apple Watch',
            category: 'Wearable',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sync HealthKit'));
      await tester.pump();
      // Sync HealthKit triggers WatchSyncService which has timers
      // Just verify no crash — the BLE service singleton has periodic timers
      // that prevent pumpAndSettle, so we use pump with duration only
      await tester.pump(const Duration(milliseconds: 3000));
    });

    testWidgets('tapping Force Sync triggers manual sync flow', (tester) async {
      SharedPreferences.setMockInitialValues({
        'device_status_Wahoo KICKR': true,
        'device_sync_Wahoo KICKR': DateTime.now().toIso8601String(),
      });
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Wahoo KICKR',
            category: 'Trainer',
            isConnected: true,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Force Sync'));
      await tester.pump();
      expect(find.text('Communicating with sensor...'), findsOneWidget);
      // Advance past the 1000ms timer so the test completes cleanly
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
    });

    testWidgets('renders AlertDialog widget', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        openDialog(
          const DeviceConnectDialog(
            deviceName: 'Sensor',
            category: 'Sensor',
            isConnected: false,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}

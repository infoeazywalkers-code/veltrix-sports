import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/screens/devices_screen.dart';

Widget _wrap(Widget child) =>
    ProviderScope(child: MaterialApp(home: Scaffold(body: child)));

void _setMobile(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
}

void _setDesktop(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('DevicesScreen - top-level rendering', () {
    testWidgets('renders section intro and watch sync banner', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('DEVICES & WATCHES'), findsOneWidget);
      expect(find.text('One App, Endless Ways to Train'), findsOneWidget);
      expect(
        find.text('Apple Watch & HealthConnect Auto-Sync'),
        findsOneWidget,
      );
      expect(find.text('Sync Watch Workouts Now'), findsOneWidget);
      expect(find.text('Pair BLE Sensor'), findsOneWidget);
    });

    testWidgets('renders top device tiles', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Apple Watch Series 9'), findsWidgets);
      expect(find.text('Connected'), findsWidgets);
      expect(find.text('Tap to pair'), findsWidgets);
    });

    testWidgets('renders footer at bottom of screen', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -5000));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Veltrix Sports. All rights reserved'),
        findsOneWidget,
      );
    });
  });

  group('DevicesScreen - scrollable categories', () {
    testWidgets('scroll down reveals cycling and running categories', (
      tester,
    ) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('CYCLING'), findsOneWidget);
      expect(find.text('RUNNING'), findsOneWidget);
    });

    testWidgets('scroll further reveals VR, nutrition, coaching', (
      tester,
    ) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -1500));
      await tester.pumpAndSettle();

      expect(find.text('VIRTUAL REALITY'), findsOneWidget);
      expect(find.text('NUTRITION & HEALTH'), findsOneWidget);
      expect(find.text('COACHING & ANALYTICS'), findsOneWidget);
    });

    testWidgets('scroll to bottom reveals contact support', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.text('Contact support'), findsOneWidget);
    });
  });

  group('DevicesScreen - device chip interactions', () {
    testWidgets('tap cycling Garmin Edge chip opens dialog', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Garmin Edge'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('tap connected device in top devices opens dialog', (
      tester,
    ) async {
      _setDesktop(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apple Watch Series 9').first);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('DevicesScreen - BLE pair button', () {
    testWidgets('tap Pair BLE Sensor opens dialog', (tester) async {
      _setDesktop(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pair BLE Sensor'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('DevicesScreen - desktop layout', () {
    testWidgets('desktop renders all top-level sections', (tester) async {
      _setDesktop(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('DEVICES & WATCHES'), findsOneWidget);
      expect(find.text('One App, Endless Ways to Train'), findsOneWidget);
      expect(
        find.text('Apple Watch & HealthConnect Auto-Sync'),
        findsOneWidget,
      );
    });
  });

  group('DevicesScreen - additional coverage', () {
    testWidgets('contact support button shows snackbar', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -3000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contact support'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Sync Watch Workouts Now button exists', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Sync Watch Workouts Now'), findsOneWidget);
    });

    testWidgets('watch sync banner shows description text', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Auto-import workouts from Apple Watch, Garmin, Polar & COROS',
        ),
        findsOneWidget,
      );
    });

    testWidgets('tap COROS PACE 3 chip opens dialog', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('COROS PACE 3'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('tap Zwift Companion chip opens dialog', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -1500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zwift Companion'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('tap MyFitnessPal chip opens dialog', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -1500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('MyFitnessPal'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('tap TrainingPeaks chip opens dialog', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -2000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('TrainingPeaks'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('mobile layout adjusts padding', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      // Verify ListView has the correct padding for mobile
      final listView = tester.widget<ListView>(find.byType(ListView));
      final padding = listView.padding! as EdgeInsets;
      expect(padding.left, 18);
      expect(padding.right, 18);
    });

    testWidgets('desktop layout adjusts padding', (tester) async {
      _setDesktop(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = tester.widget<ListView>(find.byType(ListView));
      final padding = listView.padding! as EdgeInsets;
      expect(padding.left, 40);
      expect(padding.right, 40);
    });

    testWidgets('tap STRYD Footpod chip opens dialog', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('STRYD Footpod'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('tap Polar Vantage chip opens dialog', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Polar Vantage'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('top devices show Connected/Tap to pair text', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Connected'), findsWidgets);
      expect(find.text('Tap to pair'), findsWidgets);
    });

    testWidgets('swimming devices section renders', (tester) async {
      _setMobile(tester);
      await tester.pumpWidget(_wrap(const DevicesScreen()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(find.text('SWIMMING'), findsOneWidget);
      expect(find.text('Garmin Swim 2'), findsOneWidget);
    });
  });
}

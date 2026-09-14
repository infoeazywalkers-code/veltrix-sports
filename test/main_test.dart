import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:veltrix_sports/main.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/shell.dart';
import 'package:veltrix_sports/mobile/shell.dart';
import 'package:veltrix_sports/widgets/common/error_boundary.dart';

/// Pumps [VeltrixRoot] with a signed-in user so [AuthWrapper] renders the
/// shell instead of [LoginScreen]. Other providers (profile, notifications)
/// fall back to their loading defaults, which shells tolerate.
Widget signedInRoot() => ProviderScope(
  overrides: [
    authStateProvider.overrideWith(
      (ref) => Stream.value(MockUser(uid: 'test-uid', email: 't@t.com')),
    ),
  ],
  child: const VeltrixRoot(),
);

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('overflowed')) return;
      FlutterError.presentError(details);
    };
  });

  tearDown(() {
    FlutterError.onError = FlutterError.presentError;
  });

  group('VeltrixScrollBehavior', () {
    test('dragDevices includes touch', () {
      const behavior = VeltrixScrollBehavior();
      expect(behavior.dragDevices, contains(PointerDeviceKind.touch));
    });

    test('dragDevices includes mouse', () {
      const behavior = VeltrixScrollBehavior();
      expect(behavior.dragDevices, contains(PointerDeviceKind.mouse));
    });

    test('dragDevices includes trackpad', () {
      const behavior = VeltrixScrollBehavior();
      expect(behavior.dragDevices, contains(PointerDeviceKind.trackpad));
    });

    test('dragDevices includes stylus', () {
      const behavior = VeltrixScrollBehavior();
      expect(behavior.dragDevices, contains(PointerDeviceKind.stylus));
    });

    test('dragDevices has exactly 4 entries', () {
      const behavior = VeltrixScrollBehavior();
      expect(behavior.dragDevices.length, 4);
    });

    testWidgets('getScrollPhysics returns BouncingScrollPhysics on iOS', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      late ScrollPhysics physics;
      try {
        const behavior = VeltrixScrollBehavior();
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                physics = behavior.getScrollPhysics(context);
                return const Scaffold();
              },
            ),
          ),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
      expect(physics, isA<BouncingScrollPhysics>());
    });

    testWidgets('getScrollPhysics returns ClampingScrollPhysics on Android', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      late ScrollPhysics physics;
      try {
        const behavior = VeltrixScrollBehavior();
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                physics = behavior.getScrollPhysics(context);
                return const Scaffold();
              },
            ),
          ),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
      expect(physics, isA<ClampingScrollPhysics>());
    });
  });

  group('VeltrixRoot', () {
    testWidgets('renders MaterialApp', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(signedInRoot());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('desktop width shows Shell', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(signedInRoot());
      await tester.pumpAndSettle();
      expect(find.byType(Shell), findsOneWidget);
    });

    testWidgets('mobile width shows MobileShell', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(signedInRoot());
      await tester.pumpAndSettle();
      expect(find.byType(MobileShell), findsOneWidget);
    });

    testWidgets('sets Veltrix Sports as title', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(signedInRoot());
      await tester.pumpAndSettle();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'Veltrix Sports');
    });

    testWidgets('disables debug banner', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(signedInRoot());
      await tester.pumpAndSettle();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.debugShowCheckedModeBanner, false);
    });

    testWidgets('uses VeltrixScrollBehavior', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(signedInRoot());
      await tester.pumpAndSettle();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.scrollBehavior, isA<VeltrixScrollBehavior>());
    });

    testWidgets('uses Material3', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(signedInRoot());
      await tester.pumpAndSettle();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, true);
    });

    testWidgets('boundary between mobile and desktop is 900', (tester) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(signedInRoot());
      await tester.pumpAndSettle();
      // At exactly 900, should use desktop layout (>=900)
      expect(find.byType(Shell), findsOneWidget);
    });

    testWidgets('899 wide uses mobile layout', (tester) async {
      tester.view.physicalSize = const Size(899, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(signedInRoot());
      await tester.pumpAndSettle();
      expect(find.byType(MobileShell), findsOneWidget);
    });
  });

  group('VeltrixErrorBoundary', () {
    testWidgets('renders error message', (tester) async {
      final details = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );
      await tester.pumpWidget(
        MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );
      expect(find.text('SOMETHING WENT WRONG'), findsOneWidget);
    });

    testWidgets('renders reload button', (tester) async {
      final details = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );
      await tester.pumpWidget(
        MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );
      expect(find.text('Reload Application View'), findsOneWidget);
    });

    testWidgets('renders warning icon', (tester) async {
      final details = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );
      await tester.pumpWidget(
        MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders safety message', (tester) async {
      final details = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );
      await tester.pumpWidget(
        MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );
      expect(find.textContaining('your workout data is safe'), findsOneWidget);
    });

    testWidgets('tap reload button navigates back', (tester) async {
      final details = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              const MaterialPage(child: Text('prev')),
              MaterialPage(child: VeltrixErrorBoundary(details: details)),
            ],
            // ignore: deprecated_member_use
            onPopPage: (route, result) => route.didPop(result),
          ),
        ),
      );
      await tester.tap(find.text('Reload Application View'));
      await tester.pumpAndSettle();
      expect(find.text('prev'), findsOneWidget);
    });
  });
}

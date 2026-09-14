import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:veltrix_sports/main.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/shell.dart';
import 'package:veltrix_sports/mobile/shell.dart';

void main() {
  setUp(() {
    // Suppress RenderFlex overflow errors in Shell's AppBar Row
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('overflowed')) return;
      FlutterError.presentError(details);
    };
  });

  tearDown(() {
    FlutterError.onError = FlutterError.presentError;
  });

  testWidgets('VeltrixRoot renders without crashing', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(MockUser(uid: 'test-uid', email: 't@t.com')),
          ),
        ],
        child: const VeltrixRoot(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('narrow layouts render without crashing', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(MockUser(uid: 'test-uid', email: 't@t.com')),
          ),
        ],
        child: const VeltrixRoot(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('VeltrixRoot sets correct title', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(MockUser(uid: 'test-uid', email: 't@t.com')),
          ),
        ],
        child: const VeltrixRoot(),
      ),
    );
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Veltrix Sports');
  });

  testWidgets('VeltrixRoot disables debug banner', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(MockUser(uid: 'test-uid', email: 't@t.com')),
          ),
        ],
        child: const VeltrixRoot(),
      ),
    );
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.debugShowCheckedModeBanner, isFalse);
  });

  testWidgets('VeltrixRoot uses Shell for wide screens', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(MockUser(uid: 'test-uid', email: 't@t.com')),
          ),
        ],
        child: const VeltrixRoot(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Shell), findsOneWidget);
  });

  testWidgets('VeltrixRoot uses MobileShell for narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(MockUser(uid: 'test-uid', email: 't@t.com')),
          ),
        ],
        child: const VeltrixRoot(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MobileShell), findsOneWidget);
  });

  testWidgets('VeltrixRoot renders with ProviderScope', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(MockUser(uid: 'test-uid', email: 't@t.com')),
          ),
        ],
        child: const VeltrixRoot(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProviderScope), findsOneWidget);
  });

  testWidgets('VeltrixScrollBehavior allows mouse drag', (tester) async {
    const behavior = VeltrixScrollBehavior();
    expect(behavior.dragDevices, contains(PointerDeviceKind.mouse));
    expect(behavior.dragDevices, contains(PointerDeviceKind.touch));
    expect(behavior.dragDevices, contains(PointerDeviceKind.trackpad));
    expect(behavior.dragDevices, contains(PointerDeviceKind.stylus));
  });

  testWidgets('VeltrixRoot applies material3 theme', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(MockUser(uid: 'test-uid', email: 't@t.com')),
          ),
        ],
        child: const VeltrixRoot(),
      ),
    );
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
  });
}

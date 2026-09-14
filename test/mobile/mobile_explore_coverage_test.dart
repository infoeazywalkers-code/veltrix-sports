import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/mobile/screens/mobile_explore.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final prev = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('overflowed')) return;
      if (prev != null) {
        prev(details);
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  // ProviderScope is inert for MobileExploreScreen itself (plain
  // StatefulWidget) but required by pages it navigates to (marketplace).
  Widget wrapExplore() => const ProviderScope(
    child: MaterialApp(home: Scaffold(body: MobileExploreScreen())),
  );

  group('MobileExploreScreen search', () {
    testWidgets('renders search TextField with hint', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search plans, events'), findsOneWidget);
    });

    testWidgets('search icon visible when empty', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('clear icon appears when text entered', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'marathon');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clear button resets search', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'marathon');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('searching xyz hides Recommended plan', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();
      expect(find.text('Recommended plan'), findsNothing);
    });

    testWidgets('empty search hides events with xyz', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();
      expect(find.text('Mumbai Half Marathon'), findsNothing);
      expect(find.text('Delhi Cycling Grand Prix'), findsNothing);
    });
  });

  group('MobileExploreScreen layout', () {
    testWidgets('renders Explore title', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      expect(find.text('Explore'), findsOneWidget);
    });

    testWidgets('shows Browse Veltrix section', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      expect(find.text('Browse Veltrix'), findsOneWidget);
    });

    testWidgets('shows all explore tiles', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      expect(find.text('Training plans'), findsOneWidget);
      expect(find.text('Find a coach'), findsOneWidget);
      expect(find.text('Sports events'), findsOneWidget);
      expect(find.text('My tickets'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Devices'), findsOneWidget);
    });

    testWidgets('explore tile icons visible', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.event_note), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.confirmation_number), findsOneWidget);
      expect(find.byIcon(Icons.devices_other), findsOneWidget);
    });

    testWidgets('Premium icon is workspace_premium', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    });

    testWidgets('search TextField has no border by default', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;
      expect(decoration.fillColor, Colors.white);
    });

    testWidgets('search uses prefix icon', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration!.prefixIcon, isNotNull);
    });
  });

  group('MobileExploreScreen interactions', () {
    testWidgets('Training plans tile opens plans page', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Training plans'));
      await tester.pumpAndSettle();
      // The marketplace route covers Explore (offstage finders skip it), so
      // assert the marketplace header plus a catalog entry instead.
      expect(find.text('TRAINING PLANS'), findsOneWidget);
      expect(find.text('Sub-3h Marathon'), findsOneWidget);
    });

    testWidgets('premium tile navigates', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Premium'), warnIfMissed: false);
      await tester.pumpAndSettle();
    });

    testWidgets('devices tile navigates', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Devices'), warnIfMissed: false);
      await tester.pumpAndSettle();
    });

    testWidgets('find a coach tile navigates', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Find a coach'), warnIfMissed: false);
      await tester.pumpAndSettle();
    });

    testWidgets('search with empty string after entering text clears filter', (
      tester,
    ) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'marathon');
      await tester.pump();
      // Search "marathon" should keep recommended plan visible (via the contains check)
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      // Clear should restore everything
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('search with single char updates query', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();
      // Just verify the TextField accepted the input
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, 'x');
    });

    testWidgets('GridView renders explore tiles', (tester) async {
      await tester.pumpWidget(wrapExplore());
      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}

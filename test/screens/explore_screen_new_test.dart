import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/screens/explore_screen.dart';

void main() {
  Widget wrap(Widget child, {ValueChanged<int>? onNavigate}) =>
      MaterialApp(home: Scaffold(body: child));

  // Helper to scroll the ExploreScreen's ListView to the bottom
  Future<void> scrollDown(WidgetTester tester) async {
    final listView = find.byType(ListView);
    await tester.drag(listView, const Offset(0, -2000));
    await tester.pumpAndSettle();
  }

  group('ExploreScreen', () {
    testWidgets('renders search field and hint', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search plans, events, coaches'), findsOneWidget);
    });

    testWidgets('renders Browse Veltrix section', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Browse Veltrix'), findsOneWidget);
    });

    testWidgets('renders all 6 explore tiles', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Training plans'), findsOneWidget);
      expect(find.text('Find a coach'), findsOneWidget);
      expect(find.text('Sports events'), findsOneWidget);
      expect(find.text('My tickets'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Devices'), findsOneWidget);
    });

    testWidgets('renders explore tile icons', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.event_note), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.confirmation_number), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
      expect(find.byIcon(Icons.devices_other), findsOneWidget);
    });

    testWidgets('renders arrow forward icons on explore tiles', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_forward), findsWidgets);
    });

    testWidgets('renders recommended plan after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Recommended plan'), findsOneWidget);
      expect(find.text('See plans'), findsOneWidget);
      expect(find.text('Marathon Training Pro'), findsOneWidget);
    });

    testWidgets('renders marathon plan details after scrolling', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.textContaining('Build endurance'), findsOneWidget);
      expect(find.text('16 weeks  \u2022  Coach Amit'), findsOneWidget);
    });

    testWidgets('renders View plan button after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('View plan'), findsOneWidget);
    });

    testWidgets('tap View plan opens training plans page', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      await tester.tap(find.text('View plan'));
      await tester.pumpAndSettle();
      expect(find.text('Training plans'), findsWidgets);
      expect(find.text('Cycling Performance Builder'), findsOneWidget);
    });

    testWidgets('renders upcoming events section after scrolling', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.textContaining('Upcoming events (3)'), findsOneWidget);
    });

    testWidgets('renders all three events after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('Mumbai Half Marathon'), findsOneWidget);
      expect(find.text('Delhi Cycling Grand Prix'), findsOneWidget);
      expect(find.text('Goa Triathlon Challenge'), findsOneWidget);
    });

    testWidgets('renders event date months after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('OCT'), findsOneWidget);
      expect(find.text('NOV'), findsOneWidget);
      expect(find.text('DEC'), findsOneWidget);
    });

    testWidgets('tap event opens dialog after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      await tester.tap(find.text('Mumbai Half Marathon'));
      await tester.pumpAndSettle();
      expect(find.text('About the Event'), findsOneWidget);
    });

    testWidgets('tap close button dismisses dialog', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      await tester.tap(find.text('Mumbai Half Marathon'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('About the Event'), findsNothing);
    });

    testWidgets('search filters events', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Delhi');
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('Delhi Cycling Grand Prix'), findsOneWidget);
      expect(find.text('Mumbai Half Marathon'), findsNothing);
      expect(find.text('Goa Triathlon Challenge'), findsNothing);
    });

    testWidgets('non-matching search shows no events', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'xyznonexistent');
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('No matching events found.'), findsOneWidget);
    });

    testWidgets('clear search resets query', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.clear), findsOneWidget);
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('Mumbai Half Marathon'), findsOneWidget);
    });

    testWidgets('search by location', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Goa');
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('Goa Triathlon Challenge'), findsOneWidget);
      expect(find.text('Mumbai Half Marathon'), findsNothing);
    });

    testWidgets('recommended plan hidden for unrelated search', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();
      expect(find.text('Marathon Training Pro'), findsNothing);
    });

    testWidgets('tap Training plans opens feature page', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Training plans'));
      await tester.pumpAndSettle();
      expect(find.text('Training plans'), findsWidgets);
      expect(find.text('Marathon Training Pro'), findsOneWidget);
    });

    testWidgets('tap Find a coach calls onNavigate(6)', (tester) async {
      int navigatedTo = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreScreen(onNavigate: (i) => navigatedTo = i),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Find a coach'));
      expect(navigatedTo, 6);
    });

    testWidgets('tap Sports events opens feature page', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sports events'));
      await tester.pumpAndSettle();
      expect(find.text('Sports events'), findsWidgets);
      expect(find.text('Delhi Cycling Grand Prix'), findsOneWidget);
    });

    testWidgets('tap My tickets opens feature page', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My tickets'));
      await tester.pumpAndSettle();
      expect(find.text('My tickets'), findsWidgets);
      expect(find.text('No active tickets'), findsOneWidget);
    });

    testWidgets('tap Premium calls onNavigate(5)', (tester) async {
      int navigatedTo = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreScreen(onNavigate: (i) => navigatedTo = i),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Premium'));
      expect(navigatedTo, 5);
    });

    testWidgets('tap Devices calls onNavigate(7)', (tester) async {
      int navigatedTo = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreScreen(onNavigate: (i) => navigatedTo = i),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Devices'));
      expect(navigatedTo, 7);
    });

    testWidgets('renders search icon', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('uppercase search filters correctly', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'MUMBAI');
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('Mumbai Half Marathon'), findsOneWidget);
      expect(find.text('Delhi Cycling Grand Prix'), findsNothing);
    });

    testWidgets('renders See all action', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('See all'), findsOneWidget);
    });

    testWidgets('renders See plans action', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('See plans'), findsOneWidget);
    });

    testWidgets('renders marathon run icon after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const ExploreScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.byIcon(Icons.directions_run), findsWidgets);
    });
  });
}

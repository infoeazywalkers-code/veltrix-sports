import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/ring.dart';
import 'package:veltrix_sports/widgets/status_card.dart';
import 'package:veltrix_sports/widgets/nav_menu.dart';
import 'package:veltrix_sports/widgets/responsive_cards.dart';
import 'package:veltrix_sports/widgets/veltrix_footer.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: Center(child: child))),
  );

  group('Ring', () {
    testWidgets('renders value, label, and CircularProgressIndicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const Ring('54', 'Fitness', Colors.blue, 0.72)),
      );
      expect(find.text('54'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders with different colors', (tester) async {
      await tester.pumpWidget(
        wrap(const Ring('-7', 'Form', Colors.orange, 0.46)),
      );
      expect(find.text('-7'), findsOneWidget);
      expect(find.text('Form'), findsOneWidget);
    });

    testWidgets('renders with zero progress', (tester) async {
      await tester.pumpWidget(wrap(const Ring('0', 'None', Colors.grey, 0.0)));
      expect(find.text('0'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
    });

    testWidgets('renders with full progress', (tester) async {
      await tester.pumpWidget(
        wrap(const Ring('100', 'Max', Colors.green, 1.0)),
      );
      expect(find.text('100'), findsOneWidget);
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 1.0);
    });
  });

  group('StatusCard', () {
    testWidgets('renders three rings and training message', (tester) async {
      await tester.pumpWidget(wrap(const StatusCard()));
      expect(find.text('54'), findsOneWidget);
      expect(find.text('61'), findsOneWidget);
      expect(find.text('-7'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.text('Fatigue'), findsOneWidget);
      expect(find.text('Form'), findsOneWidget);
      expect(find.textContaining('Productive training'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('NavMenu', () {
    testWidgets('renders label and arrow icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavMenu(
              label: 'Products',
              items: const ['Item 1', 'Item 2'],
              onSelected: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Products'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('opens popup menu on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavMenu(
              label: 'Train',
              items: const ['Calendar', 'Workouts', 'Events'],
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.text('Train'));
      await tester.pumpAndSettle();
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
    });

    testWidgets('onSelected fires with correct index', (tester) async {
      int selectedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavMenu(
              label: 'Options',
              items: const ['Alpha', 'Beta'],
              onSelected: (i) => selectedIndex = i,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beta'));
      expect(selectedIndex, 1);
    });

    testWidgets('renders with empty items list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavMenu(label: 'Empty', items: const [], onSelected: (_) {}),
          ),
        ),
      );
      expect(find.text('Empty'), findsOneWidget);
      await tester.tap(find.text('Empty'));
      await tester.pumpAndSettle();
      // No menu items rendered
      expect(find.byType(PopupMenuItem), findsNothing);
    });
  });

  group('ResponsiveCards', () {
    testWidgets('renders as Row on desktop', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: ResponsiveCards(
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Card 1'),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Card 2'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Card 1'), findsOneWidget);
      expect(find.text('Card 2'), findsOneWidget);
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('renders as Wrap on mobile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: ResponsiveCards(
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Card 1'),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Card 2'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Card 1'), findsOneWidget);
      expect(find.text('Card 2'), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('renders as Wrap on desktop when mobileColumns > 1', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: ResponsiveCards(
                mobileColumns: 2,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('A'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('renders single child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: ResponsiveCards(
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Only Child'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Only Child'), findsOneWidget);
    });
  });

  group('VeltrixFooter', () {
    Widget footerWrap(Widget child) =>
        MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

    testWidgets('renders VELTRIX branding and copyright', (tester) async {
      await tester.pumpWidget(footerWrap(const VeltrixFooter()));
      expect(find.text('VELTRIX'), findsOneWidget);
      expect(find.textContaining('2026 Veltrix Sports'), findsOneWidget);
    });

    testWidgets('renders social icons', (tester) async {
      await tester.pumpWidget(footerWrap(const VeltrixFooter()));
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.facebook_rounded), findsOneWidget);
      expect(find.byIcon(Icons.alternate_email_rounded), findsOneWidget);
    });

    testWidgets('renders footer groups', (tester) async {
      await tester.pumpWidget(footerWrap(const VeltrixFooter()));
      expect(find.text('ATHLETES'), findsOneWidget);
      expect(find.text('COACHES'), findsOneWidget);
      expect(find.text('TRAIN'), findsOneWidget);
      expect(find.text('COMPANY'), findsOneWidget);
    });

    testWidgets('renders footer links', (tester) async {
      await tester.pumpWidget(footerWrap(const VeltrixFooter()));
      expect(find.text('Features'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Cookies'), findsOneWidget);
    });

    testWidgets('renders tagline', (tester) async {
      await tester.pumpWidget(footerWrap(const VeltrixFooter()));
      expect(find.textContaining('Plan with confidence'), findsOneWidget);
    });

    testWidgets('renders as Wrap on mobile viewport', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: SingleChildScrollView(child: VeltrixFooter()),
            ),
          ),
        ),
      );
      expect(find.text('VELTRIX'), findsOneWidget);
    });

    testWidgets('renders description text', (tester) async {
      await tester.pumpWidget(footerWrap(const VeltrixFooter()));
      expect(find.textContaining('English'), findsOneWidget);
    });
  });
}

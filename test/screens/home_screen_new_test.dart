import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/screens/home/home_screen.dart';

void main() {
  Widget wrap(
    Widget child, {
    ValueChanged<int>? onNavigate,
    double width = 800,
  }) => ProviderScope(
    overrides: [
      latestPerformanceProvider.overrideWith((ref) => Stream.value(null)),
      weekWorkoutsProvider.overrideWith((ref, arg) async => []),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: Size(width, 1200)),
          child: child,
        ),
      ),
    ),
  );

  group('HomeScreen', () {
    testWidgets('renders main heading', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('training platform'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Built for athletes'), findsOneWidget);
    });

    testWidgets('renders sign up buttons', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Athlete sign up'), findsWidgets);
      expect(find.text('Coach sign up'), findsWidgets);
    });

    testWidgets('has scrollable ListView', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('calls onNavigate when athlete sign up tapped', (tester) async {
      int navigatedTo = -1;
      await tester.pumpWidget(
        wrap(HomeScreen(onNavigate: (i) => navigatedTo = i)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Athlete sign up').first);
      expect(navigatedTo, 19);
    });

    testWidgets('calls onNavigate when coach sign up tapped', (tester) async {
      int navigatedTo = -1;
      await tester.pumpWidget(
        wrap(HomeScreen(onNavigate: (i) => navigatedTo = i)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coach sign up').first);
      expect(navigatedTo, 6);
    });

    testWidgets('renders YOUR TRAINING TODAY after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('YOUR TRAINING TODAY'), 300);
      await tester.pumpAndSettle();
      expect(find.text('YOUR TRAINING TODAY'), findsOneWidget);
    });

    testWidgets('renders Mumbai Half Marathon after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Mumbai Half Marathon'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Mumbai Half Marathon'), findsWidgets);
    });

    testWidgets('renders A RACE chip after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('A RACE'), 300);
      await tester.pumpAndSettle();
      expect(find.text('A RACE'), findsOneWidget);
    });

    testWidgets('renders Plan progress after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Plan progress'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Plan progress'), findsOneWidget);
    });

    testWidgets('renders LinearProgressIndicator for event', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(LinearProgressIndicator),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('renders Today training heading after scrolling', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text("Today\u2019s training"), 300);
      await tester.pumpAndSettle();
      expect(find.text("Today\u2019s training"), findsOneWidget);
    });

    testWidgets('renders View week after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('View week'), 300);
      await tester.pumpAndSettle();
      expect(find.text('View week'), findsOneWidget);
    });

    testWidgets('tapping View week calls onNavigate(1)', (tester) async {
      int navigatedTo = -1;
      await tester.pumpWidget(
        wrap(HomeScreen(onNavigate: (i) => navigatedTo = i)),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('View week'), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View week'));
      expect(navigatedTo, 1);
    });

    testWidgets('renders Training status heading after scrolling', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Training status'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Training status'), findsOneWidget);
    });

    testWidgets('tapping Details calls onNavigate(2)', (tester) async {
      int navigatedTo = -1;
      await tester.pumpWidget(
        wrap(HomeScreen(onNavigate: (i) => navigatedTo = i)),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Details'), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Details'));
      expect(navigatedTo, 2);
    });

    testWidgets('renders This week heading after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('This week'), 300);
      await tester.pumpAndSettle();
      expect(find.text('This week'), findsOneWidget);
    });

    testWidgets('renders editorial banner TRAIN WITH PURPOSE', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('TRAIN WITH PURPOSE'), 300);
      await tester.pumpAndSettle();
      expect(find.text('TRAIN WITH PURPOSE'), findsOneWidget);
    });

    testWidgets('renders editorial banner COACHING THAT CONNECTS', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('COACHING THAT CONNECTS'), 300);
      await tester.pumpAndSettle();
      expect(find.text('COACHING THAT CONNECTS'), findsOneWidget);
    });

    testWidgets('renders coach note after scrolling', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Coach note'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Coach note'), findsOneWidget);
      expect(find.text('Coach Priya'), findsOneWidget);
    });

    testWidgets('renders coach message text', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Coach Priya'), 300);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Strong work on the intervals'),
        findsOneWidget,
      );
    });

    testWidgets('renders coach timestamp', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('Yesterday'), 300);
      await tester.pumpAndSettle();
      expect(find.textContaining('Yesterday'), findsOneWidget);
    });

    testWidgets('renders PublicHomeSections heading', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text("Train like the world\u2019s best."),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text("Train like the world\u2019s best."), findsOneWidget);
    });

    testWidgets('renders trust badges', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('ENDURANCE INDIA'), 300);
      await tester.pumpAndSettle();
      expect(find.text('ENDURANCE INDIA'), findsOneWidget);
      expect(find.text('VELO CLUB'), findsOneWidget);
    });

    testWidgets('renders ONE PLATFORM section', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('ONE PLATFORM. EVERY GOAL.'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('ONE PLATFORM. EVERY GOAL.'), findsOneWidget);
    });

    testWidgets('renders marketing feature cards', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('TRAINING PLANS'), 300);
      await tester.pumpAndSettle();
      expect(find.text('TRAINING PLANS'), findsOneWidget);
      expect(find.text('COACHING'), findsOneWidget);
      expect(find.text('PERFORMANCE'), findsOneWidget);
    });

    testWidgets('renders pillar cards', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('All-in-one'), 300);
      await tester.pumpAndSettle();
      expect(find.textContaining('All-in-one'), findsOneWidget);
    });

    testWidgets('renders CONNECTED TRAINING section', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('CONNECTED TRAINING'), 300);
      await tester.pumpAndSettle();
      expect(find.text('CONNECTED TRAINING'), findsOneWidget);
    });

    testWidgets('renders device chips', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Smartwatch'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Smartwatch'), findsOneWidget);
      expect(find.text('Bike trainer'), findsOneWidget);
      expect(find.text('Heart rate'), findsOneWidget);
      expect(find.text('Recovery'), findsOneWidget);
      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Cloud sync'), findsOneWidget);
    });

    testWidgets('renders Ready starts here CTA', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Ready starts here.'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Ready starts here.'), findsOneWidget);
    });

    testWidgets('renders bottom description text', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Plan, train and grow'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Plan, train and grow'), findsOneWidget);
    });

    testWidgets('renders VELTRIX footer', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('VELTRIX'), 300);
      await tester.pumpAndSettle();
      expect(find.text('VELTRIX'), findsWidgets);
    });

    testWidgets('tapping WorkoutCard navigates to WorkoutDetailsScreen', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Aerobic endurance'), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aerobic endurance').first);
      await tester.pumpAndSettle();
      // Should navigate - WorkoutDetailsScreen has AppBar with title
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders event card date text', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('25 October 2026  \u2022  21.1 km'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('25 October 2026  \u2022  21.1 km'), findsOneWidget);
    });

    testWidgets('renders 62% progress text', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('62%'), 300);
      await tester.pumpAndSettle();
      expect(find.text('62%'), findsOneWidget);
    });

    testWidgets('renders null onNavigate without crashing on taps', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Athlete sign up').first);
      await tester.pump();
      // Should not crash
    });
  });
}

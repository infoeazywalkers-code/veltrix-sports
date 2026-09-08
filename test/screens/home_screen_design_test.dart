import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/screens/home_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final prev = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // Suppress image loading errors in test environment
      final str = details.exception.toString();
      if (str.contains('Unable to load asset') ||
          str.contains('asset does not exist') ||
          str.contains('ImageCodecException') ||
          str.contains('RenderFlex overflowed') ||
          details.context?.toString().contains('Image resource service') ==
              true) {
        return;
      }
      if (prev != null) {
        prev(details);
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  tearDown(() {
    FlutterError.onError = FlutterError.presentError;
  });

  Widget wrap(
    Widget child, {
    ValueChanged<int>? onNavigate,
    double width = 800,
    double height = 2400,
  }) => ProviderScope(
    overrides: [
      latestPerformanceProvider.overrideWith((ref) => Stream.value(null)),
      weekWorkoutsProvider.overrideWith((ref, arg) async => []),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: Size(width, height)),
          child: child,
        ),
      ),
    ),
  );

  group('HomeScreen Design', () {
    // ── Basic rendering ──────────────────────────────────────────────

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('renders as a ListView', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsWidgets);
    });

    // ── Typography ───────────────────────────────────────────────────

    testWidgets('hero heading uses large bold font on desktop', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), width: 900));
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(
        find.textContaining('training platform'),
      );
      expect(text.style?.fontWeight, FontWeight.w900);
      expect(text.style?.fontSize, 58);
    });

    testWidgets('hero heading uses smaller font on mobile', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), width: 400));
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(
        find.textContaining('training platform'),
      );
      expect(text.style?.fontSize, 38);
    });

    testWidgets('subtitle text is 17px', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(
        find.textContaining('Built for athletes'),
      );
      expect(text.style?.fontSize, 17);
    });

    // ── Buttons & interactions ───────────────────────────────────────

    testWidgets('athlete sign up button is FilledButton', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Athlete sign up').first,
      );
      expect(button, isNotNull);
    });

    testWidgets('coach sign up button is OutlinedButton', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Coach sign up').first,
      );
      expect(button, isNotNull);
    });

    testWidgets('athlete sign up triggers onNavigate(19)', (tester) async {
      int? navigated;
      await tester.pumpWidget(
        wrap(HomeScreen(onNavigate: (i) => navigated = i)),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Athlete sign up').first,
      );
      expect(navigated, 19);
    });

    testWidgets('coach sign up triggers onNavigate(6)', (tester) async {
      int? navigated;
      await tester.pumpWidget(
        wrap(HomeScreen(onNavigate: (i) => navigated = i)),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Coach sign up').first,
      );
      expect(navigated, 6);
    });

    testWidgets('null onNavigate does not crash on button tap', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Athlete sign up').first,
      );
      await tester.pump();
      // No crash = pass
    });

    // ── Race event card ──────────────────────────────────────────────

    testWidgets('event card shows Mumbai Half Marathon title', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Mumbai Half Marathon'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Mumbai Half Marathon'), findsWidgets);
    });

    testWidgets('event card shows A RACE chip', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('A RACE'), 300);
      await tester.pumpAndSettle();
      expect(find.text('A RACE'), findsOneWidget);
    });

    testWidgets('event card shows progress percentage', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('62%'), 300);
      await tester.pumpAndSettle();
      expect(find.text('62%'), findsOneWidget);
    });

    testWidgets('event card shows LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(LinearProgressIndicator),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('event card shows date info', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('25 October 2026'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('25 October 2026'), findsOneWidget);
    });

    // ── Training sections ────────────────────────────────────────────

    testWidgets('shows YOUR TRAINING TODAY divider', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('YOUR TRAINING TODAY'), 300);
      await tester.pumpAndSettle();
      expect(find.text('YOUR TRAINING TODAY'), findsOneWidget);
    });

    testWidgets('shows Today\'s training section', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text("Today\u2019s training"), 300);
      await tester.pumpAndSettle();
      expect(find.text("Today\u2019s training"), findsOneWidget);
    });

    testWidgets('shows View week action', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('View week'), 300);
      await tester.pumpAndSettle();
      expect(find.text('View week'), findsOneWidget);
    });

    testWidgets('View week triggers onNavigate(1)', (tester) async {
      int? navigated;
      await tester.pumpWidget(
        wrap(HomeScreen(onNavigate: (i) => navigated = i)),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('View week'), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View week'));
      expect(navigated, 1);
    });

    testWidgets('shows Training status section', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Training status'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Training status'), findsOneWidget);
    });

    testWidgets('Details triggers onNavigate(2)', (tester) async {
      int? navigated;
      await tester.pumpWidget(
        wrap(HomeScreen(onNavigate: (i) => navigated = i)),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Details'), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Details'));
      expect(navigated, 2);
    });

    testWidgets('shows This week section', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('This week'), 300);
      await tester.pumpAndSettle();
      expect(find.text('This week'), findsOneWidget);
    });

    // ── Workout card ─────────────────────────────────────────────────

    testWidgets('shows workout card with Aerobic endurance', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Aerobic endurance'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Aerobic endurance'), findsOneWidget);
    });

    testWidgets('workout card shows RUN label', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('RUN'), 300);
      await tester.pumpAndSettle();
      expect(find.text('RUN'), findsWidgets);
    });

    testWidgets('workout card shows distance details', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('45 min'), 300);
      await tester.pumpAndSettle();
      expect(find.textContaining('45 min'), findsOneWidget);
    });

    testWidgets('tapping workout card navigates to details', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Aerobic endurance'), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aerobic endurance').first);
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
    });

    // ── Coach note ───────────────────────────────────────────────────

    testWidgets('shows Coach note heading', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Coach note'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Coach note'), findsOneWidget);
    });

    testWidgets('shows coach name', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Coach Priya'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Coach Priya'), findsOneWidget);
    });

    testWidgets('shows coach message', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('Strong work'), 300);
      await tester.pumpAndSettle();
      expect(find.textContaining('Strong work'), findsOneWidget);
    });

    testWidgets('shows coach timestamp', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('Yesterday'), 300);
      await tester.pumpAndSettle();
      expect(find.textContaining('Yesterday'), findsOneWidget);
    });

    testWidgets('coach note has CircleAvatar', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Coach Priya'), 300);
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    // ── Editorial banners ────────────────────────────────────────────

    testWidgets('shows TRAIN WITH PURPOSE banner', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('TRAIN WITH PURPOSE'), 300);
      await tester.pumpAndSettle();
      expect(find.text('TRAIN WITH PURPOSE'), findsOneWidget);
    });

    testWidgets('shows COACHING THAT CONNECTS banner', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('COACHING THAT CONNECTS'), 300);
      await tester.pumpAndSettle();
      expect(find.text('COACHING THAT CONNECTS'), findsOneWidget);
    });

    // ── PublicHomeSections ───────────────────────────────────────────

    testWidgets('shows train like best heading', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Train like the world'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Train like the world'), findsOneWidget);
    });

    testWidgets('shows trust badges', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('ENDURANCE INDIA'), 300);
      await tester.pumpAndSettle();
      expect(find.text('ENDURANCE INDIA'), findsOneWidget);
      expect(find.text('VELO CLUB'), findsOneWidget);
      expect(find.text('AQUA ELITE'), findsOneWidget);
      expect(find.text('RACE SERIES'), findsOneWidget);
      expect(find.text('HYBRID LAB'), findsOneWidget);
    });

    testWidgets('shows ONE PLATFORM section', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('ONE PLATFORM. EVERY GOAL.'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('ONE PLATFORM. EVERY GOAL.'), findsOneWidget);
    });

    testWidgets('shows marketing feature cards', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('TRAINING PLANS'), 300);
      await tester.pumpAndSettle();
      expect(find.text('TRAINING PLANS'), findsOneWidget);
      expect(find.text('COACHING'), findsWidgets);
      expect(find.text('PERFORMANCE'), findsOneWidget);
    });

    testWidgets('shows All-in-one pillar section', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('All-in-one'), 300);
      await tester.pumpAndSettle();
      expect(find.textContaining('All-in-one'), findsOneWidget);
    });

    testWidgets('shows pillar PLAN', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('PLAN.'), 300);
      await tester.pumpAndSettle();
      expect(find.text('PLAN.'), findsOneWidget);
    });

    testWidgets('shows pillar TRAIN', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('TRAIN.'), 300);
      await tester.pumpAndSettle();
      expect(find.text('TRAIN.'), findsOneWidget);
    });

    testWidgets('shows pillar LIFT', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('LIFT.'), 300);
      await tester.pumpAndSettle();
      expect(find.text('LIFT.'), findsOneWidget);
    });

    testWidgets('shows CONNECTED TRAINING section', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('CONNECTED TRAINING'), 300);
      await tester.pumpAndSettle();
      expect(find.text('CONNECTED TRAINING'), findsOneWidget);
    });

    testWidgets('shows all device chips', (tester) async {
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

    testWidgets('shows Ready starts here CTA', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Ready starts here.'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Ready starts here.'), findsOneWidget);
    });

    testWidgets('shows footer', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('VELTRIX'), 300);
      await tester.pumpAndSettle();
      expect(find.text('VELTRIX'), findsWidgets);
    });

    // ── Responsive layout ────────────────────────────────────────────

    testWidgets('desktop width uses wider padding', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), width: 1300));
      await tester.pumpAndSettle();
      final listView = tester.widget<ListView>(find.byType(ListView).first);
      final padding = listView.padding as EdgeInsets;
      // width > 1220 => side = (1300 - 1180) / 2 = 60
      expect(padding.left, closeTo(60, 1));
    });

    testWidgets('mobile width uses narrow padding', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), width: 400));
      await tester.pumpAndSettle();
      final listView = tester.widget<ListView>(find.byType(ListView).first);
      final padding = listView.padding as EdgeInsets;
      // width <= 1220 => side = 18
      expect(padding.left, 18);
    });

    testWidgets('desktop width uses larger top padding', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), width: 900));
      await tester.pumpAndSettle();
      final listView = tester.widget<ListView>(find.byType(ListView).first);
      final padding = listView.padding as EdgeInsets;
      // width > 850 => top = 42
      expect(padding.top, 42);
    });

    testWidgets('mobile width uses smaller top padding', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), width: 400));
      await tester.pumpAndSettle();
      final listView = tester.widget<ListView>(find.byType(ListView).first);
      final padding = listView.padding as EdgeInsets;
      // width <= 850 => top = 22
      expect(padding.top, 22);
    });

    // ── Video hero ───────────────────────────────────────────────────

    testWidgets('HomeVideoHero widget is present', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(HomeVideoHero), findsOneWidget);
    });

    // ── PublicHomeSections standalone ────────────────────────────────

    testWidgets('PublicHomeSections renders independently', (tester) async {
      await tester.pumpWidget(
        wrap(const SingleChildScrollView(child: PublicHomeSections())),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Train like the world'), findsOneWidget);
    });

    // ── Edge cases ───────────────────────────────────────────────────

    testWidgets('renders with very narrow screen', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), width: 100));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('renders with very wide screen', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), width: 3000));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('renders with different heights', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), height: 600));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}

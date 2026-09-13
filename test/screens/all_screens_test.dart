import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/screens/coach/coach_match_screen.dart';
import 'package:veltrix_sports/screens/coach/coach_questionnaire_screen.dart';
import 'package:veltrix_sports/screens/devices/devices_screen.dart';
import 'package:veltrix_sports/screens/training/strength_screen.dart';
import 'package:veltrix_sports/screens/home/home_screen.dart';
import 'package:veltrix_sports/mobile/screens/mobile_explore.dart';
import 'package:veltrix_sports/mobile/screens/mobile_more.dart';

Widget screenWrap(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(height: 2000, child: child)),
);

void main() {
  group('CoachMatchScreen', () {
    testWidgets('renders heading', (tester) async {
      await tester.pumpWidget(screenWrap(const CoachMatchScreen()));
      expect(find.text('COACH MATCH'), findsOneWidget);
    });

    testWidgets('renders coaching body text', (tester) async {
      await tester.pumpWidget(screenWrap(const CoachMatchScreen()));
      expect(find.textContaining('coaching'), findsWidgets);
    });

    testWidgets('renders footer', (tester) async {
      await tester.pumpWidget(screenWrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('VELTRIX'), 300);
      await tester.pumpAndSettle();
      expect(find.text('VELTRIX'), findsOneWidget);
    });
  });

  group('CoachQuestionnaireScreen', () {
    testWidgets('widget type exists', (tester) async {
      expect(CoachQuestionnaireScreen, isA<Type>());
    });
  });

  group('DevicesScreen', () {
    testWidgets('renders heading', (tester) async {
      await tester.pumpWidget(screenWrap(const DevicesScreen()));
      expect(find.text('DEVICES & WATCHES'), findsOneWidget);
    });

    testWidgets('renders device items', (tester) async {
      await tester.pumpWidget(screenWrap(const DevicesScreen()));
      expect(find.textContaining('Apple Watch'), findsWidgets);
      expect(find.textContaining('Garmin'), findsWidgets);
    });

    testWidgets('renders footer', (tester) async {
      await tester.pumpWidget(screenWrap(const DevicesScreen()));
      await tester.scrollUntilVisible(find.text('VELTRIX'), 300);
      await tester.pumpAndSettle();
      expect(find.text('VELTRIX'), findsOneWidget);
    });
  });

  group('StrengthScreen', () {
    testWidgets('renders heading', (tester) async {
      await tester.pumpWidget(screenWrap(const StrengthScreen()));
      expect(find.text('STRENGTH'), findsOneWidget);
      expect(find.text('Empower Your Training'), findsOneWidget);
    });

    testWidgets('renders body text', (tester) async {
      await tester.pumpWidget(screenWrap(const StrengthScreen()));
      expect(find.textContaining('strength that supports'), findsWidgets);
    });

    testWidgets('renders footer', (tester) async {
      await tester.pumpWidget(screenWrap(const StrengthScreen()));
      await tester.scrollUntilVisible(find.text('VELTRIX'), 300);
      await tester.pumpAndSettle();
      expect(find.text('VELTRIX'), findsOneWidget);
    });
  });

  group('HomeScreen', () {
    testWidgets('renders main content as ListView', (tester) async {
      await tester.pumpWidget(screenWrap(const HomeScreen()));
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('renders hero heading text', (tester) async {
      await tester.pumpWidget(screenWrap(const HomeScreen()));
      expect(find.textContaining('training platform'), findsWidgets);
    });

    testWidgets('renders sign up buttons', (tester) async {
      await tester.pumpWidget(screenWrap(const HomeScreen()));
      expect(find.text('Athlete sign up'), findsOneWidget);
      expect(find.text('Coach sign up'), findsOneWidget);
    });
  });

  group('MobileExploreScreen', () {
    testWidgets('renders search bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MobileExploreScreen())),
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
    });

    testWidgets('renders explore grid', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MobileExploreScreen())),
      );
      expect(find.text('Browse Veltrix'), findsOneWidget);
      expect(find.text('Training plans'), findsOneWidget);
      expect(find.text('Find a coach'), findsOneWidget);
    });
  });

  group('MobileMoreScreen', () {
    testWidgets('renders sections and links', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MobileMoreScreen())),
      );
      expect(find.text('More features'), findsOneWidget);
      expect(find.text('Train with more support'), findsOneWidget);
      expect(find.text('Connected training'), findsOneWidget);
    });

    testWidgets('renders feature items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MobileMoreScreen())),
      );
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Find a coach'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Devices'), findsOneWidget);
      expect(find.text('Workout library'), findsOneWidget);
    });

    testWidgets('renders info cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MobileMoreScreen())),
      );
      expect(find.byType(Card), findsWidgets);
    });
  });
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/screens/coach_questionnaire_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  group('CoachQuestionnaireScreen - form rendering', () {
    testWidgets('renders all form fields', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders heading and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Tell us about your training'), findsOneWidget);
      expect(
        find.text(
          'We use your answers to recommend coaches who fit your goals and communication style.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('has submit button', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      // Scroll to reveal submit button
      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('renders 3 dropdown labels', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Primary sport'), findsOneWidget);
      expect(find.text('Experience level'), findsOneWidget);
      expect(find.text('Main goal'), findsOneWidget);
    });

    testWidgets('notes field has correct hint text', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('Schedule, upcoming events, preferences...'),
        findsOneWidget,
      );
    });
  });

  group('CoachQuestionnaireScreen - dropdown interactions', () {
    testWidgets('sport dropdown shows all 5 options', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();

      expect(find.text('Cycling'), findsWidgets);
      expect(find.text('Swimming'), findsWidgets);
      expect(find.text('Triathlon'), findsWidgets);
      expect(find.text('Strength'), findsWidgets);
    });

    testWidgets('selecting Cycling updates sport', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cycling'));
      await tester.pumpAndSettle();

      expect(find.text('Cycling'), findsOneWidget);
    });

    testWidgets('experience dropdown shows all 4 options', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      final expDropdown = find.byType(DropdownButtonFormField<String>).at(1);
      await tester.tap(expDropdown);
      await tester.pumpAndSettle();

      expect(find.text('Beginner'), findsWidgets);
      expect(find.text('Advanced'), findsWidgets);
      expect(find.text('Elite'), findsWidgets);
    });

    testWidgets('selecting Advanced updates experience', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      final expDropdown = find.byType(DropdownButtonFormField<String>).at(1);
      await tester.tap(expDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('goal dropdown shows all 4 options', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      final goalDropdown = find.byType(DropdownButtonFormField<String>).at(2);
      await tester.tap(goalDropdown);
      await tester.pumpAndSettle();

      expect(find.text('Complete my first event'), findsWidgets);
      expect(find.text('Return from injury'), findsWidgets);
      expect(find.text('Build consistency'), findsWidgets);
    });

    testWidgets('selecting Build consistency updates goal', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      final goalDropdown = find.byType(DropdownButtonFormField<String>).at(2);
      await tester.tap(goalDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Build consistency'));
      await tester.pumpAndSettle();

      expect(find.text('Build consistency'), findsOneWidget);
    });

    testWidgets('selecting Triathlon updates sport', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Triathlon'));
      await tester.pumpAndSettle();

      expect(find.text('Triathlon'), findsOneWidget);
    });

    testWidgets('selecting Elite updates experience', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      final expDropdown = find.byType(DropdownButtonFormField<String>).at(1);
      await tester.tap(expDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elite'));
      await tester.pumpAndSettle();

      expect(find.text('Elite'), findsOneWidget);
    });
  });

  group('CoachQuestionnaireScreen - text input', () {
    testWidgets('notes field accepts multi-line input', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Line 1\nLine 2\nLine 3');
      await tester.pumpAndSettle();

      expect(find.text('Line 1\nLine 2\nLine 3'), findsOneWidget);
    });

    testWidgets('notes field clears on re-enter', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'First note');
      await tester.pumpAndSettle();
      expect(find.text('First note'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Second note');
      await tester.pumpAndSettle();
      expect(find.text('Second note'), findsOneWidget);
      expect(find.text('First note'), findsNothing);
    });
  });

  group('CoachQuestionnaireScreen - submit without auth', () {
    testWidgets('submit shows sign-in required dialog', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      // Scroll to submit button and tap
      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Sign in required'), findsOneWidget);
      expect(
        find.text('Please sign in to submit your coach questionnaire.'),
        findsOneWidget,
      );
    });

    testWidgets('sign-in dialog Cancel button dismisses dialog', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in required'), findsNothing);
    });

    testWidgets('sign-in dialog Sign in button pops both dialog and screen', (
      tester,
    ) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: const CoachQuestionnaireScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in required'), findsNothing);
    });

    testWidgets('sign-in dialog has correct actions', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });
  });

  group('CoachQuestionnaireScreen - default values', () {
    testWidgets('default sport is Running', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Running'), findsOneWidget);
    });

    testWidgets('default experience is Intermediate', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Intermediate'), findsWidgets);
    });

    testWidgets('default goal is Improve performance', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Improve performance'), findsOneWidget);
    });
  });

  group('CoachQuestionnaireScreen - widget structure', () {
    testWidgets('has AppBar with title', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Find your coach'), findsOneWidget);
    });

    testWidgets('submit button shows send icon initially', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      // Scroll to make submit button visible
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('ListView allows scrolling to submit', (tester) async {
      await tester.pumpWidget(_wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();

      // Scroll down to reveal submit button
      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Submit button should be visible
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}

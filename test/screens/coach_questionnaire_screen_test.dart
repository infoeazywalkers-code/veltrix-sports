import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/screens/coach_questionnaire_screen.dart';

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  Widget wrap(Widget child) => MaterialApp(home: child);

  group('CoachQuestionnaireScreen', () {
    testWidgets('renders Scaffold with AppBar title', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Find your coach'), findsOneWidget);
    });

    testWidgets('renders heading text', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Tell us about your training'), findsOneWidget);
    });

    testWidgets('renders description subtitle text', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'We use your answers to recommend coaches who fit your goals and communication style.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Primary sport dropdown', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Primary sport'), findsOneWidget);
    });

    testWidgets('renders Experience level dropdown', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Experience level'), findsOneWidget);
    });

    testWidgets('renders Main goal dropdown', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Main goal'), findsOneWidget);
    });

    testWidgets('renders notes text field', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Anything your coach should know?'), findsOneWidget);
    });

    testWidgets('default sport value is Running', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Running'), findsOneWidget);
    });

    testWidgets('default experience value is Intermediate', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Intermediate'), findsWidgets);
    });

    testWidgets('default goal value is Improve performance', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Improve performance'), findsOneWidget);
    });

    testWidgets('has 3 dropdown button form fields', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
    });

    testWidgets('has a TextFormField for notes', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('rendering contains a Form widget', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('rendering contains a ListView', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('rendering contains AppBar', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('sport dropdown shows all sport options', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();
      expect(find.text('Cycling'), findsWidgets);
      expect(find.text('Swimming'), findsWidgets);
      expect(find.text('Triathlon'), findsWidgets);
      expect(find.text('Strength'), findsWidgets);
    });

    testWidgets('experience dropdown shows all experience options', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      final expDropdown = find.byType(DropdownButtonFormField<String>).at(1);
      await tester.tap(expDropdown);
      await tester.pumpAndSettle();
      expect(find.text('Beginner'), findsWidgets);
      expect(find.text('Advanced'), findsWidgets);
      expect(find.text('Elite'), findsWidgets);
    });

    testWidgets('goal dropdown shows all goal options', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      final goalDropdown = find.byType(DropdownButtonFormField<String>).at(2);
      await tester.tap(goalDropdown);
      await tester.pumpAndSettle();
      expect(find.text('Complete my first event'), findsWidgets);
      expect(find.text('Return from injury'), findsWidgets);
      expect(find.text('Build consistency'), findsWidgets);
    });

    testWidgets('selecting sport dropdown option updates value', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      // Open sport dropdown and select Cycling
      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cycling'));
      await tester.pumpAndSettle();
      // After selection, 'Cycling' should be the displayed value
      // and there should be exactly 1 instance (the dropdown value, not menu)
      expect(find.text('Cycling'), findsOneWidget);
    });

    testWidgets('selecting experience dropdown option updates value', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      final expDropdown = find.byType(DropdownButtonFormField<String>).at(1);
      await tester.tap(expDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('selecting goal dropdown option updates value', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      final goalDropdown = find.byType(DropdownButtonFormField<String>).at(2);
      await tester.tap(goalDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Build consistency'));
      await tester.pumpAndSettle();
      expect(find.text('Build consistency'), findsOneWidget);
    });

    testWidgets('notes field accepts text input', (tester) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Marathon training notes');
      await tester.pumpAndSettle();
      expect(find.text('Marathon training notes'), findsOneWidget);
    });

    testWidgets('tapping submit with no user shows sign-in dialog', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      // Scroll to the bottom of the ListView to find the submit button
      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -500));
      await tester.pumpAndSettle();
      // Tap the submit FilledButton (find by type since text may be off-screen)
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Sign in required'), findsOneWidget);
      expect(
        find.text('Please sign in to submit your coach questionnaire.'),
        findsOneWidget,
      );
    });

    testWidgets('sign-in dialog has Cancel and Sign in buttons', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('tapping Cancel on sign-in dialog dismisses it', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in required'), findsNothing);
    });

    testWidgets('tapping Sign in on sign-in dialog dismisses it', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const CoachQuestionnaireScreen()));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in required'), findsNothing);
    });
  });
}

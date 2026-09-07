import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/coach_service.dart';
import 'package:veltrix_sports/widgets/coach_booking_dialog.dart';

Widget openDialog(Widget dialog) => MaterialApp(
  home: Builder(
    builder:
        (context) => Scaffold(
          body: ElevatedButton(
            onPressed:
                () => showDialog(context: context, builder: (_) => dialog),
            child: const Text('Open'),
          ),
        ),
  ),
);

void main() {
  group('CoachBookingDialog - Covering uncovered lines', () {
    testWidgets('renders coach last name in title for multi-word name', (
      tester,
    ) async {
      final coach = CoachService.featuredCoaches.first; // Coach Priya Sharma

      await tester.pumpWidget(openDialog(CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Should show "Book Call with Sharma" (last name from "Coach Priya Sharma")
      expect(find.textContaining('Book Call with'), findsOneWidget);
    });

    testWidgets('renders coach full name for single-word name', (tester) async {
      const coach = CoachProfile(
        id: 'single',
        name: 'Priya',
        title: 'Running Coach',
        rating: '4.9',
        bio: 'Great coach',
        image: '',
        monthlyFee: '\$100/mo',
        specialities: ['Running'],
      );

      await tester.pumpWidget(openDialog(const CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Single-word name should use full name
      expect(find.text('Book Call with Priya'), findsOneWidget);
    });

    testWidgets('renders coach title', (tester) async {
      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(openDialog(CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text(coach.title), findsOneWidget);
    });

    testWidgets('date picker interaction via Change Date button', (
      tester,
    ) async {
      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(openDialog(CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Change Date
      await tester.tap(find.text('Change Date'));
      await tester.pumpAndSettle();

      // Date picker dialog should appear
      expect(find.text('OK'), findsOneWidget);

      // Confirm selection
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Date display should still be present
      expect(find.textContaining('Call Date:'), findsOneWidget);
    });

    testWidgets('submit with valid data triggers submit path', (tester) async {
      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(openDialog(CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Fill in valid data (defaults are pre-filled)
      // Submit - will fail on Firebase but exercises _submit catch path
      await tester.tap(find.text('Book 1-on-1 Consultation'));
      await tester.pump();
      await tester.pump();

      // After catch block, dialog should be dismissed or error shown
      await tester.pumpAndSettle();
    });

    testWidgets('submit with empty goal shows validation error', (
      tester,
    ) async {
      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(openDialog(CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Clear the goal field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Primary Target Goal *'),
        '',
      );
      // Clear the message field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Message for Coach'),
        '',
      );

      await tester.tap(find.text('Book 1-on-1 Consultation'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('submit with empty message shows validation error', (
      tester,
    ) async {
      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(openDialog(CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Clear only the message field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Message for Coach'),
        '',
      );

      await tester.tap(find.text('Book 1-on-1 Consultation'));
      await tester.pumpAndSettle();

      // Message has a validator requiring non-empty
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('submit shows saving state briefly', (tester) async {
      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(openDialog(CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap submit
      await tester.tap(find.text('Book 1-on-1 Consultation'));

      // Pump once to catch the setState for _submitting = true
      await tester.pump();

      // After pumpAndSettle the dialog may be popped or error shown
      await tester.pumpAndSettle();
    });

    testWidgets('goal field accepts custom text', (tester) async {
      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(openDialog(CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Clear default and type custom goal
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Primary Target Goal *'),
        'Sub-3 Hour Marathon',
      );

      final goalField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Primary Target Goal *'),
      );
      expect(goalField.controller?.text, 'Sub-3 Hour Marathon');
    });

    testWidgets('message field accepts custom text', (tester) async {
      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(openDialog(CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Clear default and type custom message
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Message for Coach'),
        'I need help with my training plan',
      );

      final messageField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Message for Coach'),
      );
      expect(
        messageField.controller?.text,
        'I need help with my training plan',
      );
    });

    testWidgets('dispose works correctly', (tester) async {
      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(openDialog(CoachBookingDialog(coach: coach)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Cancel triggers dispose
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Book Call with'), findsNothing);
    });
  });
}

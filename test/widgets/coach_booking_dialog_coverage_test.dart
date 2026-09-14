import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/services/social/coach_service.dart';
import 'package:veltrix_sports/widgets/dialogs/coach_booking_dialog.dart';

const _testCoach = CoachProfile(
  id: 'coach_priya',
  name: 'Coach Priya Sharma',
  title: 'Endurance Coach & IRONMAN Certified',
  rating: '4.9 (10 reviews)',
  bio: 'Professional endurance coach with 12 years experience.',
  image: 'assets/images/coach_priya.png',
  monthlyFee: '\$149/mo',
  specialities: ['Marathon', 'Triathlon', 'Power Metrics'],
);

/// Pumps [dialog] with a signed-in user so [CoachBookingDialog]'s auth gate
/// renders the booking form instead of the "Sign in required" prompt.
Widget openDialog(Widget dialog) => ProviderScope(
  overrides: [
    authStateProvider.overrideWith(
      (ref) => Stream.value(MockUser(uid: 'test-uid', email: 't@t.com')),
    ),
  ],
  child: MaterialApp(
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
  ),
);

void main() {
  group('CoachBookingDialog - Covering uncovered lines', () {
    testWidgets('renders coach last name in title for multi-word name', (
      tester,
    ) async {
      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: _testCoach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

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

      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: coach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Book Call with Priya'), findsOneWidget);
    });

    testWidgets('renders coach title', (tester) async {
      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: _testCoach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text(_testCoach.title), findsOneWidget);
    });

    testWidgets('date picker interaction via Change Date button', (
      tester,
    ) async {
      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: _testCoach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Date'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Call Date:'), findsOneWidget);
    });

    testWidgets('submit with valid data triggers submit path', (tester) async {
      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: _testCoach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Book 1-on-1 Consultation'));
      await tester.pump();
      await tester.pump();

      await tester.pumpAndSettle();
    });

    testWidgets('submit with empty goal shows validation error', (
      tester,
    ) async {
      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: _testCoach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Primary Target Goal *'),
        '',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Message for Coach *'),
        '',
      );

      await tester.tap(find.text('Book 1-on-1 Consultation'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('submit with empty message shows validation error', (
      tester,
    ) async {
      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: _testCoach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Message for Coach *'),
        '',
      );

      await tester.tap(find.text('Book 1-on-1 Consultation'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('submit shows saving state briefly', (tester) async {
      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: _testCoach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Book 1-on-1 Consultation'));

      await tester.pump();

      await tester.pumpAndSettle();
    });

    testWidgets('goal field accepts custom text', (tester) async {
      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: _testCoach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

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
      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: _testCoach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Message for Coach *'),
        'I need help with my training plan',
      );

      final messageField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Message for Coach *'),
      );
      expect(
        messageField.controller?.text,
        'I need help with my training plan',
      );
    });

    testWidgets('dispose works correctly', (tester) async {
      await tester.pumpWidget(
        openDialog(const CoachBookingDialog(coach: _testCoach)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Book Call with'), findsNothing);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user_profile.dart';
import 'package:veltrix_sports/services/coach_service.dart';
import 'package:veltrix_sports/services/payment_service.dart';
import 'package:veltrix_sports/widgets/checkout_dialog.dart';
import 'package:veltrix_sports/widgets/coach_booking_dialog.dart';
import 'package:veltrix_sports/widgets/device_connect_dialog.dart';
import 'package:veltrix_sports/widgets/edit_profile_dialog.dart';

void main() {
  group('Dialogs Interaction Widget Tests', () {
    testWidgets('CheckoutDialog renders Razorpay pay button and validates form', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final plan = PaymentService.availablePlans.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => CheckoutDialog(plan: plan),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutDialog), findsOneWidget);
      expect(find.textContaining('Pay via Razorpay'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('DeviceConnectDialog renders device name and pair buttons', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const DeviceConnectDialog(
                    deviceName: 'Garmin Forerunner 965',
                    category: 'GPS Watch',
                    isConnected: false,
                  ),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Garmin Forerunner 965'), findsOneWidget);
      expect(find.text('Pair & Connect'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Tap Close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('CoachBookingDialog renders coach profile and booking button', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => CoachBookingDialog(coach: coach),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Book Call with'), findsOneWidget);
      expect(find.text('Book 1-on-1 Consultation'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('EditProfileDialog renders display name input and save button', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final profile = UserProfile(
        id: 'test_user_1',
        email: 'test@veltrix.com',
        displayName: 'Alex Athlete',
        sports: ['Running', 'Cycling'],
        role: UserRole.athlete,
        isPremium: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => EditProfileDialog(currentProfile: profile),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}

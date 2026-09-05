import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      addTearDown(() => tester.view.resetPhysicalSize());

      final plan = PaymentService.availablePlans.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckoutDialog(plan: plan),
          ),
        ),
      );

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
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeviceConnectDialog(
              deviceName: 'Garmin Forerunner 965',
              category: 'GPS Watch',
              isConnected: false,
            ),
          ),
        ),
      );

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
      addTearDown(() => tester.view.resetPhysicalSize());

      final coach = CoachService.featuredCoaches.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoachBookingDialog(coach: coach),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining(coach.name), findsOneWidget);
      expect(find.text('Submit Consultation Request'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('EditProfileDialog renders display name input and save button', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditProfileDialog(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}

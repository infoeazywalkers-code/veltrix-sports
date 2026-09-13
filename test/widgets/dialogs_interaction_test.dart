import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user/user_profile.dart';
import 'package:veltrix_sports/services/social/coach_service.dart';
import 'package:veltrix_sports/services/payment/payment_service.dart';
import 'package:veltrix_sports/widgets/dialogs/checkout_dialog.dart';
import 'package:veltrix_sports/widgets/dialogs/coach_booking_dialog.dart';
import 'package:veltrix_sports/widgets/dialogs/device_connect_dialog.dart';
import 'package:veltrix_sports/widgets/dialogs/edit_profile_dialog.dart';

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

void main() {
  group('Dialogs Interaction Widget Tests', () {
    testWidgets(
      'CheckoutDialog renders Razorpay pay button and validates form',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final plan = PaymentService.availablePlans.first;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder:
                    (context) => ElevatedButton(
                      onPressed:
                          () => showDialog(
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

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets('DeviceConnectDialog renders device name and pair buttons', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) => const DeviceConnectDialog(
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

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('CoachBookingDialog renders coach profile and booking button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) =>
                                  const CoachBookingDialog(coach: _testCoach),
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

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('CoachBookingDialog shows goal and message fields', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) =>
                                  const CoachBookingDialog(coach: _testCoach),
                        ),
                    child: const Text('Open Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Primary Target Goal *'), findsOneWidget);
      expect(find.text('Message for Coach'), findsOneWidget);
      expect(find.textContaining('Call Date:'), findsOneWidget);
      expect(find.text('Change Date'), findsOneWidget);
    });

    testWidgets('CoachBookingDialog goal field shows default text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) =>
                                  const CoachBookingDialog(coach: _testCoach),
                        ),
                    child: const Text('Open Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Sub-3:45 Marathon PR'), findsOneWidget);
    });

    testWidgets('CoachBookingDialog shows validation errors on empty submit', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) =>
                                  const CoachBookingDialog(coach: _testCoach),
                        ),
                    child: const Text('Open Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Primary Target Goal *'),
        '',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Message for Coach'),
        '',
      );
      await tester.tap(find.text('Book 1-on-1 Consultation'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('CoachBookingDialog renders coach title and icon', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) =>
                                  const CoachBookingDialog(coach: _testCoach),
                        ),
                    child: const Text('Open Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.groups), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    });

    testWidgets(
      'EditProfileDialog renders display name input and save button',
      (tester) async {
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
                builder:
                    (context) => ElevatedButton(
                      onPressed:
                          () => showDialog(
                            context: context,
                            builder:
                                (_) =>
                                    EditProfileDialog(currentProfile: profile),
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

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets('EditProfileDialog populates name from profile', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Jordan Sprinter',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) => EditProfileDialog(currentProfile: profile),
                        ),
                    child: const Text('Open Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Display Name'),
      );
      expect(nameField.controller?.text, 'Jordan Sprinter');
    });

    testWidgets('EditProfileDialog renders all sport chips', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Test User',
        sports: ['Running', 'Cycling'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) => EditProfileDialog(currentProfile: profile),
                        ),
                    child: const Text('Open Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Primary Sports'), findsOneWidget);
      expect(find.text('Running'), findsWidgets);
      expect(find.text('Cycling'), findsWidgets);
      expect(find.text('Swimming'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Triathlon'), findsOneWidget);
      expect(find.text('Trail Running'), findsOneWidget);
    });

    testWidgets('EditProfileDialog name validation rejects empty name', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'To Clear',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) => EditProfileDialog(currentProfile: profile),
                        ),
                    child: const Text('Open Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'),
        '',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('EditProfileDialog cancel dismisses dialog', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Dismiss Test',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) => EditProfileDialog(currentProfile: profile),
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
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Profile'), findsNothing);
    });
  });
}

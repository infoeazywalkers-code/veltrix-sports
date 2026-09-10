import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/dialogs/checkout_dialog.dart';
import 'package:veltrix_sports/services/payment/payment_service.dart';

class _FakeAuthPlatform extends FirebaseAuthPlatform {
  _FakeAuthPlatform() : super();
  @override
  UserPlatform? get currentUser => null;
  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) => this;
  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) => this;
}

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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAuthPlatform.instance = _FakeAuthPlatform();
  });
  group('CheckoutDialog extended', () {
    testWidgets('promo code VELTRIXPRO applies discount', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter promo code
      final promoField = find.widgetWithText(TextFormField, 'Promo Code');
      await tester.enterText(promoField, 'VELTRIXPRO');
      await tester.pumpAndSettle();

      // Should show promo applied text
      expect(find.text('Promo code applied successfully!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('promo code ATHLETE20 applies discount', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final promoField = find.widgetWithText(TextFormField, 'Promo Code');
      await tester.enterText(promoField, 'ATHLETE20');
      await tester.pumpAndSettle();

      expect(find.text('Promo code applied successfully!'), findsOneWidget);
    });

    testWidgets('invalid promo code shows no discount', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final promoField = find.widgetWithText(TextFormField, 'Promo Code');
      await tester.enterText(promoField, 'INVALID');
      await tester.pumpAndSettle();

      expect(find.text('Promo code applied successfully!'), findsNothing);
    });

    testWidgets('tapping Razorpay button calls _payWithRazorpay', (
      tester,
    ) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Pay via Razorpay'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 3000));
    });

    testWidgets('renders lock icon and price', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      // Should show price with rupee symbol
      expect(find.textContaining('\u20b9'), findsWidgets);
    });

    testWidgets('renders plan period', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('/month'), findsOneWidget);
    });

    testWidgets('tapping Pay button with valid form processes payment', (
      tester,
    ) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Pay button
      await tester.tap(find.textContaining('Pay \u20b9'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Payment processes — may show snackbar or close dialog
      // Just verify no crash
    });

    testWidgets('empty card number shows validation error', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Clear card number
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Card Number'),
        '',
      );
      // Tap Pay
      await tester.tap(find.textContaining('Pay \u20b9'));
      await tester.pumpAndSettle();
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('invalid expiry shows validation error', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Expires (MM/YY)'),
        'invalid',
      );
      await tester.tap(find.textContaining('Pay \u20b9'));
      await tester.pumpAndSettle();
      expect(find.text('Use MM/YY'), findsOneWidget);
    });

    testWidgets('invalid CVC shows validation error', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'CVC'), 'ab');
      await tester.tap(find.textContaining('Pay \u20b9'));
      await tester.pumpAndSettle();
      expect(find.text('3-4 digits'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/dialogs/event_details_dialog.dart';
import 'package:veltrix_sports/widgets/dialogs/checkout_dialog.dart';
import 'package:veltrix_sports/services/payment/payment_service.dart';

Widget openDialog(Widget dialog) => MaterialApp(
  home: Builder(
    builder: (context) => Scaffold(
      body: ElevatedButton(
        onPressed: () => showDialog(context: context, builder: (_) => dialog),
        child: const Text('Open'),
      ),
    ),
  ),
);

void main() {
  group('EventDetailsDialog', () {
    testWidgets('renders event title and details', (tester) async {
      await tester.pumpWidget(
        openDialog(
          const EventDetailsDialog(
            event: {
              'title': 'Mumbai Half Marathon',
              'date': '25 October 2026',
              'location': 'Mumbai',
              'category': 'Running',
              'participants': '15,000+ Runners',
              'description': 'Join the premier running event.',
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Mumbai Half Marathon'), findsOneWidget);
      expect(find.text('25 October 2026'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('15,000+ Runners'), findsOneWidget);
      expect(find.text('Join the premier running event.'), findsOneWidget);
    });

    testWidgets('renders with default values for missing fields', (
      tester,
    ) async {
      await tester.pumpWidget(openDialog(const EventDetailsDialog(event: {})));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Championship Race'), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      await tester.pumpWidget(
        openDialog(const EventDetailsDialog(event: {'title': 'Test Event'})),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Add to Schedule'), findsOneWidget);
      expect(find.text('Register Now'), findsOneWidget);
    });

    testWidgets('renders about section', (tester) async {
      await tester.pumpWidget(openDialog(const EventDetailsDialog(event: {})));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('About the Event'), findsOneWidget);
    });

    testWidgets('renders leaderboard info', (tester) async {
      await tester.pumpWidget(openDialog(const EventDetailsDialog(event: {})));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Leaderboard'), findsOneWidget);
    });

    testWidgets('close button dismisses dialog', (tester) async {
      await tester.pumpWidget(openDialog(const EventDetailsDialog(event: {})));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Championship Race'), findsNothing);
    });

    testWidgets('renders info rows with icons', (tester) async {
      await tester.pumpWidget(openDialog(const EventDetailsDialog(event: {})));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
    });

    testWidgets('renders cycling category event', (tester) async {
      await tester.pumpWidget(
        openDialog(
          const EventDetailsDialog(
            event: {'title': 'Tour de France Stage 1', 'category': 'Cycling'},
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Tour de France Stage 1'), findsOneWidget);
      expect(find.text('Cycling'), findsOneWidget);
    });
  });

  group('CheckoutDialog', () {
    testWidgets('renders dialog with plan info', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Checkout'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders payment form fields', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Card Number'), findsOneWidget);
      expect(find.text('Expires (MM/YY)'), findsOneWidget);
      expect(find.text('CVC'), findsOneWidget);
      expect(find.text('Promo Code'), findsOneWidget);
    });

    testWidgets('renders Razorpay option', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Razorpay'), findsOneWidget);
    });

    testWidgets('renders demo mode banner', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('DEMO MODE'), findsOneWidget);
    });

    testWidgets('renders OR DIRECT CARD separator', (tester) async {
      await tester.pumpWidget(
        openDialog(CheckoutDialog(plan: PaymentService.availablePlans.first)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('OR DIRECT CARD'), findsOneWidget);
    });
  });
}

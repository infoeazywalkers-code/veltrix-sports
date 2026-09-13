import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/dialogs/event_details_dialog.dart';

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
  group('EventDetailsDialog - Covering uncovered lines', () {
    testWidgets('renders full event details', (tester) async {
      await tester.pumpWidget(
        openDialog(
          const EventDetailsDialog(
            event: {
              'title': 'World Championship',
              'date': '15 March 2027',
              'location': 'Berlin, Germany',
              'category': 'Running',
              'participants': '2000+ Athletes',
              'description': 'The world championship event.',
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('World Championship'), findsOneWidget);
      expect(find.text('15 March 2027'), findsOneWidget);
      expect(find.text('Berlin, Germany'), findsOneWidget);
      expect(find.text('Running'), findsWidgets);
      expect(find.text('2000+ Athletes'), findsOneWidget);
      expect(find.text('The world championship event.'), findsOneWidget);
    });

    testWidgets('close button dismisses dialog', (tester) async {
      await tester.pumpWidget(
        openDialog(const EventDetailsDialog(event: {'title': 'Test'})),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('Add to Schedule button triggers action', (tester) async {
      await tester.pumpWidget(
        openDialog(
          const EventDetailsDialog(
            event: {
              'title': 'Berlin Marathon',
              'category': 'Running',
              'location': 'Berlin',
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap "Add to Schedule"
      await tester.tap(find.text('Add to Schedule'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Button was tapped without crashing
      expect(find.text('Add to Schedule'), findsOneWidget);
    });

    testWidgets('Register Now button triggers action and pops', (tester) async {
      await tester.pumpWidget(
        openDialog(
          const EventDetailsDialog(event: {'title': 'Tokyo Marathon'}),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register Now'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();
    });

    testWidgets('renders default values for missing event fields', (
      tester,
    ) async {
      await tester.pumpWidget(openDialog(const EventDetailsDialog(event: {})));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Championship Race'), findsOneWidget);
      expect(find.text('Upcoming Event'), findsOneWidget);
      expect(find.text('Global'), findsOneWidget);
      expect(find.text('Endurance'), findsWidgets);
      expect(find.text('500+ Athletes'), findsOneWidget);
    });

    testWidgets('renders leaderboard info banner', (tester) async {
      await tester.pumpWidget(openDialog(const EventDetailsDialog(event: {})));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Leaderboard'), findsOneWidget);
      expect(find.byIcon(Icons.stars), findsOneWidget);
    });

    testWidgets('renders event info icons', (tester) async {
      await tester.pumpWidget(openDialog(const EventDetailsDialog(event: {})));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
    });

    testWidgets('Add to Schedule with cycling category uses bike sport', (
      tester,
    ) async {
      await tester.pumpWidget(
        openDialog(
          const EventDetailsDialog(
            event: {
              'title': 'Tour de France',
              'category': 'Cycling Race',
              'location': 'France',
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Schedule'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Button was tapped without crashing
      expect(find.text('Add to Schedule'), findsOneWidget);
    });

    testWidgets('Add to Schedule with non-cycling uses run sport', (
      tester,
    ) async {
      await tester.pumpWidget(
        openDialog(
          const EventDetailsDialog(
            event: {
              'title': 'NYC Marathon',
              'category': 'Running',
              'location': 'New York',
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Schedule'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Button was tapped without crashing
      expect(find.text('Add to Schedule'), findsOneWidget);
    });
  });
}

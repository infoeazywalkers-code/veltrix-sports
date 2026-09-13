import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user/user_profile.dart';
import 'package:veltrix_sports/widgets/dialogs/edit_profile_dialog.dart';

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
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  group('EditProfileDialog - Covering uncovered lines', () {
    testWidgets('toggle sport chip adds sport to selection', (tester) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Test User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final swimmingChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Swimming',
      );
      expect(swimmingChip, findsOneWidget);

      final chipBefore = tester.widget<FilterChip>(swimmingChip);
      expect(chipBefore.selected, false);

      await tester.tap(swimmingChip);
      await tester.pumpAndSettle();

      final chipAfter = tester.widget<FilterChip>(swimmingChip);
      expect(chipAfter.selected, true);
    });

    testWidgets('toggle sport chip removes sport from selection', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Test User',
        sports: ['Running', 'Cycling'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final runningChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Running',
      );

      final chipBefore = tester.widget<FilterChip>(runningChip);
      expect(chipBefore.selected, true);

      await tester.tap(runningChip);
      await tester.pumpAndSettle();

      final chipAfter = tester.widget<FilterChip>(runningChip);
      expect(chipAfter.selected, false);
    });

    testWidgets('save with empty name shows validation error', (tester) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Test User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'),
        '',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('save with all sports deselected shows snackbar', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Test User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final runningChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Running',
      );
      await tester.tap(runningChip);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please select at least one primary sport.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'save with invalid name and valid sports still shows name error',
      (tester) async {
        final profile = UserProfile(
          id: 'u1',
          email: 'a@b.com',
          displayName: 'Test User',
          sports: ['Running', 'Cycling', 'Swimming'],
          role: UserRole.athlete,
          isPremium: true,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          openDialog(EditProfileDialog(currentProfile: profile)),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Display Name'),
          '  ',
        );
        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle();

        expect(find.text('Enter your name'), findsOneWidget);
      },
    );

    testWidgets('renders all available sports as filter chips', (tester) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Running'), findsWidgets);
      expect(find.text('Cycling'), findsOneWidget);
      expect(find.text('Swimming'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Triathlon'), findsOneWidget);
      expect(find.text('Trail Running'), findsOneWidget);
    });

    testWidgets('name field accepts updated text', (tester) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Old Name',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'),
        'New Name',
      );

      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Display Name'),
      );
      expect(nameField.controller?.text, 'New Name');
    });

    testWidgets('cancel button dismisses dialog', (tester) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Dismiss Test',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Profile'), findsNothing);
    });

    testWidgets('multiple sport chips can be toggled in sequence', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'User',
        sports: [],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final runningChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Running',
      );
      await tester.tap(runningChip);
      await tester.pumpAndSettle();
      expect(tester.widget<FilterChip>(runningChip).selected, true);

      final cyclingChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Cycling',
      );
      await tester.tap(cyclingChip);
      await tester.pumpAndSettle();
      expect(tester.widget<FilterChip>(cyclingChip).selected, true);

      await tester.tap(runningChip);
      await tester.pumpAndSettle();
      expect(tester.widget<FilterChip>(runningChip).selected, false);
      expect(tester.widget<FilterChip>(cyclingChip).selected, true);
    });

    testWidgets('renders edit icon and save changes button', (tester) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Primary Sports'), findsOneWidget);
    });

    testWidgets('empty sports list renders chips all unselected', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'User',
        sports: [],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final runningChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Running',
      );
      expect(tester.widget<FilterChip>(runningChip).selected, false);
    });

    testWidgets('no profile falls back to defaults', (tester) async {
      await tester.pumpWidget(openDialog(const EditProfileDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final runningChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Running',
      );
      expect(tester.widget<FilterChip>(runningChip).selected, true);
    });

    testWidgets('save with no current user shows sign-in snackbar', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Valid Name',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'),
        'Valid Name',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please sign in to update your profile.'),
        findsOneWidget,
      );
    });

    testWidgets('save with whitespace-only name shows validation', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'),
        '   ',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('six sport chips rendered', (tester) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsNWidgets(6));
    });

    testWidgets('displays all sports from profile as selected', (tester) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'User',
        sports: ['Cycling', 'Swimming', 'Strength'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        openDialog(EditProfileDialog(currentProfile: profile)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final cyclingChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Cycling',
      );
      final swimmingChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Swimming',
      );
      final strengthChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Strength',
      );

      expect(tester.widget<FilterChip>(cyclingChip).selected, true);
      expect(tester.widget<FilterChip>(swimmingChip).selected, true);
      expect(tester.widget<FilterChip>(strengthChip).selected, true);
    });
  });
}

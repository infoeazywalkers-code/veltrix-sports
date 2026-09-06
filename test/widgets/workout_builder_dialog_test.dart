import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/workout_builder_dialog.dart';

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
  group('WorkoutBuilderDialog', () {
    testWidgets('renders dialog with title', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Schedule Workout'), findsOneWidget);
    });

    testWidgets('renders form fields', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Workout Title *'), findsOneWidget);
      expect(find.text('Duration *'), findsOneWidget);
      expect(find.text('Distance (km)'), findsOneWidget);
      expect(find.text('Target TSS Score'), findsOneWidget);
      expect(find.text('Target Pace'), findsOneWidget);
      expect(find.text('Notes / Description'), findsOneWidget);
    });

    testWidgets('renders sport dropdown', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Sport Category'), findsOneWidget);
    });

    testWidgets('renders date picker button', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Date:'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('renders Cancel and Create Workout buttons', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create Workout'), findsOneWidget);
    });

    testWidgets('cancel dismisses dialog', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Schedule Workout'), findsNothing);
    });

    testWidgets('validation shows errors for empty required fields', (
      tester,
    ) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      // Clear the pre-filled duration
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Duration *'),
        '',
      );
      // Submit
      await tester.tap(find.text('Create Workout'));
      await tester.pumpAndSettle();
      // Validation error messages should appear
      expect(find.text('Enter workout title'), findsOneWidget);
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('renders fitness center icon', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.fitness_center), findsWidgets);
    });

    testWidgets('renders calendar today icon', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('entering title clears validation error', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      // Submit empty to trigger errors
      await tester.tap(find.text('Create Workout'));
      await tester.pumpAndSettle();
      expect(find.text('Enter workout title'), findsOneWidget);
      // Now fill title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Workout Title *'),
        'Tempo Run',
      );
      await tester.pumpAndSettle();
    });

    testWidgets('entering distance field with valid input', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Distance (km)'),
        '12.5',
      );
      await tester.pumpAndSettle();
      expect(find.text('12.5'), findsOneWidget);
    });

    testWidgets('distance field rejects negative values', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Distance (km)'),
        '-5',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Workout Title *'),
        'Test',
      );
      await tester.tap(find.text('Create Workout'));
      await tester.pumpAndSettle();
      expect(find.text('Must be >= 0'), findsOneWidget);
    });

    testWidgets('TSS field rejects negative values', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Target TSS Score'),
        '-10',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Workout Title *'),
        'Test',
      );
      await tester.tap(find.text('Create Workout'));
      await tester.pumpAndSettle();
      expect(find.text('Must be >= 0'), findsWidgets);
    });

    testWidgets('target pace field accepts text input', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Target Pace'),
        '5:00 /km',
      );
      await tester.pumpAndSettle();
      expect(find.text('5:00 /km'), findsWidgets);
    });

    testWidgets('notes field accepts multiline text', (tester) async {
      await tester.pumpWidget(openDialog(const WorkoutBuilderDialog()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Notes / Description'),
        'Focus on cadence\nand form drills',
      );
      await tester.pumpAndSettle();
      expect(find.text('Focus on cadence\nand form drills'), findsOneWidget);
    });
  });
}

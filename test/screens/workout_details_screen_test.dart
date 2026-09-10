import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/workout.dart';
import 'package:veltrix_sports/screens/activity/workout_details.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  Workout makeWorkout({
    String id = 'w1',
    Sport sport = Sport.run,
    String title = 'Easy run',
    String description = '',
    String duration = '45 min',
    double? distanceKm = 7.2,
    int? tss = 62,
    String? targetPace = '5:55–6:15 /km',
    bool completed = false,
    List<WorkoutSegment> segments = const [],
  }) {
    return Workout(
      id: id,
      planId: 'plan1',
      sport: sport,
      title: title,
      description: description,
      duration: duration,
      distanceKm: distanceKm,
      tss: tss,
      targetPace: targetPace,
      scheduledFor: DateTime.now(),
      completed: completed,
      segments: segments,
    );
  }

  group('WorkoutDetailsScreen', () {
    testWidgets('renders with a full workout', (tester) async {
      final workout = makeWorkout(
        title: 'Interval session',
        sport: Sport.run,
        description: 'Hard intervals today',
        segments: [
          const WorkoutSegment(label: 'Warm up', duration: '10 min'),
          const WorkoutSegment(label: 'Intervals', duration: '25 min'),
        ],
      );

      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('Interval session'), findsWidgets);
      expect(find.text('Hard intervals today'), findsOneWidget);
      expect(find.textContaining('RUN'), findsWidgets);
      expect(find.text('Warm up • 10 min'), findsOneWidget);
      expect(find.text('Intervals • 25 min'), findsOneWidget);
    });

    testWidgets('renders with null workout showing defaults', (tester) async {
      await tester.pumpWidget(wrap(const WorkoutDetailsScreen(workout: null)));
      await tester.pumpAndSettle();

      expect(find.text('Aerobic endurance'), findsWidgets);
      expect(
        find.text('Stay relaxed and keep your effort in Zone 2.'),
        findsOneWidget,
      );
      expect(find.text('7.2 km'), findsOneWidget);
      expect(find.text('62'), findsWidgets);
      expect(find.text('5:55–6:15 /km'), findsOneWidget);
    });

    testWidgets('shows start workout button for non-completed workout', (
      tester,
    ) async {
      final workout = makeWorkout(completed: false);
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('Start workout'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('shows completed button for completed workout', (tester) async {
      final workout = makeWorkout(completed: true);
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('Workout completed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows mark as complete button when workout is not completed', (
      tester,
    ) async {
      final workout = makeWorkout(completed: false);
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('Mark as complete'), findsOneWidget);
    });

    testWidgets('does not show mark as complete when workout is null', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const WorkoutDetailsScreen(workout: null)));
      await tester.pumpAndSettle();

      expect(find.text('Mark as complete'), findsNothing);
    });

    testWidgets('does not show mark as complete when completed', (
      tester,
    ) async {
      final workout = makeWorkout(completed: true);
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('Mark as complete'), findsNothing);
    });

    testWidgets('displays metric rows with duration, distance, tss', (
      tester,
    ) async {
      final workout = makeWorkout(
        duration: '60 min',
        distanceKm: 10.5,
        tss: 85,
      );
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('60 min'), findsOneWidget);
      expect(find.text('10.5 km'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
    });

    testWidgets('displays target pace ListTile', (tester) async {
      await tester.pumpWidget(wrap(const WorkoutDetailsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Target pace'), findsOneWidget);
      expect(find.byIcon(Icons.speed), findsOneWidget);
    });

    testWidgets('renders default segments when workout is null', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const WorkoutDetailsScreen(workout: null)));
      await tester.pumpAndSettle();

      expect(find.text('Warm up • 10 min'), findsOneWidget);
      expect(find.text('Aerobic run • 30 min'), findsOneWidget);
      expect(find.text('Cool down • 5 min'), findsOneWidget);
    });

    testWidgets('renders custom segments from workout', (tester) async {
      final workout = makeWorkout(
        segments: [
          const WorkoutSegment(label: 'Warm up', duration: '10 min'),
          const WorkoutSegment(label: 'Sprint', duration: '5 min'),
        ],
      );
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('Warm up • 10 min'), findsOneWidget);
      expect(find.text('Sprint • 5 min'), findsOneWidget);
    });

    testWidgets('renders workout structure section heading', (tester) async {
      await tester.pumpWidget(wrap(const WorkoutDetailsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Workout structure'), findsOneWidget);
    });

    testWidgets('renders appBar with workout title', (tester) async {
      final workout = makeWorkout(title: 'Tempo run');
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('Tempo run'), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders different sport names', (tester) async {
      final workout = makeWorkout(sport: Sport.bike, title: 'Bike ride');
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.textContaining('BIKE'), findsWidgets);
      expect(find.text('Bike ride'), findsWidgets);
    });

    testWidgets('renders swim sport', (tester) async {
      final workout = makeWorkout(sport: Sport.swim, title: 'Swim session');
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.textContaining('SWIM'), findsWidgets);
    });

    testWidgets('renders strength sport', (tester) async {
      final workout = makeWorkout(sport: Sport.strength, title: 'Strength day');
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.textContaining('STRENGTH'), findsWidgets);
    });

    testWidgets('renders without distance and tss when null', (tester) async {
      final workout = makeWorkout(distanceKm: null, tss: null);
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('7.2 km'), findsOneWidget);
      expect(find.text('62'), findsWidgets);
    });

    testWidgets('renders without target pace when null', (tester) async {
      final workout = makeWorkout(targetPace: null);
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('5:55–6:15 /km'), findsOneWidget);
    });

    testWidgets('renders with empty description fallback', (tester) async {
      final workout = makeWorkout(description: '');
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(
        find.text('Stay relaxed and keep your effort in Zone 2.'),
        findsOneWidget,
      );
    });

    testWidgets('renders with non-empty description', (tester) async {
      final workout = makeWorkout(description: 'Zone 2 effort today');
      await tester.pumpWidget(wrap(WorkoutDetailsScreen(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('Zone 2 effort today'), findsOneWidget);
    });

    testWidgets('has a scrollable ListView body', (tester) async {
      await tester.pumpWidget(wrap(const WorkoutDetailsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders card with duration, distance, tss metrics', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const WorkoutDetailsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('TSS'), findsWidgets);
    });
  });
}

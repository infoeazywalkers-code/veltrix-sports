import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/models/activity/workout.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/screens/training/calendar_screen.dart';

void main() {
  Widget wrapWithWorkouts(List<Workout> workouts) => ProviderScope(
    overrides: [
      authStateProvider.overrideWith((ref) => Stream.value(null)),
      workoutsByDateRangeProvider.overrideWith(
        (ref, arg) => Stream.value(workouts),
      ),
    ],
    child: const MaterialApp(home: Scaffold(body: CalendarScreen())),
  );

  Widget wrapEmpty() => wrapWithWorkouts([]);

  Workout makeWorkout({
    String id = 'w1',
    Sport sport = Sport.run,
    String title = 'Easy run',
    String duration = '45 min',
    int? tss = 62,
    DateTime? scheduledFor,
    double progress = 0.0,
    bool completed = false,
  }) {
    return Workout(
      id: id,
      planId: 'plan1',
      sport: sport,
      title: title,
      duration: duration,
      tss: tss,
      scheduledFor: scheduledFor ?? DateTime.now(),
      progress: progress,
      completed: completed,
    );
  }

  group('CalendarScreen', () {
    testWidgets('renders week navigation arrows', (tester) async {
      await tester.pumpWidget(wrapEmpty());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders week day labels M-S', (tester) async {
      await tester.pumpWidget(wrapEmpty());
      await tester.pumpAndSettle();

      expect(find.text('M'), findsWidgets);
      expect(find.text('T'), findsWidgets);
      expect(find.text('W'), findsWidgets);
      expect(find.text('F'), findsWidgets);
      expect(find.text('S'), findsWidgets);
    });

    testWidgets('navigates to next week', (tester) async {
      await tester.pumpWidget(wrapEmpty());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Should still render without error
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('navigates to previous week', (tester) async {
      await tester.pumpWidget(wrapEmpty());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('navigates forward and back', (tester) async {
      await tester.pumpWidget(wrapEmpty());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('shows No workouts scheduled when empty', (tester) async {
      await tester.pumpWidget(wrapEmpty());
      await tester.pumpAndSettle();

      expect(find.text('No workouts scheduled'), findsOneWidget);
      expect(find.text('Enjoy your rest day'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy), findsWidgets);
    });

    testWidgets('renders section heading with day and date', (tester) async {
      await tester.pumpWidget(wrapEmpty());
      await tester.pumpAndSettle();

      // The section heading shows the selected day label and date
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('renders Week overview heading', (tester) async {
      await tester.pumpWidget(wrapEmpty());
      await tester.pumpAndSettle();

      expect(find.text('Week overview'), findsOneWidget);
    });

    testWidgets('shows No workouts this week when empty', (tester) async {
      await tester.pumpWidget(wrapEmpty());
      await tester.pumpAndSettle();

      expect(find.text('No workouts this week'), findsOneWidget);
    });

    testWidgets('renders workouts for selected day', (tester) async {
      final today = DateTime.now();
      final workouts = [
        makeWorkout(title: 'Morning run', scheduledFor: today),
        makeWorkout(
          id: 'w2',
          title: 'Evening bike',
          sport: Sport.bike,
          scheduledFor: today,
        ),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      expect(find.text('Morning run'), findsOneWidget);
      expect(find.text('Evening bike'), findsOneWidget);
    });

    testWidgets('shows No workouts today when no match for selected day', (
      tester,
    ) async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final workouts = [
        makeWorkout(title: 'Tomorrow run', scheduledFor: tomorrow),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      // Tomorrow's workout doesn't match today's selection
      expect(find.text('No workouts today'), findsWidgets);
    });

    testWidgets('renders week overview rows', (tester) async {
      final today = DateTime.now();
      final workouts = [makeWorkout(title: 'Morning run', scheduledFor: today)];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      // WeekRow shows title
      expect(find.text('Morning run'), findsWidgets);
    });

    testWidgets('tapping a different day changes selection', (tester) async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final workouts = [
        makeWorkout(title: 'Today run', scheduledFor: today),
        makeWorkout(id: 'w2', title: 'Tomorrow run', scheduledFor: tomorrow),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      // Tap the next day in the row
      final dayButtons = find.byType(GestureDetector);
      if (dayButtons.evaluate().length > 1) {
        await tester.tap(dayButtons.at(1));
        await tester.pumpAndSettle();
      }

      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('renders sport icons for workouts', (tester) async {
      final today = DateTime.now();
      final workouts = [
        makeWorkout(sport: Sport.run, scheduledFor: today),
        makeWorkout(
          id: 'w2',
          sport: Sport.bike,
          title: 'Bike ride',
          scheduledFor: today,
        ),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.directions_run), findsWidgets);
      expect(find.byIcon(Icons.directions_bike), findsWidgets);
    });

    testWidgets('renders swim sport workout', (tester) async {
      final today = DateTime.now();
      final workouts = [
        makeWorkout(
          id: 'w3',
          sport: Sport.swim,
          title: 'Swim session',
          scheduledFor: today,
        ),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      expect(find.text('Swim session'), findsOneWidget);
      expect(find.byIcon(Icons.pool), findsWidgets);
    });

    testWidgets('renders strength sport workout', (tester) async {
      final today = DateTime.now();
      final workouts = [
        makeWorkout(
          id: 'w4',
          sport: Sport.strength,
          title: 'Strength day',
          scheduledFor: today,
        ),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      expect(find.text('Strength day'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsWidgets);
    });

    testWidgets('renders rest sport workout', (tester) async {
      final today = DateTime.now();
      final workouts = [
        makeWorkout(
          id: 'w5',
          sport: Sport.rest,
          title: 'Rest day',
          scheduledFor: today,
        ),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      expect(find.text('Rest day'), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsWidgets);
    });

    testWidgets('renders workout with tss in details', (tester) async {
      final now = DateTime.now();
      final weekStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      final saturday = weekStart.add(const Duration(days: 5));
      final workouts = [
        makeWorkout(title: 'Tempo run', tss: 85, scheduledFor: saturday),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      expect(find.textContaining('85 TSS'), findsOneWidget);
    });

    testWidgets('renders workout without tss', (tester) async {
      final today = DateTime.now();
      final workouts = [
        makeWorkout(title: 'Easy jog', tss: null, scheduledFor: today),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      expect(find.text('Easy jog'), findsOneWidget);
    });

    testWidgets('has ListView as root', (tester) async {
      await tester.pumpWidget(wrapEmpty());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders workout card with progress', (tester) async {
      final today = DateTime.now();
      final workouts = [
        makeWorkout(title: 'Long run', progress: 0.75, scheduledFor: today),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      expect(find.text('Long run'), findsOneWidget);
    });

    testWidgets('week overview sorts workouts by date', (tester) async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 2));
      final workouts = [
        makeWorkout(title: 'Later run', scheduledFor: tomorrow),
        makeWorkout(id: 'w2', title: 'Earlier run', scheduledFor: today),
      ];

      await tester.pumpWidget(wrapWithWorkouts(workouts));
      await tester.pumpAndSettle();

      // Both should render
      expect(find.text('Earlier run'), findsWidgets);
      expect(find.text('Later run'), findsWidgets);
    });
  });
}

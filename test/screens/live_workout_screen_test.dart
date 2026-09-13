import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/workout.dart';
import 'package:veltrix_sports/screens/activity/live_workout_screen.dart';

void main() {
  testWidgets('LiveWorkoutScreen renders HUD metrics and stopwatch controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(() => tester.view.resetPhysicalSize());

    final workout = Workout(
      id: 'live_test_w',
      planId: 'p1',
      sport: Sport.run,
      title: 'Live 10K Race Pace',
      description: 'Live test session',
      duration: '45m',
      distanceKm: 10.0,
      tss: 65,
      scheduledFor: DateTime(2026, 9, 4),
    );

    await tester.pumpWidget(
      MaterialApp(home: LiveWorkoutScreen(workout: workout)),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LiveWorkoutScreen), findsOneWidget);
    expect(find.text('LIVE 10K RACE PACE'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('PACE'), findsOneWidget);
    expect(find.text('HEART RATE'), findsOneWidget);
  });
}

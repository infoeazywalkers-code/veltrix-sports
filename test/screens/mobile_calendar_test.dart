import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/core/constants.dart';
import 'package:veltrix_sports/models/activity/workout.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/mobile/screens/mobile_calendar.dart';

Widget wrapCalendar({Stream<List<Workout>>? workoutStream}) => ProviderScope(
  overrides: [
    authStateProvider.overrideWith((ref) => Stream.value(null)),
    workoutsByDateRangeProvider.overrideWith(
      (ref, arg) => workoutStream ?? const Stream.empty(),
    ),
    activePlansProvider.overrideWith((ref) => Stream.value(const [])),
  ],
  child: const MaterialApp(home: Scaffold(body: MobileCalendarScreen())),
);

void main() {
  group('MobileCalendarScreen honest empty state', () {
    testWidgets('empty day shows No workouts today', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('No workouts today'), findsOneWidget);
    });

    testWidgets('empty day never fabricates a demo workout', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Easy Recovery Run'), findsNothing);
    });

    testWidgets('shows a real workout scheduled on the selected day', (
      tester,
    ) async {
      final weekStart = getStartOfWeek(DateTime.now(), weekOffset: 0);
      final selected = weekStart.add(const Duration(days: 5));
      final workout = Workout(
        id: 'real1',
        planId: 'plan1',
        sport: Sport.bike,
        title: 'Real Evening Ride',
        duration: '60 min',
        scheduledFor: selected,
      );
      await tester.pumpWidget(
        wrapCalendar(workoutStream: Stream.value([workout])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Real Evening Ride'), findsWidgets);
      expect(find.text('Easy Recovery Run'), findsNothing);
    });
  });
}

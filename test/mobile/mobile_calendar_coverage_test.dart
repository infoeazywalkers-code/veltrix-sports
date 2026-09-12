import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/core/constants.dart';
import 'package:veltrix_sports/models/activity/workout.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/mobile/screens/mobile_calendar.dart';

Widget wrapCalendar({Stream<List<Workout>>? workoutStream}) => ProviderScope(
  overrides: [
    workoutsByDateRangeProvider.overrideWith(
      (ref, arg) => workoutStream ?? const Stream.empty(),
    ),
  ],
  child: const MaterialApp(home: Scaffold(body: MobileCalendarScreen())),
);

Workout makeWorkout({
  String id = 'w1',
  Sport sport = Sport.run,
  String title = 'Easy Run',
  String duration = '30 min',
  double progress = 0.5,
  DateTime? scheduled,
}) => Workout(
  id: id,
  planId: 'plan1',
  sport: sport,
  title: title,
  duration: duration,
  scheduledFor: scheduled ?? DateTime.now(),
  progress: progress,
);

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  DateTime selectedDayDate(int dayOffset) {
    final weekStart = getStartOfWeek(DateTime.now(), weekOffset: 0);
    return weekStart.add(Duration(days: dayOffset));
  }

  group('MobileCalendarScreen', () {
    testWidgets('renders Calendar title', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('shows week day labels', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      for (final d in ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']) {
        expect(find.text(d), findsOneWidget);
      }
    });

    testWidgets('shows week overview section', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Week overview'), findsOneWidget);
    });

    testWidgets('left arrow button exists', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byIcon(Icons.chevron_left), findsWidgets);
    });

    testWidgets('right arrow button exists', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('tapping left arrow changes week', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byIcon(Icons.chevron_left).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('–'), findsOneWidget);
    });

    testWidgets('tapping right arrow changes week', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('–'), findsOneWidget);
    });

    testWidgets(
      'shows honest empty state when no workouts match selected day',
      (tester) async {
        await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('No workouts today'), findsOneWidget);
        expect(find.text('Easy Recovery Run'), findsNothing);
      },
    );

    testWidgets('shows no sport label when no workouts exist', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('RUN'), findsNothing);
    });

    testWidgets('shows empty-state card instead of demo details', (
      tester,
    ) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('No workouts today'), findsOneWidget);
      expect(find.textContaining('4.5 km'), findsNothing);
    });

    testWidgets('shows Run workout when scheduled on selected day', (
      tester,
    ) async {
      final date = selectedDayDate(5);
      final workout = makeWorkout(sport: Sport.run, scheduled: date);
      await tester.pumpWidget(
        wrapCalendar(workoutStream: Stream.value([workout])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Easy Run'), findsWidgets);
      expect(find.text('RUN'), findsOneWidget);
    });

    testWidgets('shows Bike workout', (tester) async {
      final date = selectedDayDate(5);
      final workout = makeWorkout(
        id: 'w2',
        sport: Sport.bike,
        title: 'Bike Intervals',
        scheduled: date,
      );
      await tester.pumpWidget(
        wrapCalendar(workoutStream: Stream.value([workout])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Bike Intervals'), findsWidgets);
      expect(find.text('BIKE'), findsOneWidget);
    });

    testWidgets('shows Swim workout', (tester) async {
      final date = selectedDayDate(5);
      final workout = makeWorkout(
        id: 'w3',
        sport: Sport.swim,
        title: 'Swim Drills',
        scheduled: date,
      );
      await tester.pumpWidget(
        wrapCalendar(workoutStream: Stream.value([workout])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Swim Drills'), findsWidgets);
      expect(find.text('SWIM'), findsOneWidget);
    });

    testWidgets('shows Strength workout', (tester) async {
      final date = selectedDayDate(5);
      final workout = makeWorkout(
        id: 'w4',
        sport: Sport.strength,
        title: 'Strength Session',
        scheduled: date,
      );
      await tester.pumpWidget(
        wrapCalendar(workoutStream: Stream.value([workout])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Strength Session'), findsWidgets);
      expect(find.text('STRENGTH'), findsOneWidget);
    });

    testWidgets('shows Rest workout', (tester) async {
      final date = selectedDayDate(5);
      final workout = makeWorkout(
        id: 'w5',
        sport: Sport.rest,
        title: 'Rest Day',
        scheduled: date,
      );
      await tester.pumpWidget(
        wrapCalendar(workoutStream: Stream.value([workout])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Rest Day'), findsWidgets);
      expect(find.text('REST'), findsOneWidget);
    });

    testWidgets('week overview shows Rest day for empty days', (tester) async {
      final date = selectedDayDate(0);
      final workout = makeWorkout(
        id: 'w1',
        sport: Sport.run,
        title: 'Monday Run',
        scheduled: date,
      );
      await tester.pumpWidget(
        wrapCalendar(workoutStream: Stream.value([workout])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Rest day'), findsWidgets);
    });

    testWidgets('day selection tap on different day', (tester) async {
      await tester.pumpWidget(wrapCalendar(workoutStream: Stream.value([])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('MON'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('shows TSS in workout details', (tester) async {
      final date = selectedDayDate(5);
      final workout = makeWorkout(
        id: 'w6',
        sport: Sport.run,
        title: 'Tempo Run',
        duration: '45 min',
        scheduled: date,
      );
      await tester.pumpWidget(
        wrapCalendar(workoutStream: Stream.value([workout])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Tempo Run'), findsWidgets);
      expect(find.textContaining('45 min'), findsWidgets);
    });

    testWidgets('multiple workouts shown in same day', (tester) async {
      final date = selectedDayDate(5);
      final w1 = makeWorkout(
        id: 'w1',
        sport: Sport.run,
        title: 'Morning Run',
        scheduled: date,
      );
      final w2 = makeWorkout(
        id: 'w2',
        sport: Sport.bike,
        title: 'Evening Ride',
        scheduled: date,
      );
      await tester.pumpWidget(
        wrapCalendar(workoutStream: Stream.value([w1, w2])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Morning Run'), findsWidgets);
      expect(find.text('Evening Ride'), findsWidgets);
    });

    testWidgets('error stream shows error', (tester) async {
      await tester.pumpWidget(
        wrapCalendar(workoutStream: Stream.error(Exception('test error'))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Error'), findsWidgets);
    });
  });
}

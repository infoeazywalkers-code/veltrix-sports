import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/screens/premium/premium_screen.dart';
import 'package:veltrix_sports/screens/activity/live_workout_screen.dart';
import 'package:veltrix_sports/screens/activity/workout_details.dart';
import 'package:veltrix_sports/models/activity/workout.dart';

Workout makeWorkout({
  String id = 'test1',
  String userId = 'u1',
  String planId = 'plan1',
  Sport sport = Sport.run,
  String title = 'Test Workout',
  String description = 'Test description',
  String duration = '30m',
  double? distanceKm = 5.0,
  int? tss = 40,
  String? targetPace = '6:00 /km',
  List<WorkoutSegment> segments = const [],
}) => Workout(
  id: id,
  userId: userId,
  planId: planId,
  sport: sport,
  title: title,
  description: description,
  duration: duration,
  distanceKm: distanceKm,
  tss: tss,
  targetPace: targetPace,
  scheduledFor: DateTime.now(),
  completed: false,
  segments: segments,
);

void main() {
  group('PremiumScreen', () {
    testWidgets('renders initial viewport with heading and features', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PremiumScreen())),
      );
      // Top of the ListView should show these
      expect(find.text('PREMIUM'), findsOneWidget);
      expect(find.text('Your Next Peak Starts with Premium'), findsOneWidget);
      expect(find.text('PLAN'), findsOneWidget);
      expect(find.text('ANALYZE'), findsOneWidget);
      expect(find.text('CROSS-TRAIN'), findsOneWidget);
    });

    testWidgets('scrolls to pricing section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PremiumScreen())),
      );
      // Scroll down to reach the pricing section
      await tester.scrollUntilVisible(find.text('Monthly'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Annual'), findsOneWidget);
    });

    testWidgets('scrolls to virtual section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PremiumScreen())),
      );
      await tester.scrollUntilVisible(
        find.text('Veltrix Virtual included.'),
        200,
      );
      await tester.pumpAndSettle();
      expect(find.text('Veltrix Virtual included.'), findsOneWidget);
    });

    testWidgets('scrolls to feature highlights', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PremiumScreen())),
      );
      await tester.scrollUntilVisible(
        find.text('Why athletes choose Premium'),
        200,
      );
      await tester.pumpAndSettle();
      expect(find.text('Why athletes choose Premium'), findsOneWidget);
      expect(find.text('PMC Chart'), findsOneWidget);
      expect(find.text('Workout Library'), findsOneWidget);
    });

    testWidgets('scrolls to CTA section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PremiumScreen())),
      );
      await tester.scrollUntilVisible(
        find.text('Go further with Premium.'),
        200,
      );
      await tester.pumpAndSettle();
      expect(find.text('Go further with Premium.'), findsOneWidget);
      expect(find.text('Get Premium Now'), findsOneWidget);
    });

    testWidgets('scrolls to footer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PremiumScreen())),
      );
      await tester.scrollUntilVisible(find.text('VELTRIX'), 200);
      await tester.pumpAndSettle();
      expect(find.text('VELTRIX'), findsOneWidget);
    });

    testWidgets('scrolls to pricing details', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PremiumScreen())),
      );
      await tester.scrollUntilVisible(find.text('BEST VALUE'), 200);
      await tester.pumpAndSettle();
      expect(find.text('BEST VALUE'), findsOneWidget);
      expect(find.text('Get Started Now'), findsWidgets);
      expect(find.text('Performance Management Chart'), findsWidgets);
    });

    testWidgets('renders desktop layout when wide', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: PremiumScreen(),
            ),
          ),
        ),
      );
      // In desktop layout, heading renders correctly
      expect(find.text('PREMIUM'), findsOneWidget);
      expect(find.text('PLAN'), findsOneWidget);
    });

    testWidgets('renders mobile layout when narrow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: PremiumScreen(),
            ),
          ),
        ),
      );
      expect(find.text('PREMIUM'), findsOneWidget);
    });
  });

  group('LiveWorkoutScreen', () {
    testWidgets('renders workout title and demo mode', (tester) async {
      final workout = makeWorkout(title: 'Morning Run', tss: 40);
      await tester.pumpWidget(
        MaterialApp(home: LiveWorkoutScreen(workout: workout)),
      );
      expect(find.text('MORNING RUN'), findsOneWidget);
      expect(find.textContaining('DEMO MODE'), findsWidgets);
    });

    testWidgets('renders timer display', (tester) async {
      final workout = makeWorkout(title: 'Timer Test');
      await tester.pumpWidget(
        MaterialApp(home: LiveWorkoutScreen(workout: workout)),
      );
      expect(find.textContaining(':'), findsWidgets);
    });

    testWidgets('renders metric tiles', (tester) async {
      final workout = makeWorkout(
        sport: Sport.bike,
        title: 'Bike Ride',
        description: 'Endurance',
        duration: '1h',
        distanceKm: 30.0,
        tss: 80,
        targetPace: '28 km/h',
      );
      await tester.pumpWidget(
        MaterialApp(home: LiveWorkoutScreen(workout: workout)),
      );
      expect(find.text('DISTANCE'), findsOneWidget);
      expect(find.text('PACE'), findsOneWidget);
      expect(find.text('HEART RATE'), findsOneWidget);
      expect(find.text('TSS SCORE'), findsOneWidget);
    });

    testWidgets('renders close button', (tester) async {
      final workout = makeWorkout(title: 'Close Test');
      await tester.pumpWidget(
        MaterialApp(home: LiveWorkoutScreen(workout: workout)),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders play button initially', (tester) async {
      final workout = makeWorkout(title: 'Play Test');
      await tester.pumpWidget(
        MaterialApp(home: LiveWorkoutScreen(workout: workout)),
      );
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });
  });

  group('WorkoutDetailsScreen', () {
    testWidgets('renders workout title and details', (tester) async {
      final workout = makeWorkout(
        title: 'Long Run',
        description: 'Steady aerobic run.',
        duration: '1h 30min',
        distanceKm: 15.0,
        tss: 95,
        targetPace: '5:45 /km',
        segments: const [
          WorkoutSegment(label: 'Warm up', duration: '10 min'),
          WorkoutSegment(label: 'Main set', duration: '65 min'),
          WorkoutSegment(label: 'Cool down', duration: '15 min'),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(home: WorkoutDetailsScreen(workout: workout)),
      );
      expect(find.text('Long Run'), findsWidgets);
      expect(find.text('15.0 km'), findsOneWidget);
      expect(find.text('95'), findsWidgets);
    });

    testWidgets('renders with null workout', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WorkoutDetailsScreen()));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders with workout without segments', (tester) async {
      final workout = makeWorkout(
        sport: Sport.bike,
        title: 'Bike Ride',
        description: 'Easy spin',
        duration: '45m',
        distanceKm: 20.0,
        tss: 50,
      );
      await tester.pumpWidget(
        MaterialApp(home: WorkoutDetailsScreen(workout: workout)),
      );
      expect(find.text('Bike Ride'), findsWidgets);
    });

    testWidgets('renders workout metadata and segments', (tester) async {
      final workout = makeWorkout(
        title: 'Metadata Test',
        description: 'Testing metadata display',
        duration: '45m',
        distanceKm: 7.5,
        tss: 60,
        targetPace: '6:00 /km',
        segments: const [
          WorkoutSegment(label: 'Warm up', duration: '10 min'),
          WorkoutSegment(label: 'Run', duration: '25 min'),
          WorkoutSegment(label: 'Cool down', duration: '10 min'),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(home: WorkoutDetailsScreen(workout: workout)),
      );
      expect(find.text('Testing metadata display'), findsOneWidget);
      expect(find.text('6:00 /km'), findsOneWidget);
    });
  });
}

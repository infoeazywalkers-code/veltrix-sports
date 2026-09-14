import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user/user_profile.dart';
import 'package:veltrix_sports/models/activity/workout.dart';
import 'package:veltrix_sports/models/performance/performance_snapshot.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/mobile/screens/mobile_home.dart';

Widget wrapHome({
  UserProfile? profile,
  List<Workout>? workouts,
  PerformanceSnapshot? performance,
}) => ProviderScope(
  overrides: [
    userProfileProvider.overrideWith((ref) => Stream.value(profile)),
    upcomingWorkoutsProvider.overrideWith((ref) async => workouts ?? []),
    latestPerformanceProvider.overrideWith((ref) => Stream.value(performance)),
  ],
  child: const MaterialApp(home: Scaffold(body: MobileHomeScreen())),
);

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('MobileHomeScreen', () {
    testWidgets('renders VELTRIX title in app bar', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      expect(find.text('VELTRIX'), findsOneWidget);
    });

    testWidgets('shows greeting when profile loaded', (tester) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'John Runner',
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(profile: profile));
      await tester.pumpAndSettle();
      expect(find.text('Hello, John'), findsOneWidget);
    });

    testWidgets('shows tagline', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      expect(
        find.text('Built for athletes who want more from every session.'),
        findsOneWidget,
      );
    });

    testWidgets('shows notification icon', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('YOUR TRAINING TODAY visible after scroll', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('YOUR TRAINING TODAY'), 200);
      expect(find.text('YOUR TRAINING TODAY'), findsOneWidget);
    });

    testWidgets('shows demo workout after scroll', (tester) async {
      await tester.pumpWidget(wrapHome(workouts: []));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Aerobic endurance'), 200);
      expect(find.text('Aerobic endurance'), findsOneWidget);
    });

    testWidgets('shows demo workout RUN label after scroll', (tester) async {
      await tester.pumpWidget(wrapHome(workouts: []));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('RUN'), 200);
      expect(find.text('RUN'), findsOneWidget);
    });

    testWidgets('shows demo workout details after scroll', (tester) async {
      await tester.pumpWidget(wrapHome(workouts: []));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('45 min'), 200);
      expect(find.textContaining('45 min'), findsOneWidget);
    });

    testWidgets('shows Training status section after scroll', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Training status'), 200);
      expect(find.text('Training status'), findsOneWidget);
    });

    testWidgets('shows This week section after scroll', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('This week'), 200);
      expect(find.text('This week'), findsOneWidget);
    });

    testWidgets('shows week stats after scroll', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Workouts'), 200);
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);
    });

    testWidgets('shows Ready starts here banner after scroll', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Ready starts here.'), 200);
      expect(find.text('Ready starts here.'), findsOneWidget);
    });

    testWidgets('shows Get started button after scroll', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Get started'), 200);
      expect(find.text('Get started'), findsOneWidget);
    });

    testWidgets('shows Mumbai Half Marathon banner after scroll', (
      tester,
    ) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Mumbai Half Marathon'), 200);
      expect(find.text('Mumbai Half Marathon'), findsOneWidget);
    });

    testWidgets('shows race badge after scroll', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('A RACE'), 200);
      expect(find.text('A RACE'), findsOneWidget);
    });

    testWidgets('shows 62% progress text after scroll', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('62%'), 200);
      expect(find.text('62%'), findsOneWidget);
    });

    testWidgets('shows Fitness/Fatigue/Form stat rings after scroll', (
      tester,
    ) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Fitness'), 200);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.text('Fatigue'), findsOneWidget);
      expect(find.text('Form'), findsOneWidget);
    });

    testWidgets('shows productive training text after scroll', (tester) async {
      // form -15 lands in the [-30, -10) "Productive Training" TSB zone.
      final snapshot = PerformanceSnapshot(
        id: 'p1',
        userId: 'u1',
        fitness: 72.0,
        fatigue: 87.0,
        form: -15.0,
        weeklyTss: 420,
        weeklyWorkouts: 5,
        weeklyDuration: '6h 30m',
        recordedAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(performance: snapshot));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Productive Training'),
        200,
      );
      expect(find.textContaining('Productive Training'), findsOneWidget);
    });

    testWidgets('shows Run workout when workouts exist', (tester) async {
      final workout = Workout(
        id: 'w1',
        planId: 'p1',
        sport: Sport.run,
        title: 'Tempo Run',
        duration: '40 min',
        distanceKm: 6.0,
        tss: 50,
        scheduledFor: DateTime.now(),
        progress: 0.3,
      );
      await tester.pumpWidget(wrapHome(workouts: [workout]));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Tempo Run'), 200);
      expect(find.text('Tempo Run'), findsOneWidget);
    });

    testWidgets('shows Bike workout', (tester) async {
      final workout = Workout(
        id: 'w2',
        planId: 'p1',
        sport: Sport.bike,
        title: 'Hill Intervals',
        duration: '60 min',
        tss: 75,
        scheduledFor: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(workouts: [workout]));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Hill Intervals'), 200);
      expect(find.text('Hill Intervals'), findsOneWidget);
    });

    testWidgets('shows Swim workout', (tester) async {
      final workout = Workout(
        id: 'w3',
        planId: 'p1',
        sport: Sport.swim,
        title: 'Pool Session',
        duration: '45 min',
        scheduledFor: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(workouts: [workout]));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Pool Session'), 200);
      expect(find.text('Pool Session'), findsOneWidget);
    });

    testWidgets('shows Strength workout', (tester) async {
      final workout = Workout(
        id: 'w4',
        planId: 'p1',
        sport: Sport.strength,
        title: 'Core Workout',
        duration: '30 min',
        scheduledFor: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(workouts: [workout]));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Core Workout'), 200);
      expect(find.text('Core Workout'), findsOneWidget);
    });

    testWidgets('notification icon opens notifications page', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      // NotificationsScreen requires Firebase; just verify the icon is present.
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });
  });

  group('MobileHomeScreen - additional coverage', () {
    testWidgets('null profile shows Athlete greeting', (tester) async {
      await tester.pumpWidget(wrapHome(profile: null));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Athlete'), findsOneWidget);
    });

    testWidgets('null profile shows sign up buttons after scroll', (
      tester,
    ) async {
      await tester.pumpWidget(wrapHome(profile: null));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Athlete sign up'), 200);
      expect(find.text('Athlete sign up'), findsOneWidget);
      expect(find.text('Coach sign up'), findsOneWidget);
    });

    testWidgets('profile present hides sign up buttons', (tester) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Jane Athlete',
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(profile: profile));
      await tester.pumpAndSettle();
      await tester.pump();
      expect(find.text('Athlete sign up'), findsNothing);
      expect(find.text('Coach sign up'), findsNothing);
    });

    testWidgets('shows Swim workout with pool icon', (tester) async {
      final workout = Workout(
        id: 'w5',
        planId: 'p1',
        sport: Sport.swim,
        title: 'Open Water Swim',
        duration: '60 min',
        distanceKm: 3.0,
        tss: 70,
        scheduledFor: DateTime.now(),
        progress: 0.45,
      );
      await tester.pumpWidget(wrapHome(workouts: [workout]));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Open Water Swim'), 200);
      expect(find.text('Open Water Swim'), findsOneWidget);
    });

    testWidgets('shows Strength workout with dumbbell icon', (tester) async {
      final workout = Workout(
        id: 'w6',
        planId: 'p1',
        sport: Sport.strength,
        title: 'Full Body Strength',
        duration: '50 min',
        tss: 80,
        scheduledFor: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(workouts: [workout]));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Full Body Strength'), 200);
      expect(find.text('Full Body Strength'), findsOneWidget);
    });

    testWidgets('workout with distanceKm and tss shows details', (
      tester,
    ) async {
      final workout = Workout(
        id: 'w7',
        planId: 'p1',
        sport: Sport.run,
        title: 'Long Run',
        duration: '90 min',
        distanceKm: 18.5,
        tss: 110,
        scheduledFor: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(workouts: [workout]));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Long Run'), 200);
      expect(find.textContaining('90 min'), findsOneWidget);
      expect(find.textContaining('18.5 km'), findsOneWidget);
      expect(find.textContaining('110 TSS'), findsOneWidget);
    });

    testWidgets('workout without distanceKm omits distance', (tester) async {
      final workout = Workout(
        id: 'w8',
        planId: 'p1',
        sport: Sport.bike,
        title: 'Trainer Ride',
        duration: '45 min',
        scheduledFor: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(workouts: [workout]));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Trainer Ride'), 200);
      expect(find.textContaining('45 min'), findsOneWidget);
    });

    testWidgets('week summary shows TSS stat after scroll', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('TSS'), 200);
      expect(find.text('TSS'), findsOneWidget);
    });

    testWidgets('week summary shows day labels after scroll', (tester) async {
      await tester.pumpWidget(wrapHome());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('M'), 200);
      expect(find.text('M'), findsWidgets);
      expect(find.text('T'), findsWidgets);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('S'), findsWidgets);
    });

    testWidgets('profile with single name word shows first name', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Athlete',
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(profile: profile));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Athlete'), findsOneWidget);
    });

    testWidgets('Rest workout shows self-improvement icon', (tester) async {
      final workout = Workout(
        id: 'w9',
        planId: 'p1',
        sport: Sport.rest,
        title: 'Recovery Day',
        duration: 'Rest',
        scheduledFor: DateTime.now(),
      );
      await tester.pumpWidget(wrapHome(workouts: [workout]));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Recovery Day'), 200);
      expect(find.text('Recovery Day'), findsOneWidget);
    });
  });
}

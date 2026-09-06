import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/screens/profile_screen.dart';
import 'package:veltrix_sports/screens/calendar_screen.dart';
import 'package:veltrix_sports/screens/explore_screen.dart';
import 'package:veltrix_sports/mobile/screens/mobile_explore.dart';
import 'package:veltrix_sports/models/user_profile.dart';
import 'package:veltrix_sports/models/workout.dart';
import 'package:veltrix_sports/models/performance_snapshot.dart';

final _testProfile = UserProfile(
  id: 'u1',
  email: 'priya@veltrix.com',
  displayName: 'Priya Sharma',
  role: UserRole.athlete,
  sports: ['Running', 'Cycling'],
  experienceLevel: 'Advanced',
  mainGoal: 'Marathon PB',
  isPremium: true,
  subscriptionTier: 'Elite',
  subscriptionRenewsAt: DateTime(2026, 10, 15),
  createdAt: DateTime(2024, 1, 1),
);

final _now = DateTime.now();

Workout _makeWorkout({
  required String id,
  required Sport sport,
  required String title,
  required String duration,
}) => Workout(
  id: id,
  planId: 'plan-1',
  sport: sport,
  title: title,
  description: 'Test workout',
  duration: duration,
  distanceKm: 10.0,
  tss: 80,
  scheduledFor: _now,
  progress: 0.5,
);

final _testWorkouts = [
  _makeWorkout(
    id: 'w1',
    sport: Sport.run,
    title: 'Tempo Run',
    duration: '45 min',
  ),
  _makeWorkout(
    id: 'w2',
    sport: Sport.bike,
    title: 'Endurance Ride',
    duration: '90 min',
  ),
];

final _testPerformance = PerformanceSnapshot(
  id: 'p1',
  userId: 'u1',
  fitness: 72.5,
  fatigue: 45.0,
  form: 27.5,
  weeklyTss: 420,
  weeklyWorkouts: 5,
  weeklyDuration: '6h 30m',
  recordedAt: _now,
);

Widget desktopShell(Widget child) => ProviderScope(
  overrides: [
    authStateProvider.overrideWith((ref) => Stream.value(null)),
    userProfileProvider.overrideWith((ref) => Stream.value(_testProfile)),
    upcomingWorkoutsProvider.overrideWith((ref) async => _testWorkouts),
    activePlansProvider.overrideWith((ref) => Stream.value([])),
    latestPerformanceProvider.overrideWith(
      (ref) => Stream.value(_testPerformance),
    ),
    weekWorkoutsProvider.overrideWith((ref, arg) async => _testWorkouts),
    workoutsByDateRangeProvider.overrideWith(
      (ref, arg) => Stream.value(_testWorkouts),
    ),
    performanceHistoryProvider.overrideWith(
      (ref, arg) => Stream.value([_testPerformance]),
    ),
  ],
  child: MaterialApp(home: Scaffold(body: child)),
);

void main() {
  group('ProfileScreen with data', () {
    testWidgets('renders full profile', (tester) async {
      await tester.pumpWidget(desktopShell(ProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.text('PS'), findsOneWidget);
      expect(find.textContaining('Running'), findsWidgets);
      expect(find.text('Veltrix Premium'), findsOneWidget);
      expect(find.textContaining('Renews'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Personal details'), findsOneWidget);
      expect(find.text('Training zones'), findsOneWidget);
      expect(find.text('Apps & devices'), findsOneWidget);
      expect(find.text('Equipment'), findsOneWidget);
      expect(find.text('Help center'), findsOneWidget);
      expect(find.text('Contact support'), findsOneWidget);
      expect(find.text('About Veltrix'), findsOneWidget);
    });

    testWidgets('shows no active subscription for profile without renewal', (
      tester,
    ) async {
      final noSubProfile = UserProfile(
        id: 'u2',
        email: 'test@test.com',
        displayName: 'Test User',
        role: UserRole.athlete,
        createdAt: DateTime(2024, 1, 1),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            userProfileProvider.overrideWith(
              (ref) => Stream.value(noSubProfile),
            ),
          ],
          child: MaterialApp(home: Scaffold(body: ProfileScreen())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No active subscription'), findsOneWidget);
    });
  });

  group('CalendarScreen with data', () {
    testWidgets('renders with week navigation', (tester) async {
      await tester.pumpWidget(desktopShell(CalendarScreen()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_left), findsWidgets);
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('navigates weeks', (tester) async {
      await tester.pumpWidget(desktopShell(CalendarScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left).first);
      await tester.pumpAndSettle();
    });
  });

  group('ExploreScreen with data', () {
    testWidgets('renders events and sections', (tester) async {
      await tester.pumpWidget(desktopShell(ExploreScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Browse Veltrix'), findsOneWidget);
    });
  });

  group('MobileExploreScreen', () {
    testWidgets('renders explore view', (tester) async {
      await tester.pumpWidget(desktopShell(MobileExploreScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Explore'), findsOneWidget);
    });
  });
}

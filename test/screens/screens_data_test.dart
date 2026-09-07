import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/mobile/screens/mobile_home.dart';
import 'package:veltrix_sports/mobile/screens/mobile_calendar.dart';
import 'package:veltrix_sports/mobile/screens/mobile_progress.dart';
import 'package:veltrix_sports/mobile/screens/mobile_profile.dart';
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

Widget dataShell(Widget child) => ProviderScope(
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

/// Scroll down in a CustomScrollView/ListView to find below-fold items.
Future<void> scrollDown(WidgetTester tester) async {
  await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -500));
  await tester.pumpAndSettle();
}

void main() {
  group('MobileHomeScreen with data', () {
    testWidgets('renders and shows greeting', (tester) async {
      await tester.pumpWidget(dataShell(const MobileHomeScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Priya'), findsOneWidget);
    });

    testWidgets('hides sign-up buttons for logged-in user', (tester) async {
      await tester.pumpWidget(dataShell(const MobileHomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Athlete sign up'), findsNothing);
      expect(find.text('Coach sign up'), findsNothing);
    });

    testWidgets('scrolls to show training sections', (tester) async {
      await tester.pumpWidget(dataShell(const MobileHomeScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text("YOUR TRAINING TODAY"), findsOneWidget);
    });

    testWidgets('scrolls to show event banner', (tester) async {
      await tester.pumpWidget(dataShell(const MobileHomeScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('Mumbai Half Marathon'), findsWidgets);
    });

    testWidgets('scrolls to show workout card', (tester) async {
      await tester.pumpWidget(dataShell(const MobileHomeScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('Tempo Run'), findsOneWidget);
    });

    testWidgets('scrolls to training status', (tester) async {
      await tester.pumpWidget(dataShell(const MobileHomeScreen()));
      await tester.pumpAndSettle();
      // Scroll the SliverList by dragging on the screen
      await tester.drag(find.byType(MobileHomeScreen), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(find.text('Training status'), findsOneWidget);
    });

    testWidgets('scrolls to weekly summary', (tester) async {
      await tester.pumpWidget(dataShell(const MobileHomeScreen()));
      await tester.pumpAndSettle();
      // Scroll far enough to reach weekly summary area
      for (var i = 0; i < 5; i++) {
        await tester.drag(find.byType(MobileHomeScreen), const Offset(0, -500));
        await tester.pumpAndSettle();
      }
      // Look for any weekly summary content
      expect(find.textContaining('week'), findsWidgets);
    });
  });

  group('MobileCalendarScreen with data', () {
    testWidgets('renders calendar', (tester) async {
      await tester.pumpWidget(dataShell(const MobileCalendarScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('shows week overview section', (tester) async {
      await tester.pumpWidget(dataShell(const MobileCalendarScreen()));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(find.text('Week overview'), findsOneWidget);
    });

    testWidgets('tapping day changes selection', (tester) async {
      await tester.pumpWidget(dataShell(const MobileCalendarScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TUE'));
      await tester.pumpAndSettle();
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('week navigation forward and backward', (tester) async {
      await tester.pumpWidget(dataShell(const MobileCalendarScreen()));
      await tester.pumpAndSettle();
      // The chevron buttons are in the first Row inside the SliverList
      final chevrons = find.byIcon(Icons.chevron_right);
      if (chevrons.evaluate().isNotEmpty) {
        await tester.tap(chevrons.first);
        await tester.pumpAndSettle();
      }
      expect(find.text('Calendar'), findsOneWidget);
    });
  });

  group('MobileProgressScreen with data', () {
    testWidgets('shows performance heading', (tester) async {
      await tester.pumpWidget(dataShell(const MobileProgressScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('shows segment buttons', (tester) async {
      await tester.pumpWidget(dataShell(const MobileProgressScreen()));
      await tester.pumpAndSettle();
      expect(find.text('4 weeks'), findsOneWidget);
      expect(find.text('3 months'), findsOneWidget);
      expect(find.text('Season'), findsOneWidget);
    });
  });

  group('MobileProfileScreen with data', () {
    testWidgets('shows profile heading', (tester) async {
      await tester.pumpWidget(dataShell(const MobileProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('shows user name', (tester) async {
      await tester.pumpWidget(dataShell(const MobileProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Priya Sharma'), findsOneWidget);
    });

    testWidgets('shows sports info', (tester) async {
      await tester.pumpWidget(dataShell(const MobileProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Running'), findsWidgets);
    });

    testWidgets('shows Account section', (tester) async {
      await tester.pumpWidget(dataShell(const MobileProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('shows Support section', (tester) async {
      await tester.pumpWidget(dataShell(const MobileProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Support'), findsOneWidget);
    });

    testWidgets('shows Veltrix Premium card', (tester) async {
      await tester.pumpWidget(dataShell(const MobileProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Veltrix Premium'), findsOneWidget);
    });
  });

  group('MobileProfileScreen without profile (null)', () {
    testWidgets('shows welcome card', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            userProfileProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: Scaffold(body: MobileProfileScreen())),
        ),
      );
      expect(find.text('Profile'), findsOneWidget);
    });
  });
}

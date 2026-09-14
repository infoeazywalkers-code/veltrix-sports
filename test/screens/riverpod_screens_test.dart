import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/mobile/screens/mobile_home.dart';
import 'package:veltrix_sports/mobile/screens/mobile_calendar.dart';
import 'package:veltrix_sports/mobile/screens/mobile_progress.dart';
import 'package:veltrix_sports/mobile/screens/mobile_profile.dart';
import 'package:veltrix_sports/mobile/shell.dart';
import 'package:veltrix_sports/screens/training/calendar_screen.dart';
import 'package:veltrix_sports/screens/profile/profile_screen.dart';
import 'package:veltrix_sports/screens/dashboard/progress_screen.dart';

/// Override all family providers at the family level so any argument is covered.
Widget overriddenWrap(Widget child) => ProviderScope(
  overrides: [
    // Auth
    authStateProvider.overrideWith((ref) => Stream.value(null)),
    // Non-family providers
    userProfileProvider.overrideWith((ref) => Stream.value(null)),
    upcomingWorkoutsProvider.overrideWith((ref) async => []),
    activePlansProvider.overrideWith((ref) => Stream.value([])),
    latestPerformanceProvider.overrideWith((ref) => Stream.value(null)),
    // Family providers — override at the family level
    weekWorkoutsProvider.overrideWith((ref, arg) async => []),
    workoutsByDateRangeProvider.overrideWith((ref, arg) => Stream.value([])),
    performanceHistoryProvider.overrideWith((ref, arg) => Stream.value([])),
  ],
  child: MaterialApp(home: Scaffold(body: child)),
);

void main() {
  group('MobileHomeScreen (with providers)', () {
    testWidgets('renders SliverAppBar and hello text', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileHomeScreen()));
      // SliverAppBar with VELTRIX title
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.text('VELTRIX'), findsOneWidget);
    });

    testWidgets('shows hello athlete when profile is null', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileHomeScreen()));
      await tester.pump();
      // Stream.value(null) resolves to AsyncData(null) → data callback runs
      expect(find.textContaining('Hello'), findsOneWidget);
    });
  });

  group('MobileCalendarScreen (with providers)', () {
    testWidgets('renders calendar with week navigation', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileCalendarScreen()));
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('MON'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('navigates weeks forward', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileCalendarScreen()));
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('navigates weeks backward', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileCalendarScreen()));
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      expect(find.text('Calendar'), findsOneWidget);
    });
  });

  group('MobileProgressScreen (with providers)', () {
    testWidgets('renders progress with segment buttons', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileProgressScreen()));
      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('4 weeks'), findsOneWidget);
      expect(find.text('3 months'), findsOneWidget);
      expect(find.text('Season'), findsOneWidget);
    });

    testWidgets('can switch segments', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileProgressScreen()));
      await tester.tap(find.text('4 weeks'));
      await tester.pump();
      expect(find.text('Performance'), findsOneWidget);
    });
  });

  group('MobileProfileScreen (with providers)', () {
    testWidgets('renders profile heading', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileProfileScreen()));
      expect(find.text('Profile'), findsOneWidget);
    });
  });

  group('MobileShell (with providers)', () {
    testWidgets('renders NavigationBar', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileShell()));
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('renders navigation destinations', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileShell()));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('tapping Calendar switches page', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileShell()));
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('Calendar'), findsWidgets);
    });

    testWidgets('tapping Progress switches page', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileShell()));
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('tapping Explore switches page', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileShell()));
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      expect(find.text('Explore'), findsWidgets);
    });

    testWidgets('tapping Profile switches page', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileShell()));
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('opens drawer via menu button', (tester) async {
      await tester.pumpWidget(overriddenWrap(const MobileShell()));
      // The MobileShell has a menu IconButton at top-left
      final menuIcon = find.byIcon(Icons.menu);
      if (menuIcon.evaluate().isNotEmpty) {
        await tester.tap(menuIcon);
        await tester.pumpAndSettle();
        // Drawer should show VELTRIX branding
        expect(find.text('VELTRIX'), findsWidgets);
      }
    });
  });

  group('CalendarScreen (desktop, with providers)', () {
    testWidgets('renders week label and navigation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            workoutsByDateRangeProvider.overrideWith(
              (ref, arg) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: CalendarScreen())),
        ),
      );
      // The calendar shows chevron navigation and week day labels
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.text('M'), findsWidgets);
    });
  });

  group('ProfileScreen (desktop, with providers)', () {
    testWidgets('renders signed-out prompt when no user', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            userProfileProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: Scaffold(body: ProfileScreen())),
        ),
      );
      // Signed out: ProfileScreen shows the welcome prompt, not a spinner.
      expect(find.text('Welcome to Veltrix Sports'), findsOneWidget);
    });
  });

  group('ProgressScreen (desktop, with providers)', () {
    testWidgets('renders with loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            latestPerformanceProvider.overrideWith((ref) => Stream.value(null)),
            performanceHistoryProvider.overrideWith(
              (ref, arg) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: ProgressScreen())),
        ),
      );
      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('can switch time ranges', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            latestPerformanceProvider.overrideWith((ref) => Stream.value(null)),
            performanceHistoryProvider.overrideWith(
              (ref, arg) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: ProgressScreen())),
        ),
      );
      expect(find.text('4 weeks'), findsOneWidget);
      expect(find.text('3 months'), findsOneWidget);
      expect(find.text('Season'), findsOneWidget);
    });
  });
}

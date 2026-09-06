import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/shell.dart';

Widget shellWrap() => ProviderScope(
  overrides: [
    authStateProvider.overrideWith((ref) => Stream.value(null)),
    userProfileProvider.overrideWith((ref) => Stream.value(null)),
    upcomingWorkoutsProvider.overrideWith((ref) async => []),
    activePlansProvider.overrideWith((ref) => Stream.value([])),
    latestPerformanceProvider.overrideWith((ref) => Stream.value(null)),
    weekWorkoutsProvider.overrideWith((ref, arg) async => []),
    workoutsByDateRangeProvider.overrideWith((ref, arg) => Stream.value([])),
    performanceHistoryProvider.overrideWith((ref, arg) => Stream.value([])),
  ],
  child: MaterialApp(home: Shell()),
);

void main() {
  group('Shell (desktop mode)', () {
    testWidgets('renders VELTRIX title', (tester) async {
      tester.view.physicalSize = const Size(6000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      expect(find.text('VELTRIX'), findsOneWidget);
    });

    testWidgets('renders NavMenu for desktop', (tester) async {
      tester.view.physicalSize = const Size(6000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      expect(find.text('Athletes'), findsOneWidget);
      expect(find.text('Coaches'), findsOneWidget);
      expect(find.text('Training'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Resources'), findsOneWidget);
    });

    testWidgets('no NavigationBar in desktop mode', (tester) async {
      tester.view.physicalSize = const Size(6000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('shows Log in and Get started buttons', (tester) async {
      tester.view.physicalSize = const Size(6000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
    });
  });

  group('Shell (desktop nav menus)', () {
    Widget desktopShell() => ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(null)),
        userProfileProvider.overrideWith((ref) => Stream.value(null)),
        upcomingWorkoutsProvider.overrideWith((ref) async => []),
        activePlansProvider.overrideWith((ref) => Stream.value([])),
        latestPerformanceProvider.overrideWith((ref) => Stream.value(null)),
        weekWorkoutsProvider.overrideWith((ref, arg) async => []),
        workoutsByDateRangeProvider.overrideWith(
          (ref, arg) => Stream.value([]),
        ),
        performanceHistoryProvider.overrideWith((ref, arg) => Stream.value([])),
      ],
      child: MaterialApp(home: Shell()),
    );

    void setDesktopSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(6000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
    }

    testWidgets('desktop: tapping Training > Calendar navigates to Calendar', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(desktopShell());
      await tester.tap(find.text('Training'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendar').last);
      await tester.pumpAndSettle();
      expect(find.text('M'), findsWidgets);
    });

    testWidgets(
      'desktop: tapping Training > Performance navigates to Progress',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(desktopShell());
        await tester.tap(find.text('Training'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Performance').last);
        await tester.pumpAndSettle();
        expect(find.text('Performance'), findsWidgets);
      },
    );

    testWidgets(
      'desktop: tapping Training > Strength navigates to Strength screen',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(desktopShell());
        await tester.tap(find.text('Training'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Strength').last);
        await tester.pumpAndSettle();
        expect(find.textContaining('Empower Your Training'), findsOneWidget);
      },
    );

    testWidgets(
      'desktop: tapping Athletes > Find a Coach navigates to CoachMatch',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(desktopShell());
        await tester.tap(find.text('Athletes'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Find a Coach'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Expert coaching'), findsOneWidget);
      },
    );

    testWidgets('desktop: tapping Athletes > Premium navigates to Premium', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(desktopShell());
      await tester.tap(find.text('Athletes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Premium'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Your Next Peak'), findsOneWidget);
    });

    testWidgets('desktop: tapping Connect > Devices navigates to Devices', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(desktopShell());
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Devices'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('One App, Endless Ways to Train'),
        findsOneWidget,
      );
    });

    testWidgets(
      'desktop: tapping Resources > Help Center navigates to Profile',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(desktopShell());
        await tester.tap(find.text('Resources'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Help Center'));
        await tester.pumpAndSettle();
        expect(find.text('Welcome to Veltrix Sports'), findsOneWidget);
      },
    );
  });

  group('Shell (mobile mode)', () {
    testWidgets('renders NavigationBar in mobile mode', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('renders navigation destinations', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('no NavMenu in mobile mode', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      expect(find.text('Athletes'), findsNothing);
    });

    testWidgets('tapping Home returns to home screen', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      // Navigate away first
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      // Now tap Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.textContaining('training platform'), findsOneWidget);
    });

    testWidgets('mobile: FAB is hidden on Home screen', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('mobile: floating action button appears on Calendar screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('Add workout'), findsOneWidget);
    });

    testWidgets('tapping Calendar switches screen', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('M'), findsWidgets);
    });

    testWidgets('tapping Progress switches screen', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('tapping Explore switches screen', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      expect(find.text('Browse Veltrix'), findsOneWidget);
    });

    testWidgets('tapping Profile switches screen', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(shellWrap());
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      // ProfileScreen renders — provider returns null → shows welcome text
      expect(find.text('Welcome to Veltrix Sports'), findsOneWidget);
    });
  });
}

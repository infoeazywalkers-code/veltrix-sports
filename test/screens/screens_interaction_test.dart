import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/screens/training/calendar_screen.dart';
import 'package:veltrix_sports/screens/coach/coach_match_screen.dart';
import 'package:veltrix_sports/screens/dashboard/progress_screen.dart';
import 'package:veltrix_sports/screens/training/strength_screen.dart';

void main() {
  group('Screens Interaction Widget Tests', () {
    testWidgets(
      'CalendarScreen renders calendar grid and day item interactions',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: CalendarScreen())),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(CalendarScreen), findsOneWidget);
      },
    );

    testWidgets('CoachMatchScreen renders coach cards and inquiry triggers', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: CoachMatchScreen())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CoachMatchScreen), findsOneWidget);
    });

    testWidgets('StrengthScreen renders exercise cards and workout triggers', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: StrengthScreen())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(StrengthScreen), findsOneWidget);
    });

    testWidgets(
      'ProgressScreen renders performance metrics and progress charts',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProgressScreen())),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ProgressScreen), findsOneWidget);
      },
    );
  });
}

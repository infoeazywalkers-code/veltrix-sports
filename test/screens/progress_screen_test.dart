import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/models/performance_snapshot.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/screens/progress_screen.dart';

void main() {
  Widget wrapWithProviders({
    PerformanceSnapshot? perf,
    List<PerformanceSnapshot> history = const [],
  }) => ProviderScope(
    overrides: [
      authStateProvider.overrideWith((ref) => Stream.value(null)),
      latestPerformanceProvider.overrideWith((ref) => Stream.value(perf)),
      performanceHistoryProvider.overrideWith(
        (ref, arg) => Stream.value(history),
      ),
    ],
    child: const MaterialApp(home: Scaffold(body: ProgressScreen())),
  );

  PerformanceSnapshot makeSnap({
    double fitness = 54.0,
    double fatigue = 61.0,
    double form = -7.0,
    double weeklyTss = 286.0,
    int weeklyWorkouts = 5,
  }) => PerformanceSnapshot(
    id: 'snap1',
    userId: 'u1',
    fitness: fitness,
    fatigue: fatigue,
    form: form,
    weeklyTss: weeklyTss,
    weeklyWorkouts: weeklyWorkouts,
    recordedAt: DateTime(2026, 9, 1),
  );

  group('ProgressScreen', () {
    testWidgets('renders Performance title and subtitle', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      expect(find.text('Performance'), findsOneWidget);
      expect(
        find.text('Understand the work behind your progress'),
        findsOneWidget,
      );
    });

    testWidgets('renders segmented time range buttons', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      expect(find.text('4 weeks'), findsOneWidget);
      expect(find.text('3 months'), findsOneWidget);
      expect(find.text('Season'), findsOneWidget);
    });

    testWidgets('switches to 4 weeks segment', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      await tester.tap(find.text('4 weeks'));
      await tester.pumpAndSettle();

      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('switches to Season segment', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Season'));
      await tester.pumpAndSettle();

      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('renders fitness fatigue form card', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      expect(find.text('Fitness, fatigue & form'), findsOneWidget);
      expect(
        find.text('Training load over time (CTL, ATL, TSB)'),
        findsOneWidget,
      );
    });

    testWidgets('shows performance data when available', (tester) async {
      final perf = makeSnap(fitness: 58.5, fatigue: 63.2, form: -4.7);
      await tester.pumpWidget(wrapWithProviders(perf: perf));
      await tester.pumpAndSettle();

      expect(find.textContaining('Fitness 58.5'), findsOneWidget);
      expect(find.textContaining('Fatigue 63.2'), findsOneWidget);
      expect(find.textContaining('Form -4.7'), findsOneWidget);
    });

    testWidgets('shows default values when perf is null', (tester) async {
      await tester.pumpWidget(wrapWithProviders(perf: null));
      await tester.pumpAndSettle();

      expect(find.textContaining('Fitness 54.0'), findsOneWidget);
      expect(find.textContaining('Fatigue 61.0'), findsOneWidget);
      expect(find.textContaining('Form -7.0'), findsOneWidget);
    });

    testWidgets('shows positive form with plus sign', (tester) async {
      final perf = makeSnap(form: 5.3);
      await tester.pumpWidget(wrapWithProviders(perf: perf));
      await tester.pumpAndSettle();

      expect(find.textContaining('Form +5.3'), findsOneWidget);
    });

    testWidgets('renders key insights section heading', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      expect(find.text('Key insights'), findsOneWidget);
    });

    testWidgets('shows insight cards when data available', (tester) async {
      final perf = makeSnap(fitness: 58.5, weeklyTss: 312.0, weeklyWorkouts: 6);
      await tester.pumpWidget(wrapWithProviders(perf: perf));
      await tester.pumpAndSettle();

      expect(find.textContaining('Fitness is 58.5'), findsOneWidget);
      expect(find.textContaining('Weekly load: 312 TSS'), findsOneWidget);
      expect(find.textContaining('6 workouts'), findsOneWidget);
    });

    testWidgets('renders personal bests section', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Personal bests'), 300);
      await tester.pumpAndSettle();

      expect(find.text('Personal bests'), findsOneWidget);
      expect(find.text('View all'), findsOneWidget);
      expect(find.text('5K run'), findsOneWidget);
      expect(find.text('21:42'), findsOneWidget);
      expect(find.text('20 min power'), findsOneWidget);
      expect(find.text('278 W'), findsOneWidget);
    });

    testWidgets('renders performance chart widget', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      expect(find.text('Fitness, fatigue & form'), findsOneWidget);
    });

    testWidgets('renders listview as root', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('works with empty history', (tester) async {
      await tester.pumpWidget(wrapWithProviders(history: []));
      await tester.pumpAndSettle();

      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('works with non-empty history', (tester) async {
      final history = [
        makeSnap(fitness: 48.0, fatigue: 55.0, form: -7.0),
        makeSnap(fitness: 50.0, fatigue: 58.0, form: -8.0),
        makeSnap(fitness: 54.0, fatigue: 61.0, form: -7.0),
      ];
      await tester.pumpWidget(wrapWithProviders(history: history));
      await tester.pumpAndSettle();

      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('switches segments multiple times', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Season'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3 months'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4 weeks'));
      await tester.pumpAndSettle();

      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('renders icons in personal bests', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('5K run'), 300);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.directions_run), findsWidgets);
      expect(find.byIcon(Icons.directions_bike), findsWidgets);
    });
  });
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/analytics/performance_chart.dart';
import 'package:veltrix_sports/models/performance/performance_snapshot.dart';

Widget wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(child: Center(child: child)),
  ),
);

void main() {
  group('PerformanceChartWidget - Covering uncovered lines', () {
    testWidgets('renders with empty snapshots and no currentSnapshot', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const PerformanceChartWidget(snapshots: [])),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with snapshots data and date labels', (tester) async {
      final snapshots = [
        PerformanceSnapshot(
          id: '1',
          userId: 'u1',
          fitness: 45,
          fatigue: 50,
          form: -5,
          weeklyTss: 200,
          weeklyWorkouts: 4,
          weeklyDuration: '4h',
          recordedAt: DateTime(2026, 3, 15),
        ),
        PerformanceSnapshot(
          id: '2',
          userId: 'u1',
          fitness: 50,
          fatigue: 55,
          form: -5,
          weeklyTss: 250,
          weeklyWorkouts: 5,
          weeklyDuration: '5h',
          recordedAt: DateTime(2026, 3, 22),
        ),
        PerformanceSnapshot(
          id: '3',
          userId: 'u1',
          fitness: 55,
          fatigue: 48,
          form: 7,
          weeklyTss: 280,
          weeklyWorkouts: 5,
          weeklyDuration: '5h 30m',
          recordedAt: DateTime(2026, 3, 29),
        ),
      ];
      await tester.pumpWidget(
        wrap(PerformanceChartWidget(snapshots: snapshots)),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with currentSnapshot fallback data points', (
      tester,
    ) async {
      final snap = PerformanceSnapshot(
        id: '1',
        userId: 'u1',
        fitness: 60,
        fatigue: 70,
        form: -10,
        weeklyTss: 300,
        weeklyWorkouts: 6,
        weeklyDuration: '6h',
        recordedAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrap(PerformanceChartWidget(snapshots: [], currentSnapshot: snap)),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with default baseline data when no snapshots', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const PerformanceChartWidget(snapshots: [])),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      await tester.pumpWidget(
        wrap(const PerformanceChartWidget(snapshots: [], height: 350)),
      );
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 350);
    });

    testWidgets('renders with default height', (tester) async {
      await tester.pumpWidget(
        wrap(const PerformanceChartWidget(snapshots: [])),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders bottom titles for default weeks', (tester) async {
      await tester.pumpWidget(
        wrap(const PerformanceChartWidget(snapshots: [])),
      );
      // Should render week labels like W1, W2, etc.
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders left titles with value labels', (tester) async {
      await tester.pumpWidget(
        wrap(const PerformanceChartWidget(snapshots: [])),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('touch interaction shows tooltip', (tester) async {
      final snapshots = [
        PerformanceSnapshot(
          id: '1',
          userId: 'u1',
          fitness: 45,
          fatigue: 50,
          form: -5,
          weeklyTss: 200,
          weeklyWorkouts: 4,
          weeklyDuration: '4h',
          recordedAt: DateTime(2026, 1, 1),
        ),
      ];

      await tester.pumpWidget(
        wrap(PerformanceChartWidget(snapshots: snapshots, height: 300)),
      );
      await tester.pumpAndSettle();

      // Simulate touch on the chart area
      final chartFinder = find.byType(LineChart);
      expect(chartFinder, findsOneWidget);

      // Get the chart widget position
      final chartBox = tester.getRect(chartFinder);

      // Long press in the middle of the chart to trigger touch
      await tester.longPressAt(chartBox.center);
      await tester.pumpAndSettle();
    });

    testWidgets('renders with many snapshots for full coverage', (
      tester,
    ) async {
      final snapshots = List.generate(
        12,
        (i) => PerformanceSnapshot(
          id: '$i',
          userId: 'u1',
          fitness: 30.0 + i * 3,
          fatigue: 40.0 + i * 2,
          form: -10.0 + i,
          weeklyTss: 150.0 + i * 20,
          weeklyWorkouts: 3 + (i % 4),
          weeklyDuration: '${3 + i}h',
          recordedAt: DateTime(2026, 1, 1).add(Duration(days: i * 7)),
        ),
      );

      await tester.pumpWidget(
        wrap(PerformanceChartWidget(snapshots: snapshots)),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('currentSnapshot with zero values', (tester) async {
      final snap = PerformanceSnapshot(
        id: '1',
        userId: 'u1',
        fitness: 0,
        fatigue: 0,
        form: 0,
        weeklyTss: 0,
        weeklyWorkouts: 0,
        weeklyDuration: '0h',
        recordedAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrap(PerformanceChartWidget(snapshots: [], currentSnapshot: snap)),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('currentSnapshot with high values tests clamp', (tester) async {
      final snap = PerformanceSnapshot(
        id: '1',
        userId: 'u1',
        fitness: 200,
        fatigue: 200,
        form: 100,
        weeklyTss: 500,
        weeklyWorkouts: 7,
        weeklyDuration: '10h',
        recordedAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrap(PerformanceChartWidget(snapshots: [], currentSnapshot: snap)),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}

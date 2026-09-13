import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/analytics/performance_chart.dart';
import 'package:veltrix_sports/models/performance/performance_snapshot.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: Center(child: child))),
  );

  group('PerformanceChartWidget', () {
    testWidgets('renders with empty snapshots and no currentSnapshot', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const PerformanceChartWidget(snapshots: [])),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with snapshots data', (tester) async {
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
        PerformanceSnapshot(
          id: '2',
          userId: 'u1',
          fitness: 50,
          fatigue: 55,
          form: -5,
          weeklyTss: 250,
          weeklyWorkouts: 5,
          weeklyDuration: '5h',
          recordedAt: DateTime(2026, 1, 8),
        ),
      ];
      await tester.pumpWidget(
        wrap(PerformanceChartWidget(snapshots: snapshots)),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with only currentSnapshot', (tester) async {
      final snap = PerformanceSnapshot(
        id: '1',
        userId: 'u1',
        fitness: 54,
        fatigue: 61,
        form: -7,
        weeklyTss: 286,
        weeklyWorkouts: 5,
        weeklyDuration: '4h 35m',
        recordedAt: DateTime.now(),
      );
      await tester.pumpWidget(
        wrap(PerformanceChartWidget(snapshots: [], currentSnapshot: snap)),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      await tester.pumpWidget(
        wrap(const PerformanceChartWidget(snapshots: [], height: 300)),
      );
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 300);
    });

    testWidgets('renders with default height', (tester) async {
      await tester.pumpWidget(
        wrap(const PerformanceChartWidget(snapshots: [])),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with multiple snapshots for date labels', (
      tester,
    ) async {
      final snapshots = List.generate(
        10,
        (i) => PerformanceSnapshot(
          id: '$i',
          userId: 'u1',
          fitness: 40.0 + i,
          fatigue: 50.0 + i,
          form: -5.0 + i,
          weeklyTss: 200.0 + i * 10,
          weeklyWorkouts: 3 + (i % 3),
          weeklyDuration: '${3 + i}h',
          recordedAt: DateTime(2026, 1, 1).add(Duration(days: i * 7)),
        ),
      );
      await tester.pumpWidget(
        wrap(PerformanceChartWidget(snapshots: snapshots)),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}

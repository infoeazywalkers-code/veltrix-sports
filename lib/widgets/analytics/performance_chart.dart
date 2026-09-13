import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/performance/performance_snapshot.dart';

class PerformanceChartWidget extends StatelessWidget {
  final List<PerformanceSnapshot> snapshots;
  final PerformanceSnapshot? currentSnapshot;
  final double height;

  const PerformanceChartWidget({
    super.key,
    required this.snapshots,
    this.currentSnapshot,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    // Generate data points from snapshots or fallback smoothly
    final List<FlSpot> fitnessSpots = [];
    final List<FlSpot> fatigueSpots = [];
    final List<FlSpot> formSpots = [];

    if (snapshots.isNotEmpty) {
      for (int i = 0; i < snapshots.length; i++) {
        final snap = snapshots[i];
        fitnessSpots.add(FlSpot(i.toDouble(), snap.fitness));
        fatigueSpots.add(FlSpot(i.toDouble(), snap.fatigue));
        formSpots.add(FlSpot(i.toDouble(), snap.form));
      }
    } else if (currentSnapshot != null) {
      final baseFit = currentSnapshot!.fitness;
      final baseFat = currentSnapshot!.fatigue;
      final baseForm = currentSnapshot!.form;
      fitnessSpots.addAll([
        FlSpot(0, (baseFit * 0.85).clamp(0, 150)),
        FlSpot(1, (baseFit * 0.9).clamp(0, 150)),
        FlSpot(2, (baseFit * 0.95).clamp(0, 150)),
        FlSpot(3, baseFit),
      ]);
      fatigueSpots.addAll([
        FlSpot(0, (baseFat * 0.75).clamp(0, 150)),
        FlSpot(1, (baseFat * 0.85).clamp(0, 150)),
        FlSpot(2, (baseFat * 1.1).clamp(0, 150)),
        FlSpot(3, baseFat),
      ]);
      formSpots.addAll([
        FlSpot(0, (baseForm + 10).clamp(-50, 50)),
        FlSpot(1, (baseForm + 5).clamp(-50, 50)),
        FlSpot(2, (baseForm - 5).clamp(-50, 50)),
        FlSpot(3, baseForm),
      ]);
    } else {
      // Default baseline
      fitnessSpots.addAll(const [
        FlSpot(0, 20),
        FlSpot(1, 28),
        FlSpot(2, 35),
        FlSpot(3, 42),
        FlSpot(4, 48),
        FlSpot(5, 54),
      ]);
      fatigueSpots.addAll(const [
        FlSpot(0, 15),
        FlSpot(1, 32),
        FlSpot(2, 45),
        FlSpot(3, 38),
        FlSpot(4, 58),
        FlSpot(5, 61),
      ]);
      formSpots.addAll(const [
        FlSpot(0, 5),
        FlSpot(1, -4),
        FlSpot(2, -10),
        FlSpot(3, 4),
        FlSpot(4, -10),
        FlSpot(5, -7),
      ]);
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xffE2E8F0),
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF78909C)
                              : muted),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (snapshots.isNotEmpty &&
                      index >= 0 &&
                      index < snapshots.length) {
                    final date = snapshots[index].recordedAt;
                    return Text(
                      '${date.day}/${date.month}',
                      style: TextStyle(
                        color:
                            (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF78909C)
                                : muted),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }
                  return Text(
                    'W${index + 1}',
                    style: TextStyle(
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF78909C)
                              : muted),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: -20,
          maxY: 100,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => navy,
              tooltipRoundedRadius: 10,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  String label = 'Metric';
                  if (spot.barIndex == 0) label = 'Fitness';
                  if (spot.barIndex == 1) label = 'Fatigue';
                  if (spot.barIndex == 2) label = 'Form';
                  return LineTooltipItem(
                    '$label: ${spot.y.toStringAsFixed(1)}',
                    TextStyle(
                      color:
                          spot.barIndex == 0
                              ? lime
                              : (spot.barIndex == 1 ? Colors.white : orange),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            // Fitness (CTL - Blue)
            LineChartBarData(
              spots: fitnessSpots,
              isCurved: true,
              color: blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: blue.withValues(alpha: 0.08),
              ),
            ),
            // Fatigue (ATL - Purple)
            LineChartBarData(
              spots: fatigueSpots,
              isCurved: true,
              color: purple,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: purple.withValues(alpha: 0.06),
              ),
            ),
            // Form (TSB - Orange)
            LineChartBarData(
              spots: formSpots,
              isCurved: true,
              color: orange,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

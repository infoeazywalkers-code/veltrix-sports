import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers.dart';
import '../common/metric.dart';

class WeekCard extends ConsumerWidget {
  const WeekCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final weekStart = getStartOfWeek(now);
    final weekStartDayOnly = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final weekAsync = ref.watch(weekWorkoutsProvider(weekStartDayOnly));
    final workouts = weekAsync.valueOrNull ?? [];

    // Compute stats from real workouts
    final workoutCount = workouts.length;
    final totalTss = workouts.fold<int>(0, (sum, w) => sum + (w.tss ?? 0));
    final totalMinutes = workouts.fold<int>(0, (sum, w) {
      final parsed = _parseDurationMinutes(w.duration);
      return sum + parsed;
    });
    final durationStr = _formatMinutes(totalMinutes);

    // Compute daily TSS for the 7 days (Mon-Sun)
    final dailyTss = List<double>.filled(7, 0);
    for (final w in workouts) {
      final dayIndex = w.scheduledFor.weekday - 1; // 0=Mon, 6=Sun
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyTss[dayIndex] += (w.tss ?? 0).toDouble();
      }
    }

    // Normalize bar heights to max 80
    final maxTss = dailyTss.reduce((a, b) => a > b ? a : b);
    final barHeights = maxTss > 0
        ? dailyTss.map((t) => (t / maxTss) * 80.0).toList()
        : List<double>.filled(7, 0);

    // Today's weekday index (0=Mon) for highlighting
    final todayIndex = now.weekday - 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Metric(workoutCount.toString(), 'Workouts'),
                Metric(durationStr, 'Duration'),
                Metric(totalTss.toString(), 'TSS'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                7,
                (i) => Column(
                  children: [
                    Container(
                      width: 20,
                      height: barHeights[i],
                      decoration: BoxDecoration(
                        color: i == todayIndex
                            ? lime
                            : blue.withValues(alpha: .25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                      style: TextStyle(
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF78909C)
                            : muted),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parses a duration string like "45 min", "1h 05 min", "1h 30 min" into minutes.
  static int _parseDurationMinutes(String duration) {
    final trimmed = duration.trim().toLowerCase();
    int totalMinutes = 0;

    final hourMatch = RegExp(r'(\d+)\s*h').firstMatch(trimmed);
    if (hourMatch != null) {
      totalMinutes += int.parse(hourMatch.group(1)!) * 60;
    }

    final minMatch = RegExp(r'(\d+)\s*min').firstMatch(trimmed);
    if (minMatch != null) {
      totalMinutes += int.parse(minMatch.group(1)!);
    }

    // If no hour/min pattern matched, try plain number (assumed minutes)
    if (totalMinutes == 0) {
      final plainMatch = RegExp(r'^(\d+)$').firstMatch(trimmed);
      if (plainMatch != null) {
        totalMinutes = int.parse(plainMatch.group(1)!);
      }
    }

    return totalMinutes;
  }

  /// Formats minutes into a human-readable string like "4h 35m".
  static String _formatMinutes(int totalMinutes) {
    if (totalMinutes == 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

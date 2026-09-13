import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../widgets/common/heading.dart';
import '../../widgets/common/legend.dart';
import '../../widgets/common/insight.dart';
import '../../widgets/common/best.dart';
import '../../widgets/analytics/performance_chart.dart';
import '../../providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});
  @override
  ConsumerState<ProgressScreen> createState() => _ProgressState();
}

class _ProgressState extends ConsumerState<ProgressScreen> {
  int range = 1;
  @override
  Widget build(BuildContext context) {
    final perfAsync = ref.watch(latestPerformanceProvider);
    final historyAsync = ref.watch(performanceHistoryProvider(range));

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Performance',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : navy),
          ),
        ),
        Text(
          'Understand the work behind your progress',
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF78909C)
                : muted),
          ),
        ),
        const SizedBox(height: 18),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('4 weeks')),
            ButtonSegment(value: 1, label: Text('3 months')),
            ButtonSegment(value: 2, label: Text('Season')),
          ],
          selected: {range},
          showSelectedIcon: false,
          onSelectionChanged: (v) => setState(() => range = v.first),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fitness, fatigue & form',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
                  ),
                ),
                Text(
                  'Training load over time (CTL, ATL, TSB)',
                  style: TextStyle(
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF78909C)
                        : muted),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 20),
                historyAsync.when(
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(color: navy),
                    ),
                  ),
                  error: (e, _) => SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Failed to load chart: $e',
                        style: TextStyle(
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF78909C)
                              : muted),
                        ),
                      ),
                    ),
                  ),
                  data: (history) {
                    final latest = perfAsync.valueOrNull;
                    return PerformanceChartWidget(
                      snapshots: history,
                      currentSnapshot: latest,
                      height: 200,
                    );
                  },
                ),
                const SizedBox(height: 14),
                perfAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (perf) {
                    final fit = perf?.fitness ?? 54.0;
                    final fat = perf?.fatigue ?? 61.0;
                    final form = perf?.form ?? -7.0;
                    return Wrap(
                      spacing: 18,
                      children: [
                        Legend('Fitness ${fit.toStringAsFixed(1)}', blue),
                        Legend('Fatigue ${fat.toStringAsFixed(1)}', purple),
                        Legend(
                          'Form ${form > 0 ? "+${form.toStringAsFixed(1)}" : form.toStringAsFixed(1)}',
                          orange,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeading('Key insights'),
        const SizedBox(height: 10),
        perfAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (perf) {
            final fit = perf?.fitness ?? 54.0;
            final tss = perf?.weeklyTss ?? 286.0;
            final count = perf?.weeklyWorkouts ?? 5;
            return Column(
              children: [
                Insight(
                  Icons.trending_up,
                  blue,
                  'Fitness is ${fit.toStringAsFixed(1)}',
                  'Your 42-day rolling training load is trending in the right direction.',
                ),
                const SizedBox(height: 9),
                Insight(
                  Icons.show_chart,
                  purple,
                  'Weekly load: ${tss.toStringAsFixed(0)} TSS',
                  '$count workouts recorded with steady aerobic volume.',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        const SectionHeading('Personal bests', action: 'View all'),
        const SizedBox(height: 10),
        ref
            .watch(personalBestsProvider)
            .when(
              loading: () => const Row(
                children: [
                  Expanded(
                    child: Best('5K run', '\u2014', Icons.directions_run, blue),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Best(
                      '20 min power',
                      '\u2014',
                      Icons.directions_bike,
                      purple,
                    ),
                  ),
                ],
              ),
              error: (_, __) => const Row(
                children: [
                  Expanded(
                    child: Best('5K run', '\u2014', Icons.directions_run, blue),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Best(
                      '20 min power',
                      '\u2014',
                      Icons.directions_bike,
                      purple,
                    ),
                  ),
                ],
              ),
              data: (pbs) => Row(
                children: [
                  Expanded(
                    child: Best(
                      '5K run',
                      pbs.best5kPace,
                      Icons.directions_run,
                      blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Best(
                      '20 min power',
                      pbs.best20MinPower,
                      Icons.directions_bike,
                      purple,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../widgets/analytics/performance_chart.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileProgressScreen extends ConsumerStatefulWidget {
  const MobileProgressScreen({super.key});

  @override
  ConsumerState<MobileProgressScreen> createState() =>
      _MobileProgressScreenState();
}

class _MobileProgressScreenState extends ConsumerState<MobileProgressScreen> {
  int range = 1;

  @override
  Widget build(BuildContext context) {
    final perfAsync = ref.watch(latestPerformanceProvider);
    final historyAsync = ref.watch(performanceHistoryProvider(range));

    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Performance')),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              Text(
                'Understand the work behind your progress',
                style: M.adaptiveMuted(context),
              ),
              const SizedBox(height: M.base),
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
              const SizedBox(height: M.lg),
              MCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fitness, fatigue & form', style: M.adaptiveTitle(context)),
                    const SizedBox(height: 2),
                    Text(
                      'Training load over time (CTL, ATL, TSB)',
                      style: M.adaptiveCardBody(context),
                    ),
                    const SizedBox(height: M.md),
                    historyAsync.when(
                      loading:
                          () => const SizedBox(
                            height: 190,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      error:
                          (e, _) => SizedBox(
                            height: 190,
                            child: Center(
                              child: Text(
                                'Failed to load chart: $e',
                                style: M.adaptiveCardBody(context),
                              ),
                            ),
                          ),
                      data: (history) {
                        final latest = perfAsync.valueOrNull;
                        return PerformanceChartWidget(
                          snapshots: history,
                          currentSnapshot: latest,
                          height: 190,
                        );
                      },
                    ),
                    const SizedBox(height: M.md),
                    const Wrap(
                      spacing: M.base,
                      children: [
                        _Legend('Fitness (CTL)', M.blue),
                        _Legend('Fatigue (ATL)', M.purple),
                        _Legend('Form (TSB)', M.orange),
                      ],
                    ),
                    const SizedBox(height: M.md),
                    perfAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (perf) {
                        final fitness = perf?.fitness ?? 54.0;
                        final fatigue = perf?.fatigue ?? 61.0;
                        final form = perf?.form ?? -7.0;
                        final fitnessProg = (fitness / 100).clamp(0.0, 1.0);
                        final fatigueProg = (fatigue / 100).clamp(0.0, 1.0);
                        final formProg = ((form + 50) / 100).clamp(0.0, 1.0);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatValue(
                              'Fitness',
                              fitness.toStringAsFixed(0),
                              M.blue,
                              fitnessProg,
                            ),
                            _StatValue(
                              'Fatigue',
                              fatigue.toStringAsFixed(0),
                              M.purple,
                              fatigueProg,
                            ),
                            _StatValue(
                              'Form',
                              form > 0
                                  ? '+${form.toStringAsFixed(0)}'
                                  : form.toStringAsFixed(0),
                              M.orange,
                              formProg,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Key insights',
                child: perfAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (perf) {
                    final tss = perf?.weeklyTss ?? 286.0;
                    final count = perf?.weeklyWorkouts ?? 5;
                    final dur = perf?.weeklyDuration ?? '4h 35m';
                    return Column(
                      children: [
                        _InsightCard(
                          Icons.trending_up,
                          M.blue,
                          'Weekly TSS: ${tss.toStringAsFixed(0)}',
                          '$count workouts completed ($dur total). Load trending positively.',
                        ),
                        const SizedBox(height: M.sm),
                        const _InsightCard(
                          Icons.bedtime_outlined,
                          M.purple,
                          'Recovery status: Balanced',
                          'Your Form score is within ideal adaptation parameters.',
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: M.lg),
              ref
                  .watch(personalBestsProvider)
                  .when(
                    loading:
                        () => const MSection(
                          title: 'Personal bests',
                          action: 'View all',
                          child: Row(
                            children: [
                              Expanded(
                                child: _BestCard(
                                  '5K run',
                                  '\u2014',
                                  Icons.directions_run,
                                  M.blue,
                                ),
                              ),
                              SizedBox(width: M.sm),
                              Expanded(
                                child: _BestCard(
                                  '20 min power',
                                  '\u2014',
                                  Icons.directions_bike,
                                  M.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                    error:
                        (_, __) => const MSection(
                          title: 'Personal bests',
                          action: 'View all',
                          child: Row(
                            children: [
                              Expanded(
                                child: _BestCard(
                                  '5K run',
                                  '\u2014',
                                  Icons.directions_run,
                                  M.blue,
                                ),
                              ),
                              SizedBox(width: M.sm),
                              Expanded(
                                child: _BestCard(
                                  '20 min power',
                                  '\u2014',
                                  Icons.directions_bike,
                                  M.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                    data:
                        (pbs) => MSection(
                          title: 'Personal bests',
                          action: 'View all',
                          child: Row(
                            children: [
                              Expanded(
                                child: _BestCard(
                                  '5K run',
                                  pbs.best5kPace,
                                  Icons.directions_run,
                                  M.blue,
                                ),
                              ),
                              const SizedBox(width: M.sm),
                              Expanded(
                                child: _BestCard(
                                  '20 min power',
                                  pbs.best20MinPower,
                                  Icons.directions_bike,
                                  M.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
              const SizedBox(height: M.xxl),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatValue extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double progress;
  const _StatValue(this.label, this.value, this.color, this.progress);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 5,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: M.xs),
        Text(label, style: M.adaptiveCardBody(context)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final String text;
  final Color color;
  const _Legend(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: M.xs),
        Text(text, style: M.adaptiveCardBody(context)),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _InsightCard(this.icon, this.color, this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return MCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(M.rMd),
            ),
            child: Icon(icon, color: color, size: M.iconMd),
          ),
          const SizedBox(width: M.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : M.navy),
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: M.adaptiveCardBody(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BestCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _BestCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return MCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: M.iconLg),
          const SizedBox(height: M.md),
          Text(title, style: M.adaptiveCardBody(context)),
          Text(value, style: M.adaptiveStat(context)),
        ],
      ),
    );
  }
}

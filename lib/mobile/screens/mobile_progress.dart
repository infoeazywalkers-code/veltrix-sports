import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileProgressScreen extends ConsumerStatefulWidget {
  const MobileProgressScreen({super.key});

  @override
  ConsumerState<MobileProgressScreen> createState() => _MobileProgressScreenState();
}

class _MobileProgressScreenState extends ConsumerState<MobileProgressScreen> {
  int range = 1;

  @override
  Widget build(BuildContext context) {
    final perfAsync = ref.watch(latestPerformanceProvider);

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          title: Text('Performance'),
        ),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              const Text('Understand the work behind your progress',
                  style: M.bodyMuted),
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
              perfAsync.when(
                loading: () => const MCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(M.lg),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (e, _) => MCard(
                  child: Padding(
                    padding: const EdgeInsets.all(M.base),
                    child: Text('Error loading performance data: $e', style: M.bodyMuted),
                  ),
                ),
                data: (perf) {
                  final fitness = perf?.fitness ?? 0;
                  final fatigue = perf?.fatigue ?? 0;
                  final form = perf?.form ?? 0;
                  final fitnessProg = (fitness / 100).clamp(0.0, 1.0);
                  final fatigueProg = (fatigue / 100).clamp(0.0, 1.0);
                  final formProg = ((form + 50) / 100).clamp(0.0, 1.0);
                  return MCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fitness, fatigue & form', style: M.cardTitle),
                        const SizedBox(height: 2),
                        const Text('Training load over time', style: M.caption),
                        const SizedBox(height: M.md),
                        SizedBox(
                          height: 180,
                          child: CustomPaint(
                            painter: _Chart(),
                            size: Size.infinite,
                          ),
                        ),
                        const SizedBox(height: M.md),
                        Wrap(
                          spacing: M.base,
                          children: [
                            _Legend('Fitness', M.blue),
                            _Legend('Fatigue', M.purple),
                            _Legend('Form', M.orange),
                          ],
                        ),
                        const SizedBox(height: M.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatValue('Fitness', fitness.toStringAsFixed(0), M.blue, fitnessProg),
                            _StatValue('Fatigue', fatigue.toStringAsFixed(0), M.purple, fatigueProg),
                            _StatValue('Form', form > 0 ? '+${form.toStringAsFixed(0)}' : form.toStringAsFixed(0), M.orange, formProg),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: M.lg),
              perfAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (perf) {
                  if (perf == null) {
                    return const MCard(
                      child: Padding(
                        padding: EdgeInsets.all(M.base),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: M.muted, size: 20),
                            SizedBox(width: M.sm),
                            Text('Complete workouts to see insights', style: M.bodyMuted),
                          ],
                        ),
                      ),
                    );
                  }
                  return MSection(
                    title: 'Key insights',
                    child: Column(
                      children: [
                        _InsightCard(
                          Icons.trending_up,
                          M.blue,
                          'Weekly TSS: ${perf.weeklyTss.toStringAsFixed(0)}',
                          '${perf.weeklyWorkouts} workouts this week, ${perf.weeklyDuration} total.',
                        ),
                        const SizedBox(height: M.sm),
                        _InsightCard(
                          Icons.fitness_center,
                          M.purple,
                          'Workouts completed: ${perf.weeklyWorkouts}',
                          'Keep training consistently for best results.',
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Personal bests',
                action: 'View all',
                child: Row(
                  children: [
                    Expanded(
                      child: _BestCard('5K run', '21:42', Icons.directions_run, M.blue),
                    ),
                    const SizedBox(width: M.sm),
                    Expanded(
                      child: _BestCard('20 min power', '278 W', Icons.directions_bike, M.purple),
                    ),
                  ],
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
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: M.xs),
        Text(label, style: M.caption),
      ],
    );
  }
}

class _Chart extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final grid = Paint()..color = const Color(0xFFE6EBF0);
    for (var i = 0; i < 5; i++) {
      final y = s.height * i / 4;
      c.drawLine(Offset(0, y), Offset(s.width, y), grid);
    }

    void draw(List<double> d, Color color) {
      final p = Path();
      for (var i = 0; i < d.length; i++) {
        final x = s.width * i / (d.length - 1);
        final y = s.height * (1 - d[i]);
        i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
      }
      c.drawPath(
        p,
        Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    draw([.28, .35, .33, .46, .51, .48, .61, .66, .7, .68, .78], M.blue);
    draw([.34, .5, .41, .58, .44, .7, .57, .74, .61, .79, .64], M.purple);
    draw([.65, .47, .58, .4, .6, .31, .47, .28, .45, .23, .39], M.orange);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
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
        Text(text, style: M.caption),
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
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: M.navy,
                    )),
                const SizedBox(height: 2),
                Text(body, style: M.caption),
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
          Text(title, style: M.caption),
          Text(value, style: M.statBig),
        ],
      ),
    );
  }
}


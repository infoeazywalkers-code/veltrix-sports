import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileProgressScreen extends StatefulWidget {
  const MobileProgressScreen({super.key});

  @override
  State<MobileProgressScreen> createState() => _MobileProgressScreenState();
}

class _MobileProgressScreenState extends State<MobileProgressScreen> {
  int range = 1;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Performance'),
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
                onSelectionChanged: (v) =>
                    setState(() => range = v.first),
              ),
              const SizedBox(height: M.lg),
              MCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fitness, fatigue & form',
                        style: M.cardTitle),
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
                    const Wrap(
                      spacing: M.base,
                      children: [
                        _Legend('Fitness', M.blue),
                        _Legend('Fatigue', M.purple),
                        _Legend('Form', M.orange),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Key insights',
                child: Column(
                  children: const [
                    _InsightCard(
                      Icons.trending_up,
                      M.blue,
                      'Fitness is up 12%',
                      'Your 42-day load is trending up.',
                    ),
                    SizedBox(height: M.sm),
                    _InsightCard(
                      Icons.bedtime_outlined,
                      M.purple,
                      'Recovery is consistent',
                      'Average sleep is 7h 38m across 7 days.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Personal bests',
                action: 'View all',
                child: Row(
                  children: [
                    Expanded(
                      child: _BestCard(
                          '5K run', '21:42', Icons.directions_run, M.blue),
                    ),
                    const SizedBox(width: M.sm),
                    Expanded(
                      child: _BestCard('20 min power', '278 W',
                          Icons.directions_bike, M.purple),
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

class _MobileProgressPreview extends StatelessWidget {
  const _MobileProgressPreview();
  @override
  Widget build(BuildContext context) => const MobileProgressScreen();
}

void main() => runApp(MaterialApp(
  theme: M.theme,
  home: const _MobileProgressPreview(),
));

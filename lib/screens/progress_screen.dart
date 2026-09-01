import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/heading.dart';
import '../widgets/legend.dart';
import '../widgets/insight.dart';
import '../widgets/best.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressState();
}

class _ProgressState extends State<ProgressScreen> {
  int range = 1;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const Text(
        'Performance',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: navy),
      ),
      const Text('Understand the work behind your progress', style: TextStyle(color: muted)),
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
              const Text(
                'Fitness, fatigue & form',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: navy),
              ),
              const Text('Training load over time', style: TextStyle(color: muted, fontSize: 11)),
              const SizedBox(height: 15),
              const SizedBox(
                height: 190,
                child: CustomPaint(painter: Chart(), size: Size.infinite),
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 18,
                children: [
                  Legend('Fitness', blue),
                  Legend('Fatigue', purple),
                  Legend('Form', orange),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 22),
      const SectionHeading('Key insights'),
      const SizedBox(height: 10),
      const Insight(Icons.trending_up, blue, 'Fitness is up 12%', 'Your 42-day load is trending in the right direction.'),
      const SizedBox(height: 9),
      const Insight(Icons.bedtime_outlined, purple, 'Recovery is consistent', 'Average sleep is 7h 38m across the last 7 days.'),
      const SizedBox(height: 22),
      const SectionHeading('Personal bests', action: 'View all'),
      const SizedBox(height: 10),
      const Row(
        children: [
          Expanded(child: Best('5K run', '21:42', Icons.directions_run, blue)),
          SizedBox(width: 10),
          Expanded(child: Best('20 min power', '278 W', Icons.directions_bike, purple)),
        ],
      ),
    ],
  );
}

class _ProgressPreview extends StatelessWidget {
  const _ProgressPreview();
  @override
  Widget build(BuildContext context) => const ProgressScreen();
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(body: _ProgressPreview()),
));

class Chart extends CustomPainter {
  const Chart();
  @override
  void paint(Canvas c, Size s) {
    final grid = Paint()..color = const Color(0xffe6ebf0);
    for (var i = 0; i < 5; i++) {
      final y = s.height * i / 4;
      c.drawLine(Offset(0, y), Offset(s.width, y), grid);
    }
    void draw(List<double> d, Color color) {
      final p = Path();
      for (var i = 0; i < d.length; i++) {
        final x = s.width * i / (d.length - 1), y = s.height * (1 - d[i]);
        i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
      }
      c.drawPath(
        p,
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    draw([.28, .35, .33, .46, .51, .48, .61, .66, .7, .68, .78], blue);
    draw([.34, .5, .41, .58, .44, .7, .57, .74, .61, .79, .64], purple);
    draw([.65, .47, .58, .4, .6, .31, .47, .28, .45, .23, .39], orange);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

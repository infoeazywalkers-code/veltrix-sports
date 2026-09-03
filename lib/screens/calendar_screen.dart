import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/heading.dart';
import '../widgets/workout_card.dart';
import '../widgets/week_row.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarState();
}

class _CalendarState extends State<CalendarScreen> {
  int day = 5;
  int weekOffset = 0;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
    children: [
      Row(
        children: [
          IconButton(onPressed: () => setState(() => weekOffset--), icon: const Icon(Icons.chevron_left)),
          const Expanded(
            child: Text(
              '24\u201330 Aug 2026',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: navy),
            ),
          ),
          IconButton(onPressed: () => setState(() => weekOffset++), icon: const Icon(Icons.chevron_right)),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          7,
          (i) => GestureDetector(
            onTap: () => setState(() => day = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: day == i ? navy : Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                children: [
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                    style: TextStyle(color: day == i ? Colors.white70 : muted, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${24 + i}',
                    style: TextStyle(
                      color: day == i ? Colors.white : navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 22),
      const SectionHeading('Saturday, 29 August'),
      const SizedBox(height: 12),
      const WorkoutCard(
        sport: 'BIKE',
        title: 'Tempo with surges',
        details: '1h 20 min  \u2022  78 TSS',
        color: purple,
        icon: Icons.directions_bike,
        progress: .92,
      ),
      const SizedBox(height: 10),
      const WorkoutCard(
        sport: 'STRENGTH',
        title: 'Core & mobility',
        details: '30 min  \u2022  Evening',
        color: orange,
        icon: Icons.fitness_center,
      ),
      const SizedBox(height: 24),
      const SectionHeading('Week overview'),
      const SizedBox(height: 10),
      const WeekRow('MON 24', 'Easy recovery run', '35 min', blue, Icons.directions_run),
      const WeekRow('TUE 25', 'Threshold intervals', '1h 05 min', blue, Icons.speed),
      const WeekRow('WED 26', 'Rest day', 'Recovery', muted, Icons.self_improvement),
      const WeekRow('THU 27', 'Endurance ride', '1h 45 min', purple, Icons.directions_bike),
      const WeekRow('FRI 28', 'Pool technique', '50 min', teal, Icons.pool),
      const WeekRow('SUN 30', 'Long aerobic run', '1h 30 min', blue, Icons.directions_run),
    ],
  );
}

class _CalendarPreview extends StatelessWidget {
  const _CalendarPreview();
  @override
  Widget build(BuildContext context) => const CalendarScreen();
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(body: _CalendarPreview()),
));

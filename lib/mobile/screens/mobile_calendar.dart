import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';
import '../widgets/mobile_workout_card.dart';

class MobileCalendarScreen extends StatefulWidget {
  const MobileCalendarScreen({super.key});

  @override
  State<MobileCalendarScreen> createState() => _MobileCalendarScreenState();
}

class _MobileCalendarScreenState extends State<MobileCalendarScreen> {
  int selectedDay = 5;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Calendar'),
        ),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left),
                    iconSize: M.iconMd,
                  ),
                  const Expanded(
                    child: Text(
                      '24–30 Aug 2026',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: M.navy,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right),
                    iconSize: M.iconMd,
                  ),
                ],
              ),
              const SizedBox(height: M.md),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (context, index) => const SizedBox(width: M.sm),
                  itemBuilder: (context, i) {
                    final selected = selectedDay == i;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDay = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 44,
                        decoration: BoxDecoration(
                          color: selected ? M.navy : Colors.white,
                          borderRadius: BorderRadius.circular(M.rMd),
                          border: selected
                              ? null
                              : Border.all(color: M.divider),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                              style: TextStyle(
                                color: selected
                                    ? Colors.white70
                                    : M.muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: M.xs),
                            Text(
                              '${24 + i}',
                              style: TextStyle(
                                color: selected ? Colors.white : M.navy,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Saturday, 29 August',
                child: Column(
                  children: [
                    const MWorkoutCard(
                      sport: 'BIKE',
                      title: 'Tempo with surges',
                      details: '1h 20 min  •  78 TSS',
                      color: M.purple,
                      icon: Icons.directions_bike,
                      progress: 0.92,
                    ),
                    const SizedBox(height: M.sm),
                    const MWorkoutCard(
                      sport: 'STRENGTH',
                      title: 'Core & mobility',
                      details: '30 min  •  Evening',
                      color: M.orange,
                      icon: Icons.fitness_center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Week overview',
                child: Column(
                  children: const [
                    _WeekDayRow('MON 24', 'Easy recovery run', '35 min',
                        M.blue, Icons.directions_run),
                    _WeekDayRow('TUE 25', 'Threshold intervals', '1h 05 min',
                        M.blue, Icons.speed),
                    _WeekDayRow('WED 26', 'Rest day', 'Recovery', M.muted,
                        Icons.self_improvement),
                    _WeekDayRow('THU 27', 'Endurance ride', '1h 45 min',
                        M.purple, Icons.directions_bike),
                    _WeekDayRow('FRI 28', 'Pool technique', '50 min', M.teal,
                        Icons.pool),
                    _WeekDayRow('SUN 30', 'Long aerobic run', '1h 30 min',
                        M.blue, Icons.directions_run),
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

class _WeekDayRow extends StatelessWidget {
  final String day;
  final String title;
  final String time;
  final Color color;
  final IconData icon;

  const _WeekDayRow(this.day, this.title, this.time, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: M.sm),
      child: MCard(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
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
                        fontWeight: FontWeight.w800,
                        color: M.ink,
                      )),
                  const SizedBox(height: 2),
                  Text('$day  •  $time', style: M.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: M.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MobileCalendarPreview extends StatelessWidget {
  const _MobileCalendarPreview();
  @override
  Widget build(BuildContext context) => const MobileCalendarScreen();
}

void main() => runApp(MaterialApp(
  theme: M.theme,
  home: const _MobileCalendarPreview(),
));

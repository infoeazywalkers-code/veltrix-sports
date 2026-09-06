import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../widgets/heading.dart';
import '../widgets/workout_card.dart';
import '../widgets/week_row.dart';
import '../providers.dart';
import '../models/workout.dart';
import '../screens/workout_details.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<CalendarScreen> {
  int day = 5;
  int weekOffset = 0;

  DateTime get _weekStart {
    return getStartOfWeek(DateTime.now(), weekOffset: weekOffset);
  }

  String _weekLabel() {
    final start = _weekStart;
    final end = start.add(const Duration(days: 6));
    return '${start.day}\u2013${end.day} ${monthName(start.month)} ${start.year}';
  }

  String _dayLabel(int weekday) =>
      ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][weekday - 1];

  IconData _sportIcon(Sport sport) {
    switch (sport) {
      case Sport.run:
        return Icons.directions_run;
      case Sport.bike:
        return Icons.directions_bike;
      case Sport.swim:
        return Icons.pool;
      case Sport.strength:
        return Icons.fitness_center;
      case Sport.rest:
        return Icons.self_improvement;
    }
  }

  Color _sportColor(Sport sport) {
    switch (sport) {
      case Sport.run:
        return blue;
      case Sport.bike:
        return purple;
      case Sport.swim:
        return teal;
      case Sport.strength:
        return orange;
      case Sport.rest:
        return muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutsByDateRangeProvider(_weekStart));

    final selectedDate = _weekStart.add(Duration(days: day));

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => weekOffset--),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                _weekLabel(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: navy,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => weekOffset++),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final date = _weekStart.add(Duration(days: i));
            return GestureDetector(
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
                      style: TextStyle(
                        color: day == i ? Colors.white70 : muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: day == i ? Colors.white : navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 22),
        SectionHeading(
          '${_dayLabel(selectedDate.weekday)}, ${selectedDate.day} ${monthName(selectedDate.month)}',
        ),
        const SizedBox(height: 12),
        workoutsAsync.when(
          loading:
              () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: CircularProgressIndicator(color: navy)),
              ),
          error:
              (e, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'Failed to load workouts',
                    style: TextStyle(color: muted),
                  ),
                ),
              ),
          data: (workouts) {
            if (workouts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, color: muted, size: 44),
                      SizedBox(height: 10),
                      Text(
                        'No workouts scheduled',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enjoy your rest day',
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                ),
              );
            }
            final dayWorkouts =
                workouts
                    .where(
                      (w) =>
                          w.scheduledFor.day == selectedDate.day &&
                          w.scheduledFor.month == selectedDate.month &&
                          w.scheduledFor.year == selectedDate.year,
                    )
                    .toList();
            if (dayWorkouts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, color: muted, size: 44),
                      SizedBox(height: 10),
                      Text(
                        'No workouts today',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children:
                  dayWorkouts
                      .map(
                        (w) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: WorkoutCard(
                            sport: w.sport.name.toUpperCase(),
                            title: w.title,
                            details:
                                '${w.duration}${w.tss != null ? '  \u2022  ${w.tss} TSS' : ''}',
                            color: _sportColor(w.sport),
                            icon: _sportIcon(w.sport),
                            progress: w.progress,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => WorkoutDetailsScreen(workout: w),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        const SectionHeading('Week overview'),
        const SizedBox(height: 10),
        workoutsAsync.when(
          loading:
              () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator(color: navy)),
              ),
          error:
              (e, _) => const Text(
                'Failed to load week',
                style: TextStyle(color: muted),
              ),
          data: (workouts) {
            if (workouts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'No workouts this week',
                  style: TextStyle(color: muted),
                ),
              );
            }
            final sorted = List<Workout>.from(workouts)
              ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
            return Column(
              children:
                  sorted
                      .map(
                        (w) => WeekRow(
                          '${_dayLabel(w.scheduledFor.weekday)} ${w.scheduledFor.day}',
                          w.title,
                          w.duration,
                          _sportColor(w.sport),
                          _sportIcon(w.sport),
                        ),
                      )
                      .toList(),
            );
          },
        ),
      ],
    );
  }
}

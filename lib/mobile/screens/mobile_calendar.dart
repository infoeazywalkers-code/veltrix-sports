import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/activity/workout.dart';
import '../../providers.dart';
import '../../screens/activity/workout_details.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';
import '../widgets/mobile_workout_card.dart';

class MobileCalendarScreen extends ConsumerStatefulWidget {
  const MobileCalendarScreen({super.key});

  @override
  ConsumerState<MobileCalendarScreen> createState() =>
      _MobileCalendarScreenState();
}

class _MobileCalendarScreenState extends ConsumerState<MobileCalendarScreen> {
  int selectedDay = 5;
  int weekOffset = 0;

  DateTime get _weekStart {
    return getStartOfWeek(DateTime.now(), weekOffset: weekOffset);
  }

  DateTime get _weekEnd => _weekStart.add(const Duration(days: 7));

  /// Plan chip label for a workout, or null when no chip should be shown.
  ///
  /// Legacy and empty plan ids are never chipped; anything else resolves via
  /// [planNameProvider] (which falls back to 'Training plan' and never
  /// throws), returning null only while the name is still loading.
  String? _planLabel(String planId) {
    if (!isRealPlanId(planId)) return null;
    return ref.watch(planNameProvider(planId)).valueOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutsByDateRangeProvider(_weekStart));
    final activePlans = ref.watch(activePlansProvider).valueOrNull ?? const [];
    final planFilter = ref.watch(calendarPlanFilterProvider);

    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Calendar')),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => weekOffset--),
                    icon: const Icon(Icons.chevron_left),
                    iconSize: M.iconMd,
                  ),
                  Expanded(
                    child: Text(
                      '${_weekStart.day}–${_weekEnd.subtract(const Duration(days: 1)).day} ${monthNames[_weekStart.month - 1]} ${_weekStart.year}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color:
                            (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : M.navy),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => weekOffset++),
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
                  separatorBuilder:
                      (context, index) => const SizedBox(width: M.sm),
                  itemBuilder: (context, i) {
                    final selected = selectedDay == i;
                    final day = _weekStart.add(Duration(days: i));
                    return GestureDetector(
                      onTap: () => setState(() => selectedDay = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 44,
                        decoration: BoxDecoration(
                          color:
                              selected
                                  ? M.navy
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF0F2030)
                                      : Colors.white),
                          borderRadius: BorderRadius.circular(M.rMd),
                          border:
                              selected
                                  ? null
                                  : Border.all(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF1A3040)
                                            : M.divider,
                                  ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayNames[i],
                              style: TextStyle(
                                color:
                                    selected
                                        ? Colors.white70
                                        : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF78909C)
                                            : M.muted),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: M.xs),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                color:
                                    selected
                                        ? Colors.white
                                        : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : M.navy),
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
                title:
                    '${dayNames[selectedDay]}, ${_weekStart.add(Duration(days: selectedDay)).day} ${monthNames[_weekStart.add(Duration(days: selectedDay)).month - 1]}',
                child: workoutsAsync.when(
                  loading:
                      () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(M.base),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  error:
                      (e, _) => Padding(
                        padding: const EdgeInsets.all(M.base),
                        child: Text(
                          'Error: $e',
                          style: M.adaptiveMuted(context),
                        ),
                      ),
                  data: (workouts) {
                    final selectedDate = _weekStart.add(
                      Duration(days: selectedDay),
                    );
                    final visible =
                        planFilter == null
                            ? workouts
                            : workouts
                                .where((w) => w.planId == planFilter)
                                .toList();
                    final dayWorkouts =
                        visible
                            .where(
                              (w) =>
                                  w.scheduledFor.year == selectedDate.year &&
                                  w.scheduledFor.month == selectedDate.month &&
                                  w.scheduledFor.day == selectedDate.day,
                            )
                            .toList();
                    if (dayWorkouts.isEmpty) {
                      return MCard(
                        child: Padding(
                          padding: const EdgeInsets.all(M.base),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                color:
                                    (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF78909C)
                                        : M.muted),
                                size: 20,
                              ),
                              const SizedBox(width: M.sm),
                              Text(
                                'No workouts today',
                                style: M.adaptiveMuted(context),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children:
                          dayWorkouts.map((w) {
                            final sportLabel = w.sport.name.toUpperCase();
                            final details = [
                              w.duration,
                              if (w.tss != null) '${w.tss} TSS',
                            ].join('  •  ');
                            final icon =
                                w.sport == Sport.run
                                    ? Icons.directions_run
                                    : w.sport == Sport.bike
                                    ? Icons.directions_bike
                                    : w.sport == Sport.swim
                                    ? Icons.pool
                                    : w.sport == Sport.strength
                                    ? Icons.fitness_center
                                    : Icons.self_improvement;
                            final color =
                                w.sport == Sport.run
                                    ? M.blue
                                    : w.sport == Sport.bike
                                    ? M.purple
                                    : w.sport == Sport.swim
                                    ? M.teal
                                    : w.sport == Sport.strength
                                    ? M.orange
                                    : M.muted;
                            return Column(
                              children: [
                                MWorkoutCard(
                                  sport: sportLabel,
                                  title: w.title,
                                  details: details,
                                  color: color,
                                  icon: icon,
                                  progress: w.progress,
                                  planLabel: _planLabel(w.planId),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => WorkoutDetailsScreen(
                                              workout: w,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: M.sm),
                              ],
                            );
                          }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: M.lg),
              if (activePlans.isNotEmpty) ...[
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: activePlans.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final selected =
                          isAll
                              ? planFilter == null
                              : planFilter == activePlans[index - 1].id;
                      final label = isAll ? 'All' : activePlans[index - 1].name;
                      return ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        onSelected:
                            (_) =>
                                ref
                                    .read(calendarPlanFilterProvider.notifier)
                                    .state = isAll
                                        ? null
                                        : activePlans[index - 1].id,
                      );
                    },
                  ),
                ),
                const SizedBox(height: M.md),
              ],
              MSection(
                title: 'Week overview',
                child: workoutsAsync.when(
                  loading:
                      () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(M.base),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  error:
                      (e, _) => Padding(
                        padding: const EdgeInsets.all(M.base),
                        child: Text(
                          'Error: $e',
                          style: M.adaptiveMuted(context),
                        ),
                      ),
                  data: (workouts) {
                    final visible =
                        planFilter == null
                            ? workouts
                            : workouts
                                .where((w) => w.planId == planFilter)
                                .toList();
                    if (visible.isEmpty) {
                      return MCard(
                        child: Padding(
                          padding: EdgeInsets.all(M.base),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_available,
                                color:
                                    (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF78909C)
                                        : M.muted),
                                size: 20,
                              ),
                              SizedBox(width: M.sm),
                              Text(
                                'No workouts this week',
                                style: M.adaptiveMuted(context),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: List.generate(7, (i) {
                        final day = _weekStart.add(Duration(days: i));
                        final dayWorkouts =
                            visible
                                .where(
                                  (w) =>
                                      w.scheduledFor.year == day.year &&
                                      w.scheduledFor.month == day.month &&
                                      w.scheduledFor.day == day.day,
                                )
                                .toList();
                        if (dayWorkouts.isEmpty) {
                          return _WeekDayRow(
                            '${dayNames[i]} ${day.day}',
                            'Rest day',
                            'Recovery',
                            M.muted,
                            Icons.self_improvement,
                          );
                        }
                        final w = dayWorkouts.first;
                        final color =
                            w.sport == Sport.run
                                ? M.blue
                                : w.sport == Sport.bike
                                ? M.purple
                                : w.sport == Sport.swim
                                ? M.teal
                                : w.sport == Sport.strength
                                ? M.orange
                                : M.muted;
                        final icon =
                            w.sport == Sport.run
                                ? Icons.directions_run
                                : w.sport == Sport.bike
                                ? Icons.directions_bike
                                : w.sport == Sport.swim
                                ? Icons.pool
                                : w.sport == Sport.strength
                                ? Icons.fitness_center
                                : Icons.self_improvement;
                        return _WeekDayRow(
                          '${dayNames[i]} ${day.day}',
                          w.title,
                          w.duration,
                          color,
                          icon,
                        );
                      }),
                    );
                  },
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
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFB0BEC5)
                              : M.ink),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('$day  •  $time', style: M.adaptiveCardBody(context)),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color:
                  (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF78909C)
                      : M.muted),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

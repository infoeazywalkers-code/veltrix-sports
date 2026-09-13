import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/activity/workout.dart';
import '../../providers.dart';
import '../activity/workout_details.dart';
import 'calendar_screen.dart';
import '../../mobile/screens/mobile_calendar.dart';

/// Detail view for one enrolled training plan.
///
/// Shows the plan header (name/weeks/difficulty/start-end), a live progress
/// bar, the plan's workouts grouped by week, and actions to view the plan in
/// the calendar or cancel it.
class PlanDetailScreen extends ConsumerWidget {
  final String planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Training plan')),
        body: const Center(child: Text('Sign in to view your training plan.')),
      );
    }
    final uid = user.uid;
    final plansAsync = ref.watch(activePlansProvider);
    final progressAsync = ref.watch(
      planProgressProvider((userId: uid, planId: planId)),
    );
    final workoutsAsync = ref.watch(
      planWorkoutsProvider((userId: uid, planId: planId)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        title: const Text('Training plan'),
      ),
      body: plansAsync.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            ),
        error:
            (_, _) => const Center(
              child: Text(
                'Failed to load plan',
                style: TextStyle(color: Colors.white54),
              ),
            ),
        data: (plans) {
          final matches = plans.where((p) => p.id == planId).toList();
          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Plan not found',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
                  ),
                ],
              ),
            );
          }
          final plan = matches.first;
          final dateRange = _dateRange(plan.startDate, plan.endDate);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                plan.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${plan.durationWeeks} weeks · ${plan.difficulty} · $dateRange',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),
              progressAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const LinearProgressIndicator(value: 0),
                data:
                    (progress) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 8,
                            color: const Color(0xFF10B981),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(progress.clamp(0.0, 1.0) * 100).round()}% complete',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewInCalendar(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'View in Calendar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelPlan(context, ref),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel plan',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'WORKOUTS BY WEEK',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              workoutsAsync.when(
                loading:
                    () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                error:
                    (_, _) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Failed to load workouts',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No workouts yet',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  }
                  final grouped = _groupByWeek(workouts, plan.startDate);
                  final weekNumbers = grouped.keys.toList()..sort();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final week in weekNumbers) ...[
                        Text(
                          'Week $week',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final workout in grouped[week]!)
                          _workoutRow(context, workout),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _viewInCalendar(BuildContext context, WidgetRef ref) {
    ref.read(calendarPlanFilterProvider.notifier).state = planId;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _PlanCalendarView()),
    );
  }

  Future<void> _cancelPlan(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Cancel plan?'),
            content: const Text(
              'Scheduled workouts stay on your calendar, but the plan will no longer be active.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Keep plan'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Cancel plan'),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(trainingPlanServiceProvider).update(planId, {
        'status': 'cancelled',
      });
      ref.read(calendarPlanFilterProvider.notifier).state = null;
      if (context.mounted) {
        showFeatureMessage(context, 'Plan cancelled.');
        Navigator.pop(context);
      }
    } catch (_) {
      if (context.mounted) {
        showFeatureMessage(context, 'Could not cancel the plan. Try again.');
      }
    }
  }

  Widget _workoutRow(BuildContext context, Workout workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          workout.completed ? Icons.check_circle : Icons.fitness_center,
          color:
              workout.completed
                  ? const Color(0xFF10B981)
                  : const Color(0xFF8B5CF6),
        ),
        title: Text(
          workout.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          workout.duration,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutDetailsScreen(workout: workout),
              ),
            ),
      ),
    );
  }

  Map<int, List<Workout>> _groupByWeek(
    List<Workout> workouts,
    DateTime? planStart,
  ) {
    final sorted = List<Workout>.from(workouts)
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    final base =
        planStart ??
        (sorted.isNotEmpty
            ? DateTime(
              sorted.first.scheduledFor.year,
              sorted.first.scheduledFor.month,
              sorted.first.scheduledFor.day,
            )
            : DateTime.now());
    final grouped = <int, List<Workout>>{};
    for (final workout in sorted) {
      final day = DateTime(
        workout.scheduledFor.year,
        workout.scheduledFor.month,
        workout.scheduledFor.day,
      );
      final week = (day.difference(base).inDays ~/ 7) + 1;
      grouped.putIfAbsent(week < 1 ? 1 : week, () => []).add(workout);
    }
    return grouped;
  }

  String _dateRange(DateTime? start, DateTime? end) {
    if (start == null) return 'Start date TBD';
    final endLabel =
        end == null ? '…' : '${end.day} ${monthName(end.month)} ${end.year}';
    return '${start.day} ${monthName(start.month)} ${start.year} – $endLabel';
  }
}

/// Calendar view pushed from a plan: respects [calendarPlanFilterProvider].
class _PlanCalendarView extends StatelessWidget {
  const _PlanCalendarView();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= kMobileBreakpoint;
    return Scaffold(
      appBar: AppBar(title: const Text('Plan calendar')),
      body: wide ? const CalendarScreen() : const MobileCalendarScreen(),
    );
  }
}

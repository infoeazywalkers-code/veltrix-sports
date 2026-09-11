import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../models/activity/activity.dart';
import '../../../models/activity/workout.dart';
import '../../../providers.dart';

/// One computed badge: earned only when real data meets the threshold.
class AchievementBadge {
  final String label;
  final String hint;
  final IconData icon;
  final bool earned;

  const AchievementBadge({
    required this.label,
    required this.hint,
    required this.icon,
    required this.earned,
  });
}

/// Computes achievement badges from REAL data only.
///
/// No persistence — callers recompute each build from live activities and
/// completed workouts. Never fabricates earns: every flag traces to a
/// threshold check below.
List<AchievementBadge> computeAchievements({
  required List<Activity> activities,
  required List<Workout> completedWorkouts,
}) {
  final now = DateTime.now();
  final monthAgo = now.subtract(const Duration(days: 30));
  final recent =
      activities
          .where(
            (a) =>
                a.date.isAfter(monthAgo) || a.date.isAtSameMomentAs(monthAgo),
          )
          .toList();

  var monthDistanceKm = 0.0;
  var monthClimbM = 0.0;
  for (final a in recent) {
    monthDistanceKm += a.distanceKm;
    monthClimbM += a.elevationGainMeters;
  }

  final hasFirst = activities.isNotEmpty || completedWorkouts.isNotEmpty;

  var has5kRun = false;
  for (final a in activities) {
    final isRun =
        a.sport == SportType.running || a.sport == SportType.trailRunning;
    if (isRun && a.distanceKm >= 4.5 && a.distanceKm <= 5.5) {
      has5kRun = true;
      break;
    }
  }
  if (!has5kRun) {
    for (final w in completedWorkouts) {
      final d = w.distanceKm;
      if (w.sport == Sport.run && d != null && d >= 4.5 && d <= 5.5) {
        has5kRun = true;
        break;
      }
    }
  }

  final has100kMonth = monthDistanceKm >= 100;
  final hasClimbMonth = monthClimbM >= 1000;
  final hasStreak = _hasSevenDayStreak(activities, completedWorkouts);

  return [
    const AchievementBadge(
      label: 'First workout',
      hint: 'Log your first activity',
      icon: Icons.fitness_center,
      earned: false,
    )._copyWith(earned: hasFirst),
    AchievementBadge(
      label: '5K run',
      hint: has5kRun ? 'Completed' : 'Run 4.5–5.5 km',
      icon: Icons.directions_run,
      earned: has5kRun,
    ),
    AchievementBadge(
      label: '100 km month',
      hint: '${monthDistanceKm.toStringAsFixed(0)}/100 km · 30d',
      icon: Icons.route,
      earned: has100kMonth,
    ),
    AchievementBadge(
      label: '1000m climb',
      hint: '${monthClimbM.toStringAsFixed(0)}/1000 m · 30d',
      icon: Icons.terrain,
      earned: hasClimbMonth,
    ),
    const AchievementBadge(
      label: '7-day streak',
      hint: 'Active 7 days in a row',
      icon: Icons.local_fire_department,
      earned: false,
    )._copyWith(earned: hasStreak),
  ];
}

/// True when [activities]+[workouts] cover 7 consecutive calendar days.
bool _hasSevenDayStreak(
  List<Activity> activities,
  List<Workout> completedWorkouts,
) {
  final days = <DateTime>{};
  for (final a in activities) {
    days.add(DateTime(a.date.year, a.date.month, a.date.day));
  }
  for (final w in completedWorkouts) {
    final d = w.scheduledFor;
    days.add(DateTime(d.year, d.month, d.day));
  }
  if (days.length < 7) return false;
  final sorted = days.toList()..sort();
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    final diff = sorted[i].difference(sorted[i - 1]).inDays;
    if (diff == 1) {
      run += 1;
      if (run >= 7) return true;
    } else if (diff == 0) {
      continue;
    } else {
      run = 1;
    }
  }
  return false;
}

extension on AchievementBadge {
  AchievementBadge _copyWith({bool? earned}) => AchievementBadge(
    label: label,
    hint: hint,
    icon: icon,
    earned: earned ?? this.earned,
  );
}

/// Achievements for the signed-in user, computed from live providers.
class AchievementsRow extends ConsumerWidget {
  const AchievementsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider);
    if (me == null) return const SizedBox.shrink();
    final workoutsAsync = ref.watch(completedWorkoutsProvider);
    final activitiesStream = ref
        .read(activityServiceProvider)
        .watchUserActivities(me.uid, limit: 100);
    return StreamBuilder<List<Activity>>(
      stream: activitiesStream,
      builder: (context, snapshot) {
        final activities = snapshot.data ?? const <Activity>[];
        final workouts = workoutsAsync.valueOrNull ?? const <Workout>[];
        if (snapshot.connectionState == ConnectionState.waiting &&
            workoutsAsync.isLoading) {
          return const _AchievementsCard(badges: [], loading: true);
        }
        final badges = computeAchievements(
          activities: activities,
          completedWorkouts: workouts,
        );
        return _AchievementsCard(badges: badges);
      },
    );
  }
}

/// Achievements for any athlete [uid], computed from their live activities
/// plus completed workouts in the last 90 days.
class AthleteAchievementsRow extends ConsumerWidget {
  final String uid;

  const AthleteAchievementsRow({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (uid.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 90));
    final activitiesStream = ref
        .read(activityServiceProvider)
        .watchUserActivities(uid, limit: 100);
    final workoutsStream = ref
        .read(workoutServiceProvider)
        .watchByDateRange(uid, start, now);
    return StreamBuilder<List<Activity>>(
      stream: activitiesStream,
      builder: (context, actSnap) {
        return StreamBuilder<List<Workout>>(
          stream: workoutsStream,
          builder: (context, workSnap) {
            if (actSnap.connectionState == ConnectionState.waiting &&
                workSnap.connectionState == ConnectionState.waiting) {
              return const _AchievementsCard(badges: [], loading: true);
            }
            final activities = actSnap.data ?? const <Activity>[];
            final completed =
                (workSnap.data ?? const <Workout>[])
                    .where((w) => w.completed)
                    .toList();
            final badges = computeAchievements(
              activities: activities,
              completedWorkouts: completed,
            );
            return _AchievementsCard(badges: badges);
          },
        );
      },
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  final List<AchievementBadge> badges;
  final bool loading;

  const _AchievementsCard({required this.badges, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                color: isDark ? Colors.white : navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: badges.map(_BadgeTile.new).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final AchievementBadge badge;

  const _BadgeTile(this.badge);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final earned = badge.earned;
    final fg = earned ? Colors.white : (isDark ? Colors.white38 : muted);
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          Opacity(
            opacity: earned ? 1 : 0.45,
            child: CircleAvatar(
              radius: 24,
              backgroundColor:
                  earned
                      ? const Color(0xFFF97316)
                      : (isDark ? Colors.white10 : Colors.grey.shade300),
              child: Icon(badge.icon, color: fg, size: 22),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : navy,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF78909C) : muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

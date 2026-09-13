import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth/auth_service.dart';
import '../../core/constants.dart';
import '../../models/activity/workout.dart';
import '../../providers.dart';
import '../../core/utils/unit_conversion.dart';
import '../../services/performance/pmc_service.dart';
import '../../screens/social/notifications_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/activity/workout_details.dart';
import '../../widgets/dialogs/event_details_dialog.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';
import '../widgets/mobile_stat_ring.dart';
import '../widgets/mobile_workout_card.dart';

class MobileHomeScreen extends ConsumerWidget {
  const MobileHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final workoutsAsync = ref.watch(upcomingWorkoutsProvider);
    final units = ref.watch(unitSystemProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 64,
          flexibleSpace: const FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(left: M.pageH, bottom: 14),
            title: Text(
              'VELTRIX',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              icon: const Badge(child: Icon(Icons.notifications_none_rounded)),
            ),
          ],
        ),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              profileAsync.when(
                loading: () => const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) =>
                    Text('Error: $e', style: M.adaptiveMuted(context)),
                data: (profile) {
                  final name =
                      profile?.displayName.split(' ').first ?? 'Athlete';
                  return Text(
                    'Hello, $name',
                    style: M
                        .adaptiveScreenTitle(context)
                        .copyWith(fontSize: 32),
                  );
                },
              ),
              const SizedBox(height: M.sm),
              Text(
                'Built for athletes who want more from every session.',
                style: M.adaptiveMuted(context),
              ),
              const SizedBox(height: M.lg),
              const HomeVideoHero(),
              const SizedBox(height: M.lg),
              profileAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (profile) {
                  if (profile != null) return const SizedBox.shrink();
                  return Wrap(
                    spacing: M.sm,
                    runSpacing: M.sm,
                    children: [
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: M.lime,
                          foregroundColor: M.navy,
                          padding: const EdgeInsets.symmetric(
                            horizontal: M.base,
                            vertical: M.md,
                          ),
                        ),
                        onPressed: () async {
                          await AuthService().signInWithGoogle();
                        },
                        child: const Text(
                          'Athlete sign up',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: M.navy,
                          padding: const EdgeInsets.symmetric(
                            horizontal: M.base,
                            vertical: M.md,
                          ),
                        ),
                        onPressed: () async {
                          await AuthService().signInWithGoogle();
                        },
                        child: const Text(
                          'Coach sign up',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: M.xl),
              const MDivider(label: 'YOUR TRAINING TODAY'),
              const SizedBox(height: M.lg),

              MBanner(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => const EventDetailsDialog(
                    event: {
                      'title': 'Mumbai Half Marathon',
                      'date': '25 October 2026',
                      'location': 'Mumbai, India',
                      'category': 'Running',
                      'participants': '15,000+ Runners',
                    },
                  ),
                ),
                backgroundColor: M.navy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: M.sm,
                            vertical: M.xs,
                          ),
                          decoration: BoxDecoration(
                            color: M.lime,
                            borderRadius: BorderRadius.circular(M.rSm),
                          ),
                          child: Text(
                            'A RACE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color:
                                  (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : M.navy),
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const EventDetailsDialog(
                              event: {
                                'title': 'Mumbai Half Marathon',
                                'date': '25 October 2026',
                                'location': 'Mumbai, India',
                                'category': 'Running',
                                'participants': '15,000+ Runners',
                              },
                            ),
                          ),
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: M.base),
                    const Text(
                      'Mumbai Half Marathon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: M.xs),
                    const Text(
                      '25 October 2026  •  21.1 km',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: M.base),
                    const LinearProgressIndicator(
                      value: 0.62,
                      minHeight: 6,
                      color: M.lime,
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(height: M.sm),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Plan progress',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '62%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: M.lg),
              MSection(
                title: 'Today\'s training',
                action: 'View week',
                child: workoutsAsync.when(
                  loading: () => const MCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(M.base),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  error: (e, _) => MCard(
                    child: Padding(
                      padding: const EdgeInsets.all(M.base),
                      child: Text('Error: $e', style: M.adaptiveMuted(context)),
                    ),
                  ),
                  data: (workouts) {
                    if (workouts.isEmpty) {
                      // Show demo workout when no workouts exist
                      final demoWorkout = Workout(
                        id: 'demo_run',
                        planId: 'demo',
                        sport: Sport.run,
                        title: 'Aerobic endurance',
                        description:
                            'Stay relaxed and keep your effort in Zone 2.',
                        duration: '45 min',
                        distanceKm: 7.2,
                        tss: 62,
                        targetPace: '5:55–6:15 /km',
                        scheduledFor: DateTime.now(),
                        progress: 0.68,
                        completed: false,
                      );
                      return MWorkoutCard(
                        sport: 'RUN',
                        title: demoWorkout.title,
                        details:
                            '${demoWorkout.duration}  •  ${UnitConversion.formatDistance(units, demoWorkout.distanceKm ?? 7.2)}  •  ${demoWorkout.tss} TSS',
                        color: M.blue,
                        icon: Icons.directions_run_rounded,
                        progress: demoWorkout.progress,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WorkoutDetailsScreen(workout: demoWorkout),
                            ),
                          );
                        },
                      );
                    }
                    final w = workouts.first;
                    final sportLabel = w.sport.name.toUpperCase();
                    final details = [
                      w.duration,
                      if (w.distanceKm != null)
                        UnitConversion.formatDistance(units, w.distanceKm!),
                      if (w.tss != null) '${w.tss} TSS',
                    ].join('  •  ');
                    final icon = w.sport == Sport.run
                        ? Icons.directions_run_rounded
                        : w.sport == Sport.bike
                        ? Icons.directions_bike
                        : w.sport == Sport.swim
                        ? Icons.pool
                        : w.sport == Sport.strength
                        ? Icons.fitness_center
                        : Icons.self_improvement;
                    final color = w.sport == Sport.run
                        ? M.blue
                        : w.sport == Sport.bike
                        ? M.purple
                        : w.sport == Sport.swim
                        ? M.teal
                        : w.sport == Sport.strength
                        ? M.orange
                        : M.muted;
                    return MWorkoutCard(
                      sport: sportLabel,
                      title: w.title,
                      details: details,
                      color: color,
                      icon: icon,
                      progress: w.progress,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutDetailsScreen(workout: w),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: M.lg),
              const _TrainingStatus(),

              const SizedBox(height: M.lg),
              MSection(title: 'This week', child: _WeekSummary()),

              const SizedBox(height: M.xl),
              MBanner(
                backgroundColor: M.darkNavy,
                padding: const EdgeInsets.all(M.lg),
                child: Column(
                  children: [
                    const Text(
                      'Ready starts here.',
                      style: TextStyle(
                        color: M.lime,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: M.sm),
                    const Text(
                      'Plan, train and grow on Veltrix.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: M.base),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: M.lime,
                          foregroundColor: M.navy,
                          padding: const EdgeInsets.symmetric(vertical: M.md),
                        ),
                        onPressed: () => showFeatureMessage(
                          context,
                          'Your Veltrix training journey is ready to begin.',
                        ),
                        child: const Text(
                          'Get started',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
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

class _WeekSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MCard(
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeekStat('5', 'Workouts'),
              _WeekStat('4h 35m', 'Duration'),
              _WeekStat('286', 'TSS'),
            ],
          ),
          const SizedBox(height: M.base),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (i) => Column(
                children: [
                  Container(
                    width: 16,
                    height: [30.0, 55.0, 18.0, 68.0, 42.0, 74.0, 25.0][i] * 0.6,
                    decoration: BoxDecoration(
                      color: i == 5 ? M.lime : M.blue.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: M.xs),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF78909C)
                          : M.muted),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  final String value;
  final String label;
  const _WeekStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: M.adaptiveStat(context)),
        Text(label, style: M.adaptiveMuted(context)),
      ],
    );
  }
}

/// Live training-status rings driven by the latest [PerformanceSnapshot].
///
/// Shows rounded fitness/fatigue/form values with progress normalized as
/// value/150 (clamped 0..1). When no snapshot exists yet, each ring shows
/// '–' with zero progress and the insight line says so honestly.
class _TrainingStatus extends ConsumerWidget {
  const _TrainingStatus();

  String _ringValue(double? v) => v == null ? '–' : '${v.round()}';

  double _ringProgress(double? v) =>
      v == null ? 0 : (v / 150).clamp(0, 1).toDouble();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(latestPerformanceProvider).valueOrNull;
    final formState = snapshot == null
        ? null
        : PmcService().getFormState(snapshot.form);
    final insightText = formState == null
        ? 'No training data yet — complete a workout to see your status.'
        : '${formState.label} — ${formState.description}.';

    return MSection(
      title: 'Training status',
      action: 'Details',
      child: MCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MStatRing(
                  value: _ringValue(snapshot?.fitness),
                  label: 'Fitness',
                  color: M.blue,
                  progress: _ringProgress(snapshot?.fitness),
                ),
                MStatRing(
                  value: _ringValue(snapshot?.fatigue),
                  label: 'Fatigue',
                  color: M.purple,
                  progress: _ringProgress(snapshot?.fatigue),
                ),
                MStatRing(
                  value: _ringValue(snapshot?.form),
                  label: 'Form',
                  color: M.orange,
                  progress: _ringProgress(snapshot?.form),
                ),
              ],
            ),
            const SizedBox(height: M.base),
            Container(
              padding: const EdgeInsets.all(M.md),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7EC),
                borderRadius: BorderRadius.circular(M.rMd),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Color(0xFF4C8C2B),
                    size: 20,
                  ),
                  const SizedBox(width: M.sm),
                  Expanded(
                    child: Text(
                      insightText,
                      style: const TextStyle(
                        color: Color(0xFF3F6F26),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

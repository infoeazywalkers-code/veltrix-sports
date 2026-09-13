import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/activity/workout.dart';
import '../../providers.dart' show unitSystemProvider;
import '../../core/utils/unit_conversion.dart';
import '../../screens/activity/live_workout_screen.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileWorkoutDetailScreen extends ConsumerWidget {
  final Workout? workout;
  const MobileWorkoutDetailScreen({super.key, this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitSystemProvider);
    final title = workout?.title ?? 'Aerobic endurance';
    final sportName = workout?.sport.name.toUpperCase() ?? 'RUN';
    final desc =
        workout?.description.isNotEmpty == true
            ? workout!.description
            : 'Stay relaxed and keep your effort in Zone 2.';
    final durationStr = workout?.duration ?? '45m';
    final distanceStr =
        workout?.distanceKm != null
            ? UnitConversion.formatDistance(units, workout!.distanceKm!)
            : UnitConversion.formatDistance(units, 7.2);
    final tssStr = workout?.tss != null ? '${workout!.tss}' : '62';
    final targetPace = workout?.targetPace ?? '5:55–6:15 /km';
    final segments =
        workout?.segments ??
        const [
          WorkoutSegment(label: 'Warm up', duration: '10 min'),
          WorkoutSegment(label: 'Aerobic run', duration: '30 min'),
          WorkoutSegment(label: 'Cool down', duration: '5 min'),
        ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () => _showWorkoutMenu(context),
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: ListView(
        padding: M.pagePadding(context),
        children: [
          MBanner(
            backgroundColor: M.navy,
            padding: const EdgeInsets.all(M.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$sportName • TODAY',
                  style: const TextStyle(
                    color: M.lime,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: M.md),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: M.xs),
                Text(desc, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: M.base),
          MCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Metric(durationStr, 'Duration'),
                    _Metric(distanceStr, 'Distance'),
                    _Metric(tssStr, 'TSS'),
                  ],
                ),
                const SizedBox(height: M.base),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.speed, color: M.blue),
                  title: const Text('Target pace'),
                  trailing: Text(
                    targetPace,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : M.navy),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: M.lg),
          MSection(
            title: 'Workout structure',
            child: Column(
              children: [
                for (final seg in segments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: M.sm),
                    child: MCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.drag_handle,
                            color: M.blue,
                            size: M.iconMd,
                          ),
                          const SizedBox(width: M.md),
                          Text(
                            '${seg.label} • ${seg.duration}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: M.base),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: M.lime,
              foregroundColor: M.navy,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () {
              final activeWorkout =
                  workout ??
                  Workout(
                    id: 'demo_run',
                    planId: 'demo',
                    sport: Sport.run,
                    title: title,
                    duration: durationStr,
                    distanceKm: 7.2,
                    tss: 62,
                    targetPace: targetPace,
                    scheduledFor: DateTime.now(),
                  );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveWorkoutScreen(workout: activeWorkout),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'Start workout',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
          const SizedBox(height: M.xxl),
        ],
      ),
    );
  }
}

void _showWorkoutMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder:
        (sheetContext) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit workout'),
                onTap: () => Navigator.pop(sheetContext),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove workout'),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
  );
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  const _Metric(this.value, this.label);

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

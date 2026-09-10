import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/utils/unit_conversion.dart';
import '../../providers.dart' show unitSystemProvider;
import '../../models/activity/workout.dart';
import '../../widgets/common/heading.dart';
import '../../widgets/common/metric.dart';
import '../../services/activity/workout_service.dart';
import 'live_workout_screen.dart';

class WorkoutDetailsScreen extends ConsumerStatefulWidget {
  final Workout? workout;
  const WorkoutDetailsScreen({super.key, this.workout});

  @override
  ConsumerState<WorkoutDetailsScreen> createState() =>
      _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends ConsumerState<WorkoutDetailsScreen> {
  bool _loading = false;

  Future<void> _markAsComplete() async {
    if (widget.workout == null) return;

    setState(() => _loading = true);
    try {
      await WorkoutService().complete(widget.workout!.id, progress: 1.0);
      if (mounted) {
        showFeatureMessage(context, 'Workout marked as complete!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showFeatureMessage(context, 'Failed to mark workout complete: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.workout?.title ?? 'Aerobic endurance';
    final sportName = widget.workout?.sport.name.toUpperCase() ?? 'RUN';
    final desc =
        widget.workout?.description.isNotEmpty == true
            ? widget.workout!.description
            : 'Stay relaxed and keep your effort in Zone 2.';
    final durationStr = widget.workout?.duration ?? '45m';
    final units = ref.watch(unitSystemProvider);
    final distanceStr =
        widget.workout?.distanceKm != null
            ? UnitConversion.formatDistance(units, widget.workout!.distanceKm!)
            : UnitConversion.formatDistance(units, 7.2);
    final tssStr =
        widget.workout?.tss != null ? '${widget.workout!.tss}' : '62';
    final targetPace = widget.workout?.targetPace ?? '5:55–6:15 /km';
    final segments =
        widget.workout?.segments ??
        const [
          WorkoutSegment(label: 'Warm up', duration: '10 min'),
          WorkoutSegment(label: 'Aerobic run', duration: '30 min'),
          WorkoutSegment(label: 'Cool down', duration: '5 min'),
        ];
    final isCompleted = widget.workout?.completed ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$sportName • TODAY',
                  style: const TextStyle(
                    color: lime,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Metric(durationStr, 'Duration'),
                      Metric(distanceStr, 'Distance'),
                      Metric(tssStr, 'TSS'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.speed, color: blue),
                    title: const Text('Target pace'),
                    trailing: Text(
                      targetPace,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : navy),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeading('Workout structure'),
          const SizedBox(height: 8),
          ...segments.map(
            (seg) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.drag_handle, color: blue),
                  title: Text(
                    '${seg.label} • ${seg.duration}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (isCompleted)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
              ),
              onPressed: null,
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'Workout completed',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            )
          else
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: lime,
                foregroundColor: navy,
                minimumSize: const Size.fromHeight(54),
              ),
              onPressed: () {
                final activeWorkout =
                    widget.workout ??
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
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          if (!isCompleted && widget.workout != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: navy,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _loading ? null : _markAsComplete,
              icon:
                  _loading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check),
              label: const Text(
                'Mark as complete',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

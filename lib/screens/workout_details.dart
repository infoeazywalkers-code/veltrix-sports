import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/workout.dart';
import '../widgets/heading.dart';
import '../widgets/metric.dart';
import 'live_workout_screen.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout? workout;
  const WorkoutDetailsScreen({super.key, this.workout});

  @override
  Widget build(BuildContext context) {
    final title = workout?.title ?? 'Aerobic endurance';
    final sportName = workout?.sport.name.toUpperCase() ?? 'RUN';
    final desc = workout?.description.isNotEmpty == true
        ? workout!.description
        : 'Stay relaxed and keep your effort in Zone 2.';
    final durationStr = workout?.duration ?? '45m';
    final distanceStr = workout?.distanceKm != null ? '${workout!.distanceKm} km' : '7.2 km';
    final tssStr = workout?.tss != null ? '${workout!.tss}' : '62';
    final targetPace = workout?.targetPace ?? '5:55–6:15 /km';
    final segments = workout?.segments ?? const [
      WorkoutSegment(label: 'Warm up', duration: '10 min'),
      WorkoutSegment(label: 'Aerobic run', duration: '30 min'),
      WorkoutSegment(label: 'Cool down', duration: '5 min'),
    ];

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
                Text('$sportName • TODAY', style: const TextStyle(color: lime, fontSize: 10, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
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
                    trailing: Text(targetPace, style: const TextStyle(fontWeight: FontWeight.w900, color: navy)),
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
                  title: Text('${seg.label} • ${seg.duration}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: lime,
              foregroundColor: navy,
              minimumSize: const Size.fromHeight(54),
            ),
            onPressed: () {
              final activeWorkout = workout ??
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
            label: const Text('Start workout', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}


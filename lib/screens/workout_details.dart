import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/heading.dart';
import '../widgets/metric.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  const WorkoutDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      title: const Text('Workout details', style: TextStyle(fontWeight: FontWeight.w900)),
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RUN \u2022 TODAY', style: TextStyle(color: lime, fontSize: 10, fontWeight: FontWeight.w900)),
              SizedBox(height: 17),
              Text('Aerobic endurance', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              Text('Stay relaxed and keep your effort in Zone 2.', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Metric('45m', 'Duration'),
                    Metric('7.2 km', 'Distance'),
                    Metric('62', 'TSS'),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.speed, color: blue),
                  title: Text('Target pace'),
                  trailing: Text('5:55\u20136:15 /km', style: TextStyle(fontWeight: FontWeight.w900, color: navy)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeading('Workout structure'),
        const SizedBox(height: 8),
        ...['Warm up \u2022 10 min', 'Aerobic run \u2022 30 min', 'Cool down \u2022 5 min'].map(
          (x) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.drag_handle, color: blue),
                title: Text(x, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: navy,
            minimumSize: const Size.fromHeight(54),
          ),
          onPressed: () => showFeatureMessage(context, 'Workout options are available from your plan.'),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start workout', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    ),
  );
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const WorkoutDetailsScreen(),
));

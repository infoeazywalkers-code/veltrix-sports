import 'package:flutter/material.dart';
import '../constants.dart';

class WorkoutCard extends StatelessWidget {
  final String sport, title, details;
  final Color color;
  final IconData icon;
  final double progress;
  final VoidCallback? onTap;
  const WorkoutCard({
    super.key,
    required this.sport,
    required this.title,
    required this.details,
    required this.color,
    required this.icon,
    this.progress = 0,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sport,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    details,
                    style: const TextStyle(color: muted, fontSize: 11),
                  ),
                  if (progress > 0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      color: color,
                      backgroundColor: color.withValues(alpha: .1),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: muted),
          ],
        ),
      ),
    ),
  );
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(
    body: Padding(
      padding: EdgeInsets.all(18),
      child: WorkoutCard(
        sport: 'RUN',
        title: 'Aerobic endurance',
        details: '45 min  •  7.2 km  •  62 TSS',
        color: blue,
        icon: Icons.directions_run_rounded,
        progress: .68,
      ),
    ),
  ),
));

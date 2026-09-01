import 'package:flutter/material.dart';
import '../theme.dart';
import 'mobile_card.dart';

class MWorkoutCard extends StatelessWidget {
  final String sport;
  final String title;
  final String details;
  final Color color;
  final IconData icon;
  final double progress;
  final VoidCallback? onTap;

  const MWorkoutCard({
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
  Widget build(BuildContext context) {
    return MCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(M.rMd),
            ),
            child: Icon(icon, color: color, size: M.iconLg),
          ),
          const SizedBox(width: M.md),
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
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(title, style: M.cardTitle),
                const SizedBox(height: 2),
                Text(details, style: M.caption),
                if (progress > 0) ...[
                  const SizedBox(height: M.sm),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: M.sm),
          const Icon(Icons.chevron_right, color: M.muted, size: 20),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  theme: M.theme,
  home: const Scaffold(
    body: Padding(
      padding: EdgeInsets.all(M.base),
      child: MWorkoutCard(
        sport: 'RUN',
        title: 'Aerobic endurance',
        details: '45 min  •  7.2 km  •  62 TSS',
        color: M.blue,
        icon: Icons.directions_run_rounded,
        progress: 0.68,
      ),
    ),
  ),
));

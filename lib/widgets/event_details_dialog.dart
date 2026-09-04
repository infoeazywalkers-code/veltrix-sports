import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import 'package:uuid/uuid.dart';

class EventDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final title = event['title'] as String? ?? 'Championship Race';
    final dateStr = event['date'] as String? ?? 'Upcoming Event';
    final location = event['location'] as String? ?? 'Global';
    final category = event['category'] as String? ?? 'Endurance';
    final participants = event['participants'] as String? ?? '500+ Athletes';
    final description = event['description'] as String? ??
        'Join thousands of endurance athletes in this premier competition. Course maps, hydration stations, and official chip timing provided.';

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, color: navy),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: navy.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: navy.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.calendar_month, 'Date', dateStr),
                  const Divider(),
                  _infoRow(Icons.location_on, 'Location', location),
                  const Divider(),
                  _infoRow(Icons.directions_run, 'Category', category),
                  const Divider(),
                  _infoRow(Icons.groups, 'Field Size', participants),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'About the Event',
              style: TextStyle(fontWeight: FontWeight.w800, color: navy, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(color: ink.withValues(alpha: 0.8), height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lime.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.stars, color: navy, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Includes Veltrix Live Leaderboard & GPS Tracking',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800, color: navy),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_task, size: 18),
          label: const Text('Add to Schedule'),
          onPressed: () async {
            try {
              final raceWorkout = Workout(
                id: const Uuid().v4(),
                planId: 'race_entry',
                sport: category.toLowerCase().contains('cycle')
                    ? Sport.bike
                    : Sport.run,
                title: 'RACE: $title',
                description: 'Official Race Event in $location',
                duration: '2h 30m',
                distanceKm: 21.1,
                tss: 180,
                targetPace: '4:45 /km',
                scheduledFor: DateTime.now().add(const Duration(days: 14)),
                progress: 0,
                completed: false,
              );
              await WorkoutService().create(raceWorkout);
            } catch (_) {}
            if (context.mounted) {
              Navigator.pop(context);
              showFeatureMessage(
                  context, 'Race "$title" added to your target calendar!');
            }
          },
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: navy,
          ),
          onPressed: () {
            Navigator.pop(context);
            showFeatureMessage(
                context, 'Redirecting to Official $title Registration portal...');
          },
          child: const Text(
            'Register Now',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: navy),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700, color: navy),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w800, color: ink),
            ),
          ),
        ],
      ),
    );
  }
}

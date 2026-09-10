import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/activity/workout.dart';
import '../../services/activity/workout_service.dart';
import '../../screens/explore/feature_collection_screen.dart';
import '../../models/events/event_ticket.dart';
import '../../services/events/event_service.dart';
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
    final description =
        event['description'] as String? ??
        'Join thousands of endurance athletes in this premier competition. Course maps, hydration stations, and official chip timing provided.';

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color:
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
              ),
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
                  _infoRow(context, Icons.calendar_month, 'Date', dateStr),
                  const Divider(),
                  _infoRow(context, Icons.location_on, 'Location', location),
                  const Divider(),
                  _infoRow(context, Icons.directions_run, 'Category', category),
                  const Divider(),
                  _infoRow(context, Icons.groups, 'Field Size', participants),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'About the Event',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color:
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                color:
                    (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFB0BEC5).withValues(alpha: 0.8)
                        : ink.withValues(alpha: 0.8)),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lime.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars, color: navy, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Includes Veltrix Live Leaderboard & GPS Tracking',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color:
                            (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : navy),
                      ),
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
                sport:
                    category.toLowerCase().contains('cycle')
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
                context,
                'Race "$title" added to your target calendar!',
              );
            }
          },
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: navy,
          ),
          onPressed: () async {
            try {
              final ticket = await EventService().register(
                SportsEvent(
                  id:
                      event['id'] as String? ??
                      title.toLowerCase().replaceAll(' ', '_'),
                  title: title,
                  date: DateTime.tryParse(dateStr) ?? DateTime.now(),
                  location: location,
                  category: category,
                  description: description,
                ),
              );
              if (!context.mounted) return;
              // Pop the dialog BEFORE pushing: capture the navigator first
              // so the push uses a live context after the dialog is gone.
              final navigator = Navigator.of(context);
              navigator.pop();
              await Future.microtask(() {});
              navigator.push(
                MaterialPageRoute(builder: (_) => ticketsScreen()),
              );
              showFeatureMessage(
                navigator.context,
                'Registration confirmed. Ticket ${ticket.qrPayload} is ready.',
              );
            } catch (error) {
              if (context.mounted) {
                showFeatureMessage(context, 'Registration failed: $error');
              }
            }
          },
          child: const Text(
            'Register Now',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color:
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : navy),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color:
                  (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : navy),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color:
                    (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFB0BEC5)
                        : ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/events/event_ticket.dart';
import '../../services/events/event_service.dart';

class FeatureCollectionScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<FeatureItem> items;

  const FeatureCollectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          desktop ? 40 : 18,
          24,
          desktop ? 40 : 18,
          64,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 34),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  leading: Icon(item.icon, color: accent),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : navy),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(item.subtitle),
                  trailing: Icon(Icons.chevron_right, color: (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF78909C) : muted)),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => FeatureDetailScreen(
                                title: item.title,
                                subtitle: item.subtitle,
                                icon: item.icon,
                                accent: accent,
                                message: item.message,
                              ),
                        ),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String message;

  const FeatureDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 64),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 34),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _DetailRow(
          icon: Icons.check_circle_outline,
          color: teal,
          title: 'Current status',
          body: message,
        ),
        const _DetailRow(
          icon: Icons.calendar_month,
          color: blue,
          title: 'Next action',
          body:
              'Review the details, confirm fit, and connect it to your calendar or profile when backend sync is enabled.',
        ),
        const _DetailRow(
          icon: Icons.security,
          color: orange,
          title: 'Production requirement',
          body:
              'This screen is ready for real data, but final production needs server-backed ownership, audit logs, and persistence.',
        ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _DetailRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : navy), fontWeight: FontWeight.w900),
        ),
        subtitle: Text(body),
      ),
    ),
  );
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String message;

  const FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.message,
  });
}

FeatureCollectionScreen trainingPlansScreen() => const FeatureCollectionScreen(
  title: 'Training plans',
  subtitle:
      'Browse structured plans for running, cycling, triathlon, and strength.',
  icon: Icons.event_note_rounded,
  accent: blue,
  items: [
    FeatureItem(
      icon: Icons.directions_run,
      title: 'Marathon Training Pro',
      subtitle:
          '16 weeks built around endurance, threshold, and race confidence.',
      message: 'Marathon Training Pro selected.',
    ),
    FeatureItem(
      icon: Icons.directions_bike,
      title: 'Cycling Performance Builder',
      subtitle: '12 weeks focused on FTP, cadence, and hill strength.',
      message: 'Cycling Performance Builder selected.',
    ),
    FeatureItem(
      icon: Icons.pool,
      title: 'Triathlon Base Builder',
      subtitle: '8 weeks for swim-bike-run consistency.',
      message: 'Triathlon Base Builder selected.',
    ),
  ],
);

FeatureCollectionScreen eventsScreen() => const FeatureCollectionScreen(
  title: 'Sports events',
  subtitle: 'Explore races and challenges connected to your training calendar.',
  icon: Icons.emoji_events_rounded,
  accent: orange,
  items: [
    FeatureItem(
      icon: Icons.directions_run,
      title: 'Mumbai Half Marathon',
      subtitle: '25 October 2026, Mumbai, India.',
      message: 'Mumbai Half Marathon opened.',
    ),
    FeatureItem(
      icon: Icons.directions_bike,
      title: 'Delhi Cycling Grand Prix',
      subtitle: '20 November 2026, New Delhi, India.',
      message: 'Delhi Cycling Grand Prix opened.',
    ),
  ],
);

Widget ticketsScreen() => const MyTicketsScreen();

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My tickets')),
    body: StreamBuilder<List<EventTicket>>(
      stream: EventService().watchMyTickets(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Sign in to view your tickets.'));
        }
        final tickets = snapshot.data ?? const <EventTicket>[];
        if (tickets.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Registered events will appear here with QR and arrival details.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: tickets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final ticket = tickets[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: Icon(Icons.qr_code_2, color: teal, size: 38),
                title: Text(ticket.eventTitle, style: TextStyle(fontWeight: FontWeight.w900, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : navy))),
                subtitle: Text('Status: ${ticket.status}\nTicket: ${ticket.qrPayload}'),
              ),
            );
          },
        );
      },
    ),
  );
}

FeatureCollectionScreen workoutLibraryScreen() => const FeatureCollectionScreen(
  title: 'Workout library',
  subtitle: 'Save, browse, and reuse your favorite structured sessions.',
  icon: Icons.library_books_rounded,
  accent: purple,
  items: [
    FeatureItem(
      icon: Icons.directions_run,
      title: 'Aerobic endurance',
      subtitle: '45 minutes in Zone 2 with relaxed form cues.',
      message: 'Aerobic endurance template selected.',
    ),
    FeatureItem(
      icon: Icons.fitness_center,
      title: 'Strength foundation',
      subtitle: 'Lower-body durability and mobility sequence.',
      message: 'Strength foundation template selected.',
    ),
  ],
);

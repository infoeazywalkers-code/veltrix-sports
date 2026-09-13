import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../models/events/event_ticket.dart';
import '../../../services/events/event_service.dart';
import '../../../services/performance/race_readiness_service.dart';
import '../../../widgets/common/heading.dart';
import 'race_readiness_card.dart';

/// Entry point for the Race Readiness Score on the My tickets screen.
///
/// Shows a full [RaceReadinessCard] for the nearest upcoming registered
/// event (ticket.eventId matched to an event). When nothing is registered,
/// the nearest upcoming event is shown with a 'Register to track
/// readiness' CTA wired to [EventService.register]. Per-ticket readiness
/// rows cover every other registered upcoming event.
///
/// States: signed-out shows a sign-in prompt (never crashes); loading and
/// errors show modest placeholder cards; past events are always excluded;
/// missing training data yields an honest low score from
/// [RaceReadinessService], never a fabricated mid score.
class RaceReadinessSection extends StatefulWidget {
  const RaceReadinessSection({super.key});

  @override
  State<RaceReadinessSection> createState() => _RaceReadinessSectionState();
}

class _RaceReadinessSectionState extends State<RaceReadinessSection> {
  final EventService _events = EventService();
  final RaceReadinessService _readiness = RaceReadinessService();
  late final Stream<List<SportsEvent>> _upcomingEvents = _events
      .watchUpcomingEvents();
  final Map<String, Future<RaceReadiness>> _readinessCache = {};
  bool _registering = false;

  Future<RaceReadiness> _cachedReadiness(String uid, SportsEvent event) {
    final String key = '$uid@${event.id}@${event.date.millisecondsSinceEpoch}';
    return _readinessCache.putIfAbsent(
      key,
      () => _readiness.readinessForEvent(userId: uid, eventDate: event.date),
    );
  }

  Future<void> _register(SportsEvent event) async {
    setState(() => _registering = true);
    try {
      final EventTicket ticket = await _events.register(event);
      if (!mounted) return;
      showFeatureMessage(
        context,
        'Registered for ${event.title} — ticket ${ticket.qrPayload} is ready.',
      );
    } catch (error) {
      if (!mounted) return;
      showFeatureMessage(context, 'Registration failed: $error');
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }
        final User? user = authSnapshot.data;
        if (user == null) {
          return _infoCard(
            icon: Icons.login_rounded,
            title: 'Sign in to see race readiness',
            body:
                'Your Race Readiness Score appears here once you are signed in and registered for a race.',
          );
        }
        return StreamBuilder<List<SportsEvent>>(
          stream: _upcomingEvents,
          builder: (context, eventsSnapshot) {
            if (eventsSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingCard();
            }
            if (eventsSnapshot.hasError) {
              return _infoCard(
                icon: Icons.cloud_off_rounded,
                title: 'Could not load races',
                body:
                    'Race readiness is unavailable right now. Your tickets below are unaffected.',
              );
            }
            return StreamBuilder<List<EventTicket>>(
              stream: _events.watchMyTickets(),
              builder: (context, ticketsSnapshot) {
                if (ticketsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _loadingCard();
                }
                if (ticketsSnapshot.hasError) {
                  return _infoCard(
                    icon: Icons.login_rounded,
                    title: 'Sign in to see race readiness',
                    body:
                        'Your Race Readiness Score appears here once you are signed in and registered for a race.',
                  );
                }
                return _content(
                  user.uid,
                  eventsSnapshot.data ?? const <SportsEvent>[],
                  ticketsSnapshot.data ?? const <EventTicket>[],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _content(
    String uid,
    List<SportsEvent> events,
    List<EventTicket> tickets,
  ) {
    final DateTime now = DateTime.now();
    final List<SportsEvent> upcoming =
        events.where((event) => event.date.isAfter(now)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    if (upcoming.isEmpty) {
      return _infoCard(
        icon: Icons.emoji_events_outlined,
        title: 'No upcoming races yet',
        body:
            'When new Veltrix races are announced they will appear here with your readiness score.',
      );
    }

    final Set<String> ticketEventIds = tickets
        .map((ticket) => ticket.eventId)
        .toSet();
    final List<SportsEvent> registered = upcoming
        .where((event) => ticketEventIds.contains(event.id))
        .toList();
    final SportsEvent focus = registered.isNotEmpty
        ? registered.first
        : upcoming.first;
    final bool focusRegistered = ticketEventIds.contains(focus.id);
    final List<SportsEvent> others = registered
        .where((event) => event.id != focus.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading('Race readiness'),
        const SizedBox(height: 10),
        FutureBuilder<RaceReadiness>(
          future: _cachedReadiness(uid, focus),
          builder: (context, readinessSnapshot) {
            if (readinessSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingCard();
            }
            if (readinessSnapshot.hasError || !readinessSnapshot.hasData) {
              return _infoCard(
                icon: Icons.cloud_off_rounded,
                title: 'Could not compute readiness',
                body:
                    'Your training data could not be read right now. Please try again later.',
              );
            }
            final RaceReadiness readiness = readinessSnapshot.data!;
            return RaceReadinessCard(
              eventTitle: focus.title,
              eventDate: focus.date,
              readiness: readiness,
              onRegister: focusRegistered ? null : () => _register(focus),
              registering: _registering,
            );
          },
        ),
        if (others.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...others.map(
            (event) => _TicketReadinessRow(
              key: ValueKey('readiness-${event.id}'),
              future: _cachedReadiness(uid, event),
              event: event,
            ),
          ),
        ],
      ],
    );
  }

  Widget _loadingCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(color: navy)),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: teal, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: dark ? Colors.white : navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      color: dark ? const Color(0xFF78909C) : muted,
                      height: 1.45,
                      fontSize: 13,
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

/// Compact per-ticket readiness row: event title, countdown and score pill.
///
/// Shows 'Unavailable' instead of a score while loading or on error —
/// scores are never fabricated.
class _TicketReadinessRow extends StatelessWidget {
  final Future<RaceReadiness> future;
  final SportsEvent event;

  const _TicketReadinessRow({
    super.key,
    required this.future,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final int daysOut = event.date.difference(DateTime.now()).inDays;
    final String countdown = daysOut <= 0
        ? 'Race day'
        : daysOut == 1
        ? '1 day out'
        : '$daysOut days out';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: dark ? Colors.white : navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      countdown,
                      style: TextStyle(
                        fontSize: 11,
                        color: dark ? const Color(0xFF78909C) : muted,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<RaceReadiness>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: teal,
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Text(
                      'Unavailable',
                      style: TextStyle(
                        fontSize: 12,
                        color: dark ? const Color(0xFF78909C) : muted,
                      ),
                    );
                  }
                  final RaceReadiness readiness = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: navy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${readiness.score} • ${readiness.verdict}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

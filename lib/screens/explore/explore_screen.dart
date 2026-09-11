import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../shell.dart' show ShellPage;
import '../../widgets/common/heading.dart';
import '../../widgets/dialogs/event_details_dialog.dart';
import '../activity/activity_feed_screen.dart';
import '../challenges/challenges_screen.dart';
import '../training/training_plan_marketplace_screen.dart';
import 'feature_collection_screen.dart';

class ExploreScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const ExploreScreen({super.key, this.onNavigate});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allEvents = const [
    {
      'day': '25',
      'month': 'OCT',
      'title': 'Mumbai Half Marathon',
      'location': 'Mumbai \u2022 Running',
      'date': '25 October 2026',
      'category': 'Running',
      'participants': '15,000+ Runners',
    },
    {
      'day': '20',
      'month': 'NOV',
      'title': 'Delhi Cycling Grand Prix',
      'location': 'New Delhi \u2022 Cycling',
      'date': '20 November 2026',
      'category': 'Cycling',
      'participants': '3,500+ Cyclists',
    },
    {
      'day': '15',
      'month': 'DEC',
      'title': 'Goa Triathlon Challenge',
      'location': 'Goa \u2022 Triathlon',
      'date': '15 December 2026',
      'category': 'Triathlon',
      'participants': '1,200+ Triathletes',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents =
        _allEvents.where((e) {
          final q = _searchQuery.toLowerCase();
          return e['title'].toString().toLowerCase().contains(q) ||
              e['location'].toString().toLowerCase().contains(q);
        }).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val.trim()),
          decoration: InputDecoration(
            hintText: 'Search plans, events',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                    : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeading('Browse Veltrix'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ExploreTile(
                'Training plans',
                Icons.event_note,
                blue,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrainingPlanMarketplaceScreen(),
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ExploreTile(
                'Find a coach',
                Icons.groups,
                purple,
                // Destination: Coach match.
                onTap:
                    () => widget.onNavigate?.call(ShellPage.coachMatch.index),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ExploreTile(
                'Sports events',
                Icons.emoji_events,
                orange,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => eventsScreen()),
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ExploreTile(
                'My tickets',
                Icons.confirmation_number,
                teal,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ticketsScreen()),
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ExploreTile(
                'Premium',
                Icons.workspace_premium,
                navy,
                // Destination: Premium.
                onTap: () => widget.onNavigate?.call(ShellPage.premium.index),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ExploreTile(
                'Devices',
                Icons.devices_other,
                blue,
                // Destination: Devices.
                onTap: () => widget.onNavigate?.call(ShellPage.devices.index),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_searchQuery.isEmpty ||
            'marathon training pro'.contains(_searchQuery.toLowerCase())) ...[
          const SectionHeading('Recommended plan', action: 'See plans'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.directions_run, color: lime),
                const SizedBox(height: 22),
                const Text(
                  'Marathon Training Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Build endurance, speed and race-day confidence with a structured 16-week plan.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 15),
                const Text(
                  '16 weeks  \u2022  Coach Amit',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 15),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: navy,
                  ),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrainingPlanMarketplaceScreen(),
                        ),
                      ),
                  child: const Text(
                    'View plan',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ExploreTile(
                  'Activity Feed',
                  Icons.dynamic_feed,
                  teal,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActivityFeedScreen(),
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ExploreTile(
                  'Challenges',
                  Icons.emoji_events_outlined,
                  orange,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChallengesScreen(),
                        ),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        SectionHeading(
          'Upcoming events (${filteredEvents.length})',
          action: 'See all',
        ),
        const SizedBox(height: 10),
        if (filteredEvents.isEmpty)
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No matching events found.',
                style: TextStyle(
                  color:
                      (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF78909C)
                          : muted),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        else
          ...filteredEvents.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _EventRow(
                d: e['day'],
                m: e['month'],
                title: e['title'],
                sub: e['location'],
                onTap:
                    () => showDialog(
                      context: context,
                      builder: (_) => EventDetailsDialog(event: e),
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ExploreTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ExploreTile(this.text, this.icon, this.color, {this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color:
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color:
                  (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF78909C)
                      : muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EventRow extends StatelessWidget {
  final String d, m, title, sub;
  final VoidCallback? onTap;
  const _EventRow({
    required this.d,
    required this.m,
    required this.title,
    required this.sub,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    d,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    m,
                    style: const TextStyle(
                      color: lime,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : navy),
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF78909C)
                              : muted),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color:
                  (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF78909C)
                      : muted),
            ),
          ],
        ),
      ),
    ),
  );
}

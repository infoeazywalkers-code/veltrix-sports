import 'package:flutter/material.dart';
import '../../screens/activity/activity_feed_screen.dart';
import '../../screens/athletes/athlete_discovery_screen.dart';
import '../../screens/challenges/challenges_screen.dart';
import '../../screens/coach/coach_match_screen.dart';
import '../../screens/devices/devices_screen.dart';
import '../../screens/explore/feature_collection_screen.dart';
import '../../screens/premium/premium_screen.dart';
import '../../screens/training/training_plan_marketplace_screen.dart';
import '../../widgets/dialogs/event_details_dialog.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileExploreScreen extends StatefulWidget {
  const MobileExploreScreen({super.key});

  @override
  State<MobileExploreScreen> createState() => _MobileExploreScreenState();
}

class _MobileExploreScreenState extends State<MobileExploreScreen> {
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
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _allEvents.where((e) {
      final q = _searchQuery.toLowerCase();
      return e['title'].toString().toLowerCase().contains(q) ||
          e['location'].toString().toLowerCase().contains(q);
    }).toList();

    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Explore')),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search plans, events',
                  prefixIcon: const Icon(Icons.search, size: M.iconMd),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: M.base,
                    vertical: M.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(M.rLg),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Browse Veltrix',
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: M.sm,
                  crossAxisSpacing: M.sm,
                  childAspectRatio: 1.6,
                  children: [
                    _ExploreTile(
                      'Training plans',
                      Icons.event_note,
                      M.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrainingPlanMarketplaceScreen(),
                        ),
                      ),
                    ),
                    _ExploreTile(
                      'Find a coach',
                      Icons.groups,
                      M.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CoachMatchScreen(),
                        ),
                      ),
                    ),
                    _ExploreTile(
                      'Sports events',
                      Icons.emoji_events,
                      M.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => eventsScreen()),
                      ),
                    ),
                    _ExploreTile(
                      'My tickets',
                      Icons.confirmation_number,
                      M.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ticketsScreen()),
                      ),
                    ),
                    _ExploreTile(
                      'Premium',
                      Icons.workspace_premium,
                      M.navy,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PremiumScreen(),
                        ),
                      ),
                    ),
                    _ExploreTile(
                      'Devices',
                      Icons.devices_other,
                      M.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DevicesScreen(),
                        ),
                      ),
                    ),
                    _ExploreTile(
                      'Activity Feed',
                      Icons.dynamic_feed,
                      M.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActivityFeedScreen(),
                        ),
                      ),
                    ),
                    _ExploreTile(
                      'Challenges',
                      Icons.emoji_events_outlined,
                      M.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChallengesScreen(),
                        ),
                      ),
                    ),
                    _ExploreTile(
                      'Find Athletes',
                      Icons.people_outline,
                      M.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AthleteDiscoveryScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              if (_searchQuery.isEmpty ||
                  'marathon training pro'.contains(
                    _searchQuery.toLowerCase(),
                  )) ...[
                MSection(
                  title: 'Recommended plan',
                  action: 'See plans',
                  child: MBanner(
                    backgroundColor: M.navy,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.directions_run,
                          color: M.lime,
                          size: M.iconLg,
                        ),
                        const SizedBox(height: M.base),
                        const Text(
                          'Marathon Training Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: M.xs),
                        const Text(
                          'Build endurance, speed and race-day confidence with a structured 16-week plan.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: M.md),
                        const Text(
                          '16 weeks  •  Coach Amit',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: M.base),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: M.lime,
                            foregroundColor: M.navy,
                          ),
                          onPressed: () => Navigator.push(
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
                ),
                const SizedBox(height: M.lg),
              ],
              MSection(
                title: 'Upcoming events (${filteredEvents.length})',
                action: 'See all',
                child: Column(
                  children: filteredEvents
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: M.sm),
                          child: _EventRow(
                            d: e['day'],
                            m: e['month'],
                            title: e['title'],
                            sub: e['location'],
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => EventDetailsDialog(event: e),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: M.xxl),
            ],
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
  final VoidCallback onTap;

  const _ExploreTile(this.text, this.icon, this.color, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(M.rMd),
            ),
            child: Icon(icon, color: color, size: M.iconMd),
          ),
          const Spacer(),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : M.navy),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final String d;
  final String m;
  final String title;
  final String sub;
  final VoidCallback? onTap;

  const _EventRow({
    required this.d,
    required this.m,
    required this.title,
    required this.sub,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: M.sm),
            decoration: BoxDecoration(
              color: M.navy,
              borderRadius: BorderRadius.circular(M.rMd),
            ),
            child: Column(
              children: [
                Text(
                  d,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  m,
                  style: const TextStyle(
                    color: M.lime,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: M.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : M.navy),
                  ),
                ),
                Text(sub, style: M.adaptiveCardBody(context)),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF78909C)
                : M.muted),
            size: 20,
          ),
        ],
      ),
    );
  }
}

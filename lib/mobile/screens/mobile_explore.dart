import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../screens/coach_match_screen.dart';
import '../../screens/devices_screen.dart';
import '../../screens/premium_screen.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileExploreScreen extends StatelessWidget {
  const MobileExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Explore'),
        ),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search plans, events, coaches',
                  prefixIcon: const Icon(Icons.search, size: M.iconMd),
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
                    _ExploreTile('Training plans', Icons.event_note, M.blue, onTap: () => showFeatureMessage(context, 'Training plans are ready to explore.')),
                    _ExploreTile('Find a coach', Icons.groups, M.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoachMatchScreen()))),
                    _ExploreTile('Sports events', Icons.emoji_events, M.orange, onTap: () => _showMessage(context, 'Events are coming to your calendar soon.')),
                    _ExploreTile('My tickets', Icons.confirmation_number, M.teal, onTap: () => _showMessage(context, 'Your event tickets will appear here.')),
                    _ExploreTile('Premium', Icons.workspace_premium, M.navy, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()))),
                    _ExploreTile('Devices', Icons.devices_other, M.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DevicesScreen()))),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Recommended plan',
                action: 'See plans',
                child: MBanner(
                  backgroundColor: M.navy,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.directions_run, color: M.lime, size: M.iconLg),
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
                      const Text('16 weeks  •  Coach Amit',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: M.base),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: M.lime,
                          foregroundColor: M.navy,
                        ),
                        onPressed: () => _showMessage(context, 'Marathon Training Pro has been added to your plans.'),
                        child: const Text('View plan',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Upcoming events',
                action: 'See all',
                child: Column(
                  children: const [
                    _EventRow('25', 'OCT', 'Mumbai Half Marathon',
                        'Mumbai  •  Running'),
                    SizedBox(height: M.sm),
                    _EventRow('20', 'NOV', 'Delhi Cycling Grand Prix',
                        'New Delhi  •  Cycling'),
                  ],
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

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
          Text(text,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: M.navy,
                fontSize: 13,
              )),
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

  const _EventRow(this.d, this.m, this.title, this.sub);

  @override
  Widget build(BuildContext context) {
    return MCard(
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
                Text(d,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    )),
                Text(m,
                    style: const TextStyle(
                      color: M.lime,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    )),
              ],
            ),
          ),
          const SizedBox(width: M.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: M.navy,
                    )),
                Text(sub, style: M.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: M.muted, size: 20),
        ],
      ),
    );
  }
}

class _MobileExplorePreview extends StatelessWidget {
  const _MobileExplorePreview();
  @override
  Widget build(BuildContext context) => const MobileExploreScreen();
}

void main() => runApp(MaterialApp(
  theme: M.theme,
  home: const _MobileExplorePreview(),
));

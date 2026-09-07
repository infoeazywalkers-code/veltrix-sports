import 'package:flutter/material.dart';
import '../../screens/coach_match_screen.dart';
import '../../screens/devices_screen.dart';
import '../../screens/feature_collection_screen.dart';
import '../../screens/premium_screen.dart';
import '../../screens/production_pages.dart';
import '../../screens/strength_screen.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileMoreScreen extends StatelessWidget {
  const MobileMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('More features')),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              const Text(
                'Everything around your training, in one place.',
                style: M.bodyMuted,
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Train with more support',
                child: Column(
                  children: [
                    _MoreFeature(
                      'Premium',
                      'Unlock advanced training tools',
                      Icons.workspace_premium,
                      M.orange,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PremiumScreen(),
                            ),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'Find a coach',
                      'Get guidance matched to your goals',
                      Icons.groups_outlined,
                      M.purple,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CoachMatchScreen(),
                            ),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'Strength',
                      'Build a stronger athletic foundation',
                      Icons.fitness_center,
                      M.teal,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StrengthScreen(),
                            ),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'Training plans',
                      'Browse structured plans for your goal',
                      Icons.event_note,
                      M.blue,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => trainingPlansScreen(),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Connected training',
                child: Column(
                  children: [
                    _MoreFeature(
                      'Devices',
                      'Connect your watch and sensors',
                      Icons.devices_other,
                      M.blue,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DevicesScreen(),
                            ),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'Events',
                      'Find races and challenges',
                      Icons.emoji_events_outlined,
                      M.orange,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => eventsScreen()),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'My tickets',
                      'See event entries and confirmations',
                      Icons.confirmation_number,
                      M.teal,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ticketsScreen()),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'Workout library',
                      'Save and reuse your favorite sessions',
                      Icons.library_books_outlined,
                      M.navy,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => workoutLibraryScreen(),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Operations',
                child: Column(
                  children: [
                    _MoreFeature(
                      'Coach platform',
                      'Manage athletes and training workflows',
                      Icons.dashboard_customize,
                      M.purple,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => coachPlatformScreen(),
                            ),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'Coach resources',
                      'Guides for professional coaching',
                      Icons.menu_book_outlined,
                      M.navy,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => coachResourcesScreen(),
                            ),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'Support center',
                      'Resolve device, billing, and account issues',
                      Icons.support_agent,
                      M.teal,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => supportScreen()),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'Training guides',
                      'Learn planning, racing, and recovery basics',
                      Icons.school_outlined,
                      M.blue,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => trainingGuidesScreen(),
                            ),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'About Veltrix',
                      'Product principles and roadmap direction',
                      Icons.info_outline,
                      M.orange,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => aboutScreen()),
                          ),
                    ),
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

class _MoreFeature extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MoreFeature(
    this.title,
    this.subtitle,
    this.icon,
    this.color, {
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MInfoCard(
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

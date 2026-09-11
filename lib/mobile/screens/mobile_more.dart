import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers.dart';
import '../../widgets/common/role_gate.dart';
import '../../screens/activity/activity_feed_screen.dart';
import '../../screens/challenges/challenges_screen.dart';
import '../../screens/training/training_plan_marketplace_screen.dart';
import '../../screens/coach/coach_match_screen.dart';
import '../../screens/coach/coach_dashboard_screen.dart';
import '../../screens/devices/devices_screen.dart';
import '../../screens/explore/feature_collection_screen.dart';
import '../../screens/premium/premium_screen.dart';
import '../../screens/explore/production_pages.dart';
import '../../screens/training/strength_screen.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileMoreScreen extends ConsumerWidget {
  const MobileMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Coach-only entries are hidden when logged out; non-coach roles get
    // a snackbar instead of navigation (RoleGate defaults to deny).
    final isLoggedIn = ref.watch(authStateProvider).valueOrNull != null;
    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('More features')),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              Text(
                'Everything around your training, in one place.',
                style: M.adaptiveMuted(context),
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
                              builder: (_) => TrainingPlanMarketplaceScreen(),
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
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'Activity Feed',
                      'See what athletes around you are doing',
                      Icons.dynamic_feed,
                      M.teal,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ActivityFeedScreen(),
                            ),
                          ),
                    ),
                    const SizedBox(height: M.sm),
                    _MoreFeature(
                      'Challenges',
                      'Join challenges and climb the leaderboard',
                      Icons.emoji_events_outlined,
                      M.orange,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChallengesScreen(),
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
                    if (isLoggedIn)
                      CoachOnly(
                        child: _MoreFeature(
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
                        fallback: _LockedFeature(
                          context,
                          'Coach platform',
                          'Manage athletes and training workflows',
                          Icons.dashboard_customize,
                          M.purple,
                        ),
                      ),
                    if (isLoggedIn) const SizedBox(height: M.sm),
                    if (isLoggedIn)
                      CoachOnly(
                        child: _MoreFeature(
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
                        fallback: _LockedFeature(
                          context,
                          'Coach resources',
                          'Guides for professional coaching',
                          Icons.menu_book_outlined,
                          M.navy,
                        ),
                      ),
                    if (isLoggedIn) const SizedBox(height: M.sm),
                    if (isLoggedIn)
                      CoachOnly(
                        child: _MoreFeature(
                          'My athletes',
                          'Review assigned athletes and readiness',
                          Icons.groups_outlined,
                          M.purple,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CoachDashboardScreen(),
                                ),
                              ),
                        ),
                        fallback: _LockedFeature(
                          context,
                          'My athletes',
                          'Review assigned athletes and readiness',
                          Icons.groups_outlined,
                          M.purple,
                        ),
                      ),
                    if (isLoggedIn) const SizedBox(height: M.sm),
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

/// Locked coach-only entry: reduced opacity so it does not look fully
/// tappable; tapping shows the access-required snackbar.
Widget _LockedFeature(
  BuildContext context,
  String title,
  String subtitle,
  IconData icon,
  Color color,
) {
  return Opacity(
    opacity: 0.55,
    child: _MoreFeature(
      title,
      subtitle,
      icon,
      color,
      onTap: () => showFeatureMessage(context, 'Coach access required'),
    ),
  );
}

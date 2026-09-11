import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants.dart';
import 'core/errors/error_handler.dart';
import 'widgets/common/brand.dart';
import 'widgets/common/nav_menu.dart';
import 'providers.dart';
import 'services/auth/auth_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/training/calendar_screen.dart';
import 'screens/dashboard/progress_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/premium/premium_screen.dart';
import 'screens/coach/coach_match_screen.dart';
import 'screens/devices/devices_screen.dart';
import 'screens/training/strength_screen.dart';
import 'screens/social/notifications_screen.dart';
import 'screens/explore/feature_collection_screen.dart';
import 'screens/training/training_plan_marketplace_screen.dart';
import 'screens/explore/production_pages.dart';
import 'screens/onboarding/onboarding_flow.dart';

import 'widgets/workout/workout_builder_dialog.dart';
import 'widgets/common/connectivity_banner.dart';
import 'widgets/common/role_gate.dart';

class Shell extends ConsumerStatefulWidget {
  const Shell({super.key});
  @override
  ConsumerState<Shell> createState() => _ShellState();
}

/// Desktop shell destinations in `_buildScreen` order (0..19).
enum ShellPage {
  home,
  calendar,
  progress,
  explore,
  profile,
  premium,
  coachMatch,
  devices,
  strength,
  notifications,
  trainingPlans,
  events,
  tickets,
  workoutLibrary,
  coachPlatform,
  coachResources,
  support,
  trainingGuides,
  about,
  athleteOnboarding,
}

class _ShellState extends ConsumerState<Shell> {
  int page = 0;
  bool _onboardingSkipped = false;
  String? _skipForUid;

  Widget _buildScreen() {
    switch (page) {
      case 0:
        return HomeScreen(onNavigate: go);
      case 1:
        return const CalendarScreen();
      case 2:
        return const ProgressScreen();
      case 3:
        return ExploreScreen(onNavigate: go);
      case 4:
        return ProfileScreen(onNavigateToPremium: () => go(5));
      case 5:
        return const PremiumScreen();
      case 6:
        return const CoachMatchScreen();
      case 7:
        return const DevicesScreen();
      case 8:
        return const StrengthScreen();
      case 9:
        return const NotificationsScreen();
      case 10:
        return TrainingPlanMarketplaceScreen();
      case 11:
        return eventsScreen();
      case 12:
        return ticketsScreen();
      case 13:
        return workoutLibraryScreen();
      case 14:
        return coachPlatformScreen();
      case 15:
        return coachResourcesScreen();
      case 16:
        return supportScreen();
      case 17:
        return trainingGuidesScreen();
      case 18:
        return aboutScreen();
      case 19:
        return athleteOnboardingScreen();
      default:
        return HomeScreen(onNavigate: go);
    }
  }

  void go(int index) => setState(() => page = index);

  void goPage(ShellPage p) => go(p.index);

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1050;
    final currentScreen = _buildScreen();
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.valueOrNull != null;
    final uid = authState.valueOrNull?.uid;
    // A different account signed in -> forget the previous skip decision
    // and reset to Home.
    if (_skipForUid != uid) {
      _skipForUid = uid;
      _onboardingSkipped = false;
      page = ShellPage.home.index;
    }
    final profileAsync = ref.watch(userProfileProvider);
    final onboardingStatus = ref.watch(onboardingStatusProvider);
    // Only treat onboarding as incomplete when definitively known.
    // While loading, keep rendering the current screen with a subtle
    // progress indicator instead of flashing OnboardingFlow.
    final onboardingKnown = onboardingStatus.hasValue;
    final onboardingComplete = onboardingStatus.valueOrNull == 'completed';
    final profileName = profileAsync.valueOrNull?.displayName ?? '';
    final unreadCount =
        ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    if (isLoggedIn &&
        onboardingKnown &&
        !onboardingComplete &&
        !_onboardingSkipped) {
      return OnboardingFlow(
        onComplete: () {
          _skipForUid = uid;
          setState(() => _onboardingSkipped = true);
        },
      );
    }

    // Back on a deep tab goes Home; back on Home with nothing to pop
    // allows exit. Inner pushed routes pop normally (shell scope is only
    // consulted when the shell itself is the top route).
    final innerCanPop = Navigator.of(context).canPop();
    return PopScope(
      canPop: page == ShellPage.home.index || innerCanPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && page != ShellPage.home.index) {
          goPage(ShellPage.home);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: desktop ? 78 : 68,
          backgroundColor: navy,
          foregroundColor: Colors.white,
          // Deep pages (index >= 5) show a back affordance to Home so the
          // bottom bar never falsely implies Profile is selected.
          leading:
              page >= 5
                  ? BackButton(onPressed: () => goPage(ShellPage.home))
                  : null,
          title: Row(
            children: [
              const Brand(),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => goPage(ShellPage.home),
                child: const Text(
                  'VELTRIX',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              if (desktop) ...[
                const SizedBox(width: 36),
                NavMenu(
                  label: 'Athletes',
                  items: const [
                    'Features',
                    'Training Plans',
                    'Find a Coach',
                    'Premium',
                  ],
                  onSelected:
                      (i) => goPage(
                        i == 0
                            ? ShellPage.progress
                            : i == 1
                            ? ShellPage.trainingPlans
                            : i == 2
                            ? ShellPage.coachMatch
                            : ShellPage.premium,
                      ),
                ),
                NavMenu(
                  label: 'Coaches',
                  items: const [
                    'Coach Platform',
                    'Coach Match',
                    'Coach Resources',
                  ],
                  onSelected:
                      (i) => goPage(
                        i == 0
                            ? ShellPage.coachPlatform
                            : i == 1
                            ? ShellPage.coachMatch
                            : ShellPage.coachResources,
                      ),
                ),
                NavMenu(
                  label: 'Training',
                  items: const [
                    'Calendar',
                    'Performance',
                    'Workout Library',
                    'Strength',
                  ],
                  onSelected:
                      (i) => goPage(
                        i == 0
                            ? ShellPage.calendar
                            : i == 1
                            ? ShellPage.progress
                            : i == 2
                            ? ShellPage.workoutLibrary
                            : ShellPage.strength,
                      ),
                ),
                NavMenu(
                  label: 'Connect',
                  items: const ['Devices', 'Events', 'Training Plans'],
                  onSelected:
                      (i) => goPage(
                        i == 0
                            ? ShellPage.devices
                            : i == 1
                            ? ShellPage.events
                            : ShellPage.trainingPlans,
                      ),
                ),
                NavMenu(
                  label: 'Resources',
                  items: const ['Help Center', 'Training Guides', 'About'],
                  onSelected:
                      (i) => goPage(
                        i == 0
                            ? ShellPage.support
                            : i == 1
                            ? ShellPage.trainingGuides
                            : ShellPage.about,
                      ),
                ),
              ],
            ],
          ),
          actions: [
            if (desktop) ...[
              if (isLoggedIn) ...[
                TextButton(
                  onPressed: () => goPage(ShellPage.profile),
                  child: Text(
                    profileName.isNotEmpty ? profileName : 'Profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: lime,
                      foregroundColor: navy,
                    ),
                    onPressed: () async {
                      try {
                        await AuthService().signOut();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ErrorHandler.getUserMessage(e)),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Sign out',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => goPage(ShellPage.profile),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: lime,
                      foregroundColor: navy,
                    ),
                    onPressed: () => goPage(ShellPage.athleteOnboarding),
                    child: const Text(
                      'Get started',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ] else
              IconButton(
                onPressed: () => goPage(ShellPage.notifications),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none_rounded),
                    if (unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        drawer:
            desktop
                ? null
                : Drawer(
                  child: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Row(
                          children: [
                            Brand(),
                            SizedBox(width: 10),
                            Text(
                              'VELTRIX',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 19,
                                color: navy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _drawerItem(
                          ShellPage.home,
                          Icons.home_outlined,
                          'Home',
                        ),
                        _drawerItem(
                          ShellPage.calendar,
                          Icons.calendar_month_outlined,
                          'Calendar',
                        ),
                        _drawerItem(
                          ShellPage.progress,
                          Icons.insights_outlined,
                          'Progress',
                        ),
                        _drawerItem(
                          ShellPage.explore,
                          Icons.explore_outlined,
                          'Explore',
                        ),
                        _drawerItem(
                          ShellPage.profile,
                          Icons.person_outline,
                          'Profile',
                        ),
                        const Divider(height: 32),
                        _drawerItem(
                          ShellPage.premium,
                          Icons.workspace_premium,
                          'Premium',
                        ),
                        _drawerItem(
                          ShellPage.coachMatch,
                          Icons.groups_outlined,
                          'Coach Match',
                        ),
                        _drawerItem(
                          ShellPage.devices,
                          Icons.devices_other,
                          'Devices',
                        ),
                        _drawerItem(
                          ShellPage.strength,
                          Icons.fitness_center,
                          'Strength',
                        ),
                        _drawerItem(
                          ShellPage.notifications,
                          Icons.notifications_none_rounded,
                          'Notifications',
                          badgeCount: unreadCount,
                        ),
                        _drawerItem(
                          ShellPage.trainingPlans,
                          Icons.event_note,
                          'Training plans',
                        ),
                        _drawerItem(
                          ShellPage.events,
                          Icons.emoji_events,
                          'Events',
                        ),
                        _drawerItem(
                          ShellPage.tickets,
                          Icons.confirmation_number,
                          'Tickets',
                        ),
                        _drawerItem(
                          ShellPage.workoutLibrary,
                          Icons.library_books,
                          'Workout library',
                        ),
                        // Coach-only destinations: hidden when logged out;
                        // non-coach roles get a snackbar instead of navigation
                        // (RoleGate defaults to deny on unknown/loading/error).
                        if (isLoggedIn)
                          CoachOnly(
                            child: _drawerItem(
                              ShellPage.coachPlatform,
                              Icons.dashboard_customize,
                              'Coach platform',
                            ),
                            fallback: _disabledDrawerItem(
                              Icons.dashboard_customize,
                              'Coach platform',
                              'Coach access required',
                            ),
                          ),
                        if (isLoggedIn)
                          CoachOnly(
                            child: _drawerItem(
                              ShellPage.coachResources,
                              Icons.menu_book,
                              'Coach resources',
                            ),
                            fallback: _disabledDrawerItem(
                              Icons.menu_book,
                              'Coach resources',
                              'Coach access required',
                            ),
                          ),
                        _drawerItem(
                          ShellPage.support,
                          Icons.support_agent,
                          'Support center',
                        ),
                        _drawerItem(
                          ShellPage.trainingGuides,
                          Icons.school,
                          'Training guides',
                        ),
                        _drawerItem(
                          ShellPage.about,
                          Icons.info_outline,
                          'About Veltrix',
                        ),
                        _drawerItem(
                          ShellPage.athleteOnboarding,
                          Icons.directions_run,
                          'Athlete onboarding',
                        ),
                      ],
                    ),
                  ),
                ),
        body: Column(
          children: [
            if (onboardingStatus.isLoading)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(child: ConnectivityBanner(child: currentScreen)),
          ],
        ),
        floatingActionButton:
            page == ShellPage.calendar.index
                ? FloatingActionButton.extended(
                  backgroundColor: lime,
                  foregroundColor: navy,
                  onPressed:
                      () => showDialog(
                        context: context,
                        builder: (_) => const WorkoutBuilderDialog(),
                      ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add workout',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                )
                : null,
        bottomNavigationBar:
            desktop
                ? null
                : NavigationBar(
                  height: 72,
                  // Deep pages (index >= 5) have no tab: fall back to Home
                  // visually and never falsely highlight Profile. The AppBar
                  // back button is the true affordance for deep pages.
                  selectedIndex: page < 5 ? page : ShellPage.home.index,
                  onDestinationSelected: (i) => goPage(ShellPage.values[i]),
                  indicatorColor: lime,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: 'Calendar',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights),
                      label: 'Progress',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: 'Explore',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _drawerItem(
    ShellPage destination,
    IconData icon,
    String label, {
    int badgeCount = 0,
  }) {
    final isSelected = page == destination.index;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: isSelected,
      selectedTileColor: lime.withValues(alpha: .35),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon),
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      onTap: () {
        Navigator.pop(context);
        goPage(destination);
      },
    );
  }

  /// Disabled drawer entry for gated destinations: reduced opacity so it
  /// does not look fully tappable, but still shows a snackbar on tap.
  Widget _disabledDrawerItem(IconData icon, String label, String message) {
    return Opacity(
      opacity: 0.55,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        trailing: const Icon(Icons.lock_outline, size: 18),
        onTap: () {
          Navigator.pop(context);
          showFeatureMessage(context, message);
        },
      ),
    );
  }
}

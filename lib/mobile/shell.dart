import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'screens/mobile_home.dart';
import 'screens/mobile_calendar.dart';
import 'screens/mobile_progress.dart';
import 'screens/mobile_explore.dart';
import 'screens/mobile_profile.dart';
import 'screens/mobile_more.dart';
import '../models/user/user_preferences.dart';
import '../providers.dart';
import '../screens/social/notifications_screen.dart';
import '../screens/onboarding/onboarding_flow.dart';

class MobileShell extends ConsumerStatefulWidget {
  const MobileShell({super.key});

  @override
  ConsumerState<MobileShell> createState() => _MobileShellState();
}

/// Mobile bottom-tab destinations in `_buildPage` order (0..6).
enum MobileTab {
  home,
  calendar,
  progress,
  explore,
  profile,
  more,
  notifications,
}

class _MobileShellState extends ConsumerState<MobileShell> {
  int _index = 0;
  bool _onboardingSkipped = false;
  String? _skipForUid;

  Widget _buildPage() {
    switch (_index) {
      case 0:
        return const MobileHomeScreen();
      case 1:
        return const MobileCalendarScreen();
      case 2:
        return const MobileProgressScreen();
      case 3:
        return const MobileExploreScreen();
      case 4:
        return const MobileProfileScreen();
      case 5:
        return const MobileMoreScreen();
      case 6:
        return const NotificationsScreen();
      default:
        return const MobileHomeScreen();
    }
  }

  void _navigateToScreen(int index) {
    setState(() => _index = index);
  }

  void _goTab(MobileTab tab) => _navigateToScreen(tab.index);

  @override
  Widget build(BuildContext context) {
    final themeModePref = ref.watch(themeModeProvider);
    final isDark =
        themeModePref == ThemeModePreference.dark ||
        (themeModePref == ThemeModePreference.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final unreadCount =
        ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.valueOrNull != null;
    final uid = authState.valueOrNull?.uid;
    // A different account signed in -> forget the previous skip decision
    // and reset to Home.
    if (_skipForUid != uid) {
      _skipForUid = uid;
      _onboardingSkipped = false;
      _index = MobileTab.home.index;
    }
    final onboardingStatus = ref.watch(onboardingStatusProvider);
    // Only treat onboarding as incomplete when definitively known.
    // While loading, keep rendering the current screen with a subtle
    // progress indicator instead of flashing OnboardingFlow.
    final onboardingKnown = onboardingStatus.hasValue;
    final onboardingComplete = onboardingStatus.valueOrNull == 'completed';

    if (isLoggedIn &&
        onboardingKnown &&
        !onboardingComplete &&
        !_onboardingSkipped) {
      return Theme(
        data: isDark ? M.darkTheme : M.lightTheme,
        child: OnboardingFlow(
          onComplete: () {
            _skipForUid = uid;
            setState(() => _onboardingSkipped = true);
          },
        ),
      );
    }

    // Back on a deep tab goes Home; back on Home with nothing to pop
    // allows exit. Inner pushed routes pop normally (shell scope is only
    // consulted when the shell itself is the top route).
    final innerCanPop = Navigator.of(context).canPop();
    return Theme(
      data: isDark ? M.darkTheme : M.lightTheme,
      child: PopScope(
        canPop: _index == MobileTab.home.index || innerCanPop,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _index != MobileTab.home.index) {
            _goTab(MobileTab.home);
          }
        },
        child: Scaffold(
          // Deep tabs (More/Notifications, index >= 5) get an AppBar back
          // affordance to Home so the bottom bar never falsely highlights
          // Profile.
          appBar:
              _index >= MobileTab.more.index
                  ? AppBar(
                    leading: BackButton(
                      onPressed: () => _goTab(MobileTab.home),
                    ),
                    title: Text(
                      _index == MobileTab.more.index
                          ? 'More features'
                          : 'Notifications',
                    ),
                  )
                  : null,
          body: Column(
            children: [
              if (onboardingStatus.isLoading)
                const LinearProgressIndicator(minHeight: 2),
              Expanded(child: _buildPage()),
            ],
          ),
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  M.pageH,
                  M.lg,
                  M.pageH,
                  M.lg,
                ),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: M.navy,
                        child: Text(
                          'V',
                          style: TextStyle(
                            color: M.lime,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: M.md),
                      Text(
                        'VELTRIX',
                        style: TextStyle(
                          color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : M.navy),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: M.xl),
                  const Text('YOUR TRAINING', style: M.badge),
                  const SizedBox(height: M.sm),
                  _drawerItem(MobileTab.home, Icons.home_outlined, 'Home'),
                  _drawerItem(
                    MobileTab.calendar,
                    Icons.calendar_month_outlined,
                    'Calendar',
                  ),
                  _drawerItem(
                    MobileTab.progress,
                    Icons.insights_outlined,
                    'Progress',
                  ),
                  _drawerItem(
                    MobileTab.explore,
                    Icons.explore_outlined,
                    'Explore',
                  ),
                  _drawerItem(
                    MobileTab.profile,
                    Icons.person_outline,
                    'Profile',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: M.md),
                    child: Divider(),
                  ),
                  const Text('VELTRIX NETWORK', style: M.badge),
                  const SizedBox(height: M.sm),
                  _drawerItem(
                    MobileTab.more,
                    Icons.grid_view_rounded,
                    'More features',
                  ),
                  _drawerItem(
                    MobileTab.notifications,
                    Icons.notifications_none_rounded,
                    'Notifications',
                    badgeCount: unreadCount,
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            height: M.navBarHeight,
            // Deep tabs have no bottom-bar destination: never falsely
            // highlight Profile; fall back to Home visually.
            selectedIndex: _index < 5 ? _index : MobileTab.home.index,
            onDestinationSelected: (i) => _goTab(MobileTab.values[i]),
            indicatorColor: M.lime,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
      ),
    );
  }

  Widget _drawerItem(
    MobileTab tab,
    IconData icon,
    String label, {
    int badgeCount = 0,
  }) {
    final selected = _index == tab.index;
    return ListTile(
      selected: selected,
      selectedTileColor: M.lime.withValues(alpha: .35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(M.rMd)),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: selected ? M.navy : M.muted),
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
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w800, color: (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFB0BEC5) : M.ink)),
      ),
      onTap: () {
        Navigator.pop(context);
        _goTab(tab);
      },
    );
  }
}

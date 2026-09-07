import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'screens/mobile_home.dart';
import 'screens/mobile_calendar.dart';
import 'screens/mobile_progress.dart';
import 'screens/mobile_explore.dart';
import 'screens/mobile_profile.dart';
import 'screens/mobile_more.dart';
import '../screens/notifications_screen.dart';

class MobileShell extends ConsumerStatefulWidget {
  const MobileShell({super.key});

  @override
  ConsumerState<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends ConsumerState<MobileShell> {
  int _index = 0;

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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: M.theme,
      child: Scaffold(
        body: _buildPage(),
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(M.pageH, M.lg, M.pageH, M.lg),
              children: [
                const Row(
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
                        color: M.navy,
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
                _drawerItem(0, Icons.home_outlined, 'Home'),
                _drawerItem(1, Icons.calendar_month_outlined, 'Calendar'),
                _drawerItem(2, Icons.insights_outlined, 'Progress'),
                _drawerItem(3, Icons.explore_outlined, 'Explore'),
                _drawerItem(4, Icons.person_outline, 'Profile'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: M.md),
                  child: Divider(),
                ),
                const Text('VELTRIX NETWORK', style: M.badge),
                const SizedBox(height: M.sm),
                _drawerItem(5, Icons.grid_view_rounded, 'More features'),
                _drawerItem(
                  6,
                  Icons.notifications_none_rounded,
                  'Notifications',
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          height: M.navBarHeight,
          selectedIndex: _index < 5 ? _index : 4,
          onDestinationSelected: (i) => _navigateToScreen(i),
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
    );
  }

  Widget _drawerItem(int index, IconData icon, String label) {
    final selected = _index == index;
    return ListTile(
      selected: selected,
      selectedTileColor: M.lime.withValues(alpha: .35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(M.rMd)),
      leading: Icon(icon, color: selected ? M.navy : M.muted),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800, color: M.ink),
      ),
      onTap: () {
        Navigator.pop(context);
        _navigateToScreen(index);
      },
    );
  }
}

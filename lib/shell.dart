import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../widgets/brand.dart';
import '../widgets/nav_menu.dart';
import '../providers.dart';
import '../auth_service.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/premium_screen.dart';
import '../screens/coach_match_screen.dart';
import '../screens/devices_screen.dart';
import '../screens/strength_screen.dart';

import '../widgets/workout_builder_dialog.dart';

class Shell extends ConsumerStatefulWidget {
  const Shell({super.key});
  @override
  ConsumerState<Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<Shell> {
  int page = 0;

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
      default:
        return HomeScreen(onNavigate: go);
    }
  }

  void go(int index) => setState(() => page = index);

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1050;
    final currentScreen = _buildScreen();
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.valueOrNull != null;
    final profileAsync = ref.watch(userProfileProvider);
    final profileName = profileAsync.valueOrNull?.displayName ?? '';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: desktop ? 78 : 68,
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Brand(),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => go(0),
              child: const Text(
                'VELTRIX',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
            if (desktop) ...[
              const SizedBox(width: 36),
              NavMenu(
                label: 'Athletes',
                items: const ['Features', 'Training Plans', 'Find a Coach', 'Premium'],
                onSelected: (i) => go(i == 0 ? 2 : i == 1 ? 3 : i == 2 ? 6 : 5),
              ),
              NavMenu(
                label: 'Coaches',
                items: const ['Coach Platform', 'Coach Match', 'Coach Resources'],
                onSelected: (i) => go(i == 1 ? 6 : 3),
              ),
              NavMenu(
                label: 'Training',
                items: const ['Calendar', 'Performance', 'Workout Library', 'Strength'],
                onSelected: (i) => go(i == 0 ? 1 : i == 1 ? 2 : i == 2 ? 3 : 8),
              ),
              NavMenu(
                label: 'Connect',
                items: const ['Devices', 'Events', 'Training Plans'],
                onSelected: (i) => go(i == 0 ? 7 : i == 1 ? 3 : 3),
              ),
              NavMenu(
                label: 'Resources',
                items: const ['Help Center', 'Training Guides', 'About'],
                onSelected: (_) => go(4),
              ),
            ],
          ],
        ),
        actions: [
          if (desktop) ...[
            if (isLoggedIn) ...[
              TextButton(
                onPressed: () => go(4),
                child: Text(
                  profileName.isNotEmpty ? profileName : 'Profile',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: navy),
                  onPressed: () => AuthService().signOut(),
                  child: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ] else ...[
              TextButton(
                onPressed: () => go(4),
                child: const Text('Log in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: navy),
                  onPressed: () => go(3),
                  child: const Text('Get started', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ] else
            IconButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (_) => const _Notices(),
              ),
              icon: const Badge(child: Icon(Icons.notifications_none_rounded)),
            ),
        ],
      ),
      drawer: desktop
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
                        Text('VELTRIX', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: navy)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _drawerItem(0, Icons.home_outlined, 'Home'),
                    _drawerItem(1, Icons.calendar_month_outlined, 'Calendar'),
                    _drawerItem(2, Icons.insights_outlined, 'Progress'),
                    _drawerItem(3, Icons.explore_outlined, 'Explore'),
                    _drawerItem(4, Icons.person_outline, 'Profile'),
                    const Divider(height: 32),
                    _drawerItem(5, Icons.workspace_premium, 'Premium'),
                    _drawerItem(6, Icons.groups_outlined, 'Coach Match'),
                    _drawerItem(7, Icons.devices_other, 'Devices'),
                    _drawerItem(8, Icons.fitness_center, 'Strength'),
                  ],
                ),
              ),
            ),
      body: currentScreen,
      floatingActionButton: page == 1
          ? FloatingActionButton.extended(
              backgroundColor: lime,
              foregroundColor: navy,
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const WorkoutBuilderDialog(),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add workout', style: TextStyle(fontWeight: FontWeight.w900)),
            )
          : null,
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              height: 72,
              selectedIndex: page < 5 ? page : 4,
              onDestinationSelected: (i) => setState(() => page = i),
              indicatorColor: lime,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
                NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progress'),
                NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
    );
  }

  Widget _drawerItem(int index, IconData icon, String label) {
    final isSelected = page == index;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: isSelected,
      selectedTileColor: lime.withValues(alpha: .35),
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      onTap: () {
        Navigator.pop(context);
        go(index);
      },
    );
  }
}

class _Notices extends StatelessWidget {
  const _Notices();
  @override
  Widget build(BuildContext context) => const SafeArea(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: navy)),
          SizedBox(height: 12),
          _NoticeItem(Icons.event_available, blue, 'Workout ready', 'Your aerobic run is scheduled for 7:00 AM.'),
          SizedBox(height: 9),
          _NoticeItem(Icons.chat_bubble_outline, purple, 'Coach Priya commented', 'Strong work on the intervals.'),
        ],
      ),
    ),
  );
}

class _NoticeItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, body;
  const _NoticeItem(this.icon, this.color, this.title, this.body);
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: navy)),
      subtitle: Text(body, style: const TextStyle(fontSize: 11)),
    ),
  );
}


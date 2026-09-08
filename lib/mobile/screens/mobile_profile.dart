import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_service.dart';
import '../../providers.dart';
import '../../screens/premium_screen.dart';
import '../../screens/profile_edit_screen.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';
import 'mobile_settings.dart';

class MobileProfileScreen extends ConsumerWidget {
  const MobileProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Profile')),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              profileAsync.when(
                loading:
                    () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: M.xl),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                error:
                    (e, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: M.xl),
                      child: Center(
                        child: Text(
                          'Error loading profile: $e',
                          style: M.bodyMuted,
                        ),
                      ),
                    ),
                data: (profile) {
                  if (profile == null) {
                    return MCard(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: M.navy,
                            size: 48,
                          ),
                          const SizedBox(height: M.sm),
                          const Text(
                            'Welcome to Veltrix Sports',
                            style: M.cardTitle,
                          ),
                          const SizedBox(height: M.xs),
                          const Text(
                            'Sign in to access your training plan, settings, and performance data.',
                            textAlign: TextAlign.center,
                            style: M.bodyMuted,
                          ),
                          const SizedBox(height: M.md),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: M.lime,
                              foregroundColor: M.navy,
                            ),
                            onPressed: () async {
                              await AuthService().signInWithGoogle();
                            },
                            icon: const Icon(Icons.login),
                            label: const Text(
                              'Sign in with Google',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final name = profile.displayName;
                  final sports =
                      profile.sports.isNotEmpty == true
                          ? profile.sports.join(' • ')
                          : 'No sports set';
                  final initials =
                      name
                          .split(' ')
                          .map((w) => w.isNotEmpty ? w[0] : '')
                          .take(2)
                          .join()
                          .toUpperCase();
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: M.navy,
                        backgroundImage:
                            profile.photoUrl != null &&
                                    profile.photoUrl!.isNotEmpty
                                ? NetworkImage(profile.photoUrl!)
                                : null,
                        child:
                            profile.photoUrl == null
                                ? Text(
                                  initials,
                                  style: const TextStyle(
                                    color: M.lime,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(width: M.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: M.navy,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(sports, style: M.bodyMuted),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileEditScreen(),
                              ),
                            ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: M.lg),
              MCard(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PremiumScreen()),
                    ),
                color: const Color(0xFFEAF2F8),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: M.blue),
                    const SizedBox(width: M.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Veltrix Premium',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: M.navy,
                            ),
                          ),
                          Text(
                            profileAsync.valueOrNull?.subscriptionRenewsAt !=
                                    null
                                ? 'Renews ${profileAsync.valueOrNull!.subscriptionRenewsAt!.day} ${_monthName(profileAsync.valueOrNull!.subscriptionRenewsAt!.month)} ${profileAsync.valueOrNull!.subscriptionRenewsAt!.year}'
                                : 'No active subscription',
                            style: M.caption,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: M.muted),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Account',
                child: _SettingsGroup(
                  onSelect: (item) {
                    if (item == 'Settings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MobileSettingsScreen(),
                        ),
                      );
                    } else {
                      _showMessage(context, '$item settings opened.');
                    }
                  },
                  items: const [
                    ('Personal details', Icons.person_outline),
                    ('Training zones', Icons.tune),
                    ('Apps & devices', Icons.devices),
                    ('Equipment', Icons.sports),
                    ('Settings', Icons.settings_outlined),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Support',
                child: _SettingsGroup(
                  onSelect:
                      (item) =>
                          _showMessage(context, '$item is ready to help.'),
                  items: const [
                    ('Help center', Icons.help_outline),
                    ('Contact support', Icons.chat_bubble_outline),
                    ('About Veltrix', Icons.info_outline),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              OutlinedButton(
                onPressed:
                    () => showDialog<void>(
                      context: context,
                      builder:
                          (dialogContext) => AlertDialog(
                            title: const Text('Sign out?'),
                            content: const Text(
                              'You can sign back in at any time.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  await AuthService().signOut();
                                  _showMessage(
                                    context,
                                    'You have been signed out.',
                                  );
                                },
                                child: const Text('Sign out'),
                              ),
                            ],
                          ),
                    ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(M.touchTarget),
                ),
                child: const Text(
                  'Sign out',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: M.xxl),
            ],
          ),
        ),
      ],
    );
  }

  String _monthName(int m) =>
      [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][m - 1];
}

class _SettingsGroup extends StatelessWidget {
  final List<(String, IconData)> items;
  final ValueChanged<String> onSelect;

  const _SettingsGroup({required this.items, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return MCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(
          items.length,
          (i) => Column(
            children: [
              ListTile(
                leading: Icon(items[i].$2, color: M.navy),
                title: Text(
                  items[i].$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: M.muted,
                  size: 20,
                ),
                onTap: () => onSelect(items[i].$1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: M.base,
                  vertical: 2,
                ),
                minVerticalPadding: 0,
              ),
              if (i < items.length - 1) const Divider(height: 1, indent: 52),
            ],
          ),
        ),
      ),
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

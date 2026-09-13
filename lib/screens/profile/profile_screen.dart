import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/errors/error_handler.dart';
import '../../models/user/user_profile.dart';
import '../../widgets/common/heading.dart';
import '../../providers.dart';
import '../../services/auth/auth_service.dart';

import 'profile_edit_screen.dart';
import '../athletes/athlete_card_actions.dart';
import '../athletes/widgets/achievements_row.dart';
import '../analytics/zones_screen.dart';
import '../devices/devices_screen.dart';
import '../explore/production_pages.dart';
import '../gear/gear_vault_screen.dart';
import '../settings/help_support_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToPremium;
  const ProfileScreen({super.key, this.onNavigateToPremium});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth state is the source of truth for "signed in". The Firestore
    // profile doc may be missing (provisioning failed/offline) — still show
    // the profile UI from auth data and keep Sign out reachable.
    final authUser = ref.watch(currentUserProvider);
    if (authUser == null) {
      return _buildSignedOutPrompt(context);
    }

    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: navy)),
      error: (e, _) =>
          _buildProfileContent(context, ref, authUser, null, loadError: true),
      data: (profile) => _buildProfileContent(context, ref, authUser, profile),
    );
  }

  Widget _buildSignedOutPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              color: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : navy),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to Veltrix Sports',
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : navy),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in with Google to save workouts, connect devices, and track your progress.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF78909C)
                    : muted),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: lime,
                foregroundColor: navy,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
              ),
              onPressed: () async {
                try {
                  await AuthService().signInWithGoogle();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ErrorHandler.getUserMessage(e))),
                    );
                  }
                }
              },
              icon: const Icon(Icons.login),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _retryProvision(WidgetRef ref, User authUser) async {
    // Recreate the minimal profile doc if provisioning failed, then refresh.
    try {
      final existing = await ref.read(userServiceProvider).get(authUser.uid);
      if (existing == null) {
        final name = (authUser.displayName?.isNotEmpty == true)
            ? authUser.displayName!
            : 'Athlete';
        await ref
            .read(userServiceProvider)
            .create(
              UserProfile(
                id: authUser.uid,
                email: authUser.email ?? '',
                displayName: name,
                photoUrl: authUser.photoURL,
                role: UserRole.athlete,
                createdAt: DateTime.now(),
              ),
            );
      }
    } catch (_) {}
    ref.invalidate(userProfileProvider);
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    User authUser,
    UserProfile? profile, {
    bool loadError = false,
  }) {
    final displayName = (profile?.displayName.isNotEmpty == true)
        ? profile!.displayName
        : (authUser.displayName?.isNotEmpty == true)
        ? authUser.displayName!
        : 'Athlete';
    final photoUrl = profile?.photoUrl ?? authUser.photoURL;
    final email = profile?.email.isNotEmpty == true
        ? profile!.email
        : (authUser.email ?? '');
    final initials = displayName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    final sports = profile?.sports ?? const <String>[];
    final sportsLabel = sports.isEmpty
        ? 'No sports added'
        : sports.join(' \u2022 ');
    final renewsAt = profile?.subscriptionRenewsAt;
    final renewsText = renewsAt != null
        ? 'Renews ${renewsAt.day} ${monthName(renewsAt.month)} ${renewsAt.year}'
        : 'No active subscription';

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        if (profile == null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfffff7e6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xfff0c36d)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sync_problem, color: Color(0xff9a6a00)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loadError
                        ? 'Profile failed to load. Signed in as $email.'
                        : 'Finishing profile setup for $email.',
                    style: const TextStyle(
                      color: Color(0xff7a5200),
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _retryProvision(ref, authUser),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: navy,
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null || photoUrl.isEmpty
                  ? Text(
                      initials.isNotEmpty ? initials : 'A',
                      style: const TextStyle(
                        color: lime,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : navy),
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    sportsLabel,
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF78909C)
                          : muted),
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: TextStyle(
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF78909C)
                            : muted),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 22),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onNavigateToPremium,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0F2030)
                    : const Color(0xffeaf2f8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, color: blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Veltrix Premium',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : navy),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            renewsText,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF78909C)
                  : muted),
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 22),
        const _SelfPrCard(),
        const SizedBox(height: 16),
        const AchievementsRow(),
        const SizedBox(height: 22),
        const SectionHeading('Account'),
        const SizedBox(height: 9),
        const _Settings([
          ('Personal details', Icons.person_outline),
          ('Training zones', Icons.tune),
          ('Apps & devices', Icons.devices),
          ('Equipment', Icons.sports),
          ('Athlete card', Icons.people_outline),
          ('Settings', Icons.settings_outlined),
        ]),
        const SizedBox(height: 20),
        const SectionHeading('Support'),
        const SizedBox(height: 9),
        const _Settings([
          ('Help center', Icons.help_outline),
          ('Contact support', Icons.chat_bubble_outline),
          ('About Veltrix', Icons.info_outline),
        ]),
        const SizedBox(height: 18),
        OutlinedButton(
          onPressed: () async {
            try {
              await AuthService().signOut();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ErrorHandler.getUserMessage(e))),
                );
              }
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text(
            'Sign out',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _SelfPrCard extends ConsumerWidget {
  const _SelfPrCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prAsync = ref.watch(personalBestsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal bests',
              style: TextStyle(
                color: isDark ? Colors.white : navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            prAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, _) => const _SelfPrRow('Best 5K', 'No PR yet'),
              data: (pr) => Column(
                children: [
                  _SelfPrRow('Best 5K pace', pr.best5kPace),
                  const SizedBox(height: 8),
                  _SelfPrRow('Best 20-min power', pr.best20MinPower),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelfPrRow extends StatelessWidget {
  final String label;
  final String value;

  const _SelfPrRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFF78909C) : muted,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : navy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Settings extends ConsumerWidget {
  final List<(String, IconData)> items;
  const _Settings(this.items);
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: Column(
      children: List.generate(items.length, (i) {
        final tile = ListTile(
          leading: Icon(
            items[i].$2,
            color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : navy),
          ),
          title: Text(
            items[i].$1,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF78909C)
                : muted),
          ),
          onTap: () => _open(context, ref, items[i].$1),
        );
        return Column(
          children: [
            tile,
            if (i < items.length - 1) const Divider(height: 1, indent: 55),
          ],
        );
      }),
    ),
  );

  void _open(BuildContext context, WidgetRef ref, String title) {
    switch (title) {
      case 'Personal details':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
        );
      case 'Training zones':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ZonesScreen(stats: null)),
        );
      case 'Apps & devices':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DevicesScreen()),
        );
      case 'Equipment':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GearVaultScreen()),
        );
      case 'Athlete card':
        publishAndOpenAthleteCard(context, ref);
      case 'Settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
      case 'Help center':
      case 'Contact support':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
        );
      case 'About Veltrix':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => aboutScreen()),
        );
    }
  }
}

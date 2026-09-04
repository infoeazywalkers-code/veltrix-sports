import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../widgets/heading.dart';
import '../providers.dart';
import '../auth_service.dart';

import '../widgets/edit_profile_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToPremium;
  const ProfileScreen({super.key, this.onNavigateToPremium});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: navy)),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text('Failed to load profile', style: TextStyle(color: muted)),
          ],
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, color: navy, size: 64),
                  const SizedBox(height: 16),
                  const Text('Welcome to Veltrix Sports', style: TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('Sign in with Google to save workouts, connect devices, and track your progress.', textAlign: TextAlign.center, style: TextStyle(color: muted)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: lime,
                      foregroundColor: navy,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    ),
                    onPressed: () async {
                      await AuthService().signInWithGoogle();
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
          );
        }

        final initials = profile.displayName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
        final sportsLabel = profile.sports.isEmpty ? 'No sports added' : profile.sports.join(' \u2022 ');
        final renewsText = profile.subscriptionRenewsAt != null
            ? 'Renews ${profile.subscriptionRenewsAt!.day} ${_month(profile.subscriptionRenewsAt!.month)} ${profile.subscriptionRenewsAt!.year}'
            : 'No active subscription';

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: navy,
                  backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                      ? NetworkImage(profile.photoUrl!)
                      : null,
                  child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                      ? Text(initials, style: const TextStyle(color: lime, fontSize: 20, fontWeight: FontWeight.w900))
                      : null,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.displayName, style: const TextStyle(color: navy, fontSize: 21, fontWeight: FontWeight.w900)),
                      Text(sportsLabel, style: const TextStyle(color: muted)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => EditProfileDialog(currentProfile: profile),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onNavigateToPremium,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: const Color(0xffeaf2f8), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: const [
                    Icon(Icons.workspace_premium, color: blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Veltrix Premium', style: TextStyle(fontWeight: FontWeight.w900, color: navy)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(renewsText, style: const TextStyle(color: muted, fontSize: 11)),
            ),
            const SizedBox(height: 22),
            const SectionHeading('Account'),
            const SizedBox(height: 9),
            const _Settings([
              ('Personal details', Icons.person_outline),
              ('Training zones', Icons.tune),
              ('Apps & devices', Icons.devices),
              ('Equipment', Icons.sports),
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
                await AuthService().signOut();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  String _month(int m) => ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m];
}



class _Settings extends StatelessWidget {
  final List<(String, IconData)> items;
  const _Settings(this.items);
  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: List.generate(
        items.length,
        (i) => Column(
          children: [
            ListTile(
              leading: Icon(items[i].$2, color: navy),
              title: Text(items[i].$1, style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: const Icon(Icons.chevron_right, color: muted),
            ),
            if (i < items.length - 1) const Divider(height: 1, indent: 55),
          ],
        ),
      ),
    ),
  );
}

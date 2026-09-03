import 'package:flutter/material.dart';
import '../../screens/premium_screen.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileProfileScreen extends StatelessWidget {
  const MobileProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Profile'),
        ),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: M.navy,
                    child: Text('AS',
                        style: TextStyle(
                          color: M.lime,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                  const SizedBox(width: M.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Arjun Sharma',
                            style: TextStyle(
                              color: M.navy,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            )),
                        Text('Runner • Cyclist', style: M.bodyMuted),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showMessage(context, 'Profile editing is ready for your training details.'),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              const SizedBox(height: M.lg),
              MCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
                color: const Color(0xFFEAF2F8),
                child: const Row(
                  children: [
                    Icon(Icons.workspace_premium, color: M.blue),
                    SizedBox(width: M.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Veltrix Premium',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: M.navy,
                              )),
                          Text('Renews 18 September 2026',
                              style: M.caption),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: M.muted),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Account',
                child: _SettingsGroup(
                  onSelect: (item) => _showMessage(context, '$item settings opened.'),
                  items: const [
                    ('Personal details', Icons.person_outline),
                    ('Training zones', Icons.tune),
                    ('Apps & devices', Icons.devices),
                    ('Equipment', Icons.sports),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Support',
                child: _SettingsGroup(
                  onSelect: (item) => _showMessage(context, '$item is ready to help.'),
                  items: const [
                    ('Help center', Icons.help_outline),
                    ('Contact support', Icons.chat_bubble_outline),
                    ('About Veltrix', Icons.info_outline),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              OutlinedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Sign out?'),
                    content: const Text('You can sign back in at any time.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                      FilledButton(onPressed: () { Navigator.pop(dialogContext); _showMessage(context, 'You have been signed out.'); }, child: const Text('Sign out')),
                    ],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(M.touchTarget),
                ),
                child: const Text('Sign out',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: M.xxl),
            ],
          ),
        ),
      ],
    );
  }
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
                title: Text(items[i].$1,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing:
                    const Icon(Icons.chevron_right, color: M.muted, size: 20),
                onTap: () => onSelect(items[i].$1),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: M.base, vertical: 2),
                minVerticalPadding: 0,
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 52),
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

class _MobileProfilePreview extends StatelessWidget {
  const _MobileProfilePreview();
  @override
  Widget build(BuildContext context) => const MobileProfileScreen();
}

void main() => runApp(MaterialApp(
  theme: M.theme,
  home: const _MobileProfilePreview(),
));

import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/heading.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onNavigateToPremium;
  const ProfileScreen({super.key, this.onNavigateToPremium});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: navy,
            child: Text('AS', style: TextStyle(color: lime, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Arjun Sharma', style: TextStyle(color: navy, fontSize: 21, fontWeight: FontWeight.w900)),
                Text('Runner \u2022 Cyclist', style: TextStyle(color: muted)),
              ],
            ),
          ),
          Icon(Icons.edit_outlined),
        ],
      ),
      const SizedBox(height: 22),
      GestureDetector(
        onTap: onNavigateToPremium,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: const Color(0xffeaf2f8), borderRadius: BorderRadius.circular(16)),
          child: const Row(
            children: [
              Icon(Icons.workspace_premium, color: blue),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Veltrix Premium', style: TextStyle(fontWeight: FontWeight.w900, color: navy)),
                    Text('Renews 18 September 2026', style: TextStyle(color: muted, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
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
        onPressed: () => showFeatureMessage(context, 'Profile editing is ready for your training details.'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          minimumSize: const Size.fromHeight(50),
        ),
        child: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    ],
  );
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(body: ProfileScreen()),
));

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

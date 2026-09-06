import 'package:flutter/material.dart';
import '../../screens/coach_match_screen.dart';
import '../../screens/devices_screen.dart';
import '../../screens/premium_screen.dart';
import '../../screens/strength_screen.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileMoreScreen extends StatelessWidget {
  const MobileMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          title: Text('More features'),
        ),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              const Text(
                'Everything around your training, in one place.',
                style: M.bodyMuted,
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Train with more support',
                child: Column(
                  children: [
                    _MoreFeature('Premium', 'Unlock advanced training tools', Icons.workspace_premium, M.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()))),
                    const SizedBox(height: M.sm),
                    _MoreFeature('Find a coach', 'Get guidance matched to your goals', Icons.groups_outlined, M.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoachMatchScreen()))),
                    const SizedBox(height: M.sm),
                    _MoreFeature('Strength', 'Build a stronger athletic foundation', Icons.fitness_center, M.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StrengthScreen()))),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Connected training',
                child: Column(
                  children: [
                    _MoreFeature('Devices', 'Connect your watch and sensors', Icons.devices_other, M.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DevicesScreen()))),
                    const SizedBox(height: M.sm),
                    _MoreFeature('Workout library', 'Save and reuse your favorite sessions', Icons.library_books_outlined, M.navy, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout library feature coming soon!')))),
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

  const _MoreFeature(this.title, this.subtitle, this.icon, this.color, {required this.onTap});

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
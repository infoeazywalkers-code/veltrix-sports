import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileMoreScreen extends StatelessWidget {
  const MobileMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('More features'),
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
                  children: const [
                    _MoreFeature('Premium', 'Unlock advanced training tools', Icons.workspace_premium, M.orange),
                    SizedBox(height: M.sm),
                    _MoreFeature('Find a coach', 'Get guidance matched to your goals', Icons.groups_outlined, M.purple),
                    SizedBox(height: M.sm),
                    _MoreFeature('Strength', 'Build a stronger athletic foundation', Icons.fitness_center, M.teal),
                  ],
                ),
              ),
              const SizedBox(height: M.lg),
              MSection(
                title: 'Connected training',
                child: Column(
                  children: const [
                    _MoreFeature('Devices', 'Connect your watch and sensors', Icons.devices_other, M.blue),
                    SizedBox(height: M.sm),
                    _MoreFeature('Workout library', 'Save and reuse your favorite sessions', Icons.library_books_outlined, M.navy),
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

  const _MoreFeature(this.title, this.subtitle, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return MInfoCard(
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: subtitle,
      onTap: () {},
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../auth_service.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';
import '../widgets/mobile_stat_ring.dart';
import '../widgets/mobile_workout_card.dart';

class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 64,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: M.pageH, bottom: 14),
            title: Text(
              'VELTRIX',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Badge(
                child: Icon(Icons.notifications_none_rounded),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: M.pagePadding(context),
          sliver: SliverList.list(
            children: [
              Text(
                'Your complete\ntraining platform.',
                style: M.screenTitle.copyWith(fontSize: 32),
              ),
              const SizedBox(height: M.sm),
              const Text(
                'Built for athletes who want more from every session.',
                style: M.bodyMuted,
              ),
              const SizedBox(height: M.lg),
              Wrap(
                spacing: M.sm,
                runSpacing: M.sm,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: M.lime,
                      foregroundColor: M.navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: M.base,
                        vertical: M.md,
                      ),
                    ),
                    onPressed: () async {
                      final authService = AuthService();
                      final user = await authService.signInWithGoogle();
                      if (user != null) {
                        // Handle successful sign-in
                        // You could navigate to a different screen or update state
                        if (kDebugMode) {
                          print('User signed in: ${user.displayName}');
                        }
                      }
                    },
                    child: const Text('Athlete sign up',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: M.navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: M.base,
                        vertical: M.md,
                      ),
                    ),
                    onPressed: () async {
                      final authService = AuthService();
                      final user = await authService.signInWithGoogle();
                      if (user != null) {
                        // Handle successful sign-in
                        // You could navigate to a different screen or update state
                        if (kDebugMode) {
                          print('User signed in: ${user.displayName}');
                        }
                      }
                    },
                    child: const Text('Coach sign up',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),

              const SizedBox(height: M.xl),
              const MDivider(label: 'YOUR TRAINING TODAY'),
              const SizedBox(height: M.lg),

              MBanner(
                backgroundColor: M.navy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: M.sm,
                            vertical: M.xs,
                          ),
                          decoration: BoxDecoration(
                            color: M.lime,
                            borderRadius: BorderRadius.circular(M.rSm),
                          ),
                          child: const Text(
                            'A RACE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: M.navy,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: M.base),
                    const Text(
                      'Mumbai Half Marathon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: M.xs),
                    const Text(
                      '25 October 2026  •  21.1 km',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: M.base),
                    const LinearProgressIndicator(
                      value: 0.62,
                      minHeight: 6,
                      color: M.lime,
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(height: M.sm),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plan progress',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        Text('62%',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: M.lg),
              MSection(
                title: 'Today\'s training',
                action: 'View week',
                child: const MWorkoutCard(
                  sport: 'RUN',
                  title: 'Aerobic endurance',
                  details: '45 min  •  7.2 km  •  62 TSS',
                  color: M.blue,
                  icon: Icons.directions_run_rounded,
                  progress: 0.68,
                ),
              ),

              const SizedBox(height: M.lg),
              MSection(
                title: 'Training status',
                action: 'Details',
                child: MCard(
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          MStatRing(
                            value: '54',
                            label: 'Fitness',
                            color: M.blue,
                            progress: 0.72,
                          ),
                          MStatRing(
                            value: '61',
                            label: 'Fatigue',
                            color: M.purple,
                            progress: 0.81,
                          ),
                          MStatRing(
                            value: '-7',
                            label: 'Form',
                            color: M.orange,
                            progress: 0.46,
                          ),
                        ],
                      ),
                      const SizedBox(height: M.base),
                      Container(
                        padding: const EdgeInsets.all(M.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7EC),
                          borderRadius: BorderRadius.circular(M.rMd),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.trending_up,
                                color: Color(0xFF4C8C2B), size: 20),
                            SizedBox(width: M.sm),
                            Expanded(
                              child: Text(
                                'Productive training — fitness is building steadily.',
                                style: TextStyle(
                                  color: Color(0xFF3F6F26),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: M.lg),
              MSection(
                title: 'This week',
                child: _WeekSummary(),
              ),

              const SizedBox(height: M.xl),
              MBanner(
                backgroundColor: M.darkNavy,
                padding: const EdgeInsets.all(M.lg),
                child: Column(
                  children: [
                    const Text(
                      'Ready starts here.',
                      style: TextStyle(
                        color: M.lime,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: M.sm),
                    const Text(
                      'Plan, train and grow on Veltrix.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: M.base),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: M.lime,
                          foregroundColor: M.navy,
                          padding: const EdgeInsets.symmetric(vertical: M.md),
                        ),
                        onPressed: () {},
                        child: const Text('Get started',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
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

class _WeekSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekStat('5', 'Workouts'),
              _WeekStat('4h 35m', 'Duration'),
              _WeekStat('286', 'TSS'),
            ],
          ),
          const SizedBox(height: M.base),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (i) => Column(
                children: [
                  Container(
                    width: 16,
                    height: [30.0, 55.0, 18.0, 68.0, 42.0, 74.0, 25.0][i] *
                        0.6,
                    decoration: BoxDecoration(
                      color: i == 5 ? M.lime : M.blue.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: M.xs),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                    style: const TextStyle(
                      color: M.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  final String value;
  final String label;
  const _WeekStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: M.statBig),
        Text(label, style: M.statLabel),
      ],
    );
  }
}

class _MobileHomePreview extends StatelessWidget {
  const _MobileHomePreview();
  @override
  Widget build(BuildContext context) => const MobileHomeScreen();
}

void main() => runApp(MaterialApp(
  theme: M.theme,
  home: const _MobileHomePreview(),
));

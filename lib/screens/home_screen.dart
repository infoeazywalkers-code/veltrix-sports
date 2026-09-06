import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../constants.dart';
import '../widgets/heading.dart';
import '../widgets/section_intro.dart';
import '../widgets/responsive_cards.dart';
import '../widgets/trust_badge.dart';
import '../widgets/marketing_feature_card.dart';
import '../widgets/pillar_card.dart';
import '../widgets/device_chip.dart';
import '../widgets/editorial_banner.dart';
import '../widgets/status_card.dart';
import '../widgets/week_card.dart';
import '../widgets/workout_card.dart';
import '../widgets/veltrix_footer.dart';
import '../widgets/event_details_dialog.dart';
import '../screens/workout_details.dart';
import '../models/workout.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigate;
  const HomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final side = width > 1220 ? (width - 1180) / 2 : 18.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(side, width > 850 ? 42 : 22, side, 48),
      children: [
        Text(
          'Your complete\ntraining platform.',
          style: TextStyle(
            fontSize: width > 850 ? 58 : 38,
            height: .98,
            fontWeight: FontWeight.w900,
            color: navy,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Built for athletes and coaches who want more from every session.',
          style: TextStyle(color: muted, fontSize: 17),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: lime,
                foregroundColor: navy,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              ),
              onPressed: () => onNavigate?.call(3),
              child: const Text('Athlete sign up', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: navy,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              ),
              onPressed: () => onNavigate?.call(6),
              child: const Text('Coach sign up', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const HomeVideoHero(),
        const SizedBox(height: 54),
        const PublicHomeSections(),
        const SizedBox(height: 54),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'YOUR TRAINING TODAY',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 26),
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => showDialog(
            context: context,
            builder: (_) => const EventDetailsDialog(
              event: {
                'title': 'Mumbai Half Marathon',
                'date': '25 October 2026',
                'location': 'Mumbai, India',
                'category': 'Running',
                'participants': '15,000+ Runners',
              },
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [navy, Color(0xff174c72)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Chip(
                      label: Text('A RACE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                      backgroundColor: lime,
                      side: BorderSide.none,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const EventDetailsDialog(
                          event: {
                            'title': 'Mumbai Half Marathon',
                            'date': '25 October 2026',
                            'location': 'Mumbai, India',
                            'category': 'Running',
                            'participants': '15,000+ Runners',
                          },
                        ),
                      ),
                      icon: const Icon(Icons.more_horiz, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mumbai Half Marathon',
                  style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                const Text('25 October 2026  \u2022  21.1 km', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 18),
                const LinearProgressIndicator(
                  value: .62,
                  minHeight: 7,
                  color: lime,
                  backgroundColor: Colors.white24,
                ),
                const SizedBox(height: 7),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Plan progress', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('62%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SectionHeading(
          'Today\u2019s training',
          action: 'View week',
          onActionTap: () => onNavigate?.call(1),
        ),
        const SizedBox(height: 12),
        WorkoutCard(
          sport: 'RUN',
          title: 'Aerobic endurance',
          details: '45 min  \u2022  7.2 km  \u2022  62 TSS',
          color: blue,
          icon: Icons.directions_run_rounded,
          progress: .68,
          onTap: () {
            final demoWorkout = Workout(
              id: 'demo_run',
              planId: 'demo',
              sport: Sport.run,
              title: 'Aerobic endurance',
              description: 'Stay relaxed and keep your effort in Zone 2.',
              duration: '45 min',
              distanceKm: 7.2,
              tss: 62,
              targetPace: '5:55–6:15 /km',
              scheduledFor: DateTime.now(),
              progress: 0.68,
              completed: false,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutDetailsScreen(workout: demoWorkout),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        SectionHeading(
          'Training status',
          action: 'Details',
          onActionTap: () => onNavigate?.call(2),
        ),
        const SizedBox(height: 12),
        const StatusCard(),
        const SizedBox(height: 24),
        const SectionHeading('This week'),
        const SizedBox(height: 12),
        const WeekCard(),
        const SizedBox(height: 24),
        const EditorialBanner(
          image: 'assets/images/endurance-runner.png',
          eyebrow: 'TRAIN WITH PURPOSE',
          title: 'Every session. One clear path forward.',
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 16),
        const EditorialBanner(
          image: 'assets/images/cyclist-coaching.png',
          eyebrow: 'COACHING THAT CONNECTS',
          title: 'Expert guidance, grounded in your data.',
          alignment: Alignment.centerRight,
        ),
        const SizedBox(height: 24),
        const SectionHeading('Coach note'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xffe7eff6),
                  child: Icon(Icons.person, color: navy),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Coach Priya', style: TextStyle(fontWeight: FontWeight.w900, color: navy)),
                      const SizedBox(height: 5),
                      const Text(
                        'Strong work on the intervals. Keep tomorrow truly easy so we can build again Thursday.',
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Yesterday \u2022 6:42 PM',
                        style: TextStyle(color: muted.withValues(alpha: .9), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 64),
        const VeltrixFooter(),
      ],
    );
  }
}

class PublicHomeSections extends StatelessWidget {
  const PublicHomeSections({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return Column(
      children: [
        const Text(
          'Train like the world\u2019s best.',
          textAlign: TextAlign.center,
          style: TextStyle(color: navy, fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 22),
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            TrustBadge(Icons.directions_run, 'ENDURANCE INDIA'),
            TrustBadge(Icons.directions_bike, 'VELO CLUB'),
            TrustBadge(Icons.pool, 'AQUA ELITE'),
            TrustBadge(Icons.emoji_events_outlined, 'RACE SERIES'),
            TrustBadge(Icons.fitness_center, 'HYBRID LAB'),
          ],
        ),
        const SizedBox(height: 54),
        const SectionIntro(
          eyebrow: 'ONE PLATFORM. EVERY GOAL.',
          title: 'Everything you need to go further.',
          body: 'Expert plans, connected coaching and purposeful training\u2014working together in one place.',
        ),
        const SizedBox(height: 24),
        const ResponsiveCards(
          children: [
            MarketingFeatureCard(
              image: 'assets/images/endurance-runner.png',
              eyebrow: 'TRAINING PLANS',
              title: 'Expertise. No guesswork.',
              body: 'Follow a proven path built for your sport, schedule and goal.',
              action: 'Find your plan',
            ),
            MarketingFeatureCard(
              image: 'assets/images/cyclist-coaching.png',
              eyebrow: 'COACHING',
              title: 'Even better together.',
              body: 'Work with an expert who sees the full picture behind every session.',
              action: 'Find a coach',
            ),
            MarketingFeatureCard(
              color: Color(0xff173f5f),
              icon: Icons.insights_rounded,
              eyebrow: 'PERFORMANCE',
              title: 'Real progress.',
              body: 'Turn workouts, health metrics and trends into clear next steps.',
              action: 'Explore insights',
            ),
          ],
        ),
        const SizedBox(height: 64),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: desktop ? 56 : 22, vertical: desktop ? 56 : 34),
          decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(28)),
          child: const Column(
            children: [
              Text(
                'All-in-one, for the all-in\nathlete and coach.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 34, height: 1.02, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 12),
              Text(
                'Plan. Train. Lift. Find your coach. One connected platform.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 34),
              ResponsiveCards(
                children: [
                  PillarCard(
                    number: '01',
                    verb: 'PLAN.',
                    title: 'Be ready for what\u2019s next.',
                    body: 'Build a season around structured workouts, events and expert guidance.',
                    icon: Icons.event_note_rounded,
                  ),
                  PillarCard(
                    number: '02',
                    verb: 'TRAIN.',
                    title: 'Purpose in every session.',
                    body: 'Take workouts anywhere and keep every device in sync.',
                    icon: Icons.directions_run_rounded,
                  ),
                  PillarCard(
                    number: '03',
                    verb: 'LIFT.',
                    title: 'Build durable strength.',
                    body: 'Balance endurance with guided strength and mobility work.',
                    icon: Icons.fitness_center_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        const SectionIntro(
          eyebrow: 'CONNECTED TRAINING',
          title: 'Connect with any device.',
          body: 'Bring your watches, trainers and health data together. Veltrix keeps the entire journey in sync.',
        ),
        const SizedBox(height: 24),
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            DeviceChip(Icons.watch_outlined, 'Smartwatch'),
            DeviceChip(Icons.directions_bike_outlined, 'Bike trainer'),
            DeviceChip(Icons.favorite_outline, 'Heart rate'),
            DeviceChip(Icons.bedtime_outlined, 'Recovery'),
            DeviceChip(Icons.phone_android, 'Mobile'),
            DeviceChip(Icons.cloud_sync_outlined, 'Cloud sync'),
          ],
        ),
        const SizedBox(height: 60),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [lime, Color(0xffd6f15f)]),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              const Text(
                'Ready starts here.',
                style: TextStyle(color: navy, fontSize: 34, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Plan, train and grow on the complete Veltrix sports platform.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ink, fontSize: 15),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    ),
                    onPressed: () => showFeatureMessage(context, 'Athlete registration is ready to begin.'),
                    child: const Text('Athlete sign up', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: navy,
                      side: const BorderSide(color: navy),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    ),
                    onPressed: () => showFeatureMessage(context, 'Coach registration is ready to begin.'),
                    child: const Text('Coach sign up', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeVideoHero extends StatefulWidget {
  const HomeVideoHero({super.key});
  @override
  State<HomeVideoHero> createState() => _HomeVideoHeroState();
}

class _HomeVideoHeroState extends State<HomeVideoHero> {
  late final VideoPlayerController controller;
  bool muted = true;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset('assets/video/home-training.mp4');
    controller.setLooping(true);
    controller.setVolume(0);
    controller.initialize().then((_) {
      if (mounted) setState(() {});
      controller.play();
    }).catchError((_) {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller.value.isInitialized && !controller.value.hasError)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            )
          else
            Image.asset(
              'assets/images/endurance-runner.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [navy, Color(0xff1e3a5f)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.fitness_center_rounded, color: lime, size: 48),
                ),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xdd102a43)],
              ),
            ),
          ),
          const Positioned(
            left: 18,
            right: 70,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUILT FOR THE WORK',
                  style: TextStyle(
                    color: lime,
                    fontSize: 10,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your strongest season starts here.',
                  style: TextStyle(color: Colors.white, fontSize: 23, height: 1.05, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: IconButton.filledTonal(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: .9),
                foregroundColor: navy,
              ),
              onPressed: () {
                setState(() => muted = !muted);
                controller.setVolume(muted ? 0 : 1);
              },
              icon: Icon(muted ? Icons.volume_off_rounded : Icons.volume_up_rounded),
            ),
          ),
        ],
      ),
    ),
  );
}


import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/section_intro.dart';
import '../widgets/responsive_cards.dart';
import '../widgets/veltrix_footer.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return ListView(
      padding: EdgeInsets.fromLTRB(desktop ? 40 : 18, 32, desktop ? 40 : 18, 64),
      children: [
        const SectionIntro(
          eyebrow: 'PREMIUM',
          title: 'Your Next Peak Starts with Premium',
          body: 'Unlock the full power of Veltrix with advanced analytics, expert plans and connected coaching.',
        ),
        const SizedBox(height: 40),
        const ResponsiveCards(
          children: [
            _PremiumFeature(
              icon: Icons.event_note_rounded,
              eyebrow: 'PLAN',
              title: 'Flexible planning tools',
              body: 'Build your season with the Annual Training Plan. Drag, drop and adjust workouts with a clear long-range view.',
            ),
            _PremiumFeature(
              icon: Icons.insights_rounded,
              eyebrow: 'ANALYZE',
              title: 'Performance Management',
              body: 'Real-time fitness score, fatigue and form tracking. See how every session contributes to your peak.',
            ),
            _PremiumFeature(
              icon: Icons.fitness_center_rounded,
              eyebrow: 'CROSS-TRAIN',
              title: 'Strength, health & fueling',
              body: 'Guided strength workouts, health metrics and Fueling Insights to complement your endurance training.',
            ),
          ],
        ),
        const SizedBox(height: 48),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: desktop ? 56 : 24, vertical: 48),
          decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(28)),
          child: Column(
            children: [
              const Text(
                'Veltrix Virtual included.',
                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'Indoor cycling with structured workouts, community rides and realistic physics.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: const [
                  _VirtualFeature(Icons.sports_esports, 'Workout sync'),
                  _VirtualFeature(Icons.group, 'Community rides'),
                  _VirtualFeature(Icons.phonelink_setup, 'Any device'),
                  _VirtualFeature(Icons.wifi, 'Real-time data'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        const _PricingSection(),
        const SizedBox(height: 48),
        const _FeatureHighlights(),
        const SizedBox(height: 48),
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
                'Go further with Premium.',
                style: TextStyle(color: navy, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                '14-day free trial. Cancel anytime.',
                style: TextStyle(color: ink, fontSize: 15),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                ),
                onPressed: () {},
                child: const Text('Get Premium Now', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        VeltrixFooter(),
      ],
    );
  }
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(body: PremiumScreen()),
));

class _PremiumFeature extends StatelessWidget {
  final IconData icon;
  final String eyebrow, title, body;
  const _PremiumFeature({required this.icon, required this.eyebrow, required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: lime, size: 36),
          const SizedBox(height: 20),
          Text(
            eyebrow,
            style: const TextStyle(color: blue, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: muted, fontSize: 13, height: 1.5)),
        ],
      ),
    ),
  );
}

class _VirtualFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _VirtualFeature(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Container(
    width: 140,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      children: [
        Icon(icon, color: lime, size: 28),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _PricingSection extends StatelessWidget {
  const _PricingSection();
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return Column(
      children: [
        const Text(
          'Simple, transparent pricing',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: navy),
        ),
        const SizedBox(height: 8),
        const Text('Start with a 14-day free trial', style: TextStyle(color: muted, fontSize: 15)),
        const SizedBox(height: 28),
        if (desktop)
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PriceCard('Monthly', '\u20b9499', '/month', 'Billed monthly', false)),
              SizedBox(width: 14),
              Expanded(child: _PriceCard('Annual', '\u20b9399', '/month', 'Billed annually \u2022 Save 20%', true)),
            ],
          )
        else
          const Column(
            children: [
              _PriceCard('Monthly', '\u20b9499', '/month', 'Billed monthly', false),
              SizedBox(height: 14),
              _PriceCard('Annual', '\u20b9399', '/month', 'Billed annually \u2022 Save 20%', true),
            ],
          ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String plan, price, period, detail;
  final bool featured;
  const _PriceCard(this.plan, this.price, this.period, this.detail, this.featured);
  @override
  Widget build(BuildContext context) => Card(
    color: featured ? navy : null,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (featured)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(8)),
              child: const Text('BEST VALUE', style: TextStyle(color: navy, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
          if (featured) const SizedBox(height: 12),
          Text(plan, style: TextStyle(color: featured ? Colors.white : navy, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: TextStyle(color: featured ? Colors.white : navy, fontSize: 36, fontWeight: FontWeight.w900)),
              Text(period, style: TextStyle(color: featured ? Colors.white70 : muted, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Text(detail, style: TextStyle(color: featured ? Colors.white60 : muted, fontSize: 12)),
          const SizedBox(height: 16),
          ...[
            'Performance Management Chart',
            'Training Plan Library',
            'Annual Training Plan',
            'Strength Training',
            'Veltrix Virtual included',
            'Enhanced coaching tools',
          ].map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: featured ? lime : blue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(f, style: TextStyle(color: featured ? Colors.white70 : ink, fontSize: 13)),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: featured ? lime : navy,
              foregroundColor: featured ? navy : Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () {},
            child: const Text('Start free trial', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    ),
  );
}

class _FeatureHighlights extends StatelessWidget {
  const _FeatureHighlights();
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    const features = [
      (Icons.show_chart, 'PMC Chart', 'Track fitness, fatigue and form over time with the Performance Management Chart.'),
      (Icons.library_books, 'Workout Library', 'Drag-and-drop workout builder with structured workout templates.'),
      (Icons.chat_bubble_outline, 'Enhanced Coaching', 'Real-time notifications, availability status and detailed workout notes.'),
      (Icons.restaurant, 'Fueling Insights', 'Track nutrition and fueling strategies aligned with your training load.'),
    ];
    return Column(
      children: [
        const Text(
          'Why athletes choose Premium',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: navy),
        ),
        const SizedBox(height: 24),
        if (desktop)
          Row(
            children: features
                .map((f) => Expanded(child: _FeatureTile(f.$1, f.$2, f.$3)))
                .toList(),
          )
        else
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: features.map((f) => SizedBox(
              width: (MediaQuery.sizeOf(context).width - 50) / 2,
              child: _FeatureTile(f.$1, f.$2, f.$3),
            )).toList(),
          ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _FeatureTile(this.icon, this.title, this.body);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: blue, size: 28),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: navy, fontSize: 15)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: muted, fontSize: 12, height: 1.5)),
        ],
      ),
    ),
  );
}

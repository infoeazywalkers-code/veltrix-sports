import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/common/section_intro.dart';
import '../../widgets/common/responsive_cards.dart';
import '../../widgets/common/veltrix_footer.dart';
import '../premium/premium_screen.dart';
import '../explore/production_pages.dart';

class StrengthScreen extends StatelessWidget {
  const StrengthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        desktop ? 40 : 18,
        32,
        desktop ? 40 : 18,
        64,
      ),
      children: [
        const SectionIntro(
          eyebrow: 'STRENGTH',
          title: 'Empower Your Training',
          body:
              'Build strength that supports endurance. Guided workouts, exercise library and calendar sync\u2014all in one place.',
        ),
        const SizedBox(height: 40),
        const ResponsiveCards(
          children: [
            _StrengthFeature(
              Icons.shield_outlined,
              'DYNAMIC CONFIDENCE',
              'Train with purpose',
              '1000+ exercise videos with form cues and progressions to keep every rep intentional.',
            ),
            _StrengthFeature(
              Icons.repeat,
              'STEADFAST CONSISTENCY',
              'Build the habit',
              'Color-coded compliance scores help you stay on track and build lasting strength habits.',
            ),
            _StrengthFeature(
              Icons.emoji_events_outlined,
              'EMPOWERED RESULTS',
              'Perform at your best',
              'Structured strength sessions that complement your endurance training and prevent injury.',
            ),
          ],
        ),
        const SizedBox(height: 48),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? 56 : 24,
            vertical: 44,
          ),
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Column(
            children: [
              Text(
                'Strength for endurance athletes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Workouts sync to your calendar. Execute on mobile. Build on desktop.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _StrengthStat(Icons.library_books, '1000+', 'Exercises'),
                  _StrengthStat(Icons.videocam_outlined, 'Video', 'Library'),
                  _StrengthStat(Icons.sync, 'Calendar', 'Sync'),
                  _StrengthStat(
                    Icons.check_circle_outline,
                    'Compliance',
                    'Tracking',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        const _StrengthPlans(),
        const SizedBox(height: 48),
        const _StrengthTestimonials(),
        const SizedBox(height: 48),
        const _StrengthFAQ(),
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
              Text(
                'Start building strength today.',
                style: TextStyle(
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : navy),
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Included with Veltrix Premium.',
                style: TextStyle(
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFB0BEC5)
                      : ink),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                ),
                child: const Text(
                  'Explore Premium',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        const VeltrixFooter(),
      ],
    );
  }
}

class _StrengthFeature extends StatelessWidget {
  final IconData icon;
  final String eyebrow, title, body;
  const _StrengthFeature(this.icon, this.eyebrow, this.title, this.body);
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
            style: const TextStyle(
              color: orange,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : navy),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF78909C)
                  : muted),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

class _StrengthStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _StrengthStat(this.icon, this.value, this.label);
  @override
  Widget build(BuildContext context) => Container(
    width: 130,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      children: [
        Icon(icon, color: lime, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    ),
  );
}

class _StrengthPlans extends StatelessWidget {
  const _StrengthPlans();
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    const plans = [
      (
        'Base Building',
        '12 weeks',
        'Foundation strength for endurance athletes',
        blue,
      ),
      (
        'Race Ready',
        '8 weeks',
        'Power and explosive strength for race day',
        purple,
      ),
      (
        'Injury Prevention',
        '6 weeks',
        'Mobility, stability and prehab exercises',
        teal,
      ),
    ];
    return Column(
      children: [
        Text(
          'Explore strength plans',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : navy),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Find the right strength program for your phase',
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF78909C)
                : muted),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        if (desktop)
          Row(
            children: plans
                .map((p) => Expanded(child: _PlanCard(p.$1, p.$2, p.$3, p.$4)))
                .toList(),
          )
        else
          ...plans.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PlanCard(p.$1, p.$2, p.$3, p.$4),
            ),
          ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title, duration, description;
  final Color color;
  const _PlanCard(this.title, this.duration, this.description, this.color);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              duration,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : navy),
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF78909C)
                  : muted),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => strengthPlanDetailScreen(title),
              ),
            ),
            child: const Text(
              'View plan',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ),
  );
}

class _StrengthTestimonials extends StatelessWidget {
  const _StrengthTestimonials();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: navy,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Column(
      children: [
        Icon(Icons.format_quote, color: lime, size: 40),
        SizedBox(height: 16),
        Text(
          '"Adding structured strength work has made me a more resilient runner. I\u2019ve stayed injury-free for two full seasons."',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Ryan M.',
          style: TextStyle(color: lime, fontWeight: FontWeight.w900),
        ),
        Text(
          'Marathon Runner',
          style: TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    ),
  );
}

class _StrengthFAQ extends StatelessWidget {
  const _StrengthFAQ();
  @override
  Widget build(BuildContext context) {
    const faqs = [
      (
        'Is strength training included in Premium?',
        'Yes. All strength features including the exercise library, workout builder and compliance tracking are included with Veltrix Premium.',
      ),
      (
        'Can I build custom workouts?',
        'Premium coach and athlete accounts can build custom strength workouts on desktop. Mobile is for execution only.',
      ),
      (
        'Do strength workouts sync to my calendar?',
        'Yes. Purchased and custom strength plans are delivered to your Training Plan Library and sync to your calendar automatically.',
      ),
      (
        'Can I export strength workouts to other apps?',
        'Currently strength workouts cannot be exported to third-party apps. They are designed to be used within the Veltrix ecosystem.',
      ),
    ];
    return Column(
      children: [
        Text(
          'Frequently asked questions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : navy),
          ),
        ),
        const SizedBox(height: 20),
        ...faqs.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 18),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: Text(
                  f.$1,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
                  ),
                ),
                children: [
                  Text(
                    f.$2,
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF78909C)
                          : muted),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

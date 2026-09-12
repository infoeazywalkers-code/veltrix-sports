import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/common/section_intro.dart';
import '../../widgets/common/veltrix_footer.dart';
import '../../services/social/coach_service.dart';
import '../../widgets/dialogs/coach_booking_dialog.dart';
import 'coach_detail_screen.dart';
import 'coach_questionnaire_screen.dart';
import 'my_coach_requests_screen.dart';

class CoachMatchScreen extends StatelessWidget {
  const CoachMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    // Scaffold + AppBar so pushed routes get system back and an in-app
    // back button. When hosted in the shell, the back button auto-hides.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Match'),
        actions: [
          Builder(
            builder:
                (actionContext) => TextButton(
                  onPressed:
                      () => Navigator.of(actionContext).push(
                        MaterialPageRoute(
                          builder: (_) => const MyCoachRequestsScreen(),
                        ),
                      ),
                  child: const Text(
                    'My requests',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          desktop ? 40 : 18,
          32,
          desktop ? 40 : 18,
          64,
        ),
        children: [
          const SectionIntro(
            eyebrow: 'COACH MATCH',
            title: 'Expert coaching, no matter your starting point',
            body:
                'Answer a few questions and our team will match you with the perfect coach for your goals, sport and level.',
          ),
          const SizedBox(height: 32),
          Center(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: lime,
                foregroundColor: navy,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
              ),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CoachQuestionnaireScreen(),
                  ),
                );
                if (!context.mounted) return;
                if (result == true) {
                  showFeatureMessage(
                    context,
                    'Questionnaire submitted. We will match you shortly.',
                  );
                } else if (result == 'signIn') {
                  showFeatureMessage(
                    context,
                    'Please sign in to submit your coach questionnaire.',
                  );
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Start Questionnaire',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 48),
          const _FeaturedCoachesList(),
          const SizedBox(height: 48),
          const _HowItWorks(),
          const SizedBox(height: 48),
          const _CoachFeatures(),
          const SizedBox(height: 48),
          const _Testimonials(),
          const SizedBox(height: 48),
          const _PricingPackages(),
          const SizedBox(height: 48),
          const _FAQSection(),
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
                  'Ready to find your coach?',
                  style: TextStyle(
                    color:
                        (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : navy),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '30-day money-back guarantee. No risk.',
                  style: TextStyle(
                    color:
                        (Theme.of(context).brightness == Brightness.dark
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
                  onPressed: () async {
                    // Single-pop flow: the questionnaire pops once with a
                    // result (true = submitted, 'signIn' = needs auth).
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CoachQuestionnaireScreen(),
                      ),
                    );
                    if (!context.mounted) return;
                    if (result == true) {
                      showFeatureMessage(
                        context,
                        'Questionnaire submitted. We will match you shortly.',
                      );
                    } else if (result == 'signIn') {
                      showFeatureMessage(
                        context,
                        'Please sign in to submit your coach questionnaire.',
                      );
                    }
                  },
                  child: const Text(
                    'Get started',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          const VeltrixFooter(),
        ],
      ),
    );
  }
}

class _FeaturedCoachesList extends StatefulWidget {
  const _FeaturedCoachesList();

  @override
  State<_FeaturedCoachesList> createState() => _FeaturedCoachesListState();
}

class _FeaturedCoachesListState extends State<_FeaturedCoachesList> {
  Future<List<CoachProfile>>? _future;

  @override
  void initState() {
    super.initState();
    _future = CoachService.fetchFeaturedCoaches();
  }

  void _retry() {
    setState(() => _future = CoachService.fetchFeaturedCoaches());
  }

  Future<void> _openQuestionnaire() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CoachQuestionnaireScreen()));
    if (!mounted) return;
    if (result == true) {
      showFeatureMessage(
        context,
        'Questionnaire submitted. We will match you shortly.',
      );
    } else if (result == 'signIn') {
      showFeatureMessage(
        context,
        'Please sign in to submit your coach questionnaire.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Veltrix Coaches',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color:
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : navy),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Book a direct 1-on-1 consultation with certified endurance experts.',
          style: TextStyle(
            color:
                (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF78909C)
                    : muted),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        FutureBuilder<List<CoachProfile>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40, color: orange),
                    const SizedBox(height: 12),
                    const Text('Could not load coaches.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final coaches = snapshot.data ?? [];
            if (coaches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.groups_outlined, size: 40, color: muted),
                    const SizedBox(height: 12),
                    const Text(
                      'No featured coaches yet — tell us what you need',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _openQuestionnaire,
                      child: const Text('Start Questionnaire'),
                    ),
                  ],
                ),
              );
            }
            if (desktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    coaches
                        .map(
                          (coach) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _CoachCard(coach: coach),
                            ),
                          ),
                        )
                        .toList(),
              );
            }
            return Column(
              children:
                  coaches
                      .map(
                        (coach) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _CoachCard(coach: coach),
                        ),
                      )
                      .toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Avatar with network-with-fallback: http(s) uses NetworkImage,
/// asset paths use AssetImage, empty/unknown falls back to initials.
/// Never crashes on URL/empty strings.
class _CoachAvatar extends StatelessWidget {
  final String image;
  final String name;
  const _CoachAvatar({required this.image, required this.name});

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = image.trim();
    if (trimmed.isEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: navy,
        child: Text(
          _initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }
    if (trimmed.startsWith('http')) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: navy,
        child: ClipOval(
          child: Image.network(
            trimmed,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 26,
      backgroundColor: navy,
      child: ClipOval(
        child: Image.asset(
          trimmed,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final CoachProfile coach;
  const _CoachCard({required this.coach});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CoachDetailScreen(coachId: coach.id),
            ),
          ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CoachAvatar(image: coach.image, name: coach.name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coach.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : navy),
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              coach.rating,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color:
                                    (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF78909C)
                                        : muted),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                coach.title,
                style: const TextStyle(
                  color: blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                coach.bio,
                style: TextStyle(
                  color:
                      (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF78909C)
                          : muted),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    coach.specialities.map((spec) {
                      return Chip(
                        label: Text(
                          spec,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: bg,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    coach.monthlyFee,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : navy),
                      fontSize: 16,
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: lime,
                      foregroundColor: navy,
                    ),
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder: (_) => CoachBookingDialog(coach: coach),
                        ),
                    child: const Text(
                      'Book Call',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    const steps = [
      (
        '01',
        'QUESTIONNAIRE',
        'Answer questions about your goals, sport, experience and preferences.',
        Icons.quiz_outlined,
      ),
      (
        '02',
        'EXPERT REVIEW',
        'Our team of coaching experts reviews your profile and requirements.',
        Icons.person_search_outlined,
      ),
      (
        '03',
        'YOUR MATCH',
        'Receive an email with your matched coach and a free consultation offer.',
        Icons.mail_outline,
      ),
    ];
    return Column(
      children: [
        Text(
          'How it works',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color:
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : navy),
          ),
        ),
        const SizedBox(height: 28),
        if (desktop)
          Row(
            children:
                steps
                    .map(
                      (s) => Expanded(child: _StepCard(s.$1, s.$2, s.$3, s.$4)),
                    )
                    .toList(),
          )
        else
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _StepCard(s.$1, s.$2, s.$3, s.$4),
            ),
          ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number, eyebrow, body;
  final IconData icon;
  const _StepCard(this.number, this.eyebrow, this.body, this.icon);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                number,
                style: TextStyle(
                  color:
                      (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF78909C)
                          : muted),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Icon(icon, color: blue, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            eyebrow,
            style: const TextStyle(
              color: blue,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color:
                  (Theme.of(context).brightness == Brightness.dark
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

class _CoachFeatures extends StatelessWidget {
  const _CoachFeatures();
  @override
  Widget build(BuildContext context) {
    const features = [
      (
        Icons.science_outlined,
        'Science-backed',
        'Training plans built on proven methodology and performance data.',
      ),
      (
        Icons.person_outline,
        'Personalized',
        'Every workout and adjustment tailored to your unique physiology and goals.',
      ),
      (
        Icons.chat_outlined,
        'Communication',
        'Direct line to your coach with regular check-ins and feedback.',
      ),
      (
        Icons.trending_up,
        'Long-game approach',
        'Season-over-season progression with strategic peak planning.',
      ),
    ];
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return Column(
      children: [
        Text(
          'Why Coach Match works',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color:
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : navy),
          ),
        ),
        const SizedBox(height: 24),
        if (desktop)
          Row(
            children:
                features
                    .map((f) => Expanded(child: _FeatureItem(f.$1, f.$2, f.$3)))
                    .toList(),
          )
        else
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children:
                features
                    .map(
                      (f) => SizedBox(
                        width: (MediaQuery.sizeOf(context).width - 50) / 2,
                        child: _FeatureItem(f.$1, f.$2, f.$3),
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _FeatureItem(this.icon, this.title, this.body);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: lime, size: 28),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color:
                  (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : navy),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color:
                  (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF78909C)
                      : muted),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Testimonials extends StatelessWidget {
  const _Testimonials();
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
          '"Having a coach who understands my data and my goals has completely changed how I approach training."',
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
          'Ruth Croft',
          style: TextStyle(color: lime, fontWeight: FontWeight.w900),
        ),
        Text(
          'Elite Trail Runner',
          style: TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    ),
  );
}

class _PricingPackages extends StatelessWidget {
  const _PricingPackages();
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    const packages = [
      (
        'Bronze',
        '\u20b9149',
        '/mo',
        [
          'Free consultation',
          'Premium account',
          'Custom training plan',
          '2 emails / month',
          '1 call / quarter',
          '1 plan adjustment / month',
        ],
      ),
      (
        'Silver',
        '\u20b9229',
        '/mo',
        [
          'Everything in Bronze',
          'Unlimited emails',
          'Key workout feedback',
          '1 call / month',
          '2 adjustments / month',
          'Priority support',
        ],
      ),
      (
        'Gold',
        '\u20b9359',
        '/mo',
        [
          'Everything in Silver',
          'Unlimited calls',
          'Unlimited adjustments',
          'Feedback on every workout',
          'Race strategy planning',
          'Direct coach messaging',
        ],
      ),
    ];
    return Column(
      children: [
        Text(
          'Choose your package',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color:
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : navy),
          ),
        ),
        const SizedBox(height: 24),
        if (desktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                packages
                    .map(
                      (p) =>
                          Expanded(child: _PackageCard(p.$1, p.$2, p.$3, p.$4)),
                    )
                    .toList(),
          )
        else
          ...packages.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PackageCard(p.$1, p.$2, p.$3, p.$4),
            ),
          ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String name, price, period;
  final List<String> features;
  const _PackageCard(this.name, this.price, this.period, this.features);
  @override
  Widget build(BuildContext context) {
    final isGold = name == 'Gold';
    return Card(
      color: isGold ? navy : null,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGold)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: lime,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: navy,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            if (isGold) const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                color:
                    isGold
                        ? Colors.white
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : navy),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    color:
                        isGold
                            ? Colors.white
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : navy),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    color:
                        isGold
                            ? Colors.white70
                            : (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF78909C)
                                : muted),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isGold ? lime : blue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(
                          color:
                              isGold
                                  ? Colors.white70
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFB0BEC5)
                                      : ink),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isGold ? lime : navy,
                foregroundColor: isGold ? navy : Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => CoachQuestionnaireScreen(
                          package: name.toLowerCase(),
                        ),
                  ),
                );
                if (!context.mounted) return;
                if (result == true) {
                  showFeatureMessage(
                    context,
                    'Questionnaire submitted. We will match you shortly.',
                  );
                } else if (result == 'signIn') {
                  showFeatureMessage(
                    context,
                    'Please sign in to submit your coach questionnaire.',
                  );
                }
              },
              child: const Text(
                'Get started',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQSection extends StatelessWidget {
  const _FAQSection();
  @override
  Widget build(BuildContext context) {
    const faqs = [
      (
        'How does the matching work?',
        'Our team reviews your questionnaire responses including your goals, sport, experience level, location and communication preferences. We then match you with a coach who specializes in your area.',
      ),
      (
        'Can I switch coaches?',
        'Yes. If you feel your coach isn\'t the right fit, contact our support team and we\'ll arrange a rematch at no extra cost.',
      ),
      (
        'What\u2019s included in the free consultation?',
        'A 20-minute call with your matched coach to discuss your goals, training history and approach. No obligation to continue.',
      ),
      (
        'Is there a contract?',
        'No long-term contracts. You can cancel monthly at any time. Annual plans can be cancelled with a prorated refund.',
      ),
      (
        'What\u2019s the money-back guarantee?',
        'If you\u2019re not satisfied within the first 30 days, we\u2019ll refund your subscription in full.',
      ),
    ];
    return Column(
      children: [
        Text(
          'Frequently asked questions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color:
                (Theme.of(context).brightness == Brightness.dark
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
                    color:
                        (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : navy),
                  ),
                ),
                children: [
                  Text(
                    f.$2,
                    style: TextStyle(
                      color:
                          (Theme.of(context).brightness == Brightness.dark
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

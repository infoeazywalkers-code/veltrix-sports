import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../premium/premium_screen.dart';
import '../../services/core/onboarding_service.dart';

class ProductionInfoScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<InfoBlock> blocks;
  final List<Widget> actions;

  const ProductionInfoScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.blocks,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          desktop ? 40 : 18,
          24,
          desktop ? 40 : 18,
          64,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 34),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(spacing: 10, runSpacing: 10, children: actions),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          ...blocks.map(
            (block) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: block.color.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(block.icon, color: block.color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              block.title,
                              style: TextStyle(
                                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : navy),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              block.body,
                              style: TextStyle(
                                color: (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF78909C) : muted),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoBlock {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const InfoBlock(this.icon, this.color, this.title, this.body);
}

Widget athleteOnboardingScreen() => const AthleteOnboardingScreen();

// TODO(deprecated): AthleteOnboardingScreen is superseded by OnboardingFlow.
// Kept only for the legacy desktop shell index 19 entry; new flows must use
// OnboardingFlow with onboardingStatusProvider gating.
class AthleteOnboardingScreen extends StatefulWidget {
  const AthleteOnboardingScreen({super.key});

  @override
  State<AthleteOnboardingScreen> createState() =>
      _AthleteOnboardingScreenState();
}

class _AthleteOnboardingScreenState extends State<AthleteOnboardingScreen> {
  final _raceController = TextEditingController();
  String _sport = 'Running';
  String _experience = 'Intermediate';
  String _goal = 'Build consistency';
  double _weeklyHours = 5;
  bool _saving = false;

  @override
  void dispose() {
    _raceController.dispose();
    super.dispose();
  }

  Future<void> _save({required bool complete}) async {
    setState(() => _saving = true);
    try {
      await OnboardingService().saveProgress(
        sports: [_sport],
        experienceLevel: _experience,
        mainGoal: _goal,
        weeklyHours: _weeklyHours.round(),
        goalRace:
            _raceController.text.trim().isEmpty
                ? null
                : _raceController.text.trim(),
        complete: complete,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            complete
                ? 'Profile ready. Your plan can now be personalized.'
                : 'Progress saved.',
          ),
        ),
      );
      if (complete) {
        // Return to the shell index flow instead of pushing a new route on
        // top (avoids a dead-end stack). The shell already hosts the
        // training plans destination at its trainingPlans index.
        if (context.mounted) Navigator.pop(context);
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Athlete onboarding')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 64),
      children: [
        Text(
          'Build your athlete profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : navy),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Save as you go. These answers shape your training recommendations and can be updated later.',
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _sport,
          decoration: const InputDecoration(labelText: 'Primary sport'),
          items:
              ['Running', 'Cycling', 'Triathlon', 'Strength']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _sport = value ?? _sport),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _experience,
          decoration: const InputDecoration(labelText: 'Experience level'),
          items:
              ['Beginner', 'Intermediate', 'Advanced']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
          onChanged:
              (value) => setState(() => _experience = value ?? _experience),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _goal,
          decoration: const InputDecoration(labelText: 'Main goal'),
          items:
              [
                    'Build consistency',
                    'Race faster',
                    'Return from injury',
                    'Improve strength',
                  ]
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _goal = value ?? _goal),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _raceController,
          decoration: const InputDecoration(
            labelText: 'Goal race or milestone',
            hintText: 'Optional',
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Weekly training availability: ${_weeklyHours.round()} hours',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Slider(
          value: _weeklyHours,
          min: 1,
          max: 20,
          divisions: 19,
          label: '${_weeklyHours.round()}h',
          onChanged: (value) => setState(() => _weeklyHours = value),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: _saving ? null : () => _save(complete: false),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save progress'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _saving ? null : () => _save(complete: true),
          icon: const Icon(Icons.check_circle_outline),
          label: Text(_saving ? 'Saving...' : 'Complete onboarding'),
        ),
      ],
    ),
  );
}

ProductionInfoScreen coachPlatformScreen() => const ProductionInfoScreen(
  title: 'Coach platform',
  subtitle:
      'Manage athletes, prescribe training, review readiness, and keep communication tied to the work.',
  icon: Icons.groups_rounded,
  accent: purple,
  blocks: [
    InfoBlock(
      Icons.dashboard_customize,
      purple,
      'Athlete command center',
      'See compliance, fatigue, missed sessions, upcoming races, and coach notes from one dashboard.',
    ),
    InfoBlock(
      Icons.edit_calendar,
      blue,
      'Plan builder',
      'Create reusable blocks, assign workouts, and adjust sessions around fatigue or life constraints.',
    ),
    InfoBlock(
      Icons.privacy_tip_outlined,
      orange,
      'Trusted permissions',
      'Athletes control what health, device, and profile data a coach can access.',
    ),
  ],
);

ProductionInfoScreen coachResourcesScreen() => const ProductionInfoScreen(
  title: 'Coach resources',
  subtitle:
      'Operating guides for onboarding athletes, reviewing data, and running a professional coaching workflow.',
  icon: Icons.menu_book_rounded,
  accent: navy,
  blocks: [
    InfoBlock(
      Icons.assignment_turned_in,
      teal,
      'Onboarding checklist',
      'Standardize intake, goal setting, injury history, schedule constraints, and communication expectations.',
    ),
    InfoBlock(
      Icons.monitor_heart_outlined,
      orange,
      'Readiness review',
      'Use training load, subjective feedback, and recovery trends before increasing intensity.',
    ),
    InfoBlock(
      Icons.message_outlined,
      blue,
      'Feedback cadence',
      'Keep comments specific, timely, and tied to the next training decision.',
    ),
  ],
);

ProductionInfoScreen trainingGuidesScreen() => const ProductionInfoScreen(
  title: 'Training guides',
  subtitle:
      'Practical guidance for endurance planning, strength integration, racing, recovery, and device data.',
  icon: Icons.school_rounded,
  accent: blue,
  blocks: [
    InfoBlock(
      Icons.timeline,
      blue,
      'Build a season',
      'Move from base to build to race-specific work with recovery weeks placed before fatigue becomes expensive.',
    ),
    InfoBlock(
      Icons.fitness_center,
      purple,
      'Strength that supports sport',
      'Use mobility, trunk stability, single-leg strength, and progressive loading without stealing quality from key sessions.',
    ),
    InfoBlock(
      Icons.local_fire_department_outlined,
      orange,
      'Race week execution',
      'Keep volume low, sharpen intensity carefully, prepare logistics, and protect sleep.',
    ),
  ],
);

ProductionInfoScreen supportScreen() => const ProductionInfoScreen(
  title: 'Support center',
  subtitle:
      'Device pairing, billing, profile, and workout troubleshooting paths for athletes and coaches.',
  icon: Icons.support_agent_rounded,
  accent: teal,
  blocks: [
    InfoBlock(
      Icons.bluetooth_searching,
      teal,
      'Device pairing help',
      'Check permissions, Bluetooth state, battery level, and whether another app is already holding the sensor connection.',
    ),
    InfoBlock(
      Icons.receipt_long,
      orange,
      'Billing and premium',
      'Payments stay pending until trusted server verification completes, protecting both users and the business.',
    ),
    InfoBlock(
      Icons.bug_report_outlined,
      purple,
      'Report an issue',
      'Include device model, app version, screenshots, and the exact workout or payment step that failed.',
    ),
  ],
);

ProductionInfoScreen aboutScreen() => const ProductionInfoScreen(
  title: 'About Veltrix',
  subtitle:
      'A training platform for athletes and coaches who need planning, execution, insight, and communication in one place.',
  icon: Icons.info_outline_rounded,
  accent: navy,
  blocks: [
    InfoBlock(
      Icons.security,
      blue,
      'Production principle',
      'Critical actions such as premium entitlement and user data ownership should be verified by trusted services, not client-only UI.',
    ),
    InfoBlock(
      Icons.devices_other,
      teal,
      'Connected ecosystem',
      'Veltrix is designed around workouts, coaches, events, tickets, devices, and recovery signals working together.',
    ),
    InfoBlock(
      Icons.auto_graph,
      orange,
      'Long-term product direction',
      'The app should graduate from demo data into real plans, backend notifications, audit logs, and full release monitoring.',
    ),
  ],
);

ProductionInfoScreen strengthPlanDetailScreen(
  String title,
) => ProductionInfoScreen(
  title: title,
  subtitle:
      'A structured strength plan with phase goals, session rhythm, movement library, and progression notes.',
  icon: Icons.fitness_center_rounded,
  accent: purple,
  actions: [
    Builder(
      builder:
          (context) => FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: lime,
              foregroundColor: navy,
            ),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                ),
            icon: const Icon(Icons.workspace_premium),
            label: const Text('Review Premium'),
          ),
    ),
  ],
  blocks: const [
    InfoBlock(
      Icons.view_week,
      blue,
      'Weekly rhythm',
      'Two gym sessions, one mobility session, and optional activation work before key workouts.',
    ),
    InfoBlock(
      Icons.video_library_outlined,
      teal,
      'Exercise library',
      'Each movement needs video, form cues, regressions, progressions, and coach notes before full production.',
    ),
    InfoBlock(
      Icons.check_circle_outline,
      orange,
      'Compliance tracking',
      'Track completed sets, skipped movements, soreness feedback, and next-session readiness.',
    ),
  ],
);

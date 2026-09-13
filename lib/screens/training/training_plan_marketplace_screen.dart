import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/training/training_plan.dart';
import '../../providers.dart';
import '../../services/payment/payment_service.dart';
import '../../services/training/plan_templates.dart';
import '../../widgets/dialogs/checkout_dialog.dart';
import 'ai_plan_generator_screen.dart';
import 'plan_detail_screen.dart';

class TrainingPlanMarketplaceScreen extends ConsumerWidget {
  final List<_Plan> plans = const [
    _Plan(
      id: '1',
      title: 'Gran Fondo 200km',
      subtitle: '12 weeks · Intermediate',
      description:
          'Progressive endurance plan targeting a 200km Gran Fondo with 2500m+ climbing. Peaks at 14h/week with altitude simulation.',
      coach: 'Veltrix AI',
      coachAvatar: '🤖',
      price: 39.99,
      gradient: [Color(0xFFF97316), Color(0xFFFBBF24)],
      tags: ['Endurance', 'Cycling', 'Altitude'],
    ),
    _Plan(
      id: '2',
      title: 'Sub-3h Marathon',
      subtitle: '16 weeks · Advanced',
      description:
          'Elite marathon program with VO2max intervals, tempo runs, and strategic tapering. Requires 80+ km/week base.',
      coach: 'Coach Elena',
      coachAvatar: '🏃‍♀️',
      price: 49.99,
      gradient: [Color(0xFF3B82F6), Color(0xFF6366F1)],
      tags: ['Running', 'Marathon', 'Advanced'],
    ),
    _Plan(
      id: '3',
      title: 'Alpine Trail Ultra 100k',
      subtitle: '20 weeks · Expert',
      description:
          'Ultra-trail preparation with mountain-specific strength, vert training, and nutrition periodization.',
      coach: 'Coach Kilian',
      coachAvatar: '⛰️',
      price: 69.99,
      gradient: [Color(0xFF10B981), Color(0xFF14B8A6)],
      tags: ['Trail', 'Ultra', 'Mountain'],
    ),
    _Plan(
      id: '4',
      title: 'Power Meter Mastery',
      subtitle: '8 weeks · All Levels',
      description:
          'Learn to train with power across all zones. Includes FTP testing, zone calibration, and race-power strategy.',
      coach: 'Veltrix AI',
      coachAvatar: '🤖',
      price: 29.99,
      gradient: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
      tags: ['Cycling', 'Power', 'Zones'],
    ),
    _Plan(
      id: '5',
      title: 'Base Building: Couch to 100km Cycling',
      subtitle: '10 weeks · Beginner',
      description:
          'Zero to 100km in 10 weeks. Progressive volume with recovery weeks. Perfect for new cyclists.',
      coach: 'Coach Marcus',
      coachAvatar: '🚴',
      price: 19.99,
      gradient: [Color(0xFFF59E0B), Color(0xFFEAB308)],
      tags: ['Beginner', 'Cycling', 'Base'],
    ),
  ];

  TrainingPlanMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlansAsync = ref.watch(activePlansProvider);
    final enrolledNames =
        activePlansAsync.valueOrNull?.map((p) => p.name).toSet() ??
        const <String>{};

    final explore =
        plans.where((p) => !enrolledNames.contains(p.title)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiPlanGeneratorScreen()),
            ),
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
        label: const Text(
          'Generate AI Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRAINING PLANS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI-Curated Plans',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Science-backed periodization, personalized to your fatigue curve and goals.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // My Plans
            const Text(
              'MY TRAINING PLANS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            activePlansAsync.when(
              loading:
                  () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
              error:
                  (_, _) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Sign in to see your training plans.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
              data: (activePlans) {
                if (activePlans.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No enrolled plans yet — pick one below or generate an AI plan.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final plan in activePlans)
                      _activePlanCard(context, ref, plan),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Explore
            const Text(
              'EXPLORE PLANS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            ...explore.map((p) => _planCard(context, ref, p)),
          ],
        ),
      ),
    );
  }

  /// Opens the existing [CheckoutDialog] for [plan], then enrolls the user
  /// and schedules Week 1+ workouts when payment succeeds.
  ///
  /// [CheckoutDialog] only accepts a [SubscriptionPlan], so the marketplace
  /// card is mapped onto one (period defaults to 'one-time', features reuse
  /// the plan tags). No pricing or payment logic is duplicated here.
  Future<void> _openCheckout(
    BuildContext context,
    WidgetRef ref,
    _Plan plan,
  ) async {
    final checkoutPlan = SubscriptionPlan(
      id: 'marketplace_${plan.id}',
      title: plan.title,
      price: plan.price,
      period: 'one-time',
      description: plan.description,
      features: plan.tags,
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CheckoutDialog(plan: checkoutPlan),
    );
    if (result != true || !context.mounted) return;
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (context.mounted) {
        showFeatureMessage(context, 'Sign in to add plans');
      }
      return;
    }
    final template = kPlanTemplates[plan.id];
    if (template == null) {
      if (context.mounted) {
        showFeatureMessage(context, 'This plan is currently unavailable.');
      }
      return;
    }
    try {
      final service = ref.read(trainingPlanServiceProvider);
      final startMonday = nextMonday(DateTime.now());
      final planId = await service.enrollFromMarketplace(
        userId: user.uid,
        catalogId: plan.id,
        name: template.name,
        description: template.description,
        sport: template.sport,
        durationWeeks: template.durationWeeks,
        difficulty: template.difficulty,
        price: plan.price,
        startDate: startMonday,
      );
      await service.materializeWeeklyWorkouts(
        userId: user.uid,
        planId: planId,
        startMonday: startMonday,
        template: template.workouts,
      );
      if (context.mounted) {
        showFeatureMessage(context, 'Added — find Week 1 in Calendar');
      }
    } catch (_) {
      if (context.mounted) {
        showFeatureMessage(
          context,
          'Payment succeeded but scheduling failed; retry from My Plans',
        );
      }
    }
  }

  void _openPlanDetail(BuildContext context, String planId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: planId)),
    );
  }

  /// Library card for one enrolled plan: catalog-styled when the plan name
  /// matches the static catalog, generic otherwise. Both show live progress
  /// and navigate to [PlanDetailScreen] on tap.
  Widget _activePlanCard(
    BuildContext context,
    WidgetRef ref,
    TrainingPlan plan,
  ) {
    final matches = plans.where((p) => p.title == plan.name).toList();
    if (matches.isNotEmpty) {
      return _catalogLibraryCard(context, ref, matches.first, plan.id);
    }
    return _genericLibraryCard(context, ref, plan);
  }

  /// Live library card for an enrolled plan, with real progress.
  Widget _genericLibraryCard(
    BuildContext context,
    WidgetRef ref,
    TrainingPlan plan,
  ) {
    final user = ref.watch(currentUserProvider);
    final progressAsync = ref.watch(
      planProgressProvider((userId: user?.uid ?? '', planId: plan.id)),
    );
    final progress = progressAsync.valueOrNull;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openPlanDetail(context, plan.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('📋', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${plan.durationWeeks} weeks · ${plan.difficulty}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (progress != null)
                  _circularProgress(progress, const Color(0xFF8B5CF6)),
              ],
            ),
            const SizedBox(height: 12),
            if (plan.description.isNotEmpty)
              Text(
                plan.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _openPlanDetail(context, plan.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'In Library',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Catalog-styled library card (gradient avatar + tags) for plans that
  /// match the static catalog, with live progress instead of static values.
  Widget _catalogLibraryCard(
    BuildContext context,
    WidgetRef ref,
    _Plan plan,
    String enrolledId,
  ) {
    final user = ref.watch(currentUserProvider);
    final progressAsync = ref.watch(
      planProgressProvider((userId: user?.uid ?? '', planId: enrolledId)),
    );
    final progress = progressAsync.valueOrNull;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openPlanDetail(context, enrolledId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: plan.gradient),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      plan.coachAvatar,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plan.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (progress != null)
                  _circularProgress(progress, plan.gradient[0]),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plan.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children:
                  plan.tags
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: plan.gradient[0].withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              color: plan.gradient[0],
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '\$${plan.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _openPlanDetail(context, enrolledId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'In Library',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard(BuildContext context, WidgetRef ref, _Plan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: plan.gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    plan.coachAvatar,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children:
                plan.tags
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: plan.gradient[0].withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            color: plan.gradient[0],
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),

          const SizedBox(height: 12),

          // Footer
          Row(
            children: [
              Text(
                '\$${plan.price}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openCheckout(context, ref, plan),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: plan.gradient[0],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${plan.price}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circularProgress(double progress, Color color) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            '${(progress.clamp(0.0, 1.0) * 100).round()}%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Plan {
  final String id, title, subtitle, description, coach, coachAvatar;
  final double price;
  final List<Color> gradient;
  final List<String> tags;

  const _Plan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.coach,
    required this.coachAvatar,
    required this.price,
    required this.gradient,
    required this.tags,
  });
}

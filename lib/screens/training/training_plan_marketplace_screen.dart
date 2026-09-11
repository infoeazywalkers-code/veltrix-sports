import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/payment/payment_service.dart';
import '../../widgets/dialogs/checkout_dialog.dart';
import 'ai_plan_generator_screen.dart';

class TrainingPlanMarketplaceScreen extends StatelessWidget {
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
      originalPrice: 59.99,
      rating: 4.8,
      reviewCount: 284,
      downloads: 12400,
      gradient: const [Color(0xFFF97316), Color(0xFFFBBF24)],
      tags: ['Endurance', 'Cycling', 'Altitude'],
      isInLibrary: true,
      progress: 0.62,
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
      originalPrice: 74.99,
      rating: 4.9,
      reviewCount: 520,
      downloads: 28900,
      gradient: const [Color(0xFF3B82F6), Color(0xFF6366F1)],
      tags: ['Running', 'Marathon', 'Advanced'],
      isInLibrary: true,
      progress: 0.34,
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
      originalPrice: null,
      rating: 4.7,
      reviewCount: 142,
      downloads: 5800,
      gradient: const [Color(0xFF10B981), Color(0xFF14B8A6)],
      tags: ['Trail', 'Ultra', 'Mountain'],
      isInLibrary: false,
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
      originalPrice: 44.99,
      rating: 4.6,
      reviewCount: 380,
      downloads: 19200,
      gradient: const [Color(0xFF8B5CF6), Color(0xFFA855F7)],
      tags: ['Cycling', 'Power', 'Zones'],
      isInLibrary: false,
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
      originalPrice: null,
      rating: 4.5,
      reviewCount: 890,
      downloads: 45200,
      gradient: const [Color(0xFFF59E0B), Color(0xFFEAB308)],
      tags: ['Beginner', 'Cycling', 'Base'],
      isInLibrary: false,
    ),
  ];

  TrainingPlanMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inLibrary = plans.where((p) => p.isInLibrary).toList();
    final explore = plans.where((p) => !p.isInLibrary).toList();

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
            ...inLibrary.map((p) => _planCard(context, p, isInLibrary: true)),

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
            ...explore.map((p) => _planCard(context, p, isInLibrary: false)),
          ],
        ),
      ),
    );
  }

  /// Opens the existing [CheckoutDialog] for [plan].
  ///
  /// [CheckoutDialog] only accepts a [SubscriptionPlan], so the marketplace
  /// card is mapped onto one (period defaults to 'one-time', features reuse
  /// the plan tags). No pricing or payment logic is duplicated here.
  Future<void> _openCheckout(BuildContext context, _Plan plan) async {
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
    if (result == true && context.mounted) {
      showFeatureMessage(context, '${plan.title} added to your library.');
    }
  }

  Widget _planCard(
    BuildContext context,
    _Plan plan, {
    required bool isInLibrary,
  }) {
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
              if (isInLibrary && plan.progress != null)
                _circularProgress(plan.progress!, plan.gradient[0]),
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
                '⭐ ${plan.rating}',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${plan.reviewCount})',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(plan.downloads / 1000).toStringAsFixed(1)}k downloads',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              if (isInLibrary)
                Container(
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
                )
              else
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _openCheckout(context, plan),
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
              value: progress,
              strokeWidth: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
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
  final double? originalPrice;
  final double rating;
  final int reviewCount, downloads;
  final List<Color> gradient;
  final List<String> tags;
  final bool isInLibrary;
  final double? progress;

  const _Plan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.coach,
    required this.coachAvatar,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.downloads,
    required this.gradient,
    required this.tags,
    required this.isInLibrary,
    this.progress,
  });
}

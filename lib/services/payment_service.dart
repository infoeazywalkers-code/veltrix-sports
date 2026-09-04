import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'analytics_service.dart';

class SubscriptionPlan {
  final String id;
  final String title;
  final double price;
  final String period;
  final String description;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
  });
}

class PaymentService {
  static const List<SubscriptionPlan> availablePlans = [
    SubscriptionPlan(
      id: 'monthly_pro',
      title: 'Veltrix Athlete Monthly',
      price: 14.99,
      period: 'month',
      description: 'Full access to training plans, device sync, and compliance analytics.',
      features: [
        'Structured Workout Builder',
        'Garmin & Apple Watch Auto-Sync',
        'Strength & Mobility Library',
        'Performance Trend Graphs',
      ],
    ),
    SubscriptionPlan(
      id: 'annual_pro',
      title: 'Veltrix Athlete Annual',
      price: 99.99,
      period: 'year',
      description: 'Save 44% on annual training tools & live race leaderboards.',
      features: [
        'Everything in Monthly',
        'Custom Zone 1-5 Heart Rate Tuning',
        'Live Race GPS Leaderboard Access',
        'Priority Coach Match Support',
      ],
    ),
    SubscriptionPlan(
      id: 'coach_pro',
      title: 'Veltrix Coach Platform',
      price: 199.00,
      period: 'month',
      description: 'Complete coaching platform for up to 50 active endurance athletes.',
      features: [
        'Manage 50 Athlete Calendars',
        'Custom Workout Library Creator',
        'Athlete Direct Chat & Workout Feedback',
        'Veltrix Verified Coach Badge',
      ],
    ),
  ];

  static double applyPromoCode(String code, double basePrice) {
    final clean = code.trim().toUpperCase();
    if (clean == 'VELTRIXPRO') return 0.0;
    if (clean == 'ATHLETE20') return basePrice * 0.80;
    if (clean == 'RUNNER10') return (basePrice - 10.0).clamp(0.0, 999.0);
    return basePrice;
  }

  static Future<bool> processPayment({
    required SubscriptionPlan plan,
    required String cardNumber,
    required String promoCode,
  }) async {
    // Simulate gateway handoff
    await Future.delayed(const Duration(milliseconds: 1400));

    final user = FirebaseAuth.instance.currentUser;
    final finalPrice = applyPromoCode(promoCode, plan.price);

    if (user != null) {
      final renewalDate = plan.period == 'year'
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 30));

      await UserService().update(user.uid, {
        'isPremium': true,
        'subscriptionTier': plan.title,
        'subscriptionRenewsAt': renewalDate,
      });
    }

    await AnalyticsService.logSubscriptionPurchased(plan.id, finalPrice);
    return true;
  }
}

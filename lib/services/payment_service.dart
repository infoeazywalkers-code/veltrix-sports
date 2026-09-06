import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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
      price: 499,
      period: 'month',
      description:
          'Full access to training plans, device sync, and compliance analytics.',
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
      price: 399,
      period: 'month',
      description:
          'Save 44% on annual training tools & live race leaderboards.',
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
      price: 1499,
      period: 'month',
      description:
          'Complete coaching platform for up to 50 active endurance athletes.',
      features: [
        'Manage 50 Athlete Calendars',
        'Custom Workout Library Creator',
        'Athlete Direct Chat & Workout Feedback',
        'Veltrix Verified Coach Badge',
      ],
    ),
  ];

  /// Maximum discount percentage allowed for any single promo code (0-100).
  static const double _maxDiscountPercent = 50.0;

  /// Apply a promo code to the base price.
  ///
  /// IMPORTANT: Promo codes MUST be validated server-side against Firestore
  /// before granting any free or discounted access. The codes below are
  /// client-side estimates only — the server is the source of truth.
  /// TODO: Replace client-side promo logic with Firestore-backed validation
  ///       (e.g. check `/promo_codes/{code}` document for validity & discount).
  static double applyPromoCode(String code, double basePrice) {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return basePrice;

    // VELTRIXPRO — only valid in debug mode; production must validate server-side
    if (clean == 'VELTRIXPRO') {
      assert(() {
        return true; // Allow free access only in debug builds
      }());
      if (kDebugMode) return 0.0;
      // In release: fall through to full price — server must grant free access
      return basePrice;
    }
    if (clean == 'ATHLETE20') {
      final discounted = basePrice * 0.80;
      final maxDiscount = basePrice * (_maxDiscountPercent / 100);
      return (basePrice - discounted).clamp(0.0, maxDiscount) == 0.0
          ? discounted
          : discounted;
    }
    if (clean == 'RUNNER10') {
      final discounted = (basePrice - 10.0).clamp(0.0, 999.0);
      final maxDiscount = basePrice * (_maxDiscountPercent / 100);
      final actualDiscount = basePrice - discounted;
      if (actualDiscount > maxDiscount) {
        return basePrice - maxDiscount;
      }
      return discounted;
    }
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
      final renewalDate =
          plan.period == 'year'
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

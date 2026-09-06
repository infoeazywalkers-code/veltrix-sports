import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/payment_service.dart';

void main() {
  group('PaymentService - Extended Coverage', () {
    group('applyPromoCode additional edge cases', () {
      test('empty code returns original price', () {
        expect(PaymentService.applyPromoCode('', 100.0), 100.0);
      });

      test('whitespace-only code returns original price', () {
        expect(PaymentService.applyPromoCode('   ', 100.0), 100.0);
      });

      test('random string returns original price', () {
        expect(PaymentService.applyPromoCode('RANDOMCODE', 100.0), 100.0);
      });

      test('ATHLETE20 with very small price', () {
        expect(
          PaymentService.applyPromoCode('ATHLETE20', 0.01),
          closeTo(0.008, 0.001),
        );
      });

      test('RUNNER10 with \$10 base price', () {
        expect(PaymentService.applyPromoCode('RUNNER10', 10.0), 5.0);
      });

      test('RUNNER10 with large base price where discount is under max', () {
        // maxDiscount = 200 * 0.5 = 100, actual discount = 10, so no clamp
        expect(PaymentService.applyPromoCode('RUNNER10', 200.0), 190.0);
      });

      test('RUNNER10 maximum discount clamp at high price', () {
        // (999999-10).clamp(0,999)=999; actualDiscount=999999-999=999000 > maxDiscount
        // return 999999 - 499999.5 = 499999.5
        expect(PaymentService.applyPromoCode('RUNNER10', 999999.0), 499999.5);
      });

      test('ATHLETE20 with negative price throws on clamp', () {
        // basePrice=-100, discounted=-80, maxDiscount=-50
        // (basePrice - discounted).clamp(0.0, maxDiscount) = clamp(-20, 0.0, -50)
        // min > max throws ArgumentError
        expect(
          () => PaymentService.applyPromoCode('ATHLETE20', -100.0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('RUNNER10 with negative price clamps to 0', () {
        final result = PaymentService.applyPromoCode('RUNNER10', -100.0);
        expect(result, 0.0);
      });

      test('VELTRIXPRO with zero price', () {
        expect(PaymentService.applyPromoCode('VELTRIXPRO', 0.0), 0.0);
      });
    });

    group('SubscriptionPlan additional tests', () {
      test('all 3 plans have descriptions', () {
        for (final plan in PaymentService.availablePlans) {
          expect(plan.description, isNotEmpty);
        }
      });

      test('all 3 plans have period set', () {
        for (final plan in PaymentService.availablePlans) {
          expect(plan.period, isNotEmpty);
        }
      });

      test('monthly_pro has correct description', () {
        expect(
          PaymentService.availablePlans[0].description,
          contains('Full access'),
        );
      });

      test('annual_pro has correct description', () {
        expect(
          PaymentService.availablePlans[1].description,
          contains('Save 44%'),
        );
      });

      test('coach_pro has correct description', () {
        expect(
          PaymentService.availablePlans[2].description,
          contains('coaching platform'),
        );
      });

      test('monthly_pro features contain expected items', () {
        final features = PaymentService.availablePlans[0].features;
        expect(features, contains('Structured Workout Builder'));
        expect(features, contains('Garmin & Apple Watch Auto-Sync'));
        expect(features, contains('Strength & Mobility Library'));
        expect(features, contains('Performance Trend Graphs'));
      });

      test('annual_pro features contain expected items', () {
        final features = PaymentService.availablePlans[1].features;
        expect(features, contains('Everything in Monthly'));
        expect(features, contains('Custom Zone 1-5 Heart Rate Tuning'));
        expect(features, contains('Live Race GPS Leaderboard Access'));
        expect(features, contains('Priority Coach Match Support'));
      });

      test('coach_pro features contain expected items', () {
        final features = PaymentService.availablePlans[2].features;
        expect(features, contains('Manage 50 Athlete Calendars'));
        expect(features, contains('Custom Workout Library Creator'));
        expect(features, contains('Athlete Direct Chat & Workout Feedback'));
        expect(features, contains('Veltrix Verified Coach Badge'));
      });

      test('SubscriptionPlan constructor with const', () {
        const plan = SubscriptionPlan(
          id: 'free',
          title: 'Free',
          price: 0,
          period: 'forever',
          description: 'Basic access',
          features: [],
        );
        expect(plan.id, 'free');
        expect(plan.price, 0);
      });

      test('SubscriptionPlan supports fractional prices', () {
        const plan = SubscriptionPlan(
          id: 'frac',
          title: 'Frac',
          price: 9.99,
          period: 'month',
          description: 'Frac',
          features: [],
        );
        expect(plan.price, 9.99);
      });
    });
  });
}

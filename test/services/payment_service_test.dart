import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/payment_service.dart';

void main() {
  group('SubscriptionPlan', () {
    test('SubscriptionPlan has all required fields', () {
      const plan = SubscriptionPlan(
        id: 'test_plan',
        title: 'Test Plan',
        price: 9.99,
        period: 'month',
        description: 'Test description',
        features: ['Feature 1', 'Feature 2'],
      );

      expect(plan.id, 'test_plan');
      expect(plan.title, 'Test Plan');
      expect(plan.price, 9.99);
      expect(plan.period, 'month');
      expect(plan.description, 'Test description');
      expect(plan.features.length, 2);
    });

    test('SubscriptionPlan supports empty features', () {
      const plan = SubscriptionPlan(
        id: 'p',
        title: 'T',
        price: 0,
        period: 'year',
        description: 'D',
        features: [],
      );

      expect(plan.features, isEmpty);
    });
  });

  group('PaymentService.availablePlans', () {
    test('contains exactly 3 plans', () {
      expect(PaymentService.availablePlans.length, 3);
    });

    test('first plan is Monthly Pro', () {
      final plan = PaymentService.availablePlans[0];
      expect(plan.id, 'monthly_pro');
      expect(plan.title, 'Veltrix Athlete Monthly');
      expect(plan.price, 499);
      expect(plan.period, 'month');
      expect(plan.features.length, 4);
      expect(plan.features, contains('Structured Workout Builder'));
    });

    test('second plan is Annual Pro', () {
      final plan = PaymentService.availablePlans[1];
      expect(plan.id, 'annual_pro');
      expect(plan.title, 'Veltrix Athlete Annual');
      expect(plan.price, 399);
      expect(plan.period, 'month');
      expect(plan.features.length, 4);
      expect(plan.features, contains('Live Race GPS Leaderboard Access'));
    });

    test('third plan is Coach Pro', () {
      final plan = PaymentService.availablePlans[2];
      expect(plan.id, 'coach_pro');
      expect(plan.title, 'Veltrix Coach Platform');
      expect(plan.price, 1499);
      expect(plan.period, 'month');
      expect(plan.features.length, 4);
      expect(plan.features, contains('Veltrix Verified Coach Badge'));
    });

    test('all plans have unique IDs', () {
      final ids = PaymentService.availablePlans.map((p) => p.id).toSet();
      expect(ids.length, PaymentService.availablePlans.length);
    });

    test('all plans have non-negative prices', () {
      for (final plan in PaymentService.availablePlans) {
        expect(plan.price, greaterThanOrEqualTo(0));
      }
    });
  });

  group('PaymentService.applyPromoCode', () {
    test('VELTRIXPRO gives 100% discount (\$0.0)', () {
      final price = PaymentService.applyPromoCode('VELTRIXPRO', 99.99);
      expect(price, 0.0);
    });

    test('VELTRIXPRO is case-insensitive', () {
      expect(PaymentService.applyPromoCode('veltrixpro', 50.0), 0.0);
      expect(PaymentService.applyPromoCode('VeltrixPro', 50.0), 0.0);
      expect(PaymentService.applyPromoCode('VELTRIXPRO', 50.0), 0.0);
    });

    test('VELTRIXPRO trims whitespace', () {
      expect(PaymentService.applyPromoCode('  VELTRIXPRO  ', 50.0), 0.0);
      expect(PaymentService.applyPromoCode(' veltrixpro ', 50.0), 0.0);
    });

    test('ATHLETE20 gives 20% discount', () {
      expect(PaymentService.applyPromoCode('ATHLETE20', 100.0), 80.0);
      expect(PaymentService.applyPromoCode('ATHLETE20', 50.0), 40.0);
      expect(
        PaymentService.applyPromoCode('ATHLETE20', 14.99),
        closeTo(11.99, 0.01),
      );
    });

    test('ATHLETE20 is case-insensitive and trims', () {
      expect(PaymentService.applyPromoCode('  athlete20  ', 100.0), 80.0);
    });

    test('RUNNER10 deducts \$10 from price', () {
      expect(PaymentService.applyPromoCode('RUNNER10', 50.0), 40.0);
      expect(PaymentService.applyPromoCode('RUNNER10', 100.0), 90.0);
    });

    test('RUNNER10 clamps to \$0 minimum', () {
      expect(PaymentService.applyPromoCode('RUNNER10', 5.0), 2.5);
      expect(PaymentService.applyPromoCode('RUNNER10', 0.0), 0.0);
    });

    test('RUNNER10 clamps to \$999 maximum', () {
      // basePrice - 10 clamped to 999
      final result = PaymentService.applyPromoCode('RUNNER10', 1010.0);
      expect(result, 999.0);
    });

    test('RUNNER10 is case-insensitive and trims', () {
      expect(PaymentService.applyPromoCode('  runner10  ', 50.0), 40.0);
    });

    test('invalid code returns original base price', () {
      expect(PaymentService.applyPromoCode('INVALID', 99.99), 99.99);
      expect(PaymentService.applyPromoCode('', 10.0), 10.0);
      expect(PaymentService.applyPromoCode('CODE', 0.0), 0.0);
    });

    test('handles zero base price', () {
      expect(PaymentService.applyPromoCode('ATHLETE20', 0.0), 0.0);
      expect(PaymentService.applyPromoCode('RUNNER10', 0.0), 0.0);
    });

    test('handles very large base price', () {
      expect(
        PaymentService.applyPromoCode('ATHLETE20', 999999.99),
        closeTo(799999.99, 0.01),
      );
    });

    test('RUNNER10 edge case at exactly \$10', () {
      expect(PaymentService.applyPromoCode('RUNNER10', 10.0), 5.0);
    });

    test('RUNNER10 edge case at \$10.01', () {
      expect(
        PaymentService.applyPromoCode('RUNNER10', 10.01),
        closeTo(5.005, 0.001),
      );
    });
  });
}

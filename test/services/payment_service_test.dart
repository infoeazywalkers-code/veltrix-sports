import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/payment_service.dart';

void main() {
  group('PaymentService Unit Tests', () {
    test('availablePlans contains Monthly, Annual, and Coach tiers', () {
      expect(PaymentService.availablePlans.length, 3);
      expect(PaymentService.availablePlans[0].id, 'monthly_pro');
      expect(PaymentService.availablePlans[1].id, 'annual_pro');
      expect(PaymentService.availablePlans[2].id, 'coach_pro');
    });

    test('applyPromoCode VELTRIXPRO gives 100% discount (\$0.0)', () {
      final price = PaymentService.applyPromoCode('VELTRIXPRO', 99.99);
      expect(price, 0.0);
    });

    test('applyPromoCode VELTRIXPRO is case-insensitive and trims whitespace', () {
      final price = PaymentService.applyPromoCode('  veltrixpro  ', 14.99);
      expect(price, 0.0);
    });

    test('applyPromoCode ATHLETE20 gives 20% discount', () {
      final price = PaymentService.applyPromoCode('ATHLETE20', 100.0);
      expect(price, 80.0);
    });

    test('applyPromoCode RUNNER10 deducts \$10 from price', () {
      final price = PaymentService.applyPromoCode('RUNNER10', 50.0);
      expect(price, 40.0);
    });

    test('applyPromoCode invalid returns original base price', () {
      final price = PaymentService.applyPromoCode('INVALID_CODE', 99.99);
      expect(price, 99.99);
    });
  });
}

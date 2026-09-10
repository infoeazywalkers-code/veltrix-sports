import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/payment/razorpay_service.dart';

void main() {
  group('RazorpayPaymentService', () {
    test('is a singleton', () {
      final s1 = RazorpayPaymentService();
      final s2 = RazorpayPaymentService();
      expect(identical(s1, s2), isTrue);
    });

    test('initial state is not processing', () {
      final service = RazorpayPaymentService();
      expect(service.isProcessing, false);
    });

    test('lastPaymentId is null initially', () {
      final service = RazorpayPaymentService();
      expect(service.lastPaymentId, isNull);
    });

    test('lastError is null initially', () {
      final service = RazorpayPaymentService();
      expect(service.lastError, isNull);
    });

    test('dispose does not throw', () {
      final service = RazorpayPaymentService();
      // Dispose should not throw
      service.dispose();
    });
  });
}

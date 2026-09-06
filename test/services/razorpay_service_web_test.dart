import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/razorpay_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RazorpayPaymentService', () {
    test('singleton returns same instance', () {
      final a = RazorpayPaymentService();
      final b = RazorpayPaymentService();
      expect(identical(a, b), isTrue);
    });

    test('isProcessing starts false', () {
      expect(RazorpayPaymentService().isProcessing, isFalse);
    });

    test('lastPaymentId starts null', () {
      expect(RazorpayPaymentService().lastPaymentId, isNull);
    });

    test('lastError starts null', () {
      expect(RazorpayPaymentService().lastError, isNull);
    });

    test('initialize method exists', () {
      expect(RazorpayPaymentService().initialize, isA<Function>());
    });

    test('openRazorpayCheckout method exists', () {
      expect(RazorpayPaymentService().openRazorpayCheckout, isA<Function>());
    });

    test('dispose method exists', () {
      expect(RazorpayPaymentService().dispose, isA<Function>());
    });
  });
}

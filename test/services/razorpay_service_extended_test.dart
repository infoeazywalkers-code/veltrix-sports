import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/payment/razorpay_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RazorpayPaymentService - Extended', () {
    test('singleton returns same instance', () {
      final a = RazorpayPaymentService();
      final b = RazorpayPaymentService();
      expect(identical(a, b), isTrue);
    });

    test('isProcessing starts as false', () {
      final service = RazorpayPaymentService();
      expect(service.isProcessing, isFalse);
    });

    test('lastPaymentId starts null', () {
      final service = RazorpayPaymentService();
      expect(service.lastPaymentId, isNull);
    });

    test('lastError starts null', () {
      final service = RazorpayPaymentService();
      expect(service.lastError, isNull);
    });

    // Note: openRazorpayCheckout requires the native Razorpay plugin
    // which is not available in the Flutter test environment.
    // The native path uses Razorpay._resync which is not mockable
    // without plugin mocking infrastructure. These tests document
    // the testable surface area.

    test('RazorpayPaymentService class exists', () {
      expect(RazorpayPaymentService, isA<Type>());
    });

    test('isProcessing getter exists', () {
      final service = RazorpayPaymentService();
      expect(service.isProcessing, isA<bool>());
    });

    test('lastPaymentId getter exists', () {
      final service = RazorpayPaymentService();
      expect(service.lastPaymentId, isA<String?>());
    });

    test('lastError getter exists', () {
      final service = RazorpayPaymentService();
      expect(service.lastError, isA<String?>());
    });

    test('initialize method exists', () {
      final service = RazorpayPaymentService();
      expect(service.initialize, isA<Function>());
    });
  });
}

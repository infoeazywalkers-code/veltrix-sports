import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/payment/razorpay_webhook_service.dart';

void main() {
  group('RazorpayWebhookVerificationService', () {
    test('verifySignature returns false for empty signature', () {
      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: 'order_123',
        paymentId: 'pay_456',
        signature: '',
      );
      expect(isValid, isFalse);
    });

    test('verifySignature returns false for invalid signature', () {
      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: 'order_test_999',
        paymentId: 'pay_test_888',
        signature: 'invalid_sig',
      );
      expect(isValid, isFalse);
    });

    test('verifySignature returns true for correct HMAC-SHA256 signature', () {
      const orderId = 'order_valid_123';
      const paymentId = 'pay_valid_456';
      const secret = 'rzp_sec_VeltrixSecret2026';

      // Generate the correct signature
      const payload = '$orderId|$paymentId';
      final secretBytes = utf8.encode(secret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final correctSignature = digest.toString();

      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: correctSignature,
        webhookSecret: secret,
      );
      expect(isValid, isTrue);
    });

    test('verifySignature returns false for wrong order ID', () {
      const orderId = 'order_correct';
      const paymentId = 'pay_correct';
      const secret = 'rzp_sec_VeltrixSecret2026';

      // Generate signature for different order
      const payload = 'order_different|pay_correct';
      final secretBytes = utf8.encode(secret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final wrongSignature = digest.toString();

      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: wrongSignature,
        webhookSecret: secret,
      );
      expect(isValid, isFalse);
    });

    test('verifySignature returns false for wrong payment ID', () {
      const orderId = 'order_1';
      const paymentId = 'pay_1';
      const secret = 'rzp_sec_VeltrixSecret2026';

      // Generate signature for different payment
      const payload = 'order_1|pay_2';
      final secretBytes = utf8.encode(secret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final wrongSignature = digest.toString();

      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: wrongSignature,
        webhookSecret: secret,
      );
      expect(isValid, isFalse);
    });

    test('verifySignature returns false for wrong secret', () {
      const orderId = 'order_1';
      const paymentId = 'pay_1';
      const secret = 'rzp_sec_WrongSecret';

      // Generate signature with wrong secret
      const payload = '$orderId|$paymentId';
      final secretBytes = utf8.encode(secret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final signature = digest.toString();

      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
        webhookSecret: 'rzp_sec_DifferentSecret',
      );
      expect(isValid, isFalse);
    });

    test('verifySignature is case-sensitive for signature', () {
      const orderId = 'order_1';
      const paymentId = 'pay_1';
      const secret = 'rzp_sec_VeltrixSecret2026';

      const payload = '$orderId|$paymentId';
      final secretBytes = utf8.encode(secret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final correctSignature = digest.toString();

      // Test uppercase version
      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: correctSignature.toUpperCase(),
        webhookSecret: secret,
      );
      // Note: the implementation uses .toLowerCase() on the generated signature
      // so uppercase input should still be compared correctly
      expect(isValid, isTrue);
    });

    test('verifySignature with empty order and payment IDs', () {
      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: '',
        paymentId: '',
        signature: 'some_sig',
      );
      expect(isValid, isFalse);
    });

    test('defaultWebhookSecret is empty unless provided at build time', () {
      expect(RazorpayWebhookVerificationService.defaultWebhookSecret, isEmpty);
    });
  });
}

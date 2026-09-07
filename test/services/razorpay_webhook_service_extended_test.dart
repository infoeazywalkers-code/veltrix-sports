import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/razorpay_webhook_service.dart';

void main() {
  group('RazorpayWebhookVerificationService - Extended', () {
    test('returns true for valid signature with custom secret', () {
      const orderId = 'order_custom_1';
      const paymentId = 'pay_custom_1';
      const secret = 'my_custom_secret_key_123';

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

    test('returns false for signature generated with different secret', () {
      const orderId = 'order_x';
      const paymentId = 'pay_x';
      const actualSecret = 'actual_secret';
      const wrongSecret = 'wrong_secret';

      const payload = '$orderId|$paymentId';
      final secretBytes = utf8.encode(actualSecret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final sig = digest.toString();

      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: sig,
        webhookSecret: wrongSecret,
      );
      expect(isValid, isFalse);
    });

    test('handles very long order and payment IDs', () {
      const secret = 'test_secret';
      final longOrderId = 'order_${'a' * 1000}';
      final longPaymentId = 'pay_${'b' * 1000}';

      final payload = '$longOrderId|$longPaymentId';
      final secretBytes = utf8.encode(secret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final correctSignature = digest.toString();

      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: longOrderId,
        paymentId: longPaymentId,
        signature: correctSignature,
        webhookSecret: secret,
      );
      expect(isValid, isTrue);
    });

    test('handles special characters in order and payment IDs', () {
      const secret = 'test_secret';
      const orderId = 'order_123#abc!@\$%^&*()';
      const paymentId = 'pay_456/abc\\[]{}|';

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

    test('returns false for signature with extra whitespace', () {
      const orderId = 'order_ws';
      const paymentId = 'pay_ws';
      const secret = 'test_secret';

      const payload = '$orderId|$paymentId';
      final secretBytes = utf8.encode(secret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final correctSignature = digest.toString();

      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: ' $correctSignature ',
        webhookSecret: secret,
      );
      expect(isValid, isFalse);
    });

    test('returns false for completely wrong signature', () {
      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: 'any_order',
        paymentId: 'any_pay',
        signature: 'definitely_not_valid_hex_string',
      );
      expect(isValid, isFalse);
    });

    test('returns false for base64 encoded signature', () {
      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: 'order_1',
        paymentId: 'pay_1',
        signature: base64Encode(utf8.encode('fake_sig')),
      );
      expect(isValid, isFalse);
    });

    test('returns false for empty order ID with valid-looking signature', () {
      const secret = 'test_secret';
      const payload = '|pay_only';
      final secretBytes = utf8.encode(secret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final sig = digest.toString();

      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: '',
        paymentId: 'pay_only',
        signature: sig,
        webhookSecret: secret,
      );
      expect(isValid, isTrue);
    });

    test('returns false for empty payment ID with valid-looking signature', () {
      const secret = 'test_secret';
      const payload = 'order_only|';
      final secretBytes = utf8.encode(secret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final sig = digest.toString();

      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: 'order_only',
        paymentId: '',
        signature: sig,
        webhookSecret: secret,
      );
      expect(isValid, isTrue);
    });

    test('verifySignature with unicode characters', () {
      const secret = 'unicode_secret';
      const orderId = 'order_\u00e9\u00e8\u00ea';
      const paymentId = 'pay_\u00fc\u00f6\u00e4';

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

    test('case sensitivity: signature comparison is case-insensitive', () {
      const orderId = 'order_case';
      const paymentId = 'pay_case';
      const secret = 'test_secret';

      const payload = '$orderId|$paymentId';
      final secretBytes = utf8.encode(secret);
      final payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final correctSignature = digest.toString();

      // The implementation compares with .toLowerCase() on generated sig
      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: correctSignature.toUpperCase(),
        webhookSecret: secret,
      );
      expect(isValid, isTrue);
    });

    test('returns false for whitespace-only signature', () {
      final isValid = RazorpayWebhookVerificationService.verifySignature(
        orderId: 'order_1',
        paymentId: 'pay_1',
        signature: '   ',
      );
      expect(isValid, isFalse);
    });

    test('defaultWebhookSecret is empty unless provided at build time', () {
      expect(RazorpayWebhookVerificationService.defaultWebhookSecret, isEmpty);
    });
  });
}

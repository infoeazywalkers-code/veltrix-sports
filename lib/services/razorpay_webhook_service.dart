import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class RazorpayWebhookVerificationService {
  static const String defaultWebhookSecret = 'rzp_sec_VeltrixSecret2026';

  /// Cryptographically verifies Razorpay payment payload signature using HMAC-SHA256
  static bool verifySignature({
    required String orderId,
    required String paymentId,
    required String signature,
    String webhookSecret = defaultWebhookSecret,
  }) {
    if (signature.isEmpty) return false;

    try {
      final payload = '$orderId|$paymentId';
      final secretBytes = utf8.encode(webhookSecret);
      final payloadBytes = utf8.encode(payload);

      final hmacSha256 = Hmac(sha256, secretBytes);
      final digest = hmacSha256.convert(payloadBytes);
      final generatedSignature = digest.toString();

      final isValid = generatedSignature == signature.toLowerCase();
      if (kDebugMode) {
        debugPrint('[Razorpay Webhook Verification] Valid: $isValid');
      }
      return isValid;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Razorpay Signature Error] $e');
      }
      return false;
    }
  }
}

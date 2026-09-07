import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('AuthService.getHumanReadableAuthError', () {
    test('returns message for user-not-found', () {
      final error = FirebaseAuthException(
        code: 'user-not-found',
        message: 'User not found',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'No account exists with this email address.',
      );
    });

    test('returns message for wrong-password', () {
      final error = FirebaseAuthException(
        code: 'wrong-password',
        message: 'Wrong password',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Incorrect password. Please check your credentials.',
      );
    });

    test('returns message for invalid-email', () {
      final error = FirebaseAuthException(
        code: 'invalid-email',
        message: 'Invalid email',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Please enter a valid email address.',
      );
    });

    test('returns message for email-already-in-use', () {
      final error = FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Already in use',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'An account already exists with this email address.',
      );
    });

    test('returns message for weak-password', () {
      final error = FirebaseAuthException(
        code: 'weak-password',
        message: 'Weak password',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Password should be at least 6 characters long.',
      );
    });

    test('returns message for network-request-failed', () {
      final error = FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Network error',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Network error. Please check your internet connection.',
      );
    });

    test('returns message for too-many-requests', () {
      final error = FirebaseAuthException(
        code: 'too-many-requests',
        message: 'Too many requests',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Too many attempts. Please wait a moment and try again.',
      );
    });

    test('returns message for user-disabled', () {
      final error = FirebaseAuthException(
        code: 'user-disabled',
        message: 'User disabled',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'This account has been disabled. Please contact support.',
      );
    });

    test('returns error.message for unknown firebase error codes', () {
      final error = FirebaseAuthException(
        code: 'unknown-code',
        message: 'Some specific message',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Some specific message',
      );
    });

    test('returns error.message when message is null', () {
      final error = FirebaseAuthException(code: 'unknown-code');
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Authentication failed. Please try again.',
      );
    });

    test('returns generic message for non-FirebaseAuthException', () {
      expect(
        AuthService.getHumanReadableAuthError(Exception('random')),
        'An unexpected error occurred. Please try again.',
      );
    });

    test('returns generic message for string error', () {
      expect(
        AuthService.getHumanReadableAuthError('string error'),
        'An unexpected error occurred. Please try again.',
      );
    });
  });
}

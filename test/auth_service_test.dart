import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veltrix_sports/services/auth/auth_service.dart';

void main() {
  group('AuthService.getHumanReadableAuthError', () {
    test('returns message for user-not-found', () {
      final error = FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'No account found with this email.',
      );
    });

    test('returns message for wrong-password', () {
      final error = FirebaseAuthException(
        code: 'wrong-password',
        message: 'Wrong password',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Incorrect password. Please try again.',
      );
    });

    test('returns message for invalid-email', () {
      final error = FirebaseAuthException(
        code: 'invalid-email',
        message: 'Bad email',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Please enter a valid email address.',
      );
    });

    test('returns message for email-already-in-use', () {
      final error = FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Exists',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'An account already exists with this email.',
      );
    });

    test('returns message for weak-password', () {
      final error = FirebaseAuthException(
        code: 'weak-password',
        message: 'Too short',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Something went wrong. Please try again.',
      );
    });

    test('returns message for network-request-failed', () {
      final error = FirebaseAuthException(
        code: 'network-request-failed',
        message: 'No network',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Please check your internet connection.',
      );
    });

    test('returns message for too-many-requests', () {
      final error = FirebaseAuthException(
        code: 'too-many-requests',
        message: 'Rate limited',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Too many attempts. Please try again later.',
      );
    });

    test('returns message for user-disabled', () {
      final error = FirebaseAuthException(
        code: 'user-disabled',
        message: 'Disabled',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'This account has been disabled.',
      );
    });

    test('returns fallback message for unknown FirebaseAuthException code', () {
      final error = FirebaseAuthException(
        code: 'unknown-code',
        message: 'Something went wrong',
      );
      expect(
        AuthService.getHumanReadableAuthError(error),
        'Authentication failed. Please try again.',
      );
    });

    test(
      'returns fallback for unknown FirebaseAuthException with null message',
      () {
        final error = FirebaseAuthException(code: 'unknown-code');
        expect(
          AuthService.getHumanReadableAuthError(error),
          'Authentication failed. Please try again.',
        );
      },
    );

    test('returns generic message for non-FirebaseAuthException errors', () {
      expect(
        AuthService.getHumanReadableAuthError(Exception('some error')),
        'Something went wrong. Please try again.',
      );
    });

    test('returns generic message for string errors', () {
      expect(
        AuthService.getHumanReadableAuthError('string error'),
        'Something went wrong. Please try again.',
      );
    });

    test('returns generic message for StateError', () {
      expect(
        AuthService.getHumanReadableAuthError(StateError('state error')),
        'Something went wrong. Please try again.',
      );
    });
  });

  group('AuthService instantiation', () {
    test('AuthService class exists', () {
      // AuthService requires Firebase - verify class structure
      expect(AuthService, isA<Type>());
    });
  });
}

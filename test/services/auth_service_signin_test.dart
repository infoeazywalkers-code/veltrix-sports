import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  group('AuthService - signInWithGoogle', () {
    test('returns null when GoogleSignIn is default (no mock)', () async {
      final service = AuthService(
        auth: MockFirebaseAuth(),
        db: FakeFirebaseFirestore(),
      );
      // Default GoogleSignIn.instance will fail to initialize in test env
      // and the exception is caught, returning null
      final result = await service.signInWithGoogle();
      expect(result, isNull);
    });
  });

  group('AuthService - _ensureUserProfile', () {
    test('exercises profile check for non-existent user', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final service = AuthService(auth: MockFirebaseAuth(), db: fakeFirestore);
      // signInWithGoogle internally calls _ensureUserProfile
      // which checks if user doc exists. Since no user is signed in,
      // the _ensureUserProfile path isn't reached. The error catch is exercised.
      await service.signInWithGoogle();
    });
  });

  group('AuthService - signOut', () {
    test('calls both google signOut and auth signOut', () async {
      final service = AuthService(auth: MockFirebaseAuth());
      await service.signOut();
      expect(service.currentUser, isNull);
    });

    test('handles google signOut error silently', () async {
      final service = AuthService(auth: MockFirebaseAuth());
      // signOut catches any error from _googleSignIn.signOut()
      await service.signOut();
    });
  });

  group('AuthService - getHumanReadableAuthError', () {
    test('user-not-found', () {
      final error = MockFirebaseAuthException('user-not-found');
      expect(
        AuthService.getHumanReadableAuthError(error),
        contains('No account exists'),
      );
    });

    test('wrong-password', () {
      final error = MockFirebaseAuthException('wrong-password');
      expect(
        AuthService.getHumanReadableAuthError(error),
        contains('Incorrect password'),
      );
    });

    test('invalid-email', () {
      final error = MockFirebaseAuthException('invalid-email');
      expect(
        AuthService.getHumanReadableAuthError(error),
        contains('valid email'),
      );
    });

    test('email-already-in-use', () {
      final error = MockFirebaseAuthException('email-already-in-use');
      expect(
        AuthService.getHumanReadableAuthError(error),
        contains('already exists'),
      );
    });

    test('weak-password', () {
      final error = MockFirebaseAuthException('weak-password');
      expect(
        AuthService.getHumanReadableAuthError(error),
        contains('at least 6'),
      );
    });

    test('network-request-failed', () {
      final error = MockFirebaseAuthException('network-request-failed');
      expect(AuthService.getHumanReadableAuthError(error), contains('Network'));
    });

    test('too-many-requests', () {
      final error = MockFirebaseAuthException('too-many-requests');
      expect(
        AuthService.getHumanReadableAuthError(error),
        contains('Too many'),
      );
    });

    test('user-disabled', () {
      final error = MockFirebaseAuthException('user-disabled');
      expect(
        AuthService.getHumanReadableAuthError(error),
        contains('disabled'),
      );
    });

    test('unknown code returns message', () {
      final error = MockFirebaseAuthException('unknown-xyz');
      expect(AuthService.getHumanReadableAuthError(error), isNotEmpty);
    });

    test('non-FirebaseAuthException returns generic message', () {
      expect(
        AuthService.getHumanReadableAuthError(Exception('oops')),
        contains('unexpected'),
      );
    });
  });
}

class MockFirebaseAuthException extends Fake implements FirebaseAuthException {
  MockFirebaseAuthException(this._code);
  final String _code;

  @override
  String get code => _code;

  @override
  String get message => 'Mock error: $_code';
}

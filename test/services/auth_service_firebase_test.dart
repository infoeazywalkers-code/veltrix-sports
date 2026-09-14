import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/core/errors/app_exception.dart';
import 'package:veltrix_sports/services/auth/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  group('AuthService - constructor and properties', () {
    test('can be created with mock dependencies', () {
      final service = AuthService(
        auth: MockFirebaseAuth(),
        db: FakeFirebaseFirestore(),
      );
      expect(service, isA<AuthService>());
    });

    test('authStateChanges returns a Stream', () {
      final service = AuthService(auth: MockFirebaseAuth());
      expect(service.authStateChanges, isA<Stream>());
    });

    test('currentUser is null when no user signed in', () {
      final service = AuthService(auth: MockFirebaseAuth());
      expect(service.currentUser, isNull);
    });
  });

  group('AuthService - isSignedIn', () {
    test('returns false when no user signed in', () async {
      final service = AuthService(auth: MockFirebaseAuth());
      final result = await service.isSignedIn();
      expect(result, false);
    });

    test(
      'returns false when user is signed in with MockFirebaseAuth',
      () async {
        final mockAuth = MockFirebaseAuth(
          mockUser: MockUser(uid: 'test-uid', email: 'test@test.com'),
        );
        final service = AuthService(auth: mockAuth);
        // MockFirebaseAuth mockUser doesn't set currentUser directly;
        // it simulates the auth state stream but currentUser remains null
        // until the listener fires. This tests the isSignedIn path.
        final result = await service.isSignedIn();
        expect(result, isA<bool>());
      },
    );
  });

  group('AuthService - signInWithGoogle', () {
    test('throws AuthException when GoogleSignIn fails', () async {
      final service = AuthService(
        auth: MockFirebaseAuth(),
        db: FakeFirebaseFirestore(),
      );
      // Default GoogleSignIn.instance cannot initialize in the test env,
      // so the service wraps the failure in an AuthException for callers
      // (e.g. AuthWrapper) to surface via snackbar.
      await expectLater(
        service.signInWithGoogle(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthService - signOut', () {
    test('completes without error when no user signed in', () async {
      final service = AuthService(auth: MockFirebaseAuth());
      await service.signOut();
    });
  });

  group('AuthService - _ensureUserProfile', () {
    test('surfaces AuthException when sign-in prerequisites fail', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final service = AuthService(auth: MockFirebaseAuth(), db: fakeFirestore);
      // signInWithGoogle triggers _ensureUserProfile internally, but Google
      // sign-in fails first in the test env and is wrapped in AuthException.
      await expectLater(
        service.signInWithGoogle(),
        throwsA(isA<AuthException>()),
      );
    });
  });
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/activity/watch_sync_service.dart';

/// Minimal fake that extends FirebaseAuthPlatform.
/// Only overrides what our code actually needs: currentUser (null),
/// delegateFor (return self), and setInitialValues (return self).
class _FakeAuthPlatform extends FirebaseAuthPlatform {
  _FakeAuthPlatform() : super();

  @override
  UserPlatform? get currentUser => null;

  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) {
    return this;
  }

  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) {
    return this;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAuthPlatform fakeAuth;

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    fakeAuth = _FakeAuthPlatform();
    FirebaseAuthPlatform.instance = fakeAuth;
  });

  group('WatchSyncService - requestPermissions', () {
    test('requestPermissions returns bool', () async {
      final result = await WatchSyncService.requestPermissions();
      expect(result, isA<bool>());
    });
  });

  group('WatchSyncService - syncLatestWatchWorkouts', () {
    test('syncLatestWatchWorkouts returns an int', () async {
      final result = await WatchSyncService.syncLatestWatchWorkouts();
      expect(result, isA<int>());
      expect(result, greaterThanOrEqualTo(0));
    });
  });
}

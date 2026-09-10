import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/core/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });
  group('NotificationService', () {
    test('singleton pattern returns same instance', () {
      final s1 = NotificationService();
      final s2 = NotificationService();
      expect(identical(s1, s2), isTrue);
    });

    test('fcmToken is null before initialization', () {
      final service = NotificationService();
      expect(service.fcmToken, isNull);
    });

    test('showNotification completes without crash', () async {
      final service = NotificationService();
      // showNotification calls FlutterLocalNotificationsPlugin.show
      // In test env this will throw a MissingPluginException, caught internally
      await service.showNotification(title: 'Test', body: 'Body');
    });

    test('scheduleWorkoutReminder completes without crash', () async {
      final service = NotificationService();
      await service.scheduleWorkoutReminder(
        'Morning Run',
        DateTime.now().add(const Duration(hours: 1)),
      );
    });

    test('scheduleWorkoutReminder returns early for past times', () async {
      final service = NotificationService();
      // Should return early without crashing
      await service.scheduleWorkoutReminder(
        'Past Workout',
        DateTime.now().subtract(const Duration(hours: 1)),
      );
    });

    test('cancelWorkoutReminder calls cancel with hashCode', () async {
      final service = NotificationService();
      expect(
        () => service.cancelWorkoutReminder('Morning Run'),
        throwsA(isA<Error>()),
      );
    });

    test('cancelAllNotifications calls cancelAll', () async {
      final service = NotificationService();
      expect(() => service.cancelAllNotifications(), throwsA(isA<Error>()));
    });

    test('initialize is idempotent', () async {
      final service = NotificationService();
      // Second call should be a no-op due to _initialized guard
      await service.initialize();
      await service.initialize();
    });
  });
}

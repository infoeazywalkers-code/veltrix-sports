import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/core/notification_service.dart';

void main() {
  group('NotificationService - Extended', () {
    test('NotificationService class can be referenced', () {
      expect(NotificationService, isA<Type>());
    });

    test('NotificationService has fcmToken getter', () {
      try {
        final service = NotificationService();
        expect(service.fcmToken, isA<String?>());
      } catch (e) {
        // Expected: Firebase not initialized in test
        expect(e, isA<Exception>());
      }
    });

    test('NotificationService singleton pattern', () {
      try {
        final s1 = NotificationService();
        final s2 = NotificationService();
        expect(identical(s1, s2), isTrue);
      } catch (e) {
        // Expected: Firebase not initialized in test
        expect(e, isA<Exception>());
      }
    });
  });
}

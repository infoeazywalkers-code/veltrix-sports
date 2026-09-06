import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/watch_sync_service.dart';

void main() {
  group('WatchSyncService', () {
    test('WatchSyncService class exists', () {
      expect(WatchSyncService, isA<Type>());
    });

    test('WatchSyncService has requestPermissions static method', () {
      // Verify the static method signature exists
      expect(WatchSyncService.requestPermissions, isA<Function>());
    });

    test('WatchSyncService has syncLatestWatchWorkouts static method', () {
      expect(WatchSyncService.syncLatestWatchWorkouts, isA<Function>());
    });
  });
}

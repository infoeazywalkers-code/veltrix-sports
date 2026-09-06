import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/watch_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WatchSyncService - requestPermissions', () {
    test('requestPermissions returns bool', () async {
      final result = await WatchSyncService.requestPermissions();
      expect(result, isA<bool>());
    });
  });

  group('WatchSyncService - syncLatestWatchWorkouts', () {
    test('syncLatestWatchWorkouts returns an int', () async {
      // In test env, Health plugin is not available, so it falls
      // back to _simulateWatchSync which returns 1
      final result = await WatchSyncService.syncLatestWatchWorkouts();
      expect(result, isA<int>());
      expect(result, greaterThanOrEqualTo(0));
    });
  });
}

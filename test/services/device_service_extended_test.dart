import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veltrix_sports/services/device_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DeviceService - Extended', () {
    test('isConnected returns false for brand new device', () async {
      expect(await DeviceService.isConnected('brand_new_device'), false);
    });

    test('setConnected true then false', () async {
      await DeviceService.setConnected('watch_a', 'Wearable', true);
      expect(await DeviceService.isConnected('watch_a'), true);
      await DeviceService.setConnected('watch_a', 'Wearable', false);
      expect(await DeviceService.isConnected('watch_a'), false);
    });

    test('setConnected true stores ISO timestamp', () async {
      await DeviceService.setConnected('w', 'Cat', true);
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('device_sync_w');
      expect(raw, isNotNull);
      expect(DateTime.tryParse(raw!), isNotNull);
    });

    test('setConnected false does not update sync timestamp', () async {
      await DeviceService.setConnected('w', 'Cat', true);
      final prefs = await SharedPreferences.getInstance();
      final before = prefs.getString('device_sync_w');

      await DeviceService.setConnected('w', 'Cat', false);
      final after = prefs.getString('device_sync_w');
      // The sync timestamp should remain the same after disconnection
      expect(after, before);
    });

    test('getLastSync returns Just now for recently connected', () async {
      await DeviceService.setConnected('w', 'Wearable', true);
      expect(await DeviceService.getLastSync('w'), 'Just now');
    });

    test(
      'getLastSync returns Never for disconnected device with no sync',
      () async {
        expect(await DeviceService.getLastSync('never_synced'), 'Never');
      },
    );

    test('forceSync sets Just now', () async {
      await DeviceService.forceSync('watch_force');
      expect(await DeviceService.getLastSync('watch_force'), 'Just now');
    });

    test('forceSync overwrites existing sync', () async {
      await DeviceService.setConnected('w', 'Cat', true);
      await Future.delayed(const Duration(milliseconds: 50));
      await DeviceService.forceSync('w');
      expect(await DeviceService.getLastSync('w'), 'Just now');
    });

    test('multiple devices have independent status', () async {
      await DeviceService.setConnected('w1', 'A', true);
      await DeviceService.setConnected('w2', 'B', false);
      await DeviceService.setConnected('w3', 'C', true);

      expect(await DeviceService.isConnected('w1'), true);
      expect(await DeviceService.isConnected('w2'), false);
      expect(await DeviceService.isConnected('w3'), true);
    });

    test('multiple devices have independent sync times', () async {
      await DeviceService.setConnected('w1', 'A', true);
      await DeviceService.forceSync('w2');

      expect(await DeviceService.getLastSync('w1'), 'Just now');
      expect(await DeviceService.getLastSync('w2'), 'Just now');
    });

    test('getLastSync returns Never for invalid ISO string', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_sync_bad', 'not_a_date');
      expect(await DeviceService.getLastSync('bad'), 'Never');
    });

    test('getLastSync returns formatted date for older timestamps', () async {
      final prefs = await SharedPreferences.getInstance();
      // 5 minutes ago
      final fiveMinAgo = DateTime.now().subtract(const Duration(minutes: 5));
      await prefs.setString('device_sync_old', fiveMinAgo.toIso8601String());
      final result = await DeviceService.getLastSync('old');
      expect(result, '5m ago');
    });

    test('getLastSync returns hours format for older timestamps', () async {
      final prefs = await SharedPreferences.getInstance();
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      await prefs.setString('device_sync_hours', twoHoursAgo.toIso8601String());
      final result = await DeviceService.getLastSync('hours');
      expect(result, '2h ago');
    });

    test('getLastSync returns date format for very old timestamps', () async {
      final prefs = await SharedPreferences.getInstance();
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      await prefs.setString('device_sync_old2', threeDaysAgo.toIso8601String());
      final result = await DeviceService.getLastSync('old2');
      // Should be formatted as M/D H:MM
      expect(result, contains('/'));
    });

    test('getLastSync returns Just now for very recent (< 1 min)', () async {
      await DeviceService.setConnected('just', 'X', true);
      expect(await DeviceService.getLastSync('just'), 'Just now');
    });

    test('device status key uses correct prefix', () async {
      await DeviceService.setConnected('my_watch', 'Wearable', true);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('device_status_my_watch'), true);
    });

    test('device sync key uses correct prefix', () async {
      await DeviceService.setConnected('my_watch', 'Wearable', true);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('device_sync_my_watch'), isNotNull);
    });

    test('empty device name works', () async {
      await DeviceService.setConnected('', 'Category', true);
      expect(await DeviceService.isConnected(''), true);
      expect(await DeviceService.getLastSync(''), 'Just now');
    });
  });
}

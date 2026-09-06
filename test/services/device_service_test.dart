import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veltrix_sports/services/device_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DeviceService', () {
    test('isConnected returns false by default', () async {
      final result = await DeviceService.isConnected('test_device');
      expect(result, false);
    });

    test('setConnected and isConnected roundtrip', () async {
      await DeviceService.setConnected('watch_1', 'Wearable', true);
      final connected = await DeviceService.isConnected('watch_1');
      expect(connected, true);
    });

    test('setConnected false marks device as disconnected', () async {
      await DeviceService.setConnected('watch_1', 'Wearable', true);
      await DeviceService.setConnected('watch_1', 'Wearable', false);
      final connected = await DeviceService.isConnected('watch_1');
      expect(connected, false);
    });

    test('isConnected returns false for unknown device', () async {
      final result = await DeviceService.isConnected('nonexistent');
      expect(result, false);
    });

    test('different devices have independent status', () async {
      await DeviceService.setConnected('watch_1', 'Wearable', true);
      await DeviceService.setConnected('watch_2', 'Wearable', false);

      expect(await DeviceService.isConnected('watch_1'), true);
      expect(await DeviceService.isConnected('watch_2'), false);
    });

    test('getLastSync returns Never by default', () async {
      final result = await DeviceService.getLastSync('watch_1');
      expect(result, 'Never');
    });

    test('getLastSync returns Just now after setting connected', () async {
      await DeviceService.setConnected('watch_1', 'Wearable', true);
      final result = await DeviceService.getLastSync('watch_1');
      expect(result, 'Just now');
    });

    test('forceSync updates last sync time', () async {
      await DeviceService.forceSync('watch_1');
      final result = await DeviceService.getLastSync('watch_1');
      expect(result, 'Just now');
    });

    test('getLastSync returns Never for unknown device', () async {
      final result = await DeviceService.getLastSync('nonexistent');
      expect(result, 'Never');
    });

    test('setConnected stores last sync as ISO string', () async {
      await DeviceService.setConnected('watch_1', 'Wearable', true);
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('device_sync_watch_1');
      expect(raw, isNotNull);
      expect(DateTime.tryParse(raw!), isNotNull);
    });
  });
}

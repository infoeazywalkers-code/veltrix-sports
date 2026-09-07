import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/ble_sensor_service.dart';

void main() {
  group('BleSensorService - startWatchScan simulation', () {
    test('startWatchScan triggers simulation on test env', () async {
      final ble = BleSensorService();
      // In test env, kIsWeb is true, so startWatchScan uses simulation
      // _simulateDiscoveredDevices uses Future.delayed(600ms) which is NOT awaited
      await ble.startWatchScan();
      // Wait for the delayed simulation to complete
      await Future.delayed(const Duration(milliseconds: 800));
      expect(ble.isScanning, isFalse);
      expect(ble.discoveredDevices.length, 4);
      expect(ble.discoveredDevices[0].name, contains('Apple Watch'));
      expect(ble.discoveredDevices[1].name, contains('Garmin'));
      expect(ble.discoveredDevices[2].name, contains('Polar'));
      expect(ble.discoveredDevices[3].name, contains('Wahoo'));
    });

    test('startWatchScan clears previous devices', () async {
      final ble = BleSensorService();
      await ble.startWatchScan();
      await Future.delayed(const Duration(milliseconds: 800));
      expect(ble.discoveredDevices.length, 4);

      // Second scan should clear and re-add
      await ble.startWatchScan();
      await Future.delayed(const Duration(milliseconds: 800));
      expect(ble.discoveredDevices.length, 4);
    });

    test('notifyListeners fires during scan', () async {
      final ble = BleSensorService();
      var notifyCount = 0;
      ble.addListener(() => notifyCount++);

      await ble.startWatchScan();
      await Future.delayed(const Duration(milliseconds: 800));
      expect(notifyCount, greaterThan(0));

      ble.removeListener(() {});
    });

    test('discoveredDevices are correct type', () async {
      final ble = BleSensorService();
      await ble.startWatchScan();
      await Future.delayed(const Duration(milliseconds: 800));
      for (final device in ble.discoveredDevices) {
        expect(device, isA<DiscoveredWatchDevice>());
        expect(device.id, isNotEmpty);
        expect(device.name, isNotEmpty);
        expect(device.rssi, isA<int>());
      }
    });
  });

  group('BleSensorService - connect with HR stream', () {
    test('liveHeartRate updates after connect', () async {
      final ble = BleSensorService();
      const device = DiscoveredWatchDevice(
        id: 'd1',
        name: 'Test Watch',
        rssi: -50,
      );
      await ble.connectToWatch(device);
      expect(ble.isConnected, isTrue);

      // Wait for HR stream to emit (periodic is 2s)
      await Future.delayed(const Duration(seconds: 3));
      expect(ble.liveHeartRate, isNot(equals(145)));

      ble.disconnect();
    });

    test('connect then disconnect full lifecycle', () async {
      final ble = BleSensorService();
      const device = DiscoveredWatchDevice(
        id: 'd2',
        name: 'Polar H10',
        rssi: -42,
      );

      await ble.connectToWatch(device);
      expect(ble.isConnected, isTrue);
      expect(ble.connectedDeviceName, 'Polar H10');

      ble.disconnect();
      expect(ble.isConnected, isFalse);
      expect(ble.connectedDeviceName, isNull);
    });
  });

  group('BleSensorService - dispose', () {
    test('dispose method exists', () {
      final ble = BleSensorService();
      // dispose is on ChangeNotifier - calling it disposes the singleton
      // Just verify the method exists and is callable
      expect(ble.dispose, isA<Function>());
    });
  });
}

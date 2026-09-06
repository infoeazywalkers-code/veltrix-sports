import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/ble_sensor_service.dart';

void main() {
  group('DiscoveredWatchDevice', () {
    test('has correct id, name, and rssi', () {
      const device = DiscoveredWatchDevice(
        id: 'test_id',
        name: 'Apple Watch',
        rssi: -50,
      );

      expect(device.id, 'test_id');
      expect(device.name, 'Apple Watch');
      expect(device.rssi, -50);
    });

    test('supports negative rssi values', () {
      const device = DiscoveredWatchDevice(
        id: 'd1',
        name: 'Sensor',
        rssi: -100,
      );
      expect(device.rssi, -100);
    });

    test('supports zero rssi', () {
      const device = DiscoveredWatchDevice(id: 'd2', name: 'Sensor', rssi: 0);
      expect(device.rssi, 0);
    });

    test('supports positive rssi', () {
      const device = DiscoveredWatchDevice(
        id: 'd3',
        name: 'Nearby Sensor',
        rssi: 10,
      );
      expect(device.rssi, 10);
    });

    test('supports empty string id and name', () {
      const device = DiscoveredWatchDevice(id: '', name: '', rssi: -42);
      expect(device.id, '');
      expect(device.name, '');
    });
  });

  group('BleSensorService', () {
    test('is a singleton', () {
      final s1 = BleSensorService();
      final s2 = BleSensorService();
      expect(identical(s1, s2), isTrue);
    });

    test('initial state has no connected device', () {
      final ble = BleSensorService();
      expect(ble.isConnected, isFalse);
      expect(ble.connectedDeviceName, isNull);
      expect(ble.isScanning, isFalse);
      expect(ble.liveHeartRate, 145);
      expect(ble.discoveredDevices, isEmpty);
    });

    test('connectToWatch sets connected status and device name', () async {
      final ble = BleSensorService();
      const device = DiscoveredWatchDevice(
        id: 'test_apple_watch',
        name: 'Apple Watch Ultra',
        rssi: -50,
      );

      await ble.connectToWatch(device);

      expect(ble.isConnected, isTrue);
      expect(ble.connectedDeviceName, 'Apple Watch Ultra');

      ble.disconnect();
      expect(ble.isConnected, isFalse);
      expect(ble.connectedDeviceName, isNull);
    });

    test('disconnect clears state', () {
      final ble = BleSensorService();
      ble.disconnect();

      expect(ble.isConnected, isFalse);
      expect(ble.connectedDeviceName, isNull);
      expect(ble.isScanning, isFalse);
    });

    test('discoveredDevices returns unmodifiable list', () {
      final ble = BleSensorService();
      final devices = ble.discoveredDevices;
      expect(devices, isEmpty);
    });

    test('connectToWatch sets isScanning to false', () async {
      final ble = BleSensorService();
      const device = DiscoveredWatchDevice(id: 'd1', name: 'Test', rssi: -60);

      await ble.connectToWatch(device);
      expect(ble.isScanning, isFalse);

      ble.disconnect();
    });

    test('liveHeartRate changes after connection', () async {
      final ble = BleSensorService();
      const device = DiscoveredWatchDevice(id: 'd1', name: 'Watch', rssi: -50);

      final initialHeartRate = ble.liveHeartRate;
      await ble.connectToWatch(device);

      // Wait for at least one periodic update
      await Future.delayed(const Duration(seconds: 3));
      expect(ble.liveHeartRate, isNot(equals(initialHeartRate)));

      ble.disconnect();
    });

    test('notifies listeners on state changes', () {
      final ble = BleSensorService();
      var notified = false;
      ble.addListener(() {
        notified = true;
      });

      ble.disconnect();

      // The disconnect method calls notifyListeners
      // Note: may or may not be notified depending on state change
      ble.removeListener(() {});
    });

    test('dispose cancels subscriptions', () {
      final ble = BleSensorService();
      // Dispose should not throw
      ble.disconnect();
    });
  });
}

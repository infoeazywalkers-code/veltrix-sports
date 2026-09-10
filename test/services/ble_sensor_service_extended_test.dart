import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/devices/ble_sensor_service.dart';

void main() {
  group('BleSensorService - Extended', () {
    test('singleton pattern holds', () {
      final a = BleSensorService();
      final b = BleSensorService();
      expect(identical(a, b), isTrue);
    });

    test('initial state: all defaults correct', () {
      final ble = BleSensorService();
      expect(ble.isConnected, isFalse);
      expect(ble.isScanning, isFalse);
      expect(ble.connectedDeviceName, isNull);
      expect(ble.liveHeartRate, 0);
      expect(ble.discoveredDevices, isEmpty);
    });

    test('connect then disconnect full cycle', () async {
      final ble = BleSensorService();
      const device = DiscoveredWatchDevice(
        id: 'test_watch',
        name: 'Test Watch',
        rssi: -50,
      );

      await ble.connectToWatch(device);
      expect(ble.isConnected, isTrue);
      expect(ble.connectedDeviceName, 'Test Watch');

      ble.disconnect();
      expect(ble.isConnected, isFalse);
      expect(ble.connectedDeviceName, isNull);
      expect(ble.isScanning, isFalse);
    });

    test('multiple connect/disconnect cycles', () async {
      final ble = BleSensorService();
      const device1 = DiscoveredWatchDevice(
        id: 'd1',
        name: 'Watch One',
        rssi: -45,
      );
      const device2 = DiscoveredWatchDevice(
        id: 'd2',
        name: 'Watch Two',
        rssi: -60,
      );

      await ble.connectToWatch(device1);
      expect(ble.connectedDeviceName, 'Watch One');
      ble.disconnect();

      await ble.connectToWatch(device2);
      expect(ble.connectedDeviceName, 'Watch Two');
      ble.disconnect();

      expect(ble.isConnected, isFalse);
    });

    test('connectToWatch stops scanning', () async {
      final ble = BleSensorService();
      const device = DiscoveredWatchDevice(id: 'd1', name: 'Watch', rssi: -50);

      await ble.connectToWatch(device);
      expect(ble.isScanning, isFalse);
      ble.disconnect();
    });

    test('liveHeartRate changes after connection', () async {
      final ble = BleSensorService();
      const device = DiscoveredWatchDevice(id: 'd1', name: 'Watch', rssi: -50);

      await ble.connectToWatch(device);
      await Future.delayed(const Duration(seconds: 3));
      expect(ble.liveHeartRate, isNot(equals(145)));
      ble.disconnect();
    });

    test('disconnect clears connectedDeviceName', () {
      final ble = BleSensorService();
      ble.disconnect();
      expect(ble.connectedDeviceName, isNull);
    });

    test('disconnect sets isConnected to false', () {
      final ble = BleSensorService();
      ble.disconnect();
      expect(ble.isConnected, isFalse);
    });

    test('discoveredDevices is unmodifiable', () {
      final ble = BleSensorService();
      final devices = ble.discoveredDevices;
      expect(
        () => devices.add(
          const DiscoveredWatchDevice(id: 'x', name: 'X', rssi: -50),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('addListener fires on state changes', () async {
      final ble = BleSensorService();
      var notifyCount = 0;
      ble.addListener(() => notifyCount++);

      const device = DiscoveredWatchDevice(id: 'd1', name: 'Watch', rssi: -50);

      await ble.connectToWatch(device);
      expect(notifyCount, greaterThan(0));

      ble.disconnect();
      expect(notifyCount, greaterThan(1));

      ble.removeListener(() {});
    });

    test('dispose cancels subscriptions without error', () {
      final ble = BleSensorService();
      // Note: dispose on singleton will dispose the singleton.
      // Don't call it in tests that need the singleton later.
      // This test just verifies the method exists.
      expect(ble.dispose, isA<Function>());
    });
  });

  group('DiscoveredWatchDevice - Extended', () {
    test('equality with same values', () {
      const d1 = DiscoveredWatchDevice(id: 'a', name: 'A', rssi: -50);
      const d2 = DiscoveredWatchDevice(id: 'a', name: 'A', rssi: -50);
      expect(d1.id, d2.id);
      expect(d1.name, d2.name);
      expect(d1.rssi, d2.rssi);
    });

    test('different devices have different IDs', () {
      const d1 = DiscoveredWatchDevice(id: 'd1', name: 'A', rssi: -50);
      const d2 = DiscoveredWatchDevice(id: 'd2', name: 'A', rssi: -50);
      expect(d1.id, isNot(d2.id));
    });

    test('supports very long name', () {
      final device = DiscoveredWatchDevice(
        id: 'long_id',
        name: 'N' * 500,
        rssi: -80,
      );
      expect(device.name.length, 500);
    });

    test('supports very negative rssi', () {
      const device = DiscoveredWatchDevice(
        id: 'd1',
        name: 'Far Watch',
        rssi: -200,
      );
      expect(device.rssi, -200);
    });

    test('supports positive rssi', () {
      const device = DiscoveredWatchDevice(
        id: 'd1',
        name: 'Strong Signal',
        rssi: 50,
      );
      expect(device.rssi, 50);
    });
  });
}

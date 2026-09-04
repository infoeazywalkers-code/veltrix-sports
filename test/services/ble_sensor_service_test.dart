import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/ble_sensor_service.dart';

void main() {
  group('BleSensorService Unit Tests', () {
    test('BleSensorService is a singleton', () {
      final s1 = BleSensorService();
      final s2 = BleSensorService();
      expect(identical(s1, s2), isTrue);
    });

    test('initial state has no connected device', () {
      final ble = BleSensorService();
      expect(ble.isConnected, isFalse);
      expect(ble.connectedDeviceName, isNull);
      expect(ble.isScanning, isFalse);
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
  });
}

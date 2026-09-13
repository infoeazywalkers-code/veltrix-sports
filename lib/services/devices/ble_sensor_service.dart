import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'device_service.dart';

class DiscoveredWatchDevice {
  final String id;
  final String name;
  final int rssi;

  const DiscoveredWatchDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });
}

class BleSensorService extends ChangeNotifier {
  static final BleSensorService _instance = BleSensorService._internal();
  factory BleSensorService() => _instance;
  BleSensorService._internal();

  bool _isScanning = false;
  bool _isConnected = false;
  bool _isSimulated = false;
  String? _connectedDeviceName;
  int _liveHeartRate = 0;

  StreamSubscription? _scanSub;
  StreamSubscription? _hrSub;

  final List<DiscoveredWatchDevice> _discoveredDevices = [];
  final Map<String, BluetoothDevice> _devices = {};
  BluetoothDevice? _connectedDevice;

  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get isSimulated => _isSimulated;
  String? get connectedDeviceName => _connectedDeviceName;
  int get liveHeartRate => _liveHeartRate;
  List<DiscoveredWatchDevice> get discoveredDevices =>
      List.unmodifiable(_discoveredDevices);

  Future<void> startWatchScan() async {
    _discoveredDevices.clear();
    _devices.clear();
    _isSimulated = false;
    _isScanning = true;
    notifyListeners();

    try {
      final bool supported = await FlutterBluePlus.isSupported;
      if (!supported) {
        _useSimulatedFallback();
        return;
      }

      await FlutterBluePlus.startScan(
        withServices: [Guid('180D')],
        timeout: const Duration(seconds: 10),
      );

      await _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        var added = false;
        for (ScanResult r in results) {
          _devices[r.device.remoteId.str] = r.device;
          final deviceName =
              r.device.platformName.isNotEmpty
                  ? r.device.platformName
                  : 'Heart Rate Monitor (${r.device.remoteId.str.length >= 5 ? r.device.remoteId.str.substring(0, 5) : r.device.remoteId.str})';

          if (!_discoveredDevices.any((d) => d.id == r.device.remoteId.str)) {
            _discoveredDevices.add(
              DiscoveredWatchDevice(
                id: r.device.remoteId.str,
                name: deviceName,
                rssi: r.rssi,
              ),
            );
            added = true;
          }
        }
        if (added) notifyListeners();
      });

      // Real scans stop on their own after the timeout; reflect that in UI.
      Future.delayed(const Duration(seconds: 11), () {
        if (_isScanning && !_isSimulated) {
          _isScanning = false;
          notifyListeners();
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[BLE Scan Error] $e');
      _useSimulatedFallback();
    }
  }

  /// Clearly-labeled fallback used ONLY when BLE is unsupported or fails.
  void _useSimulatedFallback() {
    _isSimulated = true;
    Future.delayed(const Duration(milliseconds: 600), () {
      _discoveredDevices.addAll([
        const DiscoveredWatchDevice(
          id: 'dev_apple',
          name: 'Apple Watch Series 9',
          rssi: -58,
        ),
        const DiscoveredWatchDevice(
          id: 'dev_garmin',
          name: 'Garmin Forerunner 965',
          rssi: -64,
        ),
        const DiscoveredWatchDevice(
          id: 'dev_polar',
          name: 'Polar H10 Heart Rate Sensor',
          rssi: -42,
        ),
        const DiscoveredWatchDevice(
          id: 'dev_wahoo',
          name: 'Wahoo TICKR X',
          rssi: -71,
        ),
      ]);
      _isScanning = false;
      notifyListeners();
    });
  }

  Future<void> stopScan() async {
    // Clear scan state synchronously so callers/tests see it immediately.
    _isScanning = false;
    final StreamSubscription? scanSub = _scanSub;
    _scanSub = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      if (kDebugMode) debugPrint('[BLE StopScan Error] $e');
    }
    try {
      await scanSub?.cancel();
    } catch (e) {
      if (kDebugMode) debugPrint('[BLE ScanSub Cancel Error] $e');
    }
    notifyListeners();
  }

  Future<void> _startSimulatedHeartRate(String deviceName) async {
    _isSimulated = true;
    _connectedDeviceName = deviceName;
    _isConnected = true;
    _isScanning = false;
    notifyListeners();

    try {
      await DeviceService.setConnected(deviceName, 'Heart Rate', true);
    } catch (e) {
      if (kDebugMode) debugPrint('[BLE Persist Error] $e');
    }

    // Simulated BPM feed for demo entries (no real hardware handle).
    await _hrSub?.cancel();
    _hrSub = Stream.periodic(
      const Duration(seconds: 2),
      (i) => 140 + (i % 22),
    ).listen((bpm) {
      _liveHeartRate = bpm;
      notifyListeners();
    });
  }

  Future<void> connectToWatch(DiscoveredWatchDevice device) async {
    await stopScan();

    final BluetoothDevice? dev = _devices[device.id];
    if (dev == null) {
      // Simulated/demo entry (or test double with no hardware handle):
      // keep the simulated-BPM behavior so UI/tests still function,
      // honestly flagged via isSimulated.
      await _startSimulatedHeartRate(device.name);
      return;
    }

    try {
      _isSimulated = false;
      await dev.connect(timeout: const Duration(seconds: 15));
      final List<BluetoothService> services = await dev.discoverServices();

      BluetoothCharacteristic? hrChar;
      for (final svc in services) {
        if (svc.uuid.str.toLowerCase() == '180d') {
          for (final c in svc.characteristics) {
            if (c.uuid.str.toLowerCase() == '2a37') {
              hrChar = c;
              break;
            }
          }
          if (hrChar != null) break;
        }
      }
      if (hrChar == null) {
        try {
          await dev.disconnect();
        } catch (_) {}
        throw Exception(
          'Heart-rate service (0x180D/0x2A37) not found on ${device.name}',
        );
      }

      await hrChar.setNotifyValue(true);
      await _hrSub?.cancel();
      final BluetoothCharacteristic char = hrChar;
      _hrSub = char.lastValueStream.listen((bytes) {
        final int? bpm = _parseHeartRate(bytes);
        if (bpm != null) {
          _liveHeartRate = bpm;
          notifyListeners();
        }
      });

      _connectedDevice = dev;
      _connectedDeviceName = device.name;
      _isConnected = true;
      _isScanning = false;
      notifyListeners();

      try {
        await DeviceService.setConnected(device.name, 'Heart Rate', true);
      } catch (e) {
        if (kDebugMode) debugPrint('[BLE Persist Error] $e');
      }
    } catch (e) {
      _isConnected = false;
      try {
        await dev.disconnect();
      } catch (_) {}
      if (kDebugMode) debugPrint('[BLE Connect Error] $e');
      throw Exception('Could not connect to ${device.name}: $e');
    }
  }

  int? _parseHeartRate(List<int> bytes) {
    try {
      if (bytes.isEmpty) return null;
      final int flags = bytes[0];
      final bool is16Bit = (flags & 0x01) != 0;
      if (!is16Bit) {
        if (bytes.length < 2) return null;
        return bytes[1];
      } else {
        if (bytes.length < 3) return null;
        return bytes[1] | (bytes[2] << 8);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[BLE HR Parse Error] $e');
      return null;
    }
  }

  Future<void> disconnect() async {
    // Clear visible state synchronously so sync callers (incl. tests)
    // observe the disconnect immediately; hardware cleanup follows.
    final String? name = _connectedDeviceName;
    final BluetoothDevice? dev = _connectedDevice;
    final StreamSubscription? hrSub = _hrSub;
    final StreamSubscription? scanSub = _scanSub;
    _hrSub = null;
    _scanSub = null;
    _connectedDevice = null;
    _isConnected = false;
    _connectedDeviceName = null;
    _isScanning = false;
    notifyListeners();
    try {
      await hrSub?.cancel();
    } catch (e) {
      if (kDebugMode) debugPrint('[BLE HR Cancel Error] $e');
    }
    try {
      await scanSub?.cancel();
    } catch (e) {
      if (kDebugMode) debugPrint('[BLE Scan Cancel Error] $e');
    }
    try {
      await dev?.disconnect();
    } catch (e) {
      if (kDebugMode) debugPrint('[BLE Disconnect Error] $e');
    }
    if (name != null) {
      try {
        await DeviceService.setConnected(name, 'Heart Rate', false);
      } catch (e) {
        if (kDebugMode) debugPrint('[BLE Persist Error] $e');
      }
    }
  }

  @override
  void dispose() {
    _hrSub?.cancel();
    _scanSub?.cancel();
    super.dispose();
  }
}

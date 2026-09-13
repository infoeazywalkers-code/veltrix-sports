import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../services/devices/device_service.dart';
import '../../services/activity/watch_sync_service.dart';
import '../../services/devices/ble_sensor_service.dart';

class DeviceConnectDialog extends StatefulWidget {
  final String deviceName;
  final String category;
  final bool isConnected;
  final String lastSync;

  const DeviceConnectDialog({
    super.key,
    required this.deviceName,
    required this.category,
    this.isConnected = false,
    this.lastSync = 'Just now',
  });

  @override
  State<DeviceConnectDialog> createState() => _DeviceConnectDialogState();
}

class _DeviceConnectDialogState extends State<DeviceConnectDialog> {
  late bool _connected;
  String _lastSyncText = 'Just now';
  bool _syncing = false;
  bool _showBleResults = false;
  String? _bleError;
  bool _requested = false;
  bool _requestLoading = false;
  final BleSensorService _bleService = BleSensorService();

  @override
  void initState() {
    super.initState();
    _connected = widget.isConnected;
    _loadDeviceState();
    _bleService.addListener(_onBleUpdate);
  }

  void _onBleUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bleService.removeListener(_onBleUpdate);
    super.dispose();
  }

  bool get _isSensor {
    final cat = widget.category.toLowerCase();
    final name = widget.deviceName.toLowerCase();
    if (cat.contains('heart') ||
        cat.contains('sensor') ||
        cat.contains('monitor')) {
      return true;
    }
    const hrHardware = [
      'polar',
      'h10',
      'tickr',
      'wahoo',
      'verity',
      'hrm',
      'heart',
      'footpod',
      'stryd',
      'powermeter',
      'power',
    ];
    return hrHardware.any(name.contains);
  }

  bool get _isWatch {
    final cat = widget.category.toLowerCase();
    final name = widget.deviceName.toLowerCase();
    return cat.contains('wearable') || name.contains('watch');
  }

  bool get _isAppTile => !_isSensor && !_isWatch;

  Future<void> _loadDeviceState() async {
    final status = await DeviceService.isConnected(widget.deviceName);
    final syncTime = await DeviceService.getLastSync(widget.deviceName);
    var requested = false;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('devices')
            .doc(DeviceService.sanitizeDeviceId(widget.deviceName))
            .get();
        requested = (doc.data()?['status'] == 'requested');
      }
      if (!requested) {
        final prefs = await SharedPreferences.getInstance();
        requested =
            prefs.getBool('oauth_request_${widget.deviceName}') ?? false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DeviceDialog Load Request Error] $e');
    }
    if (mounted) {
      setState(() {
        _connected = status;
        _lastSyncText = syncTime;
        _requested = requested;
      });
    }
  }

  Future<void> _toggleConnection() async {
    // Generic toggle kept only for watch/sync-type devices; sensor and
    // app tiles use their dedicated real flows.
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _syncing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final nextState = !_connected;
    await DeviceService.setConnected(
      widget.deviceName,
      widget.category,
      nextState,
    );
    final syncTime = await DeviceService.getLastSync(widget.deviceName);

    if (mounted) {
      setState(() {
        _connected = nextState;
        _lastSyncText = syncTime;
        _syncing = false;
      });
      final navigator = Navigator.of(context);
      navigator.pop(_connected);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _connected
                ? '${widget.deviceName} paired & synced successfully!'
                : '${widget.deviceName} disconnected.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleWatchPair() async {
    if (_connected) {
      await _toggleConnection();
      return;
    }
    if (kIsWeb) {
      if (!mounted) return;
      showFeatureMessage(
        context,
        'Health sync needs the mobile app — Apple Health / Health Connect aren\'t available in browsers.',
      );
      return;
    }
    setState(() => _syncing = true);
    try {
      final granted = await WatchSyncService.requestPermissions();
      if (!mounted) return;
      if (!granted) {
        setState(() => _syncing = false);
        showFeatureMessage(
          context,
          'Health permission not granted — allow access in system settings to sync watch workouts.',
        );
        return;
      }
      await DeviceService.setConnected(
        widget.deviceName,
        widget.category,
        true,
      );
      final syncTime = await DeviceService.getLastSync(widget.deviceName);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      setState(() {
        _connected = true;
        _lastSyncText = syncTime;
        _syncing = false;
      });
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${widget.deviceName} connected — health sync enabled.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _syncing = false);
      showFeatureMessage(context, 'Could not enable health sync: $e');
    }
  }

  Future<void> _startBleScan() async {
    setState(() {
      _syncing = true;
      _bleError = null;
      _showBleResults = true;
    });
    try {
      await _bleService.startWatchScan();
    } catch (e) {
      if (mounted) setState(() => _bleError = '$e');
    }
    if (mounted) setState(() => _syncing = false);
  }

  Future<void> _connectBle(DiscoveredWatchDevice device) async {
    setState(() {
      _syncing = true;
      _bleError = null;
    });
    try {
      await _bleService.connectToWatch(device);
      await DeviceService.setConnected(
        widget.deviceName,
        widget.category,
        true,
      );
      final syncTime = await DeviceService.getLastSync(widget.deviceName);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      setState(() {
        _connected = true;
        _lastSyncText = syncTime;
        _syncing = false;
        _showBleResults = false;
      });
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${device.name} connected${_bleService.isSimulated ? ' (simulated feed)' : ' — live heart rate streaming'}!',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _syncing = false;
        _bleError = '$e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
    }
  }

  Future<void> _disconnectBle() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _syncing = true);
    try {
      await _bleService.disconnect();
      await DeviceService.setConnected(
        widget.deviceName,
        widget.category,
        false,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[DeviceDialog BLE Disconnect Error] $e');
    }
    if (!mounted) return;
    setState(() {
      _connected = false;
      _syncing = false;
      _showBleResults = false;
    });
    Navigator.of(context).pop(false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${widget.deviceName} disconnected.',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _syncHealthWorkouts() async {
    if (kIsWeb) {
      showFeatureMessage(
        context,
        'Health sync needs the mobile app — Apple Health / Health Connect aren\'t available in browsers.',
      );
      return;
    }
    setState(() => _syncing = true);
    final count = await WatchSyncService.syncLatestWatchWorkouts();
    final syncTime = await DeviceService.getLastSync(widget.deviceName);

    if (mounted) {
      setState(() {
        _lastSyncText = syncTime;
        _syncing = false;
      });
      if (count == 0) {
        showFeatureMessage(
          context,
          'No new watch workouts found — grant Health permissions and record a workout first.',
        );
      } else {
        showFeatureMessage(
          context,
          '$count watch workout(s) imported to your calendar!',
        );
      }
    }
  }

  Future<void> _triggerManualSync() async {
    setState(() => _syncing = true);
    await DeviceService.forceSync(widget.deviceName);
    await Future.delayed(const Duration(milliseconds: 1000));
    final syncTime = await DeviceService.getLastSync(widget.deviceName);

    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      setState(() {
        _lastSyncText = syncTime;
        _syncing = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Latest metrics pulled from ${widget.deviceName}!',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _requestOAuthIntegration() async {
    setState(() => _requestLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('devices')
            .doc(DeviceService.sanitizeDeviceId(widget.deviceName))
            .set({
              'name': widget.deviceName,
              'category': widget.category,
              'status': 'requested',
              'requestedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('oauth_request_${widget.deviceName}', true);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DeviceDialog OAuth Request Error] $e');
    }
    if (!mounted) return;
    setState(() {
      _requested = true;
      _requestLoading = false;
    });
    showFeatureMessage(
      context,
      'We\'ll notify you when ${widget.deviceName} is ready.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: _connected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.deviceName,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : navy),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: navy.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.category,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : navy),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _connected
                              ? Colors.green.withValues(alpha: 0.15)
                              : _requested
                              ? Colors.orange.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _connected
                              ? 'CONNECTED'
                              : _requested
                              ? 'REQUESTED'
                              : 'DISCONNECTED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: _connected
                                ? Colors.green[800]
                                : _requested
                                ? Colors.orange[800]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_connected) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Last Sync',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _lastSyncText,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFB0BEC5)
                                : ink),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_syncing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Communicating with sensor...',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isSensor && _showBleResults)
              _buildBleResults()
            else if (_isAppTile)
              _buildOAuthPanel()
            else ...[
              Text(
                _connected
                    ? 'Auto-sync is enabled. Veltrix will fetch heart rate, power, and GPS tracks automatically.'
                    : 'Pair this device to sync workouts directly from your wearable sensor.',
                style: TextStyle(
                  fontSize: 13,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFB0BEC5).withValues(alpha: 0.8)
                      : ink.withValues(alpha: 0.8)),
                ),
              ),
            ],
            if (_bleError != null) ...[
              const SizedBox(height: 8),
              Text(
                _bleError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _syncing ? null : () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (_isWatch)
          OutlinedButton.icon(
            icon: const Icon(Icons.watch, size: 18),
            label: const Text('Sync HealthKit'),
            onPressed: _syncing ? null : _syncHealthWorkouts,
          )
        else if (_connected && !_isSensor && !_isAppTile)
          OutlinedButton.icon(
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Force Sync'),
            onPressed: _syncing ? null : _triggerManualSync,
          ),
        if (_isSensor)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _connected ? Colors.red[700] : lime,
              foregroundColor: _connected ? Colors.white : navy,
            ),
            onPressed: _syncing
                ? null
                : _connected
                ? _disconnectBle
                : _showBleResults
                ? null
                : _startBleScan,
            child: Text(
              _connected
                  ? 'Disconnect Device'
                  : _showBleResults
                  ? 'Scanning...'
                  : 'Pair & Connect',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          )
        else if (_isAppTile)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _requested ? Colors.grey[300] : lime,
              foregroundColor: navy,
            ),
            onPressed: (_requestLoading || _requested)
                ? null
                : _requestOAuthIntegration,
            child: Text(
              _requested ? 'Request received' : 'Notify me when ready',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          )
        else
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _connected ? Colors.red[700] : lime,
              foregroundColor: _connected ? Colors.white : navy,
            ),
            onPressed: _syncing ? null : _handleWatchPair,
            child: Text(
              _connected ? 'Disconnect Device' : 'Pair & Connect',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
      ],
    );
  }

  Widget _buildBleResults() {
    return ListenableBuilder(
      listenable: _bleService,
      builder: (context, _) {
        final devices = _bleService.discoveredDevices;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_bleService.isSimulated)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'Demo results — BLE unavailable on this device/browser.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.brown,
                  ),
                ),
              ),
            if (_bleService.isScanning && devices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Scanning for heart-rate sensors...',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            if (devices.isEmpty && !_bleService.isScanning)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No sensors found. Make sure your heart-rate strap is awake and nearby, then scan again.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ...devices.map(
              (d) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  Icons.bluetooth_searching,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : navy),
                ),
                title: Text(
                  d.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  'RSSI ${d.rssi} dBm${_bleService.isSimulated ? ' • demo' : ''}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _syncing ? null : () => _connectBle(d),
              ),
            ),
            TextButton.icon(
              onPressed: _syncing ? null : _startBleScan,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Scan again'),
            ),
            if (_bleService.isConnected)
              Text(
                'Live: ${_bleService.liveHeartRate} BPM from ${_bleService.connectedDeviceName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOAuthPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _requested
              ? '${widget.deviceName} links via OAuth — request received. We\'ll notify you when it\'s ready.'
              : '${widget.deviceName} links via OAuth — coming to your account soon.',
          style: TextStyle(
            fontSize: 13,
            color: (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFB0BEC5).withValues(alpha: 0.8)
                : ink.withValues(alpha: 0.8)),
          ),
        ),
        if (_requestLoading) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }
}

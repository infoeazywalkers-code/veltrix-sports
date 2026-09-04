import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/device_service.dart';
import '../services/watch_sync_service.dart';
import '../services/ble_sensor_service.dart';

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

  Future<void> _loadDeviceState() async {
    final status = await DeviceService.isConnected(widget.deviceName);
    final syncTime = await DeviceService.getLastSync(widget.deviceName);
    if (mounted) {
      setState(() {
        _connected = status;
        _lastSyncText = syncTime;
      });
    }
  }

  Future<void> _toggleConnection() async {
    setState(() => _syncing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final nextState = !_connected;
    await DeviceService.setConnected(widget.deviceName, widget.category, nextState);
    final syncTime = await DeviceService.getLastSync(widget.deviceName);

    if (mounted) {
      setState(() {
        _connected = nextState;
        _lastSyncText = syncTime;
        _syncing = false;
      });
      Navigator.pop(context, _connected);
      showFeatureMessage(
        context,
        _connected
            ? '${widget.deviceName} paired & synced successfully!'
            : '${widget.deviceName} disconnected.',
      );
    }
  }

  Future<void> _syncHealthWorkouts() async {
    setState(() => _syncing = true);
    final count = await WatchSyncService.syncLatestWatchWorkouts();
    final syncTime = await DeviceService.getLastSync(widget.deviceName);

    if (mounted) {
      setState(() {
        _lastSyncText = syncTime;
        _syncing = false;
      });
      showFeatureMessage(context, '$count watch workout(s) imported to your calendar!');
    }
  }

  Future<void> _triggerManualSync() async {
    setState(() => _syncing = true);
    await DeviceService.forceSync(widget.deviceName);
    await Future.delayed(const Duration(milliseconds: 1000));
    final syncTime = await DeviceService.getLastSync(widget.deviceName);

    if (mounted) {
      setState(() {
        _lastSyncText = syncTime;
        _syncing = false;
      });
      showFeatureMessage(context, 'Latest metrics pulled from ${widget.deviceName}!');
    }
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
              style: const TextStyle(fontWeight: FontWeight.w900, color: navy),
            ),
          ),
        ],
      ),
      content: Column(
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
                    const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(widget.category, style: const TextStyle(fontWeight: FontWeight.w800, color: navy)),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _connected ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _connected ? 'CONNECTED' : 'DISCONNECTED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: _connected ? Colors.green[800] : Colors.grey[700],
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
                      const Text('Last Sync', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(_lastSyncText, style: const TextStyle(fontWeight: FontWeight.w800, color: ink)),
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
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('Communicating with sensor...', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            )
          else ...[
            Text(
              _connected
                  ? 'Auto-sync is enabled. Veltrix will fetch heart rate, power, and GPS tracks automatically.'
                  : 'Pair this device to sync workouts directly from your wearable sensor.',
              style: TextStyle(fontSize: 13, color: ink.withValues(alpha: 0.8)),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _syncing ? null : () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (widget.category.toLowerCase().contains('wearable') || widget.deviceName.toLowerCase().contains('watch'))
          OutlinedButton.icon(
            icon: const Icon(Icons.watch, size: 18),
            label: const Text('Sync HealthKit'),
            onPressed: _syncing ? null : _syncHealthWorkouts,
          )
        else if (_connected)
          OutlinedButton.icon(
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Force Sync'),
            onPressed: _syncing ? null : _triggerManualSync,
          ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _connected ? Colors.red[700] : lime,
            foregroundColor: _connected ? Colors.white : navy,
          ),
          onPressed: _syncing ? null : _toggleConnection,
          child: Text(
            _connected ? 'Disconnect Device' : 'Pair & Connect',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

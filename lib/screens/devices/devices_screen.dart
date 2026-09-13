import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/common/section_intro.dart';
import '../../widgets/common/veltrix_footer.dart';
import '../../widgets/dialogs/device_connect_dialog.dart';
import '../../services/activity/watch_sync_service.dart';
import '../../services/devices/ble_sensor_service.dart';
import '../../services/devices/device_service.dart';
import '../explore/production_pages.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        desktop ? 40 : 18,
        32,
        desktop ? 40 : 18,
        64,
      ),
      children: [
        const SectionIntro(
          eyebrow: 'DEVICES & WATCHES',
          title: 'One App, Endless Ways to Train',
          body:
              'Connect your Apple Watch, Garmin, Polar, or COROS via Apple HealthKit & HealthConnect for auto workout sync, or pair BLE heart rate monitors for live training.',
        ),
        const SizedBox(height: 24),
        const _WatchSyncBanner(),
        const SizedBox(height: 32),
        const _TopDevices(),
        const SizedBox(height: 40),
        const _DeviceCategory('Cycling', [
          ('Garmin Edge', Icons.watch_outlined, true),
          ('Wahoo ELEMNT', Icons.directions_bike_outlined, true),
          ('Polar Vantage', Icons.favorite_outline, false),
          ('COROS PACE 3', Icons.watch, false),
          ('Bryton Rider', Icons.speed, false),
          ('SRM PowerMeter', Icons.power, false),
          ('Wattbike Atom', Icons.directions_bike, false),
        ]),
        const SizedBox(height: 24),
        const _DeviceCategory('Running', [
          ('Apple Watch Series 9', Icons.watch_outlined, true),
          ('Garmin Forerunner', Icons.watch, true),
          ('STRYD Footpod', Icons.speed, false),
          ('COROS Apex 2', Icons.watch_outlined, false),
          ('Polar H10', Icons.favorite_outline, false),
        ]),
        const SizedBox(height: 24),
        const _DeviceCategory('Swimming', [
          ('FORM Smart Goggles', Icons.pool, false),
          ('Garmin Swim 2', Icons.pool_outlined, true),
          ('Polar Verity Sense', Icons.favorite_outline, false),
        ]),
        const SizedBox(height: 24),
        const _DeviceCategory('Virtual Reality', [
          ('Zwift Companion', Icons.sports_esports, true),
          ('Rouvy AR', Icons.landscape, false),
          ('Veltrix Virtual', Icons.videocam_outlined, false),
          ('MyWhoosh', Icons.sports, false),
          ('Kinomap', Icons.map_outlined, false),
        ]),
        const SizedBox(height: 24),
        const _DeviceCategory('Nutrition & Health', [
          ('MyFitnessPal', Icons.restaurant_outlined, true),
          ('Withings Body Scan', Icons.monitor_weight_outlined, false),
          ('OURA Ring Gen 3', Icons.bedtime_outlined, true),
          ('Whoop 4.0', Icons.favorite_outline, false),
        ]),
        const SizedBox(height: 24),
        const _DeviceCategory('Coaching & Analytics', [
          ('TrainingPeaks', Icons.analytics_outlined, true),
          ('Best Bike Split', Icons.speed, false),
          ('TodaysPlan', Icons.insert_chart_outlined, false),
        ]),
        const SizedBox(height: 40),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0F2030)
                : const Color(0xffeaf2f8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.help_outline, color: blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Don\u2019t see your device? Contact our support team and we\u2019ll help you get connected.',
                  style: TextStyle(
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => supportScreen()),
                ),
                child: const Text(
                  'Contact support',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        const VeltrixFooter(),
      ],
    );
  }
}

class _TopDevices extends StatefulWidget {
  const _TopDevices();
  @override
  State<_TopDevices> createState() => _TopDevicesState();
}

class _TopDevicesState extends State<_TopDevices> {
  static const _devices = [
    ('Apple Watch Series 9', Icons.watch_outlined, 'Wearable', true),
    ('Garmin Forerunner', Icons.watch, 'GPS Watch', true),
    ('Wahoo ELEMNT', Icons.directions_bike_outlined, 'Bike Computer', true),
    ('Zwift Companion', Icons.videocam_outlined, 'Virtual App', false),
    ('Polar H10', Icons.favorite_outline, 'Heart Rate', false),
    ('OURA Ring Gen 3', Icons.bedtime_outlined, 'Recovery', true),
  ];

  final Map<String, bool> _states = {};

  @override
  void initState() {
    super.initState();
    _refreshStates();
  }

  Future<void> _refreshStates() async {
    for (final d in _devices) {
      try {
        final connected = await DeviceService.isConnected(d.$1);
        if (mounted) setState(() => _states[d.$1] = connected);
      } catch (_) {}
    }
  }

  bool _isConnected(String name, bool fallback) => _states[name] ?? fallback;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _devices.map((d) {
        final connected = _isConnected(d.$1, false);
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final changed = await showDialog<bool>(
              context: context,
              builder: (_) => DeviceConnectDialog(
                deviceName: d.$1,
                category: d.$3,
                isConnected: connected,
              ),
            );
            if (changed != null) {
              await _refreshStates();
            }
          },
          child: Container(
            width: desktop ? 150 : (MediaQuery.sizeOf(context).width - 50) / 3,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: connected
                    ? Colors.green.withValues(alpha: 0.4)
                    : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A3040)
                          : const Color(0xffe4eaf0)),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  d.$2,
                  color: connected
                      ? Colors.green[800]
                      : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : navy),
                  size: 32,
                ),
                const SizedBox(height: 10),
                Text(
                  d.$1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  connected ? 'Connected' : 'Tap to pair',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: connected
                        ? Colors.green[700]
                        : (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF78909C)
                              : muted),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DeviceCategory extends StatelessWidget {
  final String category;
  final List<(String, IconData, bool)> devices;
  const _DeviceCategory(this.category, this.devices);
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.toUpperCase(),
              style: const TextStyle(
                color: blue,
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: desktop ? 12 : 10,
              runSpacing: desktop ? 12 : 10,
              children: devices
                  .map((d) => _DeviceChip(d.$1, d.$2, category, d.$3))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceChip extends StatefulWidget {
  final String name;
  final IconData icon;
  final String category;
  final bool connected;
  const _DeviceChip(this.name, this.icon, this.category, this.connected);
  @override
  State<_DeviceChip> createState() => _DeviceChipState();
}

class _DeviceChipState extends State<_DeviceChip> {
  late bool _connected;

  @override
  void initState() {
    super.initState();
    _connected = widget.connected;
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final real = await DeviceService.isConnected(widget.name);
      if (mounted) setState(() => _connected = real);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () async {
      final changed = await showDialog<bool>(
        context: context,
        builder: (_) => DeviceConnectDialog(
          deviceName: widget.name,
          category: widget.category,
          isConnected: _connected,
        ),
      );
      if (changed != null && mounted) {
        setState(() => _connected = changed);
      } else {
        await _loadState();
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _connected
            ? lime.withValues(alpha: 0.25)
            : (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F2030)
                  : bg),
        borderRadius: BorderRadius.circular(12),
        border: _connected
            ? Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.3)
                    : navy.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: _connected
                ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : navy)
                : (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF78909C)
                      : muted),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            widget.name,
            style: TextStyle(
              color: _connected
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy)
                  : (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFB0BEC5)
                        : ink),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          if (_connected) ...[
            const SizedBox(width: 6),
            const Icon(Icons.check_circle, color: Colors.green, size: 14),
          ],
        ],
      ),
    ),
  );
}

class _WatchSyncBanner extends StatefulWidget {
  const _WatchSyncBanner();

  @override
  State<_WatchSyncBanner> createState() => _WatchSyncBannerState();
}

class _WatchSyncBannerState extends State<_WatchSyncBanner> {
  bool _isSyncing = false;
  String? _syncStatus;
  bool _syncSuccess = false;

  Future<void> _handleSync() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = null;
    });

    if (kIsWeb) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncSuccess = false;
          _syncStatus =
              'Watch sync isn\'t available in browsers — install the mobile app and sync via Apple Health / Health Connect there.';
        });
      }
      return;
    }

    final count = await WatchSyncService.syncLatestWatchWorkouts();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        if (count > 0) {
          _syncSuccess = true;
          _syncStatus =
              'Successfully imported $count workout${count == 1 ? '' : 's'} from Apple Health / HealthConnect!';
        } else {
          _syncSuccess = false;
          _syncStatus =
              'No new workouts — allow Health permissions and record an activity on your watch first.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ble = BleSensorService();
    return ListenableBuilder(
      listenable: ble,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [navy, Color(0xff1e3a5f)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: lime.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.watch_outlined,
                      color: lime,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Apple Watch & HealthConnect Auto-Sync',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ble.isConnected
                              ? 'Connected to ${ble.connectedDeviceName} (${ble.liveHeartRate} BPM streaming)'
                              : 'Auto-import workouts from Apple Watch, Garmin, Polar & COROS',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        if (ble.isConnected && ble.isSimulated)
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              'SIMULATED FEED — pair a real sensor for live data.',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_syncStatus != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _syncSuccess
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _syncSuccess
                          ? Colors.green.withValues(alpha: 0.5)
                          : Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _syncSuccess ? Icons.check_circle : Icons.info_outline,
                        color: _syncSuccess ? Colors.green : Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _syncStatus!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _handleSync,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lime,
                      foregroundColor: navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: navy,
                            ),
                          )
                        : const Icon(Icons.sync, size: 18),
                    label: Text(
                      _isSyncing ? 'Syncing...' : 'Sync Watch Workouts Now',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final real = await DeviceService.isConnected(
                        'Apple Watch Series 9',
                      );
                      if (!context.mounted) return;
                      await showDialog<bool>(
                        context: context,
                        builder: (_) => DeviceConnectDialog(
                          deviceName: 'Apple Watch Series 9',
                          category: 'Wearable',
                          isConnected: real,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.bluetooth_searching, size: 18),
                    label: const Text(
                      'Pair BLE Sensor',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

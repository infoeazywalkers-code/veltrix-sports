import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/section_intro.dart';
import '../widgets/veltrix_footer.dart';
import '../widgets/device_connect_dialog.dart';
import '../services/watch_sync_service.dart';
import '../services/ble_sensor_service.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return ListView(
      padding: EdgeInsets.fromLTRB(desktop ? 40 : 18, 32, desktop ? 40 : 18, 64),
      children: [
        const SectionIntro(
          eyebrow: 'DEVICES & WATCHES',
          title: 'One App, Endless Ways to Train',
          body: 'Connect your Apple Watch, Garmin, Polar, or COROS via Apple HealthKit & HealthConnect for auto workout sync, or pair BLE heart rate monitors for live training.',
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
          decoration: BoxDecoration(color: const Color(0xffeaf2f8), borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const Icon(Icons.help_outline, color: blue),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Don\u2019t see your device? Contact our support team and we\u2019ll help you get connected.',
                  style: TextStyle(color: navy, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () => showFeatureMessage(context, 'Contact support feature coming soon!'),
                child: const Text('Contact support', style: TextStyle(fontWeight: FontWeight.w800)),
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


class _TopDevices extends StatelessWidget {
  const _TopDevices();
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    const devices = [
      ('Apple Watch Series 9', Icons.watch_outlined, 'Wearable', true),
      ('Garmin Forerunner', Icons.watch, 'GPS Watch', true),
      ('Wahoo ELEMNT', Icons.directions_bike_outlined, 'Bike Computer', true),
      ('Zwift Companion', Icons.videocam_outlined, 'Virtual App', false),
      ('Polar H10', Icons.favorite_outline, 'Heart Rate', false),
      ('OURA Ring Gen 3', Icons.bedtime_outlined, 'Recovery', true),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: devices.map((d) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showDialog(
          context: context,
          builder: (_) => DeviceConnectDialog(
            deviceName: d.$1,
            category: d.$3,
            isConnected: d.$4,
          ),
        ),
        child: Container(
          width: desktop ? 150 : (MediaQuery.sizeOf(context).width - 50) / 3,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: d.$4 ? Colors.green.withValues(alpha: 0.4) : const Color(0xffe4eaf0)),
          ),
          child: Column(
            children: [
              Icon(d.$2, color: d.$4 ? Colors.green[800] : navy, size: 32),
              const SizedBox(height: 10),
              Text(
                d.$1,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, color: navy, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                d.$4 ? 'Connected' : 'Tap to pair',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: d.$4 ? Colors.green[700] : muted,
                ),
              ),
            ],
          ),
        ),
      )).toList(),
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
              style: const TextStyle(color: blue, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: desktop ? 12 : 10,
              runSpacing: desktop ? 12 : 10,
              children: devices.map((d) => _DeviceChip(d.$1, d.$2, category, d.$3)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final String category;
  final bool connected;
  const _DeviceChip(this.name, this.icon, this.category, this.connected);
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () => showDialog(
      context: context,
      builder: (_) => DeviceConnectDialog(
        deviceName: name,
        category: category,
        isConnected: connected,
      ),
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: connected ? lime.withValues(alpha: 0.25) : bg,
        borderRadius: BorderRadius.circular(12),
        border: connected ? Border.all(color: navy.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: connected ? navy : muted, size: 18),
          const SizedBox(width: 8),
          Text(name, style: TextStyle(color: connected ? navy : ink, fontWeight: FontWeight.w700, fontSize: 12)),
          if (connected) ...[
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

  Future<void> _handleSync() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = null;
    });

    final count = await WatchSyncService.syncLatestWatchWorkouts();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _syncStatus = 'Successfully imported $count workout${count == 1 ? '' : 's'} from Apple Health / HealthConnect!';
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
                    child: const Icon(Icons.watch_outlined, color: lime, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Apple Watch & HealthConnect Auto-Sync',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ble.isConnected
                              ? 'Connected to ${ble.connectedDeviceName} (${ble.liveHeartRate} BPM streaming)'
                              : 'Auto-import workouts from Apple Watch, Garmin, Polar & COROS',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _syncStatus!,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: navy),
                          )
                        : const Icon(Icons.sync, size: 18),
                    label: Text(
                      _isSyncing ? 'Syncing...' : 'Sync Watch Workouts Now',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const DeviceConnectDialog(
                          deviceName: 'Apple Watch Series 9',
                          category: 'Wearable',
                          isConnected: false,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.bluetooth_searching, size: 18),
                    label: const Text(
                      'Pair BLE Sensor',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
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



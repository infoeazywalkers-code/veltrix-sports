import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/section_intro.dart';
import '../widgets/veltrix_footer.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    return ListView(
      padding: EdgeInsets.fromLTRB(desktop ? 40 : 18, 32, desktop ? 40 : 18, 64),
      children: [
        const SectionIntro(
          eyebrow: 'DEVICES',
          title: 'One App, Endless Ways to Train',
          body: 'Connect your favorite devices and apps. Veltrix syncs with 100+ integrations to keep all your training data in one place.',
        ),
        const SizedBox(height: 40),
        const _TopDevices(),
        const SizedBox(height: 40),
        const _DeviceCategory('Cycling', [
          ('Garmin', Icons.watch_outlined),
          ('Wahoo', Icons.directions_bike_outlined),
          ('Polar', Icons.favorite_outline),
          ('COROS', Icons.watch),
          ('Bryton', Icons.speed),
          ('SRM', Icons.power),
          ('Wattbike', Icons.directions_bike),
        ]),
        const SizedBox(height: 24),
        const _DeviceCategory('Running', [
          ('Apple Watch', Icons.watch_outlined),
          ('Garmin', Icons.watch),
          ('STRYD', Icons.speed),
          ('COROS', Icons.watch_outlined),
          ('Polar', Icons.favorite_outline),
        ]),
        const SizedBox(height: 24),
        const _DeviceCategory('Swimming', [
          ('FORM', Icons.pool),
          ('Garmin Swim', Icons.pool_outlined),
          ('Polar', Icons.favorite_outline),
        ]),
        const SizedBox(height: 24),
        const _DeviceCategory('Virtual Reality', [
          ('Zwift', Icons.sports_esports),
          ('Rouvy', Icons.landscape),
          ('Veltrix Virtual', Icons.videocam_outlined),
          ('MyWhoosh', Icons.sports),
          ('Kinomap', Icons.map_outlined),
        ]),
        const SizedBox(height: 24),
        const _DeviceCategory('Nutrition & Health', [
          ('MyFitnessPal', Icons.restaurant_outlined),
          ('Withings', Icons.monitor_weight_outlined),
          ('OURA', Icons.bedtime_outlined),
          ('Whoop', Icons.favorite_outline),
        ]),
        const SizedBox(height: 24),
        const _DeviceCategory('Coaching & Analytics', [
          ('TrainingPeaks', Icons.analytics_outlined),
          ('Best Bike Split', Icons.speed),
          ('TodaysPlan', Icons.insert_chart_outlined),
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
                onPressed: () {},
                child: const Text('Contact support', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        VeltrixFooter(),
      ],
    );
  }
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(body: DevicesScreen()),
));

class _TopDevices extends StatelessWidget {
  const _TopDevices();
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    const devices = [
      ('Apple Watch', Icons.watch_outlined),
      ('Garmin', Icons.watch),
      ('Wahoo', Icons.directions_bike_outlined),
      ('Veltrix Virtual', Icons.videocam_outlined),
      ('Polar', Icons.favorite_outline),
      ('OURA', Icons.bedtime_outlined),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: devices.map((d) => Container(
        width: desktop ? 150 : (MediaQuery.sizeOf(context).width - 50) / 3,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffe4eaf0)),
        ),
        child: Column(
          children: [
            Icon(d.$2, color: navy, size: 32),
            const SizedBox(height: 10),
            Text(d.$1, style: const TextStyle(fontWeight: FontWeight.w800, color: navy, fontSize: 13)),
          ],
        ),
      )).toList(),
    );
  }
}

class _DeviceCategory extends StatelessWidget {
  final String category;
  final List<(String, IconData)> devices;
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
            if (desktop)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: devices.map((d) => _DeviceChip(d.$1, d.$2)).toList(),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: devices.map((d) => _DeviceChip(d.$1, d.$2)).toList(),
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
  const _DeviceChip(this.name, this.icon);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: navy, size: 18),
        const SizedBox(width: 8),
        Text(name, style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 12)),
      ],
    ),
  );
}

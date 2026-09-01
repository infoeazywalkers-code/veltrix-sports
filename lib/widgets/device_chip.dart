import 'package:flutter/material.dart';
import '../constants.dart';

class DeviceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const DeviceChip(this.icon, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 150,
    padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xffe4eaf0)),
    ),
    child: Column(
      children: [
        Icon(icon, color: navy, size: 27),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: ink,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(body: Center(child: DeviceChip(Icons.watch_outlined, 'Smartwatch'))),
));

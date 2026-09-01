import 'package:flutter/material.dart';
import '../constants.dart';

class Best extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const Best(this.title, this.value, this.icon, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: muted, fontSize: 11)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: navy,
            ),
          ),
        ],
      ),
    ),
  );
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(
    body: Center(
      child: Best('5K run', '21:42', Icons.directions_run, blue),
    ),
  ),
));

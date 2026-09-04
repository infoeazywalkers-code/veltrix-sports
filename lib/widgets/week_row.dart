import 'package:flutter/material.dart';
import '../constants.dart';

class WeekRow extends StatelessWidget {
  final String day, title, time;
  final Color color;
  final IconData icon;
  const WeekRow(this.day, this.title, this.time, this.color, this.icon, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: ink)),
        subtitle: Text('$day  \u2022  $time', style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, color: muted),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import '../../core/constants.dart';

class WeekRow extends StatelessWidget {
  final String day, title, time;
  final Color color;
  final IconData icon;
  const WeekRow(
    this.day,
    this.title,
    this.time,
    this.color,
    this.icon, {
    super.key,
  });
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
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFB0BEC5)
                : ink),
          ),
        ),
        subtitle: Text(
          '$day  \u2022  $time',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF78909C)
              : muted),
        ),
      ),
    ),
  );
}

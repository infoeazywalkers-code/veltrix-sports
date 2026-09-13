import 'package:flutter/material.dart';
import '../../core/constants.dart';

class Insight extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, body;
  const Insight(this.icon, this.color, this.title, this.body, {super.key});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color:
              (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : navy),
        ),
      ),
      subtitle: Text(body, style: const TextStyle(fontSize: 11)),
    ),
  );
}

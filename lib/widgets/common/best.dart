import 'package:flutter/material.dart';
import '../../core/constants.dart';

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
          Text(title, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF78909C) : muted), fontSize: 11)),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : navy),
            ),
          ),
        ],
      ),
    ),
  );
}


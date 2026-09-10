import 'package:flutter/material.dart';
import '../../core/constants.dart';

class DeviceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const DeviceChip(this.icon, this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1A3040) : const Color(0xffe4eaf0),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isDark ? Colors.white : navy, size: 27),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFFE0E6ED) : ink,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

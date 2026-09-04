import 'package:flutter/material.dart';
import '../constants.dart';

class TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const TrustBadge(this.icon, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: const Color(0xffe3e9ef)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: muted),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: muted,
            fontSize: 10,
            letterSpacing: .5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}


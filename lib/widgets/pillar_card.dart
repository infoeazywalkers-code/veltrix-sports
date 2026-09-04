import 'package:flutter/material.dart';
import '../constants.dart';

class PillarCard extends StatelessWidget {
  final String number, verb, title, body;
  final IconData icon;
  const PillarCard({
    super.key,
    required this.number,
    required this.verb,
    required this.title,
    required this.body,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 245),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Icon(icon, color: lime),
          ],
        ),
        const SizedBox(height: 48),
        Text(
          verb,
          style: const TextStyle(
            color: lime,
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}


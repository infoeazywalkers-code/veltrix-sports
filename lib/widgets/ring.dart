import 'package:flutter/material.dart';
import '../constants.dart';

class Ring extends StatelessWidget {
  final String value, label;
  final Color color;
  final double amount;
  const Ring(this.value, this.label, this.color, this.amount, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        width: 68,
        height: 68,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: amount,
                strokeWidth: 7,
                color: color,
                backgroundColor: color.withValues(alpha: .12),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 19,
                color: navy,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: const TextStyle(
          color: muted,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    ],
  );
}


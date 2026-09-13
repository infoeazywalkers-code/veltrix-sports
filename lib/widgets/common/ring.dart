import 'package:flutter/material.dart';
import '../../core/constants.dart';

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
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 19,
                color:
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: TextStyle(
          color:
              (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF78909C)
                  : muted),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    ],
  );
}

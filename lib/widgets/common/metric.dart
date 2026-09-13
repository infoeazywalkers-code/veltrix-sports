import 'package:flutter/material.dart';
import '../../core/constants.dart';

class Metric extends StatelessWidget {
  final String value, label;
  const Metric(this.value, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color:
              (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : navy),
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          color:
              (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF78909C)
                  : muted),
          fontSize: 10,
        ),
      ),
    ],
  );
}

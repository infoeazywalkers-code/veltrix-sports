import 'package:flutter/material.dart';
import '../constants.dart';

class Metric extends StatelessWidget {
  final String value, label;
  const Metric(this.value, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: navy,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(label, style: const TextStyle(color: muted, fontSize: 10)),
    ],
  );
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(body: Center(child: Metric('45m', 'Duration'))),
));

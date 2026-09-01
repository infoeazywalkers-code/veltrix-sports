import 'package:flutter/material.dart';
import '../constants.dart';

class SectionHeading extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onActionTap;
  const SectionHeading(this.text, {super.key, this.action, this.onActionTap});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: navy,
          ),
        ),
      ),
      if (action != null)
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            action!,
            style: const TextStyle(
              color: blue,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
        ),
      ),
    ],
  );
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(
    body: Padding(
      padding: EdgeInsets.all(18),
      child: SectionHeading("Today's training", action: 'View week'),
    ),
  ),
));

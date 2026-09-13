import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SectionIntro extends StatelessWidget {
  final String eyebrow, title, body;
  const SectionIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        eyebrow,
        style: const TextStyle(
          color: blue,
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color:
              (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : navy),
          fontSize: 32,
          height: 1.05,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 10),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF78909C)
                    : muted),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}

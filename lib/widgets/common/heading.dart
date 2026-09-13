import 'package:flutter/material.dart';
import '../../core/constants.dart';

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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : navy),
          ),
        ),
      ),
      if (action != null)
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
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
        ),
    ],
  );
}

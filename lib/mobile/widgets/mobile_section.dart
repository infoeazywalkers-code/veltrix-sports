import 'package:flutter/material.dart';
import '../theme.dart';

class MSection extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onActionTap;
  final Widget child;

  const MSection({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: M.adaptiveSectionTitle(context)),
            ),
            if (action != null)
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  action!,
                  style: const TextStyle(
                    color: M.blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: M.md),
        child,
      ],
    );
  }
}

class MSectionIntro extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String body;

  const MSectionIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: M.blue,
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: M.sm),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : M.navy),
            fontSize: 26,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: M.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: M.adaptiveMuted(context),
        ),
      ],
    );
  }
}

class MDivider extends StatelessWidget {
  final String? label;
  const MDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) return const Divider();
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: M.base),
          child: Text(
            label!,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF78909C) : M.muted),
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}


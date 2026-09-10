import 'package:flutter/material.dart';

class FooterSocial extends StatelessWidget {
  final IconData icon;
  const FooterSocial(this.icon, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: Colors.white70, size: 17),
  );
}


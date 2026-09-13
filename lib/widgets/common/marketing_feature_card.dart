import 'package:flutter/material.dart';
import '../../core/constants.dart';

class MarketingFeatureCard extends StatelessWidget {
  final String? image;
  final Color? color;
  final IconData? icon;
  final String eyebrow, title, body, action;
  final VoidCallback? onActionTap;
  const MarketingFeatureCard({
    super.key,
    this.image,
    this.color,
    this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.action,
    this.onActionTap,
  });
  @override
  Widget build(BuildContext context) => Container(
    height: 390,
    decoration: BoxDecoration(
      color: color ?? navy,
      borderRadius: BorderRadius.circular(22),
      image: image == null
          ? null
          : DecorationImage(image: AssetImage(image!), fit: BoxFit.cover),
    ),
    child: Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x11102a43), Color(0xf2102a43)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (icon != null) ...[
            Icon(icon, color: lime, size: 42),
            const Spacer(),
          ],
          Text(
            eyebrow,
            style: const TextStyle(
              color: lime,
              fontSize: 9,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onActionTap,
            child: Row(
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.arrow_forward_rounded, color: lime, size: 18),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import '../constants.dart';

class FooterGroup extends StatelessWidget {
  final String title;
  final List<String> links;
  final List<VoidCallback?>? onTapLinks;
  const FooterGroup({super.key, required this.title, required this.links, this.onTapLinks});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: lime,
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 13),
      for (var i = 0; i < links.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: onTapLinks != null && i < onTapLinks!.length ? onTapLinks![i] : null,
            child: Text(
              links[i],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ),
      ),
    ],
  );
}


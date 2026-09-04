import 'package:flutter/material.dart';
import '../constants.dart';

class EditorialBanner extends StatelessWidget {
  final String image, eyebrow, title;
  final Alignment alignment;
  const EditorialBanner({
    super.key,
    required this.image,
    required this.eyebrow,
    required this.title,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 190,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
    ),
    foregroundDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: alignment == Alignment.centerLeft
            ? Alignment.centerLeft
            : Alignment.centerRight,
        end: alignment == Alignment.centerLeft
            ? Alignment.centerRight
            : Alignment.centerLeft,
        colors: const [Color(0xe6102a43), Color(0x22102a43)],
      ),
    ),
    child: Align(
      alignment: alignment,
      child: SizedBox(
        width: 210,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: lime,
                  fontSize: 9,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


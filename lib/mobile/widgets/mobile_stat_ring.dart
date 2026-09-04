import 'package:flutter/material.dart';
import '../theme.dart';

class MStatRing extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final double progress;
  final double size;

  const MStatRing({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.progress,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.12),
                ),
              ),
              Text(value, style: M.statBig),
            ],
          ),
        ),
        const SizedBox(height: M.xs),
        Text(label, style: M.statLabel),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import '../../core/constants.dart';

class Brand extends StatelessWidget {
  final double size;
  const Brand({super.key, this.size = 34});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: lime,
      borderRadius: BorderRadius.circular(size * 0.29),
    ),
    child: Icon(Icons.bolt_rounded, color: navy, size: size * 0.6),
  );
}


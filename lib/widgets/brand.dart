import 'package:flutter/material.dart';
import '../constants.dart';

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

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(body: Center(child: Brand())),
));

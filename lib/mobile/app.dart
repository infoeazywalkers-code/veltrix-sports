import 'package:flutter/material.dart';
import 'theme.dart';
import 'shell.dart';

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Veltrix Sports',
      theme: M.theme,
      home: const MobileShell(),
    );
  }
}

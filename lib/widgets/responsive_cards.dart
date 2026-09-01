import 'package:flutter/material.dart';
import '../constants.dart';

class ResponsiveCards extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  const ResponsiveCards({super.key, required this.children, this.mobileColumns = 1});
  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    if (!desktop || mobileColumns > 1) {
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: children,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) const SizedBox(width: 14),
        ],
      ],
    );
  }
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(
    body: Padding(
      padding: EdgeInsets.all(18),
      child: ResponsiveCards(
        children: [
          Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Card 1'))),
          Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Card 2'))),
          Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Card 3'))),
        ],
      ),
    ),
  ),
));

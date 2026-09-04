import 'package:flutter/material.dart';

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


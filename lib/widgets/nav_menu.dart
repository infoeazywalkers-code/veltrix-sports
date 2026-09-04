import 'package:flutter/material.dart';
import '../constants.dart';

class NavMenu extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<int> onSelected;
  const NavMenu({
    super.key,
    required this.label,
    required this.items,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
    tooltip: label,
    color: Colors.white,
    offset: const Offset(0, 52),
    onSelected: onSelected,
    itemBuilder: (_) => List.generate(
      items.length,
      (i) => PopupMenuItem(
        value: i,
        child: SizedBox(
          width: 180,
          child: Text(
            items[i],
            style: const TextStyle(color: ink, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(Icons.keyboard_arrow_down, size: 17),
        ],
      ),
    ),
  );
}


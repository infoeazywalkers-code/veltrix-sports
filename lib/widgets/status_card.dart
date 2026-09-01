import 'package:flutter/material.dart';
import '../constants.dart';
import 'ring.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Ring('54', 'Fitness', blue, .72),
              Ring('61', 'Fatigue', purple, .81),
              Ring('-7', 'Form', orange, .46),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.trending_up, color: successGreen),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Productive training \u2014 fitness is building steadily.',
                    style: TextStyle(
                      color: successText,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(body: Center(child: StatusCard())),
));

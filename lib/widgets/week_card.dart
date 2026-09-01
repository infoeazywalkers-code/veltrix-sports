import 'package:flutter/material.dart';
import '../constants.dart';
import 'metric.dart';

class WeekCard extends StatelessWidget {
  const WeekCard({super.key});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Metric('5', 'Workouts'),
              Metric('4h 35m', 'Duration'),
              Metric('286', 'TSS'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (i) => Column(
                children: [
                  Container(
                    width: 20,
                    height: [30.0, 55.0, 18.0, 68.0, 42.0, 74.0, 25.0][i],
                    decoration: BoxDecoration(
                      color: i == 5 ? lime : blue.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
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
  home: const Scaffold(body: Center(child: WeekCard())),
));

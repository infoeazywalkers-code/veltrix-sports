import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers.dart';
import 'ring.dart';

class StatusCard extends ConsumerWidget {
  const StatusCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfAsync = ref.watch(latestPerformanceProvider);
    final perf = perfAsync.valueOrNull;

    final fitnessVal = perf?.fitness ?? 0;
    final fatigueVal = perf?.fatigue ?? 0;
    final formVal = perf?.form ?? 0;

    final fitnessStr = perf != null ? fitnessVal.toStringAsFixed(0) : '\u2014';
    final fatigueStr = perf != null ? fatigueVal.toStringAsFixed(0) : '\u2014';
    final formStr = perf != null
        ? (formVal > 0
              ? '+${formVal.toStringAsFixed(0)}'
              : formVal.toStringAsFixed(0))
        : '\u2014';

    // Clamp ring amounts: fitness/fatigue normalized to 0-100 scale, form to 0-1 range
    final fitnessRing = perf != null ? (fitnessVal / 100).clamp(0.0, 1.0) : 0.0;
    final fatigueRing = perf != null ? (fatigueVal / 100).clamp(0.0, 1.0) : 0.0;
    final formRing = perf != null
        ? ((formVal + 50) / 100).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Ring(fitnessStr, 'Fitness', blue, fitnessRing),
                Ring(fatigueStr, 'Fatigue', purple, fatigueRing),
                Ring(formStr, 'Form', orange, formRing),
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
}

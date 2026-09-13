import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/performance/daily_training_metric.dart';

enum ForecastScenario { linear, average, taper, overload }

class FormState {
  final String label;
  final String color;
  final String description;

  const FormState({
    required this.label,
    required this.color,
    required this.description,
  });
}

class ForecastStats {
  final double slope;
  final double intercept;
  final int avgTss;
  final int weeklyTss;

  const ForecastStats({
    required this.slope,
    required this.intercept,
    required this.avgTss,
    required this.weeklyTss,
  });
}

class PmcService {
  static const int _ctlDecayDays = 42;
  static const int _atlDecayDays = 7;

  FormState getFormState(double tsb) {
    if (tsb > 25) {
      return const FormState(
        label: 'Transition / Detraining',
        color: 'neutral',
        description: 'Resting too long, aerobic fitness decaying',
      );
    }
    if (tsb >= 5) {
      return const FormState(
        label: 'Race Ready / Peak Freshness',
        color: 'emerald',
        description: 'Optimal freshness and neuromuscular snap for race day',
      );
    }
    if (tsb >= -10) {
      return const FormState(
        label: 'Neutral / Maintenance',
        color: 'sky',
        description: 'Good balance between aerobic stimulus and freshness',
      );
    }
    if (tsb >= -30) {
      return const FormState(
        label: 'Productive Training',
        color: 'amber',
        description: 'Optimal progressive overload building long-term fitness',
      );
    }
    return const FormState(
      label: 'High Fatigue / Overreaching Risk',
      color: 'rose',
      description: 'High risk of autonomic burnout, illness, or injury',
    );
  }

  ForecastStats computeForecastStats(List<DailyTrainingMetric> metrics) {
    if (metrics.isEmpty) {
      return const ForecastStats(
        slope: 0,
        intercept: 70,
        avgTss: 70,
        weeklyTss: 490,
      );
    }

    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    final n = metrics.length;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += metrics[i].tss;
      sumXY += i * metrics[i].tss;
      sumXX += i * i;
    }

    final avgTss = (sumY / n).round();
    final denominator = n * sumXX - sumX * sumX;
    final slope = denominator != 0
        ? (n * sumXY - sumX * sumY) / denominator
        : 0;
    final intercept = (sumY - slope * sumX) / n;

    return ForecastStats(
      slope: double.parse(slope.toStringAsFixed(2)),
      intercept: double.parse(intercept.toStringAsFixed(1)),
      avgTss: avgTss,
      weeklyTss: avgTss * 7,
    );
  }

  List<DailyTrainingMetric> compute7DayForecast({
    required List<DailyTrainingMetric> metrics,
    required ForecastScenario scenario,
  }) {
    if (metrics.isEmpty) return [];

    final lastMetric = metrics.last;
    final fourWeeks = metrics.length >= 28
        ? metrics.sublist(metrics.length - 28)
        : metrics;
    final forecastStats = computeForecastStats(fourWeeks);

    double currentCtl = lastMetric.ctl;
    double currentAtl = lastMetric.atl;

    final lastDate = DateTime.tryParse(lastMetric.date) ?? DateTime.now();
    final points = <DailyTrainingMetric>[];

    for (int d = 1; d <= 7; d++) {
      final futureDate = lastDate.add(Duration(days: d));
      final dateStr =
          '${futureDate.year}-'
          '${futureDate.month.toString().padLeft(2, '0')}-'
          '${futureDate.day.toString().padLeft(2, '0')}';

      int projectedTss;
      switch (scenario) {
        case ForecastScenario.linear:
          final rawTss =
              forecastStats.intercept +
              forecastStats.slope * (fourWeeks.length - 1 + d);
          projectedTss = rawTss.clamp(15, 230).round();
          break;
        case ForecastScenario.average:
          projectedTss = forecastStats.avgTss.clamp(15, 230);
          break;
        case ForecastScenario.taper:
          final factor = (0.65 - (d - 1) * 0.08).clamp(0.12, 1.0);
          projectedTss = (forecastStats.avgTss * factor).round();
          break;
        case ForecastScenario.overload:
          projectedTss = (forecastStats.avgTss * 1.25).round();
          break;
      }

      currentCtl = currentCtl + (projectedTss - currentCtl) / _ctlDecayDays;
      currentAtl = currentAtl + (projectedTss - currentAtl) / _atlDecayDays;
      final currentTsb = (currentCtl - currentAtl).round();

      points.add(
        DailyTrainingMetric(
          date: dateStr,
          tss: projectedTss,
          ctl: double.parse(currentCtl.toStringAsFixed(1)),
          atl: double.parse(currentAtl.toStringAsFixed(1)),
          tsb: currentTsb.toDouble(),
        ),
      );
    }

    return points;
  }

  double computeRampRate(List<DailyTrainingMetric> metrics) {
    if (metrics.length < 8) return 0;
    final latestCtl = metrics.last.ctl;
    final ctl7DaysAgo = metrics[metrics.length - 8].ctl;
    return double.parse((latestCtl - ctl7DaysAgo).toStringAsFixed(1));
  }
}

final pmcServiceProvider = Provider<PmcService>((ref) => PmcService());

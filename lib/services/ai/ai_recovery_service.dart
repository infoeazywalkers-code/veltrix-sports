import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecoveryInsight {
  final double recoveryScore; // 0-100
  final String statusLabel;
  final String statusColor;
  final String diagnosis;
  final String nextSessionGuidance;
  final double targetTss;

  const RecoveryInsight({
    required this.recoveryScore,
    required this.statusLabel,
    required this.statusColor,
    required this.diagnosis,
    required this.nextSessionGuidance,
    required this.targetTss,
  });
}

class AiRecoveryService {
  RecoveryInsight generateRecoveryInsight({
    required double currentCtl,
    required double currentAtl,
    required double currentTsb,
    required int recentAvgHrv,
    required double recentSleepHours,
    required int subjectiveSoreness, // 1-5
  }) {
    // Compute recovery score from physiological inputs
    double score = 50.0;

    // HRV contribution (0-20 points)
    if (recentAvgHrv > 60) {
      score += 15;
    } else if (recentAvgHrv > 45) {
      score += 10;
    } else if (recentAvgHrv < 30) {
      score -= 10;
    }

    // Sleep contribution (0-20 points)
    if (recentSleepHours >= 8) {
      score += 15;
    } else if (recentSleepHours >= 7) {
      score += 10;
    } else if (recentSleepHours < 6) {
      score -= 10;
    }

    // Soreness contribution (0-15 points)
    if (subjectiveSoreness <= 2) {
      score += 10;
    } else if (subjectiveSoreness >= 4) {
      score -= 10;
    }

    // TSB contribution (0-15 points)
    if (currentTsb > 10) {
      score += 10;
    } else if (currentTsb > 0) {
      score += 5;
    } else if (currentTsb < -25) {
      score -= 15;
    } else if (currentTsb < -10) {
      score -= 5;
    }

    score = score.clamp(0, 100);

    // Determine status
    String statusLabel;
    String statusColor;
    if (score >= 80) {
      statusLabel = 'Peak Recovery';
      statusColor = 'emerald';
    } else if (score >= 60) {
      statusLabel = 'Good Recovery';
      statusColor = 'sky';
    } else if (score >= 40) {
      statusLabel = 'Moderate Recovery';
      statusColor = 'amber';
    } else {
      statusLabel = 'Poor Recovery';
      statusColor = 'rose';
    }

    // Generate diagnosis
    final diagnosis = _generateDiagnosis(
      currentCtl,
      currentAtl,
      currentTsb,
      score,
    );

    // Next session guidance
    final targetTss = _computeTargetTss(currentCtl, currentAtl, score);
    final nextSessionGuidance = _generateGuidance(score, targetTss);

    return RecoveryInsight(
      recoveryScore: score,
      statusLabel: statusLabel,
      statusColor: statusColor,
      diagnosis: diagnosis,
      nextSessionGuidance: nextSessionGuidance,
      targetTss: targetTss,
    );
  }

  String _generateDiagnosis(double ctl, double atl, double tsb, double score) {
    if (tsb > 15 && score > 70) {
      return 'You are well-rested with high form. Consider a race-specific or VO2max session to capitalize on freshness.';
    }
    if (tsb < -20 && score < 40) {
      return 'High fatigue detected with elevated acute load. Prioritize rest or light recovery spin to avoid overtraining.';
    }
    if (atl > ctl * 1.2) {
      return 'Acute load is significantly above chronic baseline. This is productive if planned, but monitor for illness signals.';
    }
    if (ctl > atl && score > 60) {
      return 'Fitness exceeds fatigue — good maintenance phase. Maintain consistent training with 1-2 quality sessions this week.';
    }
    return 'Training load is balanced. Continue current program with attention to sleep quality and hydration.';
  }

  double _computeTargetTss(double ctl, double atl, double score) {
    final baseline = ctl * 0.85;
    if (score > 70) return baseline * 1.15;
    if (score > 50) return baseline;
    return baseline * 0.6;
  }

  String _generateGuidance(double score, double targetTss) {
    if (score > 80) {
      return 'Ready for high-intensity work. Target ${targetTss.round()} TSS with threshold or VO2max intervals.';
    }
    if (score > 60) {
      return 'Good readiness. Aim for ${targetTss.round()} TSS with tempo or sweet spot work.';
    }
    if (score > 40) {
      return 'Moderate readiness. Keep intensity low. Target ${targetTss.round()} TSS with endurance ride.';
    }
    return 'Rest recommended. If training, limit to ${targetTss.round()} TSS recovery spin only.';
  }
}

final aiRecoveryServiceProvider = Provider<AiRecoveryService>(
  (ref) => AiRecoveryService(),
);

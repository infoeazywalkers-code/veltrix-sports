import 'dart:math';
import '../../models/health/health_biometric.dart';

class HealthService {
  /// Generate 14 days of realistic physiological recovery metrics
  List<HealthBiometricDay> generateHealthBiometricsHistory() {
    final days = <HealthBiometricDay>[];
    final today = DateTime.now();
    const baselineHRV = 72;
    const baselineRHR = 42;
    final random = Random();

    for (int i = 13; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final isHardDay = i == 1 || i == 5 || i == 9;
      final isRecoveryDay = i == 0 || i == 4 || i == 8;

      int recoveryScore;
      if (isHardDay) {
        recoveryScore = 58 + random.nextInt(9);
      } else if (isRecoveryDay) {
        recoveryScore = 88 + random.nextInt(9);
      } else {
        recoveryScore = 74 + random.nextInt(13);
      }
      recoveryScore = recoveryScore.clamp(45, 99);

      final hrvRmssd =
          recoveryScore > 75
              ? baselineHRV + random.nextInt(13)
              : baselineHRV - (random.nextInt(15) + 4);
      final restingHr =
          recoveryScore > 75
              ? baselineRHR - random.nextInt(3)
              : baselineRHR + random.nextInt(6) + 1;
      final sleepHours = double.parse(
        (6.8 + (recoveryScore / 100) * 1.6 + (random.nextDouble() * 0.4 - 0.2))
            .toStringAsFixed(1),
      );
      final sleepQuality = (recoveryScore * 0.95 + random.nextInt(7)).clamp(
        0,
        98,
      );
      final deepSleepPct = 18 + random.nextInt(8);
      final remSleepPct = 21 + random.nextInt(7);
      final spo2Pct = double.parse(
        (98.2 + random.nextDouble() * 1.2).toStringAsFixed(1),
      );
      final respiratoryRate = double.parse(
        (13.4 + random.nextDouble() * 0.8).toStringAsFixed(1),
      );
      final skinTempDev = double.parse(
        ((recoveryScore < 65 ? 0.3 : -0.2) + (random.nextDouble() * 0.2 - 0.1))
            .toStringAsFixed(2),
      );
      final soreness =
          isHardDay
              ? 4
              : isRecoveryDay
              ? 1
              : 2;
      final stress =
          recoveryScore > 80
              ? 'low'
              : recoveryScore > 60
              ? 'moderate'
              : 'high';

      String recommendation;
      if (recoveryScore < 65) {
        recommendation =
            'Sympathetic dominance detected. Recommend easy Z1/Z2 recovery or active rest.';
      } else if (recoveryScore < 80) {
        recommendation =
            'Moderate recovery. Standard aerobic endurance and tempo maintenance advised.';
      } else {
        recommendation =
            'Optimal autonomic balance. Prime for high-intensity intervals or threshold testing.';
      }

      days.add(
        HealthBiometricDay(
          date: dateStr,
          recoveryScore: recoveryScore,
          hrvRmssd: hrvRmssd,
          hrvBaseline: baselineHRV,
          restingHr: restingHr,
          sleepHours: sleepHours,
          sleepQualityScore: sleepQuality.toInt(),
          deepSleepPct: deepSleepPct,
          remSleepPct: remSleepPct,
          spo2Pct: spo2Pct,
          respiratoryRate: respiratoryRate,
          skinTempDeviationCelsius: skinTempDev,
          subjectiveSoreness: soreness,
          subjectiveStress: stress,
          hydrationLitres: double.parse(
            (2.8 + random.nextDouble() * 0.8).toStringAsFixed(1),
          ),
          weightKg: double.parse(
            (69.2 + (random.nextDouble() * 0.6 - 0.3)).toStringAsFixed(1),
          ),
          readinessRecommendation: recommendation,
          syncedWearable:
              i == 0
                  ? 'Whoop 4.0'
                  : i % 2 == 0
                  ? 'Garmin Connect'
                  : 'Oura Ring Gen 3',
        ),
      );
    }

    return days;
  }

  List<WearableDeviceStatus> getWearableDevices() {
    return const [
      WearableDeviceStatus(
        id: 'wearable-garmin',
        name: 'Garmin Forerunner 965',
        brand: 'garmin',
        icon: 'Watch',
        batteryPct: 82,
        lastSyncTime: '12 mins ago',
        isConnected: true,
        statusMessage: 'Continuous optical HR & HRV nightly status active',
      ),
      WearableDeviceStatus(
        id: 'wearable-whoop',
        name: 'Whoop 4.0 Strap',
        brand: 'whoop',
        icon: 'Activity',
        batteryPct: 64,
        lastSyncTime: '4 mins ago',
        isConnected: true,
        statusMessage: 'Sleep stages & Recovery score synced',
      ),
      WearableDeviceStatus(
        id: 'wearable-oura',
        name: 'Oura Ring Gen 3 Horizon',
        brand: 'oura',
        icon: 'CircleDot',
        batteryPct: 48,
        lastSyncTime: '1 hour ago',
        isConnected: true,
        statusMessage:
            'Skin temperature deviation & resting respiration logged',
      ),
      WearableDeviceStatus(
        id: 'wearable-wahoo',
        name: 'Wahoo ELEMNT ROAM v2',
        brand: 'wahoo',
        icon: 'Cpu',
        batteryPct: 90,
        lastSyncTime: 'Yesterday, 18:45',
        isConnected: true,
        statusMessage: 'ANT+ dual-sided power & cadence synced',
      ),
    ];
  }
}

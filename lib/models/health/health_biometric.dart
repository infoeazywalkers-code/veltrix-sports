class HealthBiometricDay {
  final String date;
  final int recoveryScore;
  final int hrvRmssd;
  final int hrvBaseline;
  final int restingHr;
  final double sleepHours;
  final int sleepQualityScore;
  final int deepSleepPct;
  final int remSleepPct;
  final double spo2Pct;
  final double respiratoryRate;
  final double skinTempDeviationCelsius;
  final int subjectiveSoreness;
  final String subjectiveStress;
  final double hydrationLitres;
  final double weightKg;
  final String readinessRecommendation;
  final String? syncedWearable;

  const HealthBiometricDay({
    required this.date,
    required this.recoveryScore,
    required this.hrvRmssd,
    required this.hrvBaseline,
    required this.restingHr,
    required this.sleepHours,
    required this.sleepQualityScore,
    required this.deepSleepPct,
    required this.remSleepPct,
    required this.spo2Pct,
    required this.respiratoryRate,
    required this.skinTempDeviationCelsius,
    required this.subjectiveSoreness,
    required this.subjectiveStress,
    required this.hydrationLitres,
    required this.weightKg,
    required this.readinessRecommendation,
    this.syncedWearable,
  });

  factory HealthBiometricDay.fromMap(Map<String, dynamic> m) =>
      HealthBiometricDay(
        date: m['date'] ?? '',
        recoveryScore: m['recoveryScore'] ?? 0,
        hrvRmssd: m['hrvRmssd'] ?? 0,
        hrvBaseline: m['hrvBaseline'] ?? 0,
        restingHr: m['restingHr'] ?? 0,
        sleepHours: (m['sleepHours'] ?? 0).toDouble(),
        sleepQualityScore: m['sleepQualityScore'] ?? 0,
        deepSleepPct: m['deepSleepPct'] ?? 0,
        remSleepPct: m['remSleepPct'] ?? 0,
        spo2Pct: (m['spo2Pct'] ?? 0).toDouble(),
        respiratoryRate: (m['respiratoryRate'] ?? 0).toDouble(),
        skinTempDeviationCelsius:
            (m['skinTempDeviationCelsius'] ?? 0).toDouble(),
        subjectiveSoreness: m['subjectiveSoreness'] ?? 1,
        subjectiveStress: m['subjectiveStress'] ?? 'low',
        hydrationLitres: (m['hydrationLitres'] ?? 0).toDouble(),
        weightKg: (m['weightKg'] ?? 0).toDouble(),
        readinessRecommendation: m['readinessRecommendation'] ?? '',
        syncedWearable: m['syncedWearable'],
      );

  Map<String, dynamic> toMap() => {
    'date': date,
    'recoveryScore': recoveryScore,
    'hrvRmssd': hrvRmssd,
    'hrvBaseline': hrvBaseline,
    'restingHr': restingHr,
    'sleepHours': sleepHours,
    'sleepQualityScore': sleepQualityScore,
    'deepSleepPct': deepSleepPct,
    'remSleepPct': remSleepPct,
    'spo2Pct': spo2Pct,
    'respiratoryRate': respiratoryRate,
    'skinTempDeviationCelsius': skinTempDeviationCelsius,
    'subjectiveSoreness': subjectiveSoreness,
    'subjectiveStress': subjectiveStress,
    'hydrationLitres': hydrationLitres,
    'weightKg': weightKg,
    'readinessRecommendation': readinessRecommendation,
    if (syncedWearable != null) 'syncedWearable': syncedWearable,
  };

  String get recoveryLabel {
    if (recoveryScore >= 85) return 'Excellent';
    if (recoveryScore >= 70) return 'Good';
    if (recoveryScore >= 55) return 'Moderate';
    return 'Poor';
  }
}

class WearableDeviceStatus {
  final String id;
  final String name;
  final String brand;
  final String icon;
  final int batteryPct;
  final String lastSyncTime;
  final bool isConnected;
  final String statusMessage;

  const WearableDeviceStatus({
    required this.id,
    required this.name,
    required this.brand,
    required this.icon,
    required this.batteryPct,
    required this.lastSyncTime,
    required this.isConnected,
    required this.statusMessage,
  });

  factory WearableDeviceStatus.fromMap(Map<String, dynamic> m) =>
      WearableDeviceStatus(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        brand: m['brand'] ?? '',
        icon: m['icon'] ?? '',
        batteryPct: m['batteryPct'] ?? 0,
        lastSyncTime: m['lastSyncTime'] ?? '',
        isConnected: m['isConnected'] ?? false,
        statusMessage: m['statusMessage'] ?? '',
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'brand': brand,
    'icon': icon,
    'batteryPct': batteryPct,
    'lastSyncTime': lastSyncTime,
    'isConnected': isConnected,
    'statusMessage': statusMessage,
  };
}

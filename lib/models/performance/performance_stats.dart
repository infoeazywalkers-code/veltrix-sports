class PowerDurationPR {
  final String durationLabel;
  final int seconds;
  final int watts;
  final double wattsPerKg;
  final String dateAchieved;
  final String activityTitle;
  final bool isAllTimeBest;

  const PowerDurationPR({
    required this.durationLabel,
    required this.seconds,
    required this.watts,
    required this.wattsPerKg,
    required this.dateAchieved,
    required this.activityTitle,
    required this.isAllTimeBest,
  });

  factory PowerDurationPR.fromMap(Map<String, dynamic> m) => PowerDurationPR(
    durationLabel: m['durationLabel'] ?? '',
    seconds: m['seconds'] ?? 0,
    watts: m['watts'] ?? 0,
    wattsPerKg: (m['wattsPerKg'] ?? 0).toDouble(),
    dateAchieved: m['dateAchieved'] ?? '',
    activityTitle: m['activityTitle'] ?? '',
    isAllTimeBest: m['isAllTimeBest'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'durationLabel': durationLabel,
    'seconds': seconds,
    'watts': watts,
    'wattsPerKg': wattsPerKg,
    'dateAchieved': dateAchieved,
    'activityTitle': activityTitle,
    'isAllTimeBest': isAllTimeBest,
  };
}

class PaceDurationPR {
  final String distanceLabel;
  final double distanceKm;
  final int paceSecondsPerKm;
  final String formattedPace;
  final String totalTime;
  final String dateAchieved;
  final String activityTitle;
  final bool isAllTimeBest;

  const PaceDurationPR({
    required this.distanceLabel,
    required this.distanceKm,
    required this.paceSecondsPerKm,
    required this.formattedPace,
    required this.totalTime,
    required this.dateAchieved,
    required this.activityTitle,
    required this.isAllTimeBest,
  });

  factory PaceDurationPR.fromMap(Map<String, dynamic> m) => PaceDurationPR(
    distanceLabel: m['distanceLabel'] ?? '',
    distanceKm: (m['distanceKm'] ?? 0).toDouble(),
    paceSecondsPerKm: m['paceSecondsPerKm'] ?? 0,
    formattedPace: m['formattedPace'] ?? '',
    totalTime: m['totalTime'] ?? '',
    dateAchieved: m['dateAchieved'] ?? '',
    activityTitle: m['activityTitle'] ?? '',
    isAllTimeBest: m['isAllTimeBest'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'distanceLabel': distanceLabel,
    'distanceKm': distanceKm,
    'paceSecondsPerKm': paceSecondsPerKm,
    'formattedPace': formattedPace,
    'totalTime': totalTime,
    'dateAchieved': dateAchieved,
    'activityTitle': activityTitle,
    'isAllTimeBest': isAllTimeBest,
  };
}

class ZoneDistribution {
  final String zone;
  final double hours;
  final double percentage;
  final String color;

  const ZoneDistribution({
    required this.zone,
    required this.hours,
    required this.percentage,
    required this.color,
  });

  factory ZoneDistribution.fromMap(Map<String, dynamic> m) => ZoneDistribution(
    zone: m['zone'] ?? '',
    hours: (m['hours'] ?? 0).toDouble(),
    percentage: (m['percentage'] ?? 0).toDouble(),
    color: m['color'] ?? '#64748b',
  );

  Map<String, dynamic> toMap() => {
    'zone': zone,
    'hours': hours,
    'percentage': percentage,
    'color': color,
  };
}

class PerformanceStatsData {
  final double ftpWatts;
  final double wattsPerKg;
  final int lthrBpm;
  final int maxHrBpm;
  final double vo2MaxEstimate;
  final double aerobicDecouplingPct;
  final double efficiencyFactor;
  final int wPrimeJoules;
  final int criticalPowerWatts;
  final List<PowerDurationPR> powerPRs;
  final List<PaceDurationPR> pacePRs;
  final Map<String, dynamic> last30Days;
  final List<ZoneDistribution> zoneDistribution;

  const PerformanceStatsData({
    required this.ftpWatts,
    required this.wattsPerKg,
    required this.lthrBpm,
    required this.maxHrBpm,
    required this.vo2MaxEstimate,
    required this.aerobicDecouplingPct,
    required this.efficiencyFactor,
    required this.wPrimeJoules,
    required this.criticalPowerWatts,
    this.powerPRs = const [],
    this.pacePRs = const [],
    this.last30Days = const {},
    this.zoneDistribution = const [],
  });

  factory PerformanceStatsData.fromMap(Map<String, dynamic> m) =>
      PerformanceStatsData(
        ftpWatts: (m['ftpWatts'] ?? 0).toDouble(),
        wattsPerKg: (m['wattsPerKg'] ?? 0).toDouble(),
        lthrBpm: m['lthrBpm'] ?? 0,
        maxHrBpm: m['maxHrBpm'] ?? 0,
        vo2MaxEstimate: (m['vo2MaxEstimate'] ?? 0).toDouble(),
        aerobicDecouplingPct: (m['aerobicDecouplingPct'] ?? 0).toDouble(),
        efficiencyFactor: (m['efficiencyFactor'] ?? 0).toDouble(),
        wPrimeJoules: m['wPrimeJoules'] ?? 0,
        criticalPowerWatts: m['criticalPowerWatts'] ?? 0,
        powerPRs:
            (m['powerPRs'] as List?)
                ?.map((e) => PowerDurationPR.fromMap(e))
                .toList() ??
            [],
        pacePRs:
            (m['pacePRs'] as List?)
                ?.map((e) => PaceDurationPR.fromMap(e))
                .toList() ??
            [],
        last30Days: m['last30Days'] ?? {},
        zoneDistribution:
            (m['zoneDistribution'] as List?)
                ?.map((e) => ZoneDistribution.fromMap(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toMap() => {
    'ftpWatts': ftpWatts,
    'wattsPerKg': wattsPerKg,
    'lthrBpm': lthrBpm,
    'maxHrBpm': maxHrBpm,
    'vo2MaxEstimate': vo2MaxEstimate,
    'aerobicDecouplingPct': aerobicDecouplingPct,
    'efficiencyFactor': efficiencyFactor,
    'wPrimeJoules': wPrimeJoules,
    'criticalPowerWatts': criticalPowerWatts,
    'powerPRs': powerPRs.map((e) => e.toMap()).toList(),
    'pacePRs': pacePRs.map((e) => e.toMap()).toList(),
    'last30Days': last30Days,
    'zoneDistribution': zoneDistribution.map((e) => e.toMap()).toList(),
  };
}

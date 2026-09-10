class MonthlyReportData {
  final String month; // e.g. "September 2026"
  final AthleteSummary athlete;
  final PmcSummary pmc;
  final MonthlyVolume volume;
  final List<PowerPacePr> powerPRs;
  final List<PowerPacePr> pacePRs;
  final List<BreakthroughActivity> breakthroughs;
  final String coachingPrescription;

  const MonthlyReportData({
    required this.month,
    required this.athlete,
    required this.pmc,
    required this.volume,
    this.powerPRs = const [],
    this.pacePRs = const [],
    this.breakthroughs = const [],
    required this.coachingPrescription,
  });
}

class AthleteSummary {
  final String name;
  final String handle;
  final double weightKg;
  final int ftpWatts;
  final double vo2Max;
  final int lthr;
  final double weeklyGoalKm;

  const AthleteSummary({
    required this.name,
    required this.handle,
    required this.weightKg,
    required this.ftpWatts,
    required this.vo2Max,
    required this.lthr,
    required this.weeklyGoalKm,
  });
}

class PmcSummary {
  final double currentCtl;
  final double currentAtl;
  final double currentTsb;
  final String formState;
  final String formStateDescription;
  final double? projectedCtl;
  final double? projectedAtl;
  final double? projectedTsb;

  const PmcSummary({
    required this.currentCtl,
    required this.currentAtl,
    required this.currentTsb,
    required this.formState,
    required this.formStateDescription,
    this.projectedCtl,
    this.projectedAtl,
    this.projectedTsb,
  });
}

class MonthlyVolume {
  final double totalDistanceKm;
  final int totalElevationMeters;
  final double totalActiveHours;
  final int totalTSS;
  final int totalActivities;
  final double cyclingKm;
  final double runningKm;
  final double avgIntensityFactor;

  const MonthlyVolume({
    required this.totalDistanceKm,
    required this.totalElevationMeters,
    required this.totalActiveHours,
    required this.totalTSS,
    required this.totalActivities,
    required this.cyclingKm,
    required this.runningKm,
    required this.avgIntensityFactor,
  });
}

class PowerPacePr {
  final String label;
  final String value;
  final String dateAchieved;
  final String activityTitle;

  const PowerPacePr({
    required this.label,
    required this.value,
    required this.dateAchieved,
    required this.activityTitle,
  });
}

class BreakthroughActivity {
  final String title;
  final String date;
  final String sport;
  final double distanceKm;
  final String duration;
  final int tss;
  final String? prAchieved;

  const BreakthroughActivity({
    required this.title,
    required this.date,
    required this.sport,
    required this.distanceKm,
    required this.duration,
    required this.tss,
    this.prAchieved,
  });
}

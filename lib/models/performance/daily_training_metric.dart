class DailyTrainingMetric {
  final String date; // YYYY-MM-DD
  final int tss;
  final double ctl; // Chronic Training Load (Fitness)
  final double atl; // Acute Training Load (Fatigue)
  final double tsb; // Training Stress Balance (Form = CTL - ATL)
  final String? workoutTitle;
  final String? workoutSport;
  final double? workoutDistanceKm;

  const DailyTrainingMetric({
    required this.date,
    required this.tss,
    required this.ctl,
    required this.atl,
    required this.tsb,
    this.workoutTitle,
    this.workoutSport,
    this.workoutDistanceKm,
  });

  factory DailyTrainingMetric.fromMap(Map<String, dynamic> m) =>
      DailyTrainingMetric(
        date: m['date'] ?? '',
        tss: m['tss'] ?? 0,
        ctl: (m['ctl'] ?? 0).toDouble(),
        atl: (m['atl'] ?? 0).toDouble(),
        tsb: (m['tsb'] ?? 0).toDouble(),
        workoutTitle: m['workoutTitle'],
        workoutSport: m['workoutSport'],
        workoutDistanceKm: m['workoutDistanceKm']?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
    'date': date,
    'tss': tss,
    'ctl': ctl,
    'atl': atl,
    'tsb': tsb,
    'workoutTitle': workoutTitle,
    'workoutSport': workoutSport,
    'workoutDistanceKm': workoutDistanceKm,
  };
}

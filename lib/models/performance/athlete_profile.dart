class AthleteProfile {
  final String name;
  final String handle;
  final String avatar;
  final String location;
  final String bio;
  final String? email;
  final double weightKg;
  final double heightCm;
  final int ftpWatts;
  final int thresholdPaceSecondsPerKm;
  final int maxHeartRate;
  final int restingHeartRate;
  final int lthr;
  final double vo2Max;
  final double weeklyGoalKm;
  final int totalActivitiesCount;
  final double totalDistanceKm;
  final int totalElevationGainMeters;
  final bool isPro;
  final String? proTier;
  final String? proRenewalDate;

  const AthleteProfile({
    required this.name,
    required this.handle,
    required this.avatar,
    required this.location,
    required this.bio,
    this.email,
    required this.weightKg,
    required this.heightCm,
    required this.ftpWatts,
    required this.thresholdPaceSecondsPerKm,
    required this.maxHeartRate,
    required this.restingHeartRate,
    required this.lthr,
    required this.vo2Max,
    required this.weeklyGoalKm,
    required this.totalActivitiesCount,
    required this.totalDistanceKm,
    required this.totalElevationGainMeters,
    this.isPro = false,
    this.proTier,
    this.proRenewalDate,
  });

  factory AthleteProfile.fromMap(Map<String, dynamic> m) => AthleteProfile(
    name: m['name'] ?? '',
    handle: m['handle'] ?? '',
    avatar: m['avatar'] ?? '',
    location: m['location'] ?? '',
    bio: m['bio'] ?? '',
    email: m['email'],
    weightKg: (m['weightKg'] ?? 0).toDouble(),
    heightCm: (m['heightCm'] ?? 0).toDouble(),
    ftpWatts: m['ftpWatts'] ?? 0,
    thresholdPaceSecondsPerKm: m['thresholdPaceSecondsPerKm'] ?? 0,
    maxHeartRate: m['maxHeartRate'] ?? 0,
    restingHeartRate: m['restingHeartRate'] ?? 0,
    lthr: m['lthr'] ?? 0,
    vo2Max: (m['vo2Max'] ?? 0).toDouble(),
    weeklyGoalKm: (m['weeklyGoalKm'] ?? 0).toDouble(),
    totalActivitiesCount: m['totalActivitiesCount'] ?? 0,
    totalDistanceKm: (m['totalDistanceKm'] ?? 0).toDouble(),
    totalElevationGainMeters: m['totalElevationGainMeters'] ?? 0,
    isPro: m['isPro'] ?? false,
    proTier: m['proTier'],
    proRenewalDate: m['proRenewalDate'],
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'handle': handle,
    'avatar': avatar,
    'location': location,
    'bio': bio,
    'email': email,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'ftpWatts': ftpWatts,
    'thresholdPaceSecondsPerKm': thresholdPaceSecondsPerKm,
    'maxHeartRate': maxHeartRate,
    'restingHeartRate': restingHeartRate,
    'lthr': lthr,
    'vo2Max': vo2Max,
    'weeklyGoalKm': weeklyGoalKm,
    'totalActivitiesCount': totalActivitiesCount,
    'totalDistanceKm': totalDistanceKm,
    'totalElevationGainMeters': totalElevationGainMeters,
    'isPro': isPro,
    'proTier': proTier,
    'proRenewalDate': proRenewalDate,
  };
}

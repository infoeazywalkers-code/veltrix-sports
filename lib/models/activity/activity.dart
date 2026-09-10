import 'package:cloud_firestore/cloud_firestore.dart';

enum SportType { cycling, running, trailRunning, gravel, rowing, swimming }

class GPSPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final int? heartRate;
  final int? cadence;
  final int? power;
  final int timestamp;

  const GPSPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heartRate,
    this.cadence,
    this.power,
    required this.timestamp,
  });

  factory GPSPoint.fromMap(Map<String, dynamic> m) => GPSPoint(
    latitude: (m['latitude'] ?? 0).toDouble(),
    longitude: (m['longitude'] ?? 0).toDouble(),
    altitude: m['altitude']?.toDouble(),
    speed: m['speed']?.toDouble(),
    heartRate: m['heartRate'],
    cadence: m['cadence'],
    power: m['power'],
    timestamp: m['timestamp'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    if (altitude != null) 'altitude': altitude,
    if (speed != null) 'speed': speed,
    if (heartRate != null) 'heartRate': heartRate,
    if (cadence != null) 'cadence': cadence,
    if (power != null) 'power': power,
    'timestamp': timestamp,
  };
}

class LapSplit {
  final int lapNumber;
  final double distanceKm;
  final int durationSeconds;
  final int avgPaceSecondsPerKm;
  final double avgSpeedKmh;
  final double elevationGainMeters;
  final int? avgHeartRate;
  final int? avgPower;

  const LapSplit({
    required this.lapNumber,
    required this.distanceKm,
    required this.durationSeconds,
    required this.avgPaceSecondsPerKm,
    required this.avgSpeedKmh,
    required this.elevationGainMeters,
    this.avgHeartRate,
    this.avgPower,
  });

  factory LapSplit.fromMap(Map<String, dynamic> m) => LapSplit(
    lapNumber: m['lapNumber'] ?? 0,
    distanceKm: (m['distanceKm'] ?? 0).toDouble(),
    durationSeconds: m['durationSeconds'] ?? 0,
    avgPaceSecondsPerKm: m['avgPaceSecondsPerKm'] ?? 0,
    avgSpeedKmh: (m['avgSpeedKmh'] ?? 0).toDouble(),
    elevationGainMeters: (m['elevationGainMeters'] ?? 0).toDouble(),
    avgHeartRate: m['avgHeartRate'],
    avgPower: m['avgPower'],
  );

  Map<String, dynamic> toMap() => {
    'lapNumber': lapNumber,
    'distanceKm': distanceKm,
    'durationSeconds': durationSeconds,
    'avgPaceSecondsPerKm': avgPaceSecondsPerKm,
    'avgSpeedKmh': avgSpeedKmh,
    'elevationGainMeters': elevationGainMeters,
    if (avgHeartRate != null) 'avgHeartRate': avgHeartRate,
    if (avgPower != null) 'avgPower': avgPower,
  };
}

class ActivityWeather {
  final double tempC;
  final String condition;
  final double windKmh;
  final int humidityPct;

  const ActivityWeather({
    required this.tempC,
    required this.condition,
    required this.windKmh,
    required this.humidityPct,
  });

  factory ActivityWeather.fromMap(Map<String, dynamic> m) => ActivityWeather(
    tempC: (m['tempC'] ?? 0).toDouble(),
    condition: m['condition'] ?? '',
    windKmh: (m['windKmh'] ?? 0).toDouble(),
    humidityPct: m['humidityPct'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'tempC': tempC,
    'condition': condition,
    'windKmh': windKmh,
    'humidityPct': humidityPct,
  };
}

class Activity {
  final String id;
  final String title;
  final SportType sport;
  final DateTime date;
  final double distanceKm;
  final int durationSeconds;
  final int movingTimeSeconds;
  final double elevationGainMeters;
  final double avgSpeedKmh;
  final double maxSpeedKmh;
  final int avgPaceSecondsPerKm;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final int? avgCadence;
  final int? avgPower;
  final int? normalizedPower;
  final int tss;
  final double? intensityFactor;
  final int calories;
  final int perceivedExertion;
  final String? description;
  final String? gearId;
  final String? gearName;
  final List<GPSPoint> gpsTrack;
  final List<LapSplit> laps;
  final int kudosCount;
  final bool userHasKudoed;
  final int commentsCount;
  final String athleteName;
  final String athleteAvatar;
  final String? athleteLocation;
  final double? trainingEffectAerobic;
  final double? trainingEffectAnaerobic;
  final List<String> prBadges;
  final ActivityWeather? weather;

  const Activity({
    required this.id,
    required this.title,
    required this.sport,
    required this.date,
    required this.distanceKm,
    required this.durationSeconds,
    required this.movingTimeSeconds,
    required this.elevationGainMeters,
    required this.avgSpeedKmh,
    required this.maxSpeedKmh,
    required this.avgPaceSecondsPerKm,
    this.avgHeartRate,
    this.maxHeartRate,
    this.avgCadence,
    this.avgPower,
    this.normalizedPower,
    required this.tss,
    this.intensityFactor,
    required this.calories,
    required this.perceivedExertion,
    this.description,
    this.gearId,
    this.gearName,
    this.gpsTrack = const [],
    this.laps = const [],
    this.kudosCount = 0,
    this.userHasKudoed = false,
    this.commentsCount = 0,
    required this.athleteName,
    required this.athleteAvatar,
    this.athleteLocation,
    this.trainingEffectAerobic,
    this.trainingEffectAnaerobic,
    this.prBadges = const [],
    this.weather,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      title: m['title'] ?? '',
      sport: SportType.values.firstWhere(
        (e) => e.name == m['sport'],
        orElse: () => SportType.cycling,
      ),
      date:
          m['date'] is Timestamp
              ? (m['date'] as Timestamp).toDate()
              : DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
      distanceKm: (m['distanceKm'] ?? 0).toDouble(),
      durationSeconds: m['durationSeconds'] ?? 0,
      movingTimeSeconds: m['movingTimeSeconds'] ?? 0,
      elevationGainMeters: (m['elevationGainMeters'] ?? 0).toDouble(),
      avgSpeedKmh: (m['avgSpeedKmh'] ?? 0).toDouble(),
      maxSpeedKmh: (m['maxSpeedKmh'] ?? 0).toDouble(),
      avgPaceSecondsPerKm: m['avgPaceSecondsPerKm'] ?? 0,
      avgHeartRate: m['avgHeartRate'],
      maxHeartRate: m['maxHeartRate'],
      avgCadence: m['avgCadence'],
      avgPower: m['avgPower'],
      normalizedPower: m['normalizedPower'],
      tss: m['tss'] ?? 0,
      intensityFactor: m['intensityFactor']?.toDouble(),
      calories: m['calories'] ?? 0,
      perceivedExertion: m['perceivedExertion'] ?? 5,
      description: m['description'],
      gearId: m['gearId'],
      gearName: m['gearName'],
      gpsTrack:
          (m['gpsTrack'] as List?)
              ?.map((e) => GPSPoint.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      laps:
          (m['laps'] as List?)
              ?.map((e) => LapSplit.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      kudosCount: m['kudosCount'] ?? 0,
      userHasKudoed: m['userHasKudoed'] ?? false,
      commentsCount: m['commentsCount'] ?? 0,
      athleteName: m['athleteName'] ?? '',
      athleteAvatar: m['athleteAvatar'] ?? '',
      athleteLocation: m['athleteLocation'],
      trainingEffectAerobic: m['trainingEffectAerobic']?.toDouble(),
      trainingEffectAnaerobic: m['trainingEffectAnaerobic']?.toDouble(),
      prBadges: List<String>.from(m['prBadges'] ?? []),
      weather:
          m['weather'] != null
              ? ActivityWeather.fromMap(m['weather'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'sport': sport.name,
    'date': Timestamp.fromDate(date),
    'distanceKm': distanceKm,
    'durationSeconds': durationSeconds,
    'movingTimeSeconds': movingTimeSeconds,
    'elevationGainMeters': elevationGainMeters,
    'avgSpeedKmh': avgSpeedKmh,
    'maxSpeedKmh': maxSpeedKmh,
    'avgPaceSecondsPerKm': avgPaceSecondsPerKm,
    if (avgHeartRate != null) 'avgHeartRate': avgHeartRate,
    if (maxHeartRate != null) 'maxHeartRate': maxHeartRate,
    if (avgCadence != null) 'avgCadence': avgCadence,
    if (avgPower != null) 'avgPower': avgPower,
    if (normalizedPower != null) 'normalizedPower': normalizedPower,
    'tss': tss,
    if (intensityFactor != null) 'intensityFactor': intensityFactor,
    'calories': calories,
    'perceivedExertion': perceivedExertion,
    if (description != null) 'description': description,
    if (gearId != null) 'gearId': gearId,
    if (gearName != null) 'gearName': gearName,
    'gpsTrack': gpsTrack.map((e) => e.toMap()).toList(),
    'laps': laps.map((e) => e.toMap()).toList(),
    'kudosCount': kudosCount,
    'userHasKudoed': userHasKudoed,
    'commentsCount': commentsCount,
    'athleteName': athleteName,
    'athleteAvatar': athleteAvatar,
    if (athleteLocation != null) 'athleteLocation': athleteLocation,
    if (trainingEffectAerobic != null)
      'trainingEffectAerobic': trainingEffectAerobic,
    if (trainingEffectAnaerobic != null)
      'trainingEffectAnaerobic': trainingEffectAnaerobic,
    'prBadges': prBadges,
    if (weather != null) 'weather': weather!.toMap(),
  };

  Activity copyWith({
    String? title,
    SportType? sport,
    DateTime? date,
    double? distanceKm,
    int? durationSeconds,
    int? movingTimeSeconds,
    double? elevationGainMeters,
    double? avgSpeedKmh,
    double? maxSpeedKmh,
    int? avgPaceSecondsPerKm,
    int? avgHeartRate,
    int? maxHeartRate,
    int? avgCadence,
    int? avgPower,
    int? normalizedPower,
    int? tss,
    double? intensityFactor,
    int? calories,
    int? perceivedExertion,
    String? description,
    String? gearId,
    String? gearName,
    List<GPSPoint>? gpsTrack,
    List<LapSplit>? laps,
    int? kudosCount,
    bool? userHasKudoed,
    int? commentsCount,
    List<String>? prBadges,
    ActivityWeather? weather,
  }) => Activity(
    id: id,
    title: title ?? this.title,
    sport: sport ?? this.sport,
    date: date ?? this.date,
    distanceKm: distanceKm ?? this.distanceKm,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    movingTimeSeconds: movingTimeSeconds ?? this.movingTimeSeconds,
    elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
    avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
    maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
    avgPaceSecondsPerKm: avgPaceSecondsPerKm ?? this.avgPaceSecondsPerKm,
    avgHeartRate: avgHeartRate ?? this.avgHeartRate,
    maxHeartRate: maxHeartRate ?? this.maxHeartRate,
    avgCadence: avgCadence ?? this.avgCadence,
    avgPower: avgPower ?? this.avgPower,
    normalizedPower: normalizedPower ?? this.normalizedPower,
    tss: tss ?? this.tss,
    intensityFactor: intensityFactor ?? this.intensityFactor,
    calories: calories ?? this.calories,
    perceivedExertion: perceivedExertion ?? this.perceivedExertion,
    description: description ?? this.description,
    gearId: gearId ?? this.gearId,
    gearName: gearName ?? this.gearName,
    gpsTrack: gpsTrack ?? this.gpsTrack,
    laps: laps ?? this.laps,
    kudosCount: kudosCount ?? this.kudosCount,
    userHasKudoed: userHasKudoed ?? this.userHasKudoed,
    commentsCount: commentsCount ?? this.commentsCount,
    athleteName: athleteName,
    athleteAvatar: athleteAvatar,
    athleteLocation: athleteLocation,
    trainingEffectAerobic: trainingEffectAerobic,
    trainingEffectAnaerobic: trainingEffectAnaerobic,
    prBadges: prBadges ?? this.prBadges,
    weather: weather ?? this.weather,
  );
}

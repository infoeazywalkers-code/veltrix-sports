class LiveWeatherData {
  final double temperatureC;
  final double apparentTemperatureC;
  final int humidityPct;
  final double windSpeedKmh;
  final int windDirectionDegrees;
  final String windDirectionCardinal;
  final double? windGustKmh;
  final String condition;
  final int weatherCode;
  final double? precipitationMm;
  final double? uvIndex;
  final double latitude;
  final double longitude;
  final String? locality;
  final RelativeWindImpact? relativeWindImpact;

  const LiveWeatherData({
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.humidityPct,
    required this.windSpeedKmh,
    required this.windDirectionDegrees,
    required this.windDirectionCardinal,
    this.windGustKmh,
    required this.condition,
    required this.weatherCode,
    this.precipitationMm,
    this.uvIndex,
    required this.latitude,
    required this.longitude,
    this.locality,
    this.relativeWindImpact,
  });

  factory LiveWeatherData.fromMap(Map<String, dynamic> m) => LiveWeatherData(
    temperatureC: (m['temperatureC'] ?? 0).toDouble(),
    apparentTemperatureC: (m['apparentTemperatureC'] ?? 0).toDouble(),
    humidityPct: m['humidityPct'] ?? 0,
    windSpeedKmh: (m['windSpeedKmh'] ?? 0).toDouble(),
    windDirectionDegrees: m['windDirectionDegrees'] ?? 0,
    windDirectionCardinal: m['windDirectionCardinal'] ?? 'N',
    windGustKmh: m['windGustKmh']?.toDouble(),
    condition: m['condition'] ?? '',
    weatherCode: m['weatherCode'] ?? 0,
    precipitationMm: m['precipitationMm']?.toDouble(),
    uvIndex: m['uvIndex']?.toDouble(),
    latitude: (m['latitude'] ?? 0).toDouble(),
    longitude: (m['longitude'] ?? 0).toDouble(),
    locality: m['locality'],
    relativeWindImpact: m['relativeWindImpact'] != null
        ? RelativeWindImpact.fromMap(m['relativeWindImpact'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'temperatureC': temperatureC,
    'apparentTemperatureC': apparentTemperatureC,
    'humidityPct': humidityPct,
    'windSpeedKmh': windSpeedKmh,
    'windDirectionDegrees': windDirectionDegrees,
    'windDirectionCardinal': windDirectionCardinal,
    'windGustKmh': windGustKmh,
    'condition': condition,
    'weatherCode': weatherCode,
    'precipitationMm': precipitationMm,
    'uvIndex': uvIndex,
    'latitude': latitude,
    'longitude': longitude,
    'locality': locality,
    'relativeWindImpact': relativeWindImpact?.toMap(),
  };
}

class RelativeWindImpact {
  final double headwindComponentKmh;
  final double crosswindComponentKmh;
  final String impactType; // 'headwind', 'tailwind', 'crosswind', 'calm'
  final String description;

  const RelativeWindImpact({
    required this.headwindComponentKmh,
    required this.crosswindComponentKmh,
    required this.impactType,
    required this.description,
  });

  factory RelativeWindImpact.fromMap(Map<String, dynamic> m) =>
      RelativeWindImpact(
        headwindComponentKmh: (m['headwindComponentKmh'] ?? 0).toDouble(),
        crosswindComponentKmh: (m['crosswindComponentKmh'] ?? 0).toDouble(),
        impactType: m['impactType'] ?? 'calm',
        description: m['description'] ?? '',
      );

  Map<String, dynamic> toMap() => {
    'headwindComponentKmh': headwindComponentKmh,
    'crosswindComponentKmh': crosswindComponentKmh,
    'impactType': impactType,
    'description': description,
  };
}

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/weather/live_weather_data.dart';

class GeoService {
  double calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  int calculateNormalizedPower(List<int> powerReadings) {
    if (powerReadings.isEmpty) return 0;
    if (powerReadings.length < 30) {
      return (powerReadings.reduce((a, b) => a + b) / powerReadings.length)
          .round();
    }

    const windowSize = 30;
    final rolling30s = <double>[];
    double currentSum = 0;

    for (int i = 0; i < powerReadings.length; i++) {
      currentSum += powerReadings[i];
      if (i >= windowSize) {
        currentSum -= powerReadings[i - windowSize];
        rolling30s.add(currentSum / windowSize);
      } else if (i == windowSize - 1) {
        rolling30s.add(currentSum / windowSize);
      }
    }

    if (rolling30s.isEmpty) return 0;
    final sum4th = rolling30s.fold<double>(
      0,
      (acc, val) => acc + pow(val, 4).toDouble(),
    );
    final avg4th = sum4th / rolling30s.length;
    return pow(avg4th, 0.25).round();
  }

  int calculateTSS(int durationSeconds, int normalizedPower, int ftp) {
    if (ftp <= 0 || normalizedPower <= 0 || durationSeconds <= 0) return 0;
    final intensityFactor = normalizedPower / ftp;
    final tss =
        ((durationSeconds * normalizedPower * intensityFactor) / (ftp * 3600)) *
        100;
    return tss.round();
  }

  RelativeWindImpact calculateRelativeWind({
    required double windDirectionDegrees,
    required double windSpeedKmh,
    required double headingDegrees,
  }) {
    final relativeAngle = _toRadians(windDirectionDegrees - headingDegrees);
    final headwindComponent = windSpeedKmh * cos(relativeAngle);
    final crosswindComponent = windSpeedKmh * sin(relativeAngle);

    String impactType;
    String description;

    if (headwindComponent > 10) {
      impactType = 'headwind';
      description =
          'Strong headwind (+${headwindComponent.round()} km/h). '
          'Expect pace/power loss.';
    } else if (headwindComponent < -10) {
      impactType = 'tailwind';
      description =
          'Helpful tailwind (${headwindComponent.round()} km/h). '
          'Slight speed advantage.';
    } else if (crosswindComponent.abs() > 8) {
      impactType = 'crosswind';
      description =
          'Significant crosswind. Maintain steady effort, watch for gusts.';
    } else {
      impactType = 'calm';
      description = 'Minimal wind impact. Conditions favorable.';
    }

    return RelativeWindImpact(
      headwindComponentKmh: double.parse(headwindComponent.toStringAsFixed(1)),
      crosswindComponentKmh: double.parse(
        crosswindComponent.toStringAsFixed(1),
      ),
      impactType: impactType,
      description: description,
    );
  }

  String formatDuration(int seconds, {bool forceHours = false}) {
    if (seconds < 0) return '00:00';
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hrs > 0 || forceHours) {
      return '${hrs.toString().padLeft(2, '0')}:'
          '${mins.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  String formatPace(int secondsPerKm) {
    if (secondsPerKm <= 0 || secondsPerKm > 3600) return '--:--/km';
    final mins = secondsPerKm ~/ 60;
    final secs = secondsPerKm % 60;
    return '$mins:${secs.toString().padLeft(2, '0')} /km';
  }

  String formatSpeed(double kmh) {
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  String getCardinalDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor();
    return directions[index.clamp(0, 7)];
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}

final geoServiceProvider = Provider<GeoService>((ref) => GeoService());

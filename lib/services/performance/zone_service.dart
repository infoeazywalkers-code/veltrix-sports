import 'package:flutter_riverpod/flutter_riverpod.dart';

class HrZoneResult {
  final int zone;
  final String label;
  final String color;
  final String description;

  const HrZoneResult({
    required this.zone,
    required this.label,
    required this.color,
    required this.description,
  });
}

class PowerZoneResult {
  final int zone;
  final String label;
  final String color;

  const PowerZoneResult({
    required this.zone,
    required this.label,
    required this.color,
  });
}

class ZoneService {
  HrZoneResult getHeartRateZone(int hr, int lthr) {
    final pct = hr / lthr;
    if (pct < 0.68) {
      return const HrZoneResult(
        zone: 1,
        label: 'Z1 Active Recovery',
        color: 'neutral',
        description: 'Easy aerobic flush',
      );
    } else if (pct < 0.84) {
      return const HrZoneResult(
        zone: 2,
        label: 'Z2 Aerobic Endurance',
        color: 'sky',
        description: 'Base building & fat burn',
      );
    } else if (pct < 0.95) {
      return const HrZoneResult(
        zone: 3,
        label: 'Z3 Tempo',
        color: 'emerald',
        description: 'Aerobic fitness & rhythm',
      );
    } else if (pct < 1.05) {
      return const HrZoneResult(
        zone: 4,
        label: 'Z4 Threshold',
        color: 'amber',
        description: 'Lactate threshold ceiling',
      );
    } else {
      return const HrZoneResult(
        zone: 5,
        label: 'Z5 Anaerobic / VO2max',
        color: 'rose',
        description: 'Max capacity & sprint',
      );
    }
  }

  PowerZoneResult getPowerZone(int watts, int ftp) {
    final pct = (watts / ftp) * 100;
    if (pct < 55) {
      return const PowerZoneResult(
        zone: 1,
        label: 'Z1 Active Recovery',
        color: 'neutral',
      );
    }
    if (pct < 75) {
      return const PowerZoneResult(
        zone: 2,
        label: 'Z2 Endurance',
        color: 'sky',
      );
    }
    if (pct < 90) {
      return const PowerZoneResult(
        zone: 3,
        label: 'Z3 Tempo',
        color: 'emerald',
      );
    }
    if (pct < 105) {
      return const PowerZoneResult(
        zone: 4,
        label: 'Z4 Sweet Spot / Threshold',
        color: 'amber',
      );
    }
    if (pct < 120) {
      return const PowerZoneResult(
        zone: 5,
        label: 'Z5 VO2 Max',
        color: 'orange',
      );
    }
    if (pct < 150) {
      return const PowerZoneResult(
        zone: 6,
        label: 'Z6 Anaerobic Capacity',
        color: 'rose',
      );
    }
    return const PowerZoneResult(
      zone: 7,
      label: 'Z7 Neuromuscular Power',
      color: 'purple',
    );
  }

  Map<int, double> computeZoneDistribution(
    List<int> values,
    int referenceValue, {
    bool isPower = false,
  }) {
    final distribution = <int, double>{};
    for (int i = 1; i <= (isPower ? 7 : 5); i++) {
      distribution[i] = 0;
    }

    for (final value in values) {
      final zone = isPower
          ? getPowerZone(value, referenceValue).zone
          : getHeartRateZone(value, referenceValue).zone;
      distribution[zone] = (distribution[zone] ?? 0) + 1;
    }

    final total = values.length.toDouble();
    if (total > 0) {
      for (final key in distribution.keys) {
        distribution[key] = (distribution[key]! / total * 100).roundToDouble();
      }
    }

    return distribution;
  }
}

final zoneServiceProvider = Provider<ZoneService>((ref) => ZoneService());

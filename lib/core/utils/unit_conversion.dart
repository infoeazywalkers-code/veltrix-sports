import '../../models/user/user_preferences.dart';

/// Stateless conversion and formatting helpers for metric / imperial units.
class UnitConversion {
  UnitConversion._();

  // -------------------------------------------------------------------------
  // Raw conversions
  // -------------------------------------------------------------------------

  static double kmToMiles(double km) => km * 0.621371;
  static double milesToKm(double mi) => mi * 1.60934;
  static double kgToLb(double kg) => kg * 2.20462;
  static double lbToKg(double lb) => lb * 0.453592;
  static double mToFt(double m) => m * 3.28084;
  static double ftToM(double ft) => ft * 0.3048;

  // -------------------------------------------------------------------------
  // Formatting helpers
  // -------------------------------------------------------------------------

  /// Formats a distance stored as km into the user's preferred unit.
  static String formatDistance(UnitSystem unit, double km) {
    if (unit == UnitSystem.imperial) {
      return '${kmToMiles(km).toStringAsFixed(1)} mi';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  /// Formats pace (min-per-km) into the user's preferred unit.
  static String formatPace(UnitSystem unit, double minPerKm) {
    if (unit == UnitSystem.imperial) {
      final minPerMile = minPerKm * 1.60934;
      final min = minPerMile.floor();
      final sec = ((minPerMile - min) * 60).round();
      return '$min:${sec.toString().padLeft(2, '0')}/mi';
    }
    final min = minPerKm.floor();
    final sec = ((minPerKm - min) * 60).round();
    return '$min:${sec.toString().padLeft(2, '0')}/km';
  }

  /// Formats elevation (meters) into the user's preferred unit.
  static String formatElevation(UnitSystem unit, double meters) {
    if (unit == UnitSystem.imperial) {
      return '${mToFt(meters).round()} ft';
    }
    return '${meters.round()} m';
  }

  /// Formats weight (kg) into the user's preferred unit.
  static String formatWeight(UnitSystem unit, double kg) {
    if (unit == UnitSystem.imperial) {
      return '${kgToLb(kg).toStringAsFixed(1)} lb';
    }
    return '${kg.toStringAsFixed(1)} kg';
  }
}

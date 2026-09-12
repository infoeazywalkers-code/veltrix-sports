import 'package:cloud_firestore/cloud_firestore.dart';

enum GearType { bike, shoes, watch, powerMeter }

class GearItem {
  final String id;
  final String name;
  final GearType type;
  final String brandModel;
  final double distanceKm;
  final double maxDistanceKm;
  final bool isRetired;

  const GearItem({
    required this.id,
    required this.name,
    required this.type,
    required this.brandModel,
    required this.distanceKm,
    required this.maxDistanceKm,
    this.isRetired = false,
  });

  factory GearItem.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>? ?? {};
    return GearItem(
      id: doc.id,
      name: (m['name'] as String? ?? '').trim(),
      type: GearType.values.firstWhere(
        (e) => e.name == m['type'],
        orElse: () => GearType.bike,
      ),
      brandModel: (m['brandModel'] as String? ?? '').trim(),
      distanceKm: (m['distanceKm'] as num? ?? 0).toDouble(),
      maxDistanceKm: (m['maxDistanceKm'] as num? ?? 0).toDouble(),
      isRetired: m['isRetired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'type': type.name,
    'brandModel': brandModel,
    'distanceKm': distanceKm,
    'maxDistanceKm': maxDistanceKm,
    'isRetired': isRetired,
  };

  double get usagePercent =>
      maxDistanceKm > 0 ? (distanceKm / maxDistanceKm * 100).clamp(0, 100) : 0;

  bool get needsReplacement => usagePercent >= 85;

  GearItem copyWith({
    String? name,
    GearType? type,
    String? brandModel,
    double? distanceKm,
    double? maxDistanceKm,
    bool? isRetired,
  }) => GearItem(
    id: id,
    name: name ?? this.name,
    type: type ?? this.type,
    brandModel: brandModel ?? this.brandModel,
    distanceKm: distanceKm ?? this.distanceKm,
    maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
    isRetired: isRetired ?? this.isRetired,
  );
}

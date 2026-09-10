import 'package:flutter/material.dart';
import '../../models/activity/gear_item.dart';

class GearVaultScreen extends StatelessWidget {
  final List<GearItem> gear;
  final Function(GearItem)? onEdit;
  final VoidCallback? onAdd;

  const GearVaultScreen({
    super.key,
    this.gear = const [],
    this.onEdit,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final bikes = gear.where((g) => g.type == GearType.bike).toList();
    final shoes = gear.where((g) => g.type == GearType.shoes).toList();
    final watches = gear.where((g) => g.type == GearType.watch).toList();
    final powerMeters =
        gear.where((g) => g.type == GearType.powerMeter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAdd,
        backgroundColor: const Color(0xFFF97316),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'Add Gear',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body:
          gear.isEmpty
              ? _emptyState()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryCards(gear),
                    const SizedBox(height: 20),
                    if (bikes.isNotEmpty) ...[
                      _sectionHeader('Bicycles', Icons.directions_bike),
                      ...bikes.map((g) => _gearCard(g, onEdit)),
                      const SizedBox(height: 16),
                    ],
                    if (shoes.isNotEmpty) ...[
                      _sectionHeader('Running Shoes', Icons.directions_run),
                      ...shoes.map((g) => _gearCard(g, onEdit)),
                      const SizedBox(height: 16),
                    ],
                    if (watches.isNotEmpty) ...[
                      _sectionHeader('Wearable Tech', Icons.watch),
                      ...watches.map((g) => _gearCard(g, onEdit)),
                      const SizedBox(height: 16),
                    ],
                    if (powerMeters.isNotEmpty) ...[
                      _sectionHeader('Power Meters', Icons.speed),
                      ...powerMeters.map((g) => _gearCard(g, onEdit)),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'Gear Vault is empty',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Track shoes, bikes, and equipment\nwith usage analytics and replacement alerts.',
            style: TextStyle(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _summaryCards(List<GearItem> allGear) {
    final totalDistance = allGear.fold<double>(
      0,
      (sum, g) => sum + g.distanceKm,
    );
    final totalMax = allGear.fold<double>(0, (sum, g) => sum + g.maxDistanceKm);

    return Row(
      children: [
        _summaryTile(
          'Total Distance',
          '${totalDistance.round()} km',
          const Color(0xFFF97316),
        ),
        const SizedBox(width: 8),
        _summaryTile(
          'Max Capacity',
          '${totalMax.round()} km',
          const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 8),
        _summaryTile(
          'Active Gear',
          '${allGear.where((g) => !g.isRetired).length}',
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _summaryTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF97316), size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gearCard(GearItem g, Function(GearItem)? onEdit) {
    return GestureDetector(
      onTap: onEdit != null ? () => onEdit(g) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _gearEmoji(g.type),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    g.brandModel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${g.distanceKm.round()} km',
                        style: const TextStyle(
                          color: Color(0xFFF97316),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Max ${g.maxDistanceKm.round()} km',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                        ),
                      ),
                      if (g.isRetired) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'RETIRED',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (g.maxDistanceKm > 0) _usageIndicator(g.usagePercent),
          ],
        ),
      ),
    );
  }

  String _gearEmoji(GearType type) {
    switch (type) {
      case GearType.bike:
        return '🚴';
      case GearType.shoes:
        return '👟';
      case GearType.watch:
        return '⌚';
      case GearType.powerMeter:
        return '⚡';
    }
  }

  Widget _usageIndicator(double pct) {
    final color =
        pct > 85
            ? const Color(0xFFEF4444)
            : pct > 60
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    return Column(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: pct / 100,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                '${pct.round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        if (pct > 85) const Text('⚠️', style: TextStyle(fontSize: 10)),
      ],
    );
  }
}

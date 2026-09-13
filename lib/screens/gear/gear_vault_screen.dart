import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/activity/gear_item.dart';
import '../../providers.dart';
import 'widgets/gear_edit_dialog.dart';
import 'widgets/gear_retire_dialog.dart';

/// Live gear vault for the signed-in user.
///
/// Reads [gearListProvider] (backed by `GearService.watchGear`) and renders
/// loading / error / data states. Signed-out users get a sign-in prompt
/// instead of a crash; users with no gear get an honest empty state.
/// The FAB opens [GearEditDialog]; tapping a card edits it; the small
/// archive icon on each card opens [GearRetireDialog].
class GearVaultScreen extends ConsumerWidget {
  const GearVaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 56, color: Colors.white24),
              SizedBox(height: 16),
              Text(
                'Sign in to view your gear',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final gearAsync = ref.watch(gearListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const GearEditDialog(),
        ),
        backgroundColor: const Color(0xFFF97316),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'Add Gear',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: gearAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFF97316)),
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            "Couldn't load gear: $e",
            style: const TextStyle(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
        data: (gear) {
          if (gear.isEmpty) return _emptyState();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryCards(gear),
                const SizedBox(height: 20),
                ..._sections(context, gear),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _sections(BuildContext context, List<GearItem> gear) {
    final bikes = gear.where((g) => g.type == GearType.bike).toList();
    final shoes = gear.where((g) => g.type == GearType.shoes).toList();
    final watches = gear.where((g) => g.type == GearType.watch).toList();
    final powerMeters = gear
        .where((g) => g.type == GearType.powerMeter)
        .toList();
    return [
      if (bikes.isNotEmpty) ...[
        _sectionHeader('Bicycles', Icons.directions_bike),
        ...bikes.map((g) => _gearCard(context, g)),
        const SizedBox(height: 16),
      ],
      if (shoes.isNotEmpty) ...[
        _sectionHeader('Running Shoes', Icons.directions_run),
        ...shoes.map((g) => _gearCard(context, g)),
        const SizedBox(height: 16),
      ],
      if (watches.isNotEmpty) ...[
        _sectionHeader('Wearable Tech', Icons.watch),
        ...watches.map((g) => _gearCard(context, g)),
        const SizedBox(height: 16),
      ],
      if (powerMeters.isNotEmpty) ...[
        _sectionHeader('Power Meters', Icons.speed),
        ...powerMeters.map((g) => _gearCard(context, g)),
      ],
    ];
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

  Widget _gearCard(BuildContext context, GearItem g) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => GearEditDialog(existing: g),
      ),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (g.maxDistanceKm > 0) _usageIndicator(g.usagePercent),
                IconButton(
                  tooltip: g.isRetired ? 'Restore gear' : 'Retire gear',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => GearRetireDialog(gear: g),
                  ),
                  icon: Icon(
                    g.isRetired
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                    color: _usageColor(g.usagePercent),
                    size: 20,
                  ),
                ),
              ],
            ),
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

  /// Shared usage color scale for the ring and the retire affordance.
  Color _usageColor(double pct) {
    if (pct > 85) return const Color(0xFFEF4444);
    if (pct > 60) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Widget _usageIndicator(double pct) {
    final color = _usageColor(pct);

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

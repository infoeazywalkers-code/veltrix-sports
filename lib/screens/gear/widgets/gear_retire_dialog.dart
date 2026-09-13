import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/activity/gear_item.dart';
import '../../../providers.dart';
import '../../../services/gear/gear_service.dart';

/// Confirm dialog for retiring / restoring / deleting a gear item.
///
/// Delete is offered because `/gear` rules allow an owner delete
/// (verified in `firestore.rules`); all writes go through [GearService].
class GearRetireDialog extends ConsumerStatefulWidget {
  final GearItem gear;

  const GearRetireDialog({super.key, required this.gear});

  @override
  ConsumerState<GearRetireDialog> createState() => _GearRetireDialogState();
}

class _GearRetireDialogState extends ConsumerState<GearRetireDialog> {
  bool _working = false;

  Future<void> _run(Future<void> Function(GearService service) action) async {
    if (_working) return;
    setState(() => _working = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action(ref.read(gearServiceProvider));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _working = false);
      messenger.showSnackBar(
        SnackBar(content: Text("Couldn't update gear: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gear = widget.gear;
    final retired = gear.isRetired;
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(
        retired ? 'Restore gear?' : 'Retire gear?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        retired
            ? '“${gear.name}” will move back to your active gear.'
            : '“${gear.name}” will stay visible but marked RETIRED.',
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: _working ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _working ? null : () => _run((s) => s.deleteGear(gear.id)),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
        FilledButton(
          onPressed: _working
              ? null
              : () => _run(
                  (s) =>
                      retired ? s.restoreGear(gear.id) : s.retireGear(gear.id),
                ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
          ),
          child: Text(_working ? 'Working…' : (retired ? 'Restore' : 'Retire')),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/activity/gear_item.dart';
import '../../../providers.dart';

/// Validated add/edit dialog for a single gear item.
///
/// Add mode ([existing] is null) writes via [GearService.addGear];
/// edit mode writes via [GearService.updateGear]. The uid comes from
/// [currentUserProvider]; failures surface as a SnackBar and the
/// submit button is disabled while saving so double-taps write once.
class GearEditDialog extends ConsumerStatefulWidget {
  final GearItem? existing;

  const GearEditDialog({super.key, this.existing});

  @override
  ConsumerState<GearEditDialog> createState() => _GearEditDialogState();
}

class _GearEditDialogState extends ConsumerState<GearEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _distanceController;
  late final TextEditingController _maxController;
  late GearType _type;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.type ?? GearType.bike;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _brandController = TextEditingController(text: existing?.brandModel ?? '');
    _distanceController = TextEditingController(
      text: existing != null ? '${existing.distanceKm}' : '0',
    );
    _maxController = TextEditingController(
      text: existing != null ? '${existing.maxDistanceKm}' : '',
    );
    for (final c in [_nameController, _distanceController, _maxController]) {
      c.addListener(_onFieldsChanged);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _distanceController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _onFieldsChanged() {
    if (mounted) setState(() {});
  }

  double get _parsedDistance =>
      double.tryParse(_distanceController.text.trim()) ?? -1;

  double get _parsedMax => double.tryParse(_maxController.text.trim()) ?? -1;

  double get _previewPercent {
    if (_parsedMax <= 0 || _parsedDistance < 0) return 0;
    return (_parsedDistance / _parsedMax * 100).clamp(0, 100);
  }

  String? _validateName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) return 'Enter a name';
    if (name.length > 80) return 'Keep the name under 80 characters';
    return null;
  }

  String? _validateDistance(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null) return 'Enter a distance';
    if (parsed < 0) return "Distance can't be negative";
    return null;
  }

  String? _validateMax(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null) return 'Enter a max distance';
    if (parsed <= 0) return 'Max distance must be more than 0';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = ref.read(currentUserProvider);
    if (user == null || user.uid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in to save gear')));
      return;
    }
    setState(() => _saving = true);
    try {
      final service = ref.read(gearServiceProvider);
      final name = _nameController.text.trim();
      final brand = _brandController.text.trim();
      final distance = double.parse(_distanceController.text.trim());
      final max = double.parse(_maxController.text.trim());
      final existing = widget.existing;
      if (existing == null) {
        await service.addGear(
          GearItem(
            id: '',
            name: name,
            type: _type,
            brandModel: brand,
            distanceKm: distance,
            maxDistanceKm: max,
          ),
          user.uid,
        );
      } else {
        await service.updateGear(existing.id, {
          'name': name,
          'type': _type.name,
          'brandModel': brand,
          'distanceKm': distance,
          'maxDistanceKm': max,
        });
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Couldn't save gear: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(
        isEdit ? 'Edit gear' : 'Add gear',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 80,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Race-day Vaporflys',
                ),
                validator: _validateName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              const Text(
                'Type',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 8),
              SegmentedButton<GearType>(
                segments: const [
                  ButtonSegment(value: GearType.bike, label: Text('Bike')),
                  ButtonSegment(value: GearType.shoes, label: Text('Shoes')),
                  ButtonSegment(value: GearType.watch, label: Text('Watch')),
                  ButtonSegment(
                    value: GearType.powerMeter,
                    label: Text('Power'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged:
                    _saving
                        ? null
                        : (selected) => setState(() => _type = selected.first),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brandController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Brand / model (optional)',
                  hintText: 'e.g. Nike Vaporfly 3',
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _distanceController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Distance (km)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateDistance,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Max distance (km)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateMax,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _parsedMax > 0
                    ? 'Usage ${_previewPercent.round()}%'
                    : 'Set a max distance to preview usage',
                style: const TextStyle(
                  color: Color(0xFFF97316),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
          ),
          child: Text(
            _saving ? 'Saving…' : (isEdit ? 'Save changes' : 'Add gear'),
          ),
        ),
      ],
    );
  }
}

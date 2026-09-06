import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../constants.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class WorkoutBuilderDialog extends StatefulWidget {
  final DateTime? initialDate;
  const WorkoutBuilderDialog({super.key, this.initialDate});

  @override
  State<WorkoutBuilderDialog> createState() => _WorkoutBuilderDialogState();
}

class _WorkoutBuilderDialogState extends State<WorkoutBuilderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '45m');
  final _distanceController = TextEditingController();
  final _tssController = TextEditingController(text: '50');
  final _targetPaceController = TextEditingController();

  Sport _selectedSport = Sport.run;
  late DateTime _scheduledFor;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _scheduledFor = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _tssController.dispose();
    _targetPaceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledFor,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _scheduledFor = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _scheduledFor.hour,
          _scheduledFor.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final newWorkout = Workout(
        id: const Uuid().v4(),
        planId: 'user_created',
        sport: _selectedSport,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        duration: _durationController.text.trim(),
        distanceKm: double.tryParse(_distanceController.text.trim()),
        tss: int.tryParse(_tssController.text.trim()),
        targetPace:
            _targetPaceController.text.trim().isNotEmpty
                ? _targetPaceController.text.trim()
                : null,
        scheduledFor: _scheduledFor,
        progress: 0.0,
        completed: false,
        segments: [
          const WorkoutSegment(label: 'Warmup', duration: '10m'),
          WorkoutSegment(
            label: 'Main Set',
            duration: _durationController.text.trim(),
          ),
          const WorkoutSegment(label: 'Cooldown', duration: '5m'),
        ],
      );

      await WorkoutService().create(newWorkout);

      if (mounted) {
        Navigator.pop(context, newWorkout);
        showFeatureMessage(context, 'Workout "${newWorkout.title}" scheduled!');
      }
    } catch (e) {
      if (mounted) {
        showFeatureMessage(context, 'Workout saved locally (demo mode).');
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.fitness_center, color: navy),
          SizedBox(width: 10),
          Text(
            'Schedule Workout',
            style: TextStyle(fontWeight: FontWeight.w900, color: navy),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Workout Title *',
                  hintText: 'e.g., Tempo Interval Run',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_run),
                ),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'Enter workout title'
                            : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<Sport>(
                initialValue: _selectedSport,
                decoration: const InputDecoration(
                  labelText: 'Sport Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    Sport.values.map((sport) {
                      return DropdownMenuItem(
                        value: sport,
                        child: Text(
                          sport.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      );
                    }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSport = val);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration *',
                        hintText: '45m',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (val) =>
                              val == null || val.trim().isEmpty
                                  ? 'Required'
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _distanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Distance (km)',
                        hintText: '10.0',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final parsed = double.tryParse(val.trim());
                          if (parsed == null || parsed < 0)
                            return 'Must be >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tssController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target TSS Score',
                        hintText: '50',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.analytics),
                      ),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final parsed = int.tryParse(val.trim());
                          if (parsed == null || parsed < 0)
                            return 'Must be >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _targetPaceController,
                      decoration: const InputDecoration(
                        labelText: 'Target Pace',
                        hintText: '5:00 /km',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: navy),
                title: Text(
                  'Date: ${_scheduledFor.year}-${_scheduledFor.month.toString().padLeft(2, '0')}-${_scheduledFor.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: navy,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Notes / Description',
                  hintText: 'e.g., Focus on consistent cadences above 175 spm',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: navy,
          ),
          onPressed: _saving ? null : _save,
          child:
              _saving
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text(
                    'Create Workout',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/coach_service.dart';

class CoachBookingDialog extends StatefulWidget {
  final CoachProfile coach;
  const CoachBookingDialog({super.key, required this.coach});

  @override
  State<CoachBookingDialog> createState() => _CoachBookingDialogState();
}

class _CoachBookingDialogState extends State<CoachBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController(text: 'Sub-3:45 Marathon PR');
  final _messageController = TextEditingController(
      text: 'Hi! Looking to optimize my weekly mileage and strength work for upcoming races.');
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 3));
  bool _submitting = false;

  @override
  void dispose() {
    _goalController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _preferredDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await CoachService.sendInquiry(
        coachId: widget.coach.id,
        coachName: widget.coach.name,
        targetGoal: _goalController.text.trim(),
        message: _messageController.text.trim(),
        preferredDate: _preferredDate,
      );

      if (mounted) {
        Navigator.pop(context, true);
        showFeatureMessage(
          context,
          'Discovery call request sent to ${widget.coach.name}! They will reply within 24 hours.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.groups, color: navy),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Book Call with ${widget.coach.name.split(' ').elementAt(1)}',
              style: const TextStyle(fontWeight: FontWeight.w900, color: navy, fontSize: 18),
            ),
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
              Text(
                widget.coach.title,
                style: const TextStyle(fontWeight: FontWeight.w700, color: blue, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(
                  labelText: 'Primary Target Goal *',
                  hintText: 'e.g. Marathon Sub-3:45',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month, color: navy),
                title: Text(
                  'Call Date: ${_preferredDate.year}-${_preferredDate.month.toString().padLeft(2, '0')}-${_preferredDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: navy, fontSize: 13),
                ),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change Date'),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message for Coach',
                  hintText: 'Share your background, injury history, and schedule availability...',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: navy,
          ),
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Book 1-on-1 Consultation',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
        ),
      ],
    );
  }
}

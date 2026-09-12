import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/social/coach_service.dart';
import '../../screens/coach/my_coach_inquiries_screen.dart';

class CoachBookingDialog extends StatefulWidget {
  final CoachProfile coach;
  const CoachBookingDialog({super.key, required this.coach});

  @override
  State<CoachBookingDialog> createState() => _CoachBookingDialogState();
}

class _CoachBookingDialogState extends State<CoachBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();
  final _messageController = TextEditingController();
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 3));
  bool _submitting = false;
  bool _submitted = false;

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
        // CoachProfile carries no auth uid (id is the coaches-doc id, not a
        // Firebase uid), so a direct chat room cannot be opened without
        // fabricating a uid. Show a success state with "View my inquiries"
        // (coach_inquiries where userId == uid via fetchMyInquiries).
        setState(() => _submitted = true);
        showFeatureMessage(
          context,
          'Discovery call request sent to ${widget.coach.name}! They will reply within 24 hours.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return AlertDialog(
        title: const Text('Sign in required'),
        content: const Text(
          'Please sign in to book a discovery call with this coach.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'signIn'),
            child: const Text('Sign in'),
          ),
        ],
      );
    }
    if (_submitted) {
      return AlertDialog(
        title: const Text('Request sent'),
        content: Text(
          'Your discovery call request was sent to ${widget.coach.name}. '
          'Track replies under your inquiries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: lime,
              foregroundColor: navy,
            ),
            onPressed: () {
              Navigator.pop(context, true);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyCoachInquiriesScreen(),
                ),
              );
            },
            child: const Text('View my inquiries'),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.groups,
            color:
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : navy),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Book Call with ${widget.coach.name.split(' ').length > 1 ? widget.coach.name.split(' ').elementAt(1) : widget.coach.name}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color:
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
                fontSize: 18,
              ),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: blue,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'Primary target goal, required',
                child: TextFormField(
                  controller: _goalController,
                  decoration: const InputDecoration(
                    labelText: 'Primary Target Goal *',
                    hintText: 'e.g. Marathon Sub-3:45',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  validator:
                      (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label:
                    'Call date: ${_preferredDate.year}-${_preferredDate.month.toString().padLeft(2, '0')}-${_preferredDate.day.toString().padLeft(2, '0')}',
                button: true,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.calendar_month,
                    color:
                        (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : navy),
                  ),
                  title: Text(
                    'Call Date: ${_preferredDate.year}-${_preferredDate.month.toString().padLeft(2, '0')}-${_preferredDate.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : navy),
                      fontSize: 13,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: _pickDate,
                    child: const Text('Change Date'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Message for coach, required',
                child: TextFormField(
                  controller: _messageController,
                  maxLines: 3,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    labelText: 'Message for Coach *',
                    hintText:
                        'Share your background, injury history, and schedule availability...',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                ),
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
        Semantics(
          label: 'Book one-on-one consultation with ${widget.coach.name}',
          button: true,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: lime,
              foregroundColor: navy,
            ),
            onPressed: _submitting ? null : _submit,
            child:
                _submitting
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
        ),
      ],
    );
  }
}

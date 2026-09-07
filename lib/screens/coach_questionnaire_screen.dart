import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../constants.dart';
import '../services/coach_request_service.dart';
import '../models/coach_request.dart';

class CoachQuestionnaireScreen extends StatefulWidget {
  const CoachQuestionnaireScreen({super.key});

  @override
  State<CoachQuestionnaireScreen> createState() =>
      _CoachQuestionnaireScreenState();
}

class _CoachQuestionnaireScreenState extends State<CoachQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _coachRequestService = CoachRequestService();
  String sport = 'Running';
  String experience = 'Intermediate';
  String goal = 'Improve performance';
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        showDialog<void>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Text('Sign in required'),
                content: const Text(
                  'Please sign in to submit your coach questionnaire.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    child: const Text('Sign in'),
                  ),
                ],
              ),
        );
      }
      return;
    }

    setState(() => _submitting = true);

    try {
      final request = CoachRequest(
        id: const Uuid().v4(),
        userId: user.uid,
        sport: sport,
        experience: experience,
        goal: goal,
        notes: _notesController.text,
        createdAt: DateTime.now(),
      );

      await _coachRequestService.create(request);

      if (mounted) {
        showDialog<void>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Questionnaire submitted'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We will match you with a $sport coach for your goal: $goal.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Our team will review your answers and contact you within 24-48 hours with a recommended coach match.',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find your coach'),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Tell us about your training',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We use your answers to recommend coaches who fit your goals and communication style.',
              style: TextStyle(color: muted, height: 1.4),
            ),
            const SizedBox(height: 28),
            DropdownButtonFormField<String>(
              initialValue: sport,
              decoration: const InputDecoration(
                labelText: 'Primary sport',
                border: OutlineInputBorder(),
              ),
              items:
                  const [
                        'Running',
                        'Cycling',
                        'Swimming',
                        'Triathlon',
                        'Strength',
                      ]
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
              onChanged: (v) => setState(() => sport = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: experience,
              decoration: const InputDecoration(
                labelText: 'Experience level',
                border: OutlineInputBorder(),
              ),
              items:
                  const ['Beginner', 'Intermediate', 'Advanced', 'Elite']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
              onChanged: (v) => setState(() => experience = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: goal,
              decoration: const InputDecoration(
                labelText: 'Main goal',
                border: OutlineInputBorder(),
              ),
              items:
                  const [
                        'Improve performance',
                        'Complete my first event',
                        'Return from injury',
                        'Build consistency',
                      ]
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
              onChanged: (v) => setState(() => goal = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Anything your coach should know?',
                hintText: 'Schedule, upcoming events, preferences...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: lime,
                foregroundColor: navy,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submitting ? null : _submit,
              icon:
                  _submitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.send),
              label: Text(
                _submitting ? 'Submitting...' : 'Submit answers',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

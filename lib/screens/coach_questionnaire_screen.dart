import 'package:flutter/material.dart';
import '../constants.dart';

class CoachQuestionnaireScreen extends StatefulWidget {
  const CoachQuestionnaireScreen({super.key});

  @override
  State<CoachQuestionnaireScreen> createState() => _CoachQuestionnaireScreenState();
}

class _CoachQuestionnaireScreenState extends State<CoachQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  String sport = 'Running';
  String experience = 'Intermediate';
  String goal = 'Improve performance';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find your coach')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Tell us about your training', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: navy)),
            const SizedBox(height: 8),
            const Text('We use your answers to recommend coaches who fit your goals and communication style.', style: TextStyle(color: muted, height: 1.4)),
            const SizedBox(height: 28),
            DropdownButtonFormField<String>(
              initialValue: sport,
              decoration: const InputDecoration(labelText: 'Primary sport', border: OutlineInputBorder()),
              items: const ['Running', 'Cycling', 'Swimming', 'Triathlon', 'Strength'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: (value) => setState(() => sport = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: experience,
              decoration: const InputDecoration(labelText: 'Experience level', border: OutlineInputBorder()),
              items: const ['Beginner', 'Intermediate', 'Advanced', 'Elite'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: (value) => setState(() => experience = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: goal,
              decoration: const InputDecoration(labelText: 'Main goal', border: OutlineInputBorder()),
              items: const ['Improve performance', 'Complete my first event', 'Return from injury', 'Build consistency'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: (value) => setState(() => goal = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Anything your coach should know?', hintText: 'Schedule, upcoming events, preferences...', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: navy, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Questionnaire submitted'),
                    content: Text('We will match you with a $sport coach for your goal: $goal.'),
                    actions: [
                      FilledButton(onPressed: () { Navigator.pop(dialogContext); Navigator.pop(context); }, child: const Text('Done')),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit answers', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}
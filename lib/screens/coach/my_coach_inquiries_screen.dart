import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/social/coach_service.dart';

/// Read-only athlete outbox: `coach_inquiries` where userId == current uid.
class MyCoachInquiriesScreen extends StatefulWidget {
  const MyCoachInquiriesScreen({super.key});

  @override
  State<MyCoachInquiriesScreen> createState() => _MyCoachInquiriesScreenState();
}

class _MyCoachInquiriesScreenState extends State<MyCoachInquiriesScreen> {
  Future<List<CoachInquiry>>? _future;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _future = CoachService.fetchMyInquiries(user.uid);
    }
  }

  void _retry() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _future = CoachService.fetchMyInquiries(user.uid));
  }

  String _formatDate(String iso) {
    try {
      final parsed = DateTime.parse(iso);
      final month = parsed.month.toString().padLeft(2, '0');
      final day = parsed.day.toString().padLeft(2, '0');
      return '${parsed.year}-$month-$day';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My inquiries')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: muted),
              const SizedBox(height: 12),
              const Text(
                'Sign in to view your coach inquiries.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My inquiries')),
      body: FutureBuilder<List<CoachInquiry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: orange),
                  const SizedBox(height: 12),
                  const Text('Could not load your inquiries.'),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            );
          }
          final inquiries = snapshot.data ?? [];
          if (inquiries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No inquiries yet. Book a discovery call and it will show up here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: inquiries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final inquiry = inquiries[index];
              final goal =
                  inquiry.targetGoal.isEmpty
                      ? 'Discovery call'
                      : inquiry.targetGoal;
              final date =
                  inquiry.preferredDate.isEmpty
                      ? ''
                      : 'Preferred: ${_formatDate(inquiry.preferredDate)}';
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.mark_email_read_outlined,
                    color: navy,
                  ),
                  title: Text(
                    '${inquiry.coachName} • $goal',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    inquiry.message.isEmpty
                        ? date
                        : date.isEmpty
                        ? inquiry.message
                        : '${inquiry.message}\n$date',
                  ),
                  isThreeLine: inquiry.message.isNotEmpty && date.isNotEmpty,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

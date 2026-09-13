import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/social/coach_service.dart';

/// Live athlete outbox: `coach_inquiries` where userId == current uid,
/// with live pending/accepted/declined status chips.
class MyCoachInquiriesScreen extends StatelessWidget {
  const MyCoachInquiriesScreen({super.key});

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
      body: StreamBuilder<List<CoachInquiry>>(
        stream: CoachService.watchInquiriesForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: orange),
                  SizedBox(height: 12),
                  Text('Could not load your inquiries.'),
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
              final goal = inquiry.targetGoal.isEmpty
                  ? 'Discovery call'
                  : inquiry.targetGoal;
              final date = inquiry.preferredDate.isEmpty
                  ? ''
                  : 'Preferred: ${_formatDate(inquiry.preferredDate)}';
              final body = inquiry.message.isEmpty
                  ? date
                  : date.isEmpty
                  ? inquiry.message
                  : '${inquiry.message}\n$date';
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (body.isNotEmpty) Text(body),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _StatusChip(status: inquiry.status),
                          if (inquiry.package.isNotEmpty)
                            Chip(
                              label: Text(
                                inquiry.package,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              backgroundColor: bg,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.isEmpty ? 'pending' : status;
    final Color color = normalized == 'accepted'
        ? Colors.green
        : normalized == 'declined'
        ? muted
        : orange;
    return Chip(
      label: Text(
        normalized,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

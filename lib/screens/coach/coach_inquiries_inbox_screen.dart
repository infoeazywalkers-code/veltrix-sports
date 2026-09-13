import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/user/user_profile.dart';
import '../../services/social/chat_service.dart';
import '../../services/social/coach_service.dart';
import '../../services/user_service.dart';
import '../../widgets/common/role_gate.dart';
import '../social/chat_screen.dart';

/// Coach-only inbox for direct discovery-call inquiries.
///
/// Streams [CoachService.watchInquiriesForCoach]. Accept writes
/// `status: accepted` (history preserved) then opens chat when the
/// athlete uid is present; Decline writes `status: declined` and the
/// row stays visible greyed.
class CoachInquiriesInboxScreen extends StatefulWidget {
  const CoachInquiriesInboxScreen({super.key});

  @override
  State<CoachInquiriesInboxScreen> createState() =>
      _CoachInquiriesInboxScreenState();
}

class _CoachInquiriesInboxScreenState extends State<CoachInquiriesInboxScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final Set<String> _busy = {};
  final Map<String, Future<UserProfile?>> _profileFutures = {};

  Future<UserProfile?> _athleteProfile(CoachInquiry inquiry) {
    return _profileFutures.putIfAbsent(
      inquiry.id,
      () => _userService.get(inquiry.userId),
    );
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

  Future<void> _accept(CoachInquiry inquiry) async {
    final coach = FirebaseAuth.instance.currentUser;
    if (coach == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in as a coach to accept.')),
        );
      }
      return;
    }
    if (_busy.contains(inquiry.id)) return;
    setState(() => _busy.add(inquiry.id));
    try {
      final ok = await CoachService.updateInquiryStatus(inquiry.id, 'accepted');
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not accept inquiry.')),
        );
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inquiry accepted.')));
      if (inquiry.userId.isEmpty || inquiry.userId == 'guest') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Accepted — no athlete account to chat with.'),
            ),
          );
        }
        return;
      }
      try {
        final profile = await _athleteProfile(inquiry);
        final athleteName = (profile?.displayName.isNotEmpty == true)
            ? profile!.displayName
            : 'Athlete';
        final roomId = await _chatService.getOrCreateChatRoom(
          athleteId: inquiry.userId,
          coachId: coach.uid,
          athleteName: athleteName,
          coachName: coach.displayName ?? 'Coach',
        );
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChatScreen(chatRoomId: roomId, otherUserName: athleteName),
          ),
        );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Accepted — chat could not be opened.'),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _busy.remove(inquiry.id));
    }
  }

  Future<void> _decline(CoachInquiry inquiry) async {
    if (_busy.contains(inquiry.id)) return;
    setState(() => _busy.add(inquiry.id));
    try {
      final ok = await CoachService.updateInquiryStatus(inquiry.id, 'declined');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Inquiry declined.' : 'Could not decline.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(inquiry.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final coach = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call inquiries'),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: CoachOnly(
        fallback: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: muted),
              SizedBox(height: 12),
              Text(
                'Coach access required',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Only coaches can review call inquiries.',
                style: TextStyle(color: muted, fontSize: 14),
              ),
            ],
          ),
        ),
        child: coach == null
            ? const Center(child: Text('Sign in as a coach to continue.'))
            : StreamBuilder<List<CoachInquiry>>(
                stream: CoachService.watchInquiriesForCoach(coach.uid),
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
                          Text('Could not load inquiries.'),
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
                          'No call inquiries yet. New discovery-call bookings will appear here.',
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
                      final busy = _busy.contains(inquiry.id);
                      return _InquiryCard(
                        inquiry: inquiry,
                        profileFuture: _athleteProfile(inquiry),
                        dateLabel: inquiry.preferredDate.isEmpty
                            ? ''
                            : _formatDate(inquiry.preferredDate),
                        busy: busy,
                        onAccept: () => _accept(inquiry),
                        onDecline: () => _decline(inquiry),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  final CoachInquiry inquiry;
  final Future<UserProfile?> profileFuture;
  final String dateLabel;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _InquiryCard({
    required this.inquiry,
    required this.profileFuture,
    required this.dateLabel,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final declined = inquiry.status == 'declined';
    final accepted = inquiry.status == 'accepted';
    return Opacity(
      opacity: declined ? 0.6 : 1.0,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<UserProfile?>(
                future: profileFuture,
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  final name = (profile?.displayName.isNotEmpty == true)
                      ? profile!.displayName
                      : inquiry.userId.isEmpty
                      ? 'Athlete'
                      : 'Athlete ${inquiry.userId.substring(0, inquiry.userId.length.clamp(0, 6))}';
                  final email = profile?.email.isNotEmpty == true
                      ? profile!.email
                      : inquiry.userEmail;
                  return Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xffe7eff6),
                        child: Icon(Icons.person, color: navy),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            if (email.isNotEmpty)
                              Text(
                                email,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _StatusChip(status: inquiry.status),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(
                inquiry.targetGoal.isEmpty
                    ? 'Discovery call'
                    : inquiry.targetGoal,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              if (inquiry.message.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  inquiry.message,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (dateLabel.isNotEmpty) _InfoChip('Preferred: $dateLabel'),
                  if (inquiry.package.isNotEmpty)
                    _InfoChip('Package: ${inquiry.package}'),
                ],
              ),
              if (!accepted && !declined) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: lime,
                          foregroundColor: navy,
                        ),
                        onPressed: busy ? null : onAccept,
                        icon: busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check, size: 18),
                        label: Text(
                          busy ? 'Working…' : 'Accept',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : onDecline,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Decline'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color = status == 'accepted'
        ? Colors.green
        : status == 'declined'
        ? muted
        : orange;
    return Chip(
      label: Text(
        status.isEmpty ? 'pending' : status,
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

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      backgroundColor: bg,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/user/coach_request.dart';
import '../../models/user/user_profile.dart';
import '../../services/social/chat_service.dart';
import '../../services/social/coach_dashboard_service.dart';
import '../../services/social/coach_request_service.dart';
import '../../services/user_service.dart';
import '../../widgets/common/role_gate.dart';
import '../social/chat_screen.dart';

/// Coach-only inbox of pending athlete match requests.
///
/// Streams [CoachRequestService.watchPending]; Accept writes
/// `matched` + a `coach_athletes` assignment doc then opens chat.
/// Decline is a client-side label only — nothing is written to Firestore.
class CoachRequestsInboxScreen extends StatefulWidget {
  const CoachRequestsInboxScreen({super.key});

  @override
  State<CoachRequestsInboxScreen> createState() =>
      _CoachRequestsInboxScreenState();
}

class _CoachRequestsInboxScreenState extends State<CoachRequestsInboxScreen> {
  final CoachRequestService _requestService = CoachRequestService();
  final CoachDashboardService _dashboardService = CoachDashboardService();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  /// Local-only declined ids (never persisted).
  final Set<String> _declined = {};
  final Set<String> _busy = {};
  final Map<String, Future<UserProfile?>> _profileFutures = {};

  Future<UserProfile?> _athleteProfile(CoachRequest request) {
    return _profileFutures.putIfAbsent(
      request.id,
      () => _userService.get(request.userId),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _accept(CoachRequest request) async {
    final coach = FirebaseAuth.instance.currentUser;
    if (coach == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in as a coach to accept.')),
        );
      }
      return;
    }
    if (_busy.contains(request.id)) return;
    setState(() => _busy.add(request.id));
    try {
      await _requestService.matchCoach(request.id, coach.uid);

      UserProfile? profile;
      try {
        profile = await _userService.get(request.userId);
      } catch (_) {
        profile = null;
      }
      final athleteName =
          (profile?.displayName.isNotEmpty == true)
              ? profile!.displayName
              : 'Athlete';
      final athleteEmail = profile?.email ?? '';

      await _dashboardService.assignAthlete(
        athleteId: request.userId,
        athleteName: athleteName,
        athleteEmail: athleteEmail,
        primarySport: request.sport,
        experienceLevel: request.experience,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$athleteName assigned. Opening chat…')),
      );

      if (request.userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment saved — chat opens from the dashboard'),
            ),
          );
        }
        return;
      }
      try {
        final roomId = await _chatService.getOrCreateChatRoom(
          athleteId: request.userId,
          coachId: coach.uid,
          athleteName: athleteName,
          coachName: coach.displayName ?? 'Coach',
        );
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    ChatScreen(chatRoomId: roomId, otherUserName: athleteName),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to accept: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(request.id));
    }
  }

  void _declineLocal(String requestId) {
    setState(() => _declined.add(requestId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach requests'),
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
                'Only coaches can review match requests.',
                style: TextStyle(color: muted, fontSize: 14),
              ),
            ],
          ),
        ),
        child: StreamBuilder<List<CoachRequest>>(
          stream: _requestService.watchPending(),
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
                    Text('Could not load requests.'),
                  ],
                ),
              );
            }
            final requests = snapshot.data ?? [];
            if (requests.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No pending requests. New athlete questionnaires will appear here.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final request = requests[index];
                final declined = _declined.contains(request.id);
                final busy = _busy.contains(request.id);
                return _RequestCard(
                  request: request,
                  profileFuture: _athleteProfile(request),
                  requestedLabel: _formatDate(request.createdAt),
                  declined: declined,
                  busy: busy,
                  onAccept: () => _accept(request),
                  onDecline: () => _declineLocal(request.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final CoachRequest request;
  final Future<UserProfile?> profileFuture;
  final String requestedLabel;
  final bool declined;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.request,
    required this.profileFuture,
    required this.requestedLabel,
    required this.declined,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<UserProfile?>(
              future: profileFuture,
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final name =
                    (profile?.displayName.isNotEmpty == true)
                        ? profile!.displayName
                        : 'Athlete ${request.userId.isEmpty ? '—' : request.userId.substring(0, request.userId.length.clamp(0, 6))}';
                final email = profile?.email ?? '';
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
                    if (declined)
                      const Chip(
                        label: Text(
                          'Declined',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: muted,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(request.sport),
                _InfoChip(request.experience),
                _InfoChip(request.goal),
              ],
            ),
            if (request.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(request.notes, style: const TextStyle(fontSize: 13)),
            ],
            const SizedBox(height: 8),
            Text(
              'Requested $requestedLabel',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
            if (!declined) ...[
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
                      icon:
                          busy
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.check, size: 18),
                      label: Text(
                        busy ? 'Accepting…' : 'Accept',
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
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
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

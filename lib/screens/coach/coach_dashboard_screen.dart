import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../../services/social/coach_dashboard_service.dart';
import '../../services/social/chat_service.dart';
import '../../widgets/common/role_gate.dart';
import '../social/chat_inbox_screen.dart';
import '../social/chat_screen.dart';
import 'coach_inquiries_inbox_screen.dart';
import 'coach_match_screen.dart';
import 'coach_requests_inbox_screen.dart';

/// Coach dashboard screen showing assigned athletes and management tools.
class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final CoachDashboardService _dashboardService = CoachDashboardService();
  final ChatService _chatService = ChatService();
  String _filter = 'all';

  List<AssignedAthlete> _applyFilter(List<AssignedAthlete> athletes) {
    if (_filter == 'all') return athletes;
    return athletes.where((a) => a.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'MY ATHLETES',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 14,
          ),
        ),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Coach requests',
            icon: const Icon(Icons.inbox_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CoachRequestsInboxScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Call inquiries',
            icon: const Icon(Icons.call_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CoachInquiriesInboxScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Messages',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatInboxScreen()),
            ),
          ),
        ],
      ),
      body: CoachOnly(
        fallback: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: muted),
              const SizedBox(height: 12),
              Text(
                'Coach access required',
                style: TextStyle(
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : navy),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Only coaches can view assigned athletes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 14),
              ),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'active', label: Text('Active')),
                  ButtonSegment(value: 'paused', label: Text('Paused')),
                ],
                selected: {_filter},
                onSelectionChanged: (selection) =>
                    setState(() => _filter = selection.first),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<AssignedAthlete>>(
                stream: _dashboardService.watchAssignedAthletes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: orange,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Error loading athletes',
                            style: TextStyle(
                              color:
                                  (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF78909C)
                                  : muted),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final athletes = snapshot.data ?? [];

                  if (athletes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF78909C)
                                : muted),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No athletes yet',
                            style: TextStyle(
                              color:
                                  (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : navy),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No athletes yet — share your coach profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF78909C)
                                  : muted),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CoachMatchScreen(),
                              ),
                            ),
                            child: const Text('Find athletes'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filtered = _applyFilter(athletes);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No athletes under ${_filter == 'all' ? 'this filter' : _filter}.',
                        style: const TextStyle(color: muted),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final athlete = filtered[index];
                      return _AthleteCard(
                        athlete: athlete,
                        summaryFuture: _dashboardService.getAthleteSummary(
                          athlete.id,
                        ),
                        onTap: () => _openChat(context, athlete),
                        onStatusToggle: (status) =>
                            _toggleStatus(athlete.id, status),
                        onRemove: () => _confirmRemove(athlete),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, AssignedAthlete athlete) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final chatRoomId = await _chatService.getOrCreateChatRoom(
        athleteId: athlete.id,
        coachId: user.uid,
        athleteName: athlete.displayName,
        coachName: user.displayName ?? 'Coach',
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatRoomId: chatRoomId,
              otherUserName: athlete.displayName,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
      }
    }
  }

  void _toggleStatus(String athleteId, String status) async {
    try {
      await _dashboardService.updateAthleteStatus(athleteId, status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  Future<void> _confirmRemove(AssignedAthlete athlete) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove athlete?'),
        content: Text(
          'Remove ${athlete.displayName} from your roster? They will be marked as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _dashboardService.removeAthlete(athlete.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${athlete.displayName} removed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove: $e')));
      }
    }
  }
}

class _AthleteCard extends StatelessWidget {
  final AssignedAthlete athlete;
  final Future<AthleteTrainingSummary> summaryFuture;
  final VoidCallback onTap;
  final ValueChanged<String> onStatusToggle;
  final VoidCallback onRemove;

  const _AthleteCard({
    required this.athlete,
    required this.summaryFuture,
    required this.onTap,
    required this.onStatusToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xffe7eff6),
                    backgroundImage: athlete.photoUrl != null
                        ? NetworkImage(athlete.photoUrl!)
                        : null,
                    onBackgroundImageError: athlete.photoUrl != null
                        ? (_, __) {}
                        : null,
                    child: athlete.photoUrl == null
                        ? Icon(
                            Icons.person,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : navy),
                            size: 24,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          athlete.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : navy),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (athlete.primarySport.isNotEmpty)
                              athlete.primarySport,
                            if (athlete.experienceLevel.isNotEmpty)
                              athlete.experienceLevel,
                            if (athlete.status.isNotEmpty) athlete.status,
                          ].join(' • '),
                          style: TextStyle(
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF78909C)
                                : muted),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF78909C)
                          : muted),
                    ),
                    onSelected: (value) {
                      if (value == 'remove') {
                        onRemove();
                      } else {
                        onStatusToggle(value);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'active', child: Text('Set Active')),
                      PopupMenuItem(value: 'paused', child: Text('Pause')),
                      PopupMenuItem(
                        value: 'completed',
                        child: Text('Complete'),
                      ),
                      PopupMenuItem(value: 'remove', child: Text('Remove')),
                    ],
                  ),
                ],
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'Training summary',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                children: [
                  FutureBuilder<AthleteTrainingSummary>(
                    future: summaryFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final summary = snapshot.data;
                      if (snapshot.hasError || summary == null) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Summary unavailable.',
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _SummaryChip('${summary.weeklyWorkouts} workouts'),
                            _SummaryChip(
                              '${summary.weeklyTss.toStringAsFixed(0)} TSS',
                            ),
                            _SummaryChip(summary.weeklyDuration),
                            _SummaryChip(
                              'Fitness ${summary.fitness.toStringAsFixed(0)}',
                            ),
                            _SummaryChip(
                              'Fatigue ${summary.fatigue.toStringAsFixed(0)}',
                            ),
                            _SummaryChip(
                              'Form ${summary.form.toStringAsFixed(0)}',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  const _SummaryChip(this.label);

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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../services/coach_dashboard_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

/// Coach dashboard screen showing assigned athletes and management tools.
class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final CoachDashboardService _dashboardService = CoachDashboardService();
  final ChatService _chatService = ChatService();

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
      ),
      body: StreamBuilder<List<AssignedAthlete>>(
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
                  const Icon(Icons.error_outline, size: 48, color: orange),
                  const SizedBox(height: 12),
                  Text(
                    'Error loading athletes',
                    style: TextStyle(color: muted, fontSize: 16),
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
                  Icon(Icons.people_outline, size: 64, color: muted),
                  const SizedBox(height: 16),
                  Text(
                    'No athletes yet',
                    style: TextStyle(
                      color: navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Athletes who sign up with your\ncoach code will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: athletes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final athlete = athletes[index];
              return _AthleteCard(
                athlete: athlete,
                onTap: () => _openChat(context, athlete),
                onStatusToggle: (status) => _toggleStatus(athlete.id, status),
              );
            },
          );
        },
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
            builder:
                (_) => ChatScreen(
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
}

class _AthleteCard extends StatelessWidget {
  final AssignedAthlete athlete;
  final VoidCallback onTap;
  final ValueChanged<String> onStatusToggle;

  const _AthleteCard({
    required this.athlete,
    required this.onTap,
    required this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xffe7eff6),
                backgroundImage:
                    athlete.photoUrl != null
                        ? NetworkImage(athlete.photoUrl!)
                        : null,
                child:
                    athlete.photoUrl == null
                        ? const Icon(Icons.person, color: navy, size: 24)
                        : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (athlete.primarySport.isNotEmpty)
                          athlete.primarySport,
                        if (athlete.experienceLevel.isNotEmpty)
                          athlete.experienceLevel,
                      ].join(' \u2022 '),
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: muted),
                onSelected: onStatusToggle,
                itemBuilder:
                    (_) => [
                      const PopupMenuItem(
                        value: 'active',
                        child: Text('Set Active'),
                      ),
                      const PopupMenuItem(
                        value: 'paused',
                        child: Text('Pause'),
                      ),
                      const PopupMenuItem(
                        value: 'completed',
                        child: Text('Complete'),
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

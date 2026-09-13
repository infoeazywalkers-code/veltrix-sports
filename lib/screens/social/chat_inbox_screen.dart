import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/social/chat_service.dart';
import 'chat_screen.dart';

/// Minimal chat inbox: streams the current user's rooms via
/// [ChatService.watchChatRooms] and pushes [ChatScreen] per room.
/// No new chat logic — thin navigation wrapper only.
class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: navy,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: muted),
              const SizedBox(height: 12),
              const Text(
                'Sign in to view your messages.',
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
    final chatService = ChatService();
    final uid = user.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: chatService.watchChatRooms(uid),
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
                  Text('Could not load your messages.'),
                ],
              ),
            );
          }
          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No conversations yet. Accept a request or book a coach to start chatting.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final isAthlete = room.athleteId == uid;
              final otherName = isAthlete ? room.coachName : room.athleteName;
              final preview =
                  room.lastMessage.isEmpty ? 'Say hello 👋' : room.lastMessage;
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xffe7eff6),
                    child: Icon(Icons.person, color: navy),
                  ),
                  title: Text(
                    otherName.isEmpty ? 'Conversation' : otherName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                chatRoomId: room.id,
                                otherUserName:
                                    otherName.isEmpty
                                        ? 'Conversation'
                                        : otherName,
                              ),
                        ),
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

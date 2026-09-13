import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Represents a single message within a chat room.
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final bool read;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.read = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
    'read': read,
  };
}

/// Represents a chat room between an athlete and a coach.
class ChatRoom {
  final String id;
  final String athleteId;
  final String coachId;
  final String athleteName;
  final String coachName;
  final String lastMessage;
  final DateTime lastMessageAt;

  const ChatRoom({
    required this.id,
    required this.athleteId,
    required this.coachId,
    required this.athleteName,
    required this.coachName,
    this.lastMessage = '',
    required this.lastMessageAt,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatRoom(
      id: doc.id,
      athleteId: data['athleteId'] as String? ?? '',
      coachId: data['coachId'] as String? ?? '',
      athleteName: data['athleteName'] as String? ?? '',
      coachName: data['coachName'] as String? ?? '',
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt:
          (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'athleteId': athleteId,
    'coachId': coachId,
    'athleteName': athleteName,
    'coachName': coachName,
    'lastMessage': lastMessage,
    'lastMessageAt': Timestamp.fromDate(lastMessageAt),
  };
}

/// Real-time Firestore messaging service for coach-athlete communication.
class ChatService {
  final FirebaseFirestore _db;

  ChatService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  /// Creates or returns an existing chat room between athlete and coach.
  Future<String> getOrCreateChatRoom({
    required String athleteId,
    required String coachId,
    required String athleteName,
    required String coachName,
  }) async {
    try {
      // Check if a chat room already exists between these two users
      final existing =
          await _db
              .collection('chat_rooms')
              .where('athleteId', isEqualTo: athleteId)
              .where('coachId', isEqualTo: coachId)
              .limit(1)
              .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }

      // Create new chat room
      final docRef = await _db.collection('chat_rooms').add({
        'athleteId': athleteId,
        'coachId': coachId,
        'athleteName': athleteName,
        'coachName': coachName,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }

  /// Sends a message to a chat room.
  Future<void> sendMessage({
    required String chatRoomId,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final messageRef =
          _db
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .doc();

      await messageRef.set({
        'senderId': user.uid,
        'senderName': user.displayName ?? 'Athlete',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Update the chat room's last message metadata
      await _db.collection('chat_rooms').doc(chatRoomId).update({
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Streams messages for a chat room, ordered by creation time.
  Stream<List<ChatMessage>> watchMessages(String chatRoomId) {
    return _db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromFirestore).toList())
        .handleError((e) {
          throw Exception('Failed to watch messages: $e');
        });
  }

  /// Streams chat rooms for a user (either as athlete or coach).
  Stream<List<ChatRoom>> watchChatRooms(String userId) {
    return _db
        .collection('chat_rooms')
        .where('athleteId', isEqualTo: userId)
        .snapshots()
        .asyncExpand((athleteSnap) {
          return _db
              .collection('chat_rooms')
              .where('coachId', isEqualTo: userId)
              .snapshots()
              .map((coachSnap) {
                final rooms = <String, ChatRoom>{};
                for (final doc in athleteSnap.docs) {
                  final room = ChatRoom.fromFirestore(doc);
                  rooms[room.id] = room;
                }
                for (final doc in coachSnap.docs) {
                  final room = ChatRoom.fromFirestore(doc);
                  rooms[room.id] = room;
                }
                final sortedRooms =
                    rooms.values.toList()..sort(
                      (a, b) => b.lastMessageAt.compareTo(a.lastMessageAt),
                    );
                return sortedRooms;
              });
        })
        .handleError((e) {
          throw Exception('Failed to watch chat rooms: $e');
        });
  }

  /// Marks all unread messages in a chat room as read for the current user.
  Future<void> markAsRead(String chatRoomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final unreadMessages =
          await _db
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .where('read', isEqualTo: false)
              .where('senderId', isNotEqualTo: user.uid)
              .get();

      final batch = _db.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      // Silently fail — non-critical operation
    }
  }
}

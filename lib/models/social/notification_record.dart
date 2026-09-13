import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRecord {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? payload;
  final DateTime createdAt;
  final bool read;

  const NotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    required this.createdAt,
    this.read = false,
  });

  factory NotificationRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];
    return NotificationRecord(
      id: doc.id,
      title: data['title'] as String? ?? 'Veltrix update',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      payload: data['payload'] as String?,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'body': body,
    'type': type,
    'payload': payload,
    'createdAt': Timestamp.fromDate(createdAt),
    'read': read,
  };
}

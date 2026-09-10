import 'package:cloud_firestore/cloud_firestore.dart';

class SportsEvent {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String category;
  final String description;
  final int capacity;
  final int registeredCount;

  const SportsEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    required this.description,
    this.capacity = 0,
    this.registeredCount = 0,
  });

  factory SportsEvent.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final date = data['date'];
    return SportsEvent(
      id: doc.id,
      title: data['title'] as String? ?? 'Veltrix event',
      date: date is Timestamp ? date.toDate() : DateTime.now(),
      location: data['location'] as String? ?? 'Global',
      category: data['category'] as String? ?? 'Endurance',
      description: data['description'] as String? ?? '',
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      registeredCount: (data['registeredCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class EventTicket {
  final String id;
  final String eventId;
  final String eventTitle;
  final String userId;
  final String status;
  final String qrPayload;
  final DateTime createdAt;

  const EventTicket({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.status,
    required this.qrPayload,
    required this.createdAt,
  });

  factory EventTicket.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];
    return EventTicket(
      id: doc.id,
      eventId: data['eventId'] as String? ?? '',
      eventTitle: data['eventTitle'] as String? ?? 'Veltrix event',
      userId: data['userId'] as String? ?? '',
      status: data['status'] as String? ?? 'confirmed',
      qrPayload: data['qrPayload'] as String? ?? doc.id,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}

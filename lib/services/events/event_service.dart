import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../models/events/event_ticket.dart';

class EventService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  EventService({FirebaseFirestore? db, FirebaseAuth? auth, FirebaseFunctions? functions})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  String get _userId => _auth.currentUser?.uid ?? (throw StateError('Sign in to register for events.'));

  Stream<List<SportsEvent>> watchUpcomingEvents() => _db
      .collection('events')
      .where('date', isGreaterThan: Timestamp.now())
      .orderBy('date')
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(SportsEvent.fromFirestore).toList());

  Stream<List<EventTicket>> watchMyTickets() => _db
      .collection('tickets')
      .where('userId', isEqualTo: _userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(EventTicket.fromFirestore).toList());

  Future<EventTicket> register(SportsEvent event) async {
    final result = await _functions.httpsCallable('registerForEvent').call({'eventId': event.id});
    final data = Map<String, dynamic>.from(result.data as Map);
    return EventTicket(
      id: data['id'] as String,
      eventId: event.id,
      eventTitle: event.title,
      userId: _userId,
      status: data['status'] as String? ?? 'confirmed',
      qrPayload: data['qrPayload'] as String,
      createdAt: DateTime.now(),
    );
  }
}

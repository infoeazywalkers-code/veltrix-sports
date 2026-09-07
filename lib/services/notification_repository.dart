import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_record.dart';

class NotificationRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  NotificationRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? (throw StateError('Sign in to view notifications.'));

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('users').doc(_userId).collection('notifications');

  Stream<List<NotificationRecord>> watch() => _notifications
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(NotificationRecord.fromFirestore).toList());

  Future<void> saveToken(String token, {required String platform}) async {
    await _db.collection('users').doc(_userId).collection('devices').doc(token).set({
      'token': token,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> add(NotificationRecord notification) async {
    await _notifications.doc(notification.id).set(notification.toMap(), SetOptions(merge: true));
  }

  Future<void> markRead(String id) => _notifications.doc(id).update({'read': true});
}

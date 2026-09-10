import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/analytics_service.dart';

class DeviceService {
  static const String _prefix = 'device_status_';
  static const String _lastSyncPrefix = 'device_sync_';

  static String sanitizeDeviceId(String deviceName) {
    var id = deviceName.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    id = id.replaceAll(RegExp(r'^_+|_+$'), '');
    if (id.isEmpty) return 'device';
    if (id.length > 120) id = id.substring(0, 120);
    return id;
  }

  static Future<bool> isConnected(String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$deviceName') ?? false;
  }

  static Future<void> setConnected(
    String deviceName,
    String category,
    bool connected,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$deviceName', connected);
    if (connected) {
      await prefs.setString(
        '$_lastSyncPrefix$deviceName',
        DateTime.now().toIso8601String(),
      );
      await AnalyticsService.logDevicePaired(deviceName, category);
    }
    // Firestore mirror (offline-safe; local prefs remain source of truth).
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('devices')
            .doc(sanitizeDeviceId(deviceName))
            .set({
              'name': deviceName,
              'category': category,
              'connected': connected,
              'lastSync': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DeviceService Firestore Mirror Error] $e');
    }
  }

  static Stream<bool> watchConnected(String deviceName, String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(sanitizeDeviceId(deviceName))
        .snapshots()
        .map((snap) => (snap.data()?['connected'] == true));
  }

  static Future<String> getLastSync(String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_lastSyncPrefix$deviceName');
    if (raw == null) return 'Never';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'Never';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static Future<void> forceSync(String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_lastSyncPrefix$deviceName',
      DateTime.now().toIso8601String(),
    );
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('devices')
            .doc(sanitizeDeviceId(deviceName))
            .set({
              'lastSync': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DeviceService forceSync Mirror Error] $e');
    }
  }
}

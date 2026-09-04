import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1. Request FCM Push Permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        debugPrint('[FCM Notification Status] Authorization: ${settings.authorizationStatus}');
      }

      // 2. Fetch FCM Device Token
      if (!kIsWeb) {
        _fcmToken = await _fcm.getToken();
        if (kDebugMode) {
          debugPrint('[FCM Device Token] $_fcmToken');
        }
      }

      // 3. Initialize Local Notifications Plugin
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _localNotifications.initialize(initSettings);

      // 4. Foreground FCM Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showNotification(
            title: message.notification?.title ?? 'Veltrix Update',
            body: message.notification?.body ?? 'You have a new activity update.',
          );
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[Notification Init Error] $e');
    }
  }

  Future<void> showNotification({required String title, required String body}) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'veltrix_channel',
        'Veltrix Notifications',
        channelDescription: 'Workout reminders and coach alerts',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Local Notification Error] $e');
    }
  }

  Future<void> scheduleWorkoutReminder(String workoutTitle, DateTime reminderTime) async {
    final now = DateTime.now();
    if (reminderTime.isBefore(now)) return;

    final delay = reminderTime.difference(now);
    Future.delayed(delay, () {
      showNotification(
        title: '🏋️ Time for Workout: $workoutTitle',
        body: 'Your scheduled Veltrix workout starts now. Let’s crush your targets!',
      );
    });
  }
}

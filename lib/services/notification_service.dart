import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'notification_repository.dart';
import '../models/notification_record.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationRepository _repository = NotificationRepository();

  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Initialize timezone database for OS-level scheduling
      tz_data.initializeTimeZones();

      // 1. Request FCM Push Permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        debugPrint(
          '[FCM Notification Status] Authorization: ${settings.authorizationStatus}',
        );
      }

      // 2. Fetch FCM Device Token
      if (!kIsWeb) {
        _fcmToken = await _fcm.getToken();
        if (_fcmToken != null) {
          await _repository.saveToken(_fcmToken!, platform: 'mobile');
        }
        if (kDebugMode) {
          debugPrint('[FCM Device Token] $_fcmToken');
        }
      }

      // 3. Initialize Local Notifications Plugin
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // 4. Request exact alarm permission on Android 13+
      await _requestExactAlarmPermission();

      // 5. Foreground FCM Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          final notification = message.notification!;
          _persistNotification(
            title: notification.title ?? 'Veltrix Update',
            body: notification.body ?? 'You have a new activity update.',
            payload: message.data['route'] as String?,
          );
          showNotification(
            title: notification.title ?? 'Veltrix Update',
            body: notification.body ?? 'You have a new activity update.',
          );
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[Notification Init Error] $e');
    }
  }

  Future<void> _persistNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _repository.add(
        NotificationRecord(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title,
          body: body,
          type: 'push',
          payload: payload,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Notification Persistence Error] $e');
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    if (kIsWeb) return;
    try {
      final androidPlugin =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Notification Permission Request] $e');
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('[Notification Tapped] payload: ${response.payload}');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'veltrix_channel',
        'Veltrix Notifications',
        channelDescription: 'Workout reminders and coach alerts',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

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

  /// Schedules a workout reminder using OS-level scheduling via [zonedSchedule].
  /// This notification persists across app restarts and device reboots.
  Future<void> scheduleWorkoutReminder(
    String workoutTitle,
    DateTime reminderTime,
  ) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

      if (scheduledDate.isBefore(now)) return;

      const androidDetails = AndroidNotificationDetails(
        'veltrix_workout_reminders',
        'Workout Reminders',
        channelDescription: 'Scheduled workout reminders',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use zonedSchedule for OS-level persistence.
      // The notification survives app kills and reboots.
      await _localNotifications.zonedSchedule(
        workoutTitle.hashCode,
        'Time for Workout: $workoutTitle',
        'Your scheduled Veltrix workout starts now. Let\'s crush your targets!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      if (kDebugMode) {
        debugPrint(
          '[Notification] Scheduled reminder for "$workoutTitle" at $scheduledDate',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Notification Schedule Error] $e');
      }
    }
  }

  /// Cancels a previously scheduled workout reminder by [workoutTitle].
  Future<void> cancelWorkoutReminder(String workoutTitle) async {
    await _localNotifications.cancel(workoutTitle.hashCode);
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:hive_flutter/hive_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Request permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;

    // Schedule daily reminder if enabled
    final box = Hive.box('chakkar_prefs');
    final enabled = box.get('daily_reminder_enabled', defaultValue: true);
    if (enabled) {
      await scheduleDailyReminder();
    }
  }

  Future<void> scheduleDailyReminder({int hour = 18, int minute = 0}) async {
    await _plugin.cancel(100); // cancel existing daily reminder if any

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      100,
      'Daily Challenge Awaits!',
      'Complete today\'s brain challenge and earn coins before it resets!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Challenge Reminders',
          channelDescription: 'Reminds you to complete your daily challenge',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(100);
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    final box = Hive.box('chakkar_prefs');
    await box.put('daily_reminder_enabled', enabled);
    if (enabled) {
      await scheduleDailyReminder();
    } else {
      await cancelDailyReminder();
    }
  }

  bool get isDailyReminderEnabled {
    try {
      return Hive.box(
        'chakkar_prefs',
      ).get('daily_reminder_enabled', defaultValue: true);
    } catch (e) {
      return true;
    }
  }

  // Show an instant local notification (used for foreground FCM messages too)
  Future<void> showInstant({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notifications',
          'App Notifications',
          channelDescription: 'Friend requests, room invites, and more',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}

final notificationService = NotificationService();

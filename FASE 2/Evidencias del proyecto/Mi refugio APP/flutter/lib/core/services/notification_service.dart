import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin _notifications =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Note: iOS settings would go here if needed
    const initSettings = fln.InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'daily_reminders',
          'Recordatorios Diarios',
          channelDescription: 'Canal para recordatorios diarios de bienestar',
          importance: fln.Importance.high,
          priority: fln.Priority.high,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     fln.UILocalNotificationDateInterpretation.absoluteTime,
      // matchDateTimeComponents: fln.DateTimeComponents.time,
    );
  }

  Future<void> scheduleIntervalNotification({
    required int id,
    required String title,
    required String body,
    required int intervalMinutes,
  }) async {
     await _notifications.periodicallyShow(
      id,
      title,
      body,
      fln.RepeatInterval.everyMinute, // Placeholder, actual interval logic might need zonedSchedule for custom intervals
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'interval_reminders',
          'Recordatorios de Intervalo',
          channelDescription: 'Canal para recordatorios frecuentes',
          importance: fln.Importance.defaultImportance,
          priority: fln.Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
  
  // Helper for daily scheduling
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

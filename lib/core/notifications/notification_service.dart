import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around flutter_local_notifications for the single daily
/// "log your meals" reminder configurable in Configuración → Notificaciones.
/// Purely local/on-device, scheduled by the OS — no push server, consistent
/// with the app's Local First architecture.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _reminderId = 1001;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
    } catch (_) {
      // Falls back to the timezone package's default (UTC) if the
      // platform's zone name isn't recognized — the reminder still fires
      // daily, just anchored to UTC wall-clock time instead of the
      // device's local time.
    }
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _initialized = true;
  }

  /// Prompts the OS notification permission (iOS shows the system dialog;
  /// Android 13+ requires it too, older Android grants it implicitly).
  /// Returns whether the app is allowed to notify.
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return (iosGranted ?? true) && (androidGranted ?? true);
  }

  Future<void> scheduleDailyReminder(
    TimeOfDay time, {
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();
    await _plugin.zonedSchedule(
      _reminderId,
      title,
      body,
      _nextInstanceOf(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_meal_reminder',
          'Recordatorio diario',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder() async {
    await _ensureInitialized();
    await _plugin.cancel(_reminderId);
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmProvider extends ChangeNotifier {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<DateTime> _alarms = [];

  List<DateTime> get alarms => _alarms;

  AlarmProvider() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Add alarm method
  void addAlarm(DateTime dateTime) {
    _alarms.add(dateTime);
    _scheduleAlarm(dateTime);
    notifyListeners();
  }

  // Remove alarm method
  void removeAlarm(DateTime dateTime) {
    _alarms.remove(dateTime);
    cancelNotification(dateTime); // Cancel the notification when removing alarm
    notifyListeners();
  }

  // Schedule alarm notification
  void _scheduleAlarm(DateTime dateTime) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alarm_notif_channel', // channel ID
      'Alarm notifications', // channel name
      // channel description
      importance: Importance.high,
      priority: Priority.high,
      playSound: true, // Play a sound
      sound: RawResourceAndroidNotificationSound(
          'your_sound'), // Custom sound file
      enableVibration: true, // Vibrate the phone
      // Custom vibration pattern
      timeoutAfter:
          5000, // Cancel the notification after a timeout (milliseconds)
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Alarm', // Notification title
      'It\'s time!', // Notification body
      tz.TZDateTime.from(
          dateTime, tz.local), // Scheduled date time in local timezone
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel a scheduled notification
  Future<void> cancelNotification(DateTime dateTime) async {
    int notificationId = dateTime.millisecondsSinceEpoch ~/ 1000;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}

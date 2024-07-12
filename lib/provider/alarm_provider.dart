import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../database/alarm_database.dart';

class AlarmProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<DateTime> _alarms = [];
  List<int> _alarmIds = [];
  List<bool> _alarmEnabled = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<DateTime> get alarms => _alarms;
  List<bool> get alarmEnabled => _alarmEnabled;

  AlarmProvider() {
    _initializeNotifications();
    tz.initializeTimeZones();
    _loadAlarmsFromDatabase();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadAlarmsFromDatabase() async {
    final alarms = await _dbHelper.getAlarms();
    for (var alarm in alarms) {
      _alarms.add(DateTime.parse(alarm['dateTime']));
      _alarmIds.add(alarm['id']);
      _alarmEnabled.add(alarm['enabled'] == 1);
    }
    notifyListeners();
  }

  Future<void> addAlarm(DateTime dateTime) async {
    _alarms.add(dateTime);
    int alarmId = _scheduleAlarm(dateTime);
    _alarmIds.add(alarmId);
    _alarmEnabled.add(true);
    await _dbHelper.insertAlarm({
      'id': alarmId,
      'dateTime': dateTime.toIso8601String(),
      'enabled': 1,
    });
    notifyListeners();
  }

  Future<void> removeAlarm(DateTime dateTime) async {
    int alarmIndex = _alarms.indexOf(dateTime);
    if (alarmIndex != -1) {
      int alarmId = _alarmIds[alarmIndex];
      _alarms.removeAt(alarmIndex);
      _alarmIds.removeAt(alarmIndex);
      _alarmEnabled.removeAt(alarmIndex);
      Alarm.stop(alarmId);
      cancelNotification(alarmId);
      await _dbHelper.deleteAlarm(alarmId);
      notifyListeners();
    }
  }

  int _scheduleAlarm(DateTime dateTime) {
    int alarmId = dateTime.hashCode;

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: dateTime,
      assetAudioPath: 'assets/Tic-Tac-Mechanical-Alarm-Clock-2-chosic.com_.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      notificationTitle: 'Alarm',
      notificationBody: 'Your alarm is ringing!',
    );

    Alarm.set(alarmSettings: alarmSettings);

    _scheduleNotification(alarmId, dateTime);

    return alarmId;
  }

  void _scheduleNotification(int alarmId, DateTime dateTime) {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      '',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.zonedSchedule(
      alarmId,
      'Alarm',
      'Your alarm is ringing!',
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> toggleAlarmEnabled(int index, bool enabled) async {
    int alarmId = _alarmIds[index];
    _alarmEnabled[index] = enabled;
    if (enabled) {
      _scheduleAlarm(_alarms[index]);
    } else {
      Alarm.stop(alarmId);
      cancelNotification(alarmId);
    }
    await _dbHelper.updateAlarm(alarmId, {
      'dateTime': _alarms[index].toIso8601String(),
      'enabled': enabled ? 1 : 0,
    });
    notifyListeners();
  }

  void stopAlarm(int alarmId) {
    Alarm.stop(alarmId);
    cancelNotification(alarmId);
  }

  void stopAllAlarms() {
    for (int alarmId in _alarmIds) {
      Alarm.stop(alarmId);
      cancelNotification(alarmId);
    }
    _alarms.clear();
    _alarmIds.clear();
    _alarmEnabled.clear();
    notifyListeners();
  }

  Future<void> cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/alarm_provider.dart';

class AlarmScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: alarmProvider.alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarmProvider.alarms[index];
                // Format date for display
                String formattedTime = DateFormat('HH:mm').format(alarm);
                return ListTile(
                  title: Text(formattedTime),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      alarmProvider.removeAlarm(alarm);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                // Show date picker
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  // Show time picker
                  TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (timeOfDay != null) {
                    // Combine date and time into a single DateTime object
                    final dateTime = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      timeOfDay.hour,
                      timeOfDay.minute,
                    );
                    // alarmProvider.addAlarm(dateTime);

                    final alarmSettings = AlarmSettings(
                      id: 42,
                      dateTime: dateTime,
                      assetAudioPath:
                          'assets/Tic-Tac-Mechanical-Alarm-Clock-2-chosic.com_.mp3',
                      loopAudio: true,
                      vibrate: true,
                      volume: 0.8,
                      fadeDuration: 3.0,
                      notificationTitle: 'This is the title',
                      notificationBody: 'This is the body',
                    );
                    await Alarm.set(alarmSettings: alarmSettings);
                  }
                }
              },
              child: Text('Add Alarm'),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Alarm.stop(42);
              },
              child: Text('stop'))
        ],
      ),
    );
  }
}

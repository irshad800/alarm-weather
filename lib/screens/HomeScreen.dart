import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/weatherController.dart';
import '../model/WeatherDataa.dart';
import '../provider/alarm_provider.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  double? _lat;
  double? _longt;
  late Future<WeatherDataa> _weatherDataFuture;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      var position = await getlocation(context: context);
      setState(() {
        _lat = position.latitude;
        _longt = position.longitude;
        _weatherDataFuture = WeatherS(lat: _lat, longt: _longt);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<WeatherDataa>(
                future: _weatherDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    var weatherData = snapshot.data;
                    return SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      '${snapshot.data!.name}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Stack(
                                    children: [
                                      Text(
                                        '${((snapshot.data!.main?.temp)! - 273.15).toStringAsFixed(0)}°c',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 50,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    '${snapshot.data?.weather?[0].main.toString()}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: Consumer<AlarmProvider>(
                                builder: (context, alarmProvider, _) =>
                                    ListView.builder(
                                  itemCount: alarmProvider.alarms.length,
                                  itemBuilder: (context, index) {
                                    final alarm = alarmProvider.alarms[index];
                                    final enabled =
                                        alarmProvider.alarmEnabled[index];
                                    String formattedTime =
                                        DateFormat('HH:mm').format(alarm);

                                    return Card(
                                      color: Colors.white.withOpacity(0.8),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child: ListTile(
                                        title: Text(
                                          formattedTime,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: Switch(
                                          value: enabled,
                                          onChanged: (bool value) {
                                            alarmProvider.toggleAlarmEnabled(
                                                index, value);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              radius: 30,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );

                                  if (pickedTime != null) {
                                    DateTime now = DateTime.now();
                                    DateTime pickedDateTime = DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                    alarmProvider.addAlarm(pickedDateTime);
                                  }
                                },
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red.withOpacity(0.8),
                              textStyle: const TextStyle(fontSize: 18),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                            ),
                            onPressed: () {
                              alarmProvider.stopAllAlarms();
                            },
                            child: const Text('Stop All Alarms'),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  Future<WeatherDataa>? _weatherDataFuture;

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
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            "Alarm",
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              _getCurrentLocation();
            },
          ),
        ],
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _weatherDataFuture != null
                ? Expanded(
                    child: FutureBuilder<WeatherDataa>(
                      future: _weatherDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          var weatherData = snapshot.data;
                          return SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: screenWidth * 0.08,
                                          ),
                                          Text(
                                            '${snapshot.data!.name}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth * 0.06,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: screenWidth * 0.04),
                                        child: Stack(
                                          children: [
                                            Text(
                                              '${((snapshot.data!.main?.temp)! - 273.15).toStringAsFixed(0)}°c',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth * 0.13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: screenWidth * 0.04),
                                        child: Text(
                                          '${snapshot.data?.weather?[0].main.toString()}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.06,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                  )
                : SizedBox.shrink(),
            Expanded(
              child: Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(screenWidth * 0.05),
                  ),
                ),
                child: Consumer<AlarmProvider>(
                  builder: (context, alarmProvider, _) => ListView.builder(
                    itemCount: alarmProvider.alarms.length,
                    itemBuilder: (context, index) {
                      final alarm = alarmProvider.alarms[index];
                      final enabled = alarmProvider.alarmEnabled[index];
                      String formattedTime = DateFormat('HH:mm').format(alarm);

                      return Card(
                        color: Colors.white.withOpacity(0.8),
                        margin: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01,
                          horizontal: screenWidth * 0.04,
                        ),
                        child: ListTile(
                          title: Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Switch(
                            value: enabled,
                            onChanged: (bool value) {
                              alarmProvider.toggleAlarmEnabled(index, value);
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
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                radius: screenWidth * 0.08,
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.black,
                    size: screenWidth * 0.08,
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
                textStyle: TextStyle(fontSize: screenWidth * 0.05),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.06,
                ),
              ),
              onPressed: () {
                alarmProvider.stopAllAlarms();
              },
              child: Text('Stop All Alarms'),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}

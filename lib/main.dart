import 'package:alarm/alarm.dart';
import 'package:alrmwhther/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/alarm_provider.dart';
import 'provider/weather_provider.dart'; // Import the WeatherProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AlarmProvider()),
        ChangeNotifierProvider(
            create: (context) => WeatherProvider()), // Add WeatherProvider
      ],
      child: MaterialApp(
        title: 'Flutter Alarm App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey,
              title: const Text("Weather Alarm Clock"),
              centerTitle: true,
              bottom: const TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 8.0),
                tabs: [
                  Tab(
                    icon: Icon(Icons.access_alarm, size: 20),
                    child: Text(
                      "Alarm",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.access_time, size: 20),
                    child: Text(
                      "Clock",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.av_timer, size: 20),
                    child: Text(
                      "Stopwatch",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.timer_rounded, size: 20),
                    child: Text(
                      "Countdown Timer",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const TabBarView(
                children: [
                  AlarmScreen(),
                  Center(child: Text('Clock Page')),
                  Center(child: Text('Stopwatch Page')),
                  Center(child: Text('Countdown Timer Page')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

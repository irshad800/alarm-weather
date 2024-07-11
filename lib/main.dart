import 'package:alarm/alarm.dart';
import 'package:alrmwhther/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/alarm_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AlarmProvider(),
      child: MaterialApp(
        title: 'Flutter Alarm App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    AlarmScreen(),
    Center(child: Text('Clock Page')),
    Center(child: Text('Stopwatch Page')),
    Center(child: Text('Countdown Timer Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm),
            label: 'Alarm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Clock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.av_timer),
            label: 'Stopwatch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_rounded),
            label: 'Countdown Timer',
          ),
        ],
      ),
    );
  }
}

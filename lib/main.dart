import 'package:alarm/alarm.dart';
import 'package:alrmwhther/screens/alarmScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/alarm_provider.dart'; // Adjust path based on your project structure

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
        home: AlarmScreen(),
      ),
    );
  }
}

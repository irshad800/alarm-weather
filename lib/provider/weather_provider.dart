import 'package:flutter/material.dart';

import '../controller/weatherController.dart';
import '../model/WeatherDataa.dart';

class WeatherProvider with ChangeNotifier {
  WeatherDataa? _weatherData;
  double? _lat;
  double? _long;

  WeatherDataa? get weatherData => _weatherData;

  void fetchWeather(double? lat, double? long) async {
    try {
      _lat = lat;
      _long = long;
      _weatherData = await WeatherS(lat: lat, longt: long);
      notifyListeners();
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../../../data/models/weather_model.dart';

// class WeatherProvider with ChangeNotifier {
//   WeatherModel? _weather;
//   bool _hasError = false;

//   WeatherModel? get weather => _weather;
//   bool get hasError => _hasError;

//   Future<void> loadWeather(String city) async {
//     print('Fetching weather for $city');
//     try {
//       _hasError = false;
//       final result = await http.get(Uri.parse(
//           'https://api.weatherapi.com/v1/current.json?key=d65958e6aa1c651ad3e8ec42a98e795a=$city'));

//       print('Response: ${result.body}');
//       if (result.statusCode == 200) {
//         final data = jsonDecode(result.body);
//         _weather = WeatherModel.fromJson(data);
//       } else {
//         _hasError = true;
//         _weather = null;
//         print('Failed to load weather: ${result.statusCode}');
//       }
//     } catch (e) {
//       _hasError = true;
//       _weather = null;
//       print('Error loading weather: $e');
//     }
//     notifyListeners();
//   }
// }

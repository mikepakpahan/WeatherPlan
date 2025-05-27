import 'package:weather/weather.dart';
import 'dart:convert';
import '../constants/api_keys.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final WeatherFactory _weatherFactory = WeatherFactory(OPENWEATHER_API_KEY);
  final String apiKey = 'd65958e6aa1c651ad3e8ec42a98e795a';

  Future<Weather> fetchWeather(String city) async {
    return await _weatherFactory.currentWeatherByCityName(city);
  }

  Future<List<dynamic>> fetchHourlyForecast(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
    print('3-hour forecast URL: $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['list']; // 'list' berisi array forecast 3 jam sekali
    } else {
      print('3-hour forecast error: ${response.body}');
      throw Exception('Failed to load 3-hour forecast');
    }
  }
}

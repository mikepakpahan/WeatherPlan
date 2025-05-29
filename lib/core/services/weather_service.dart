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

  Future<Map<String, dynamic>?> getForecastForTime({
    required double lat,
    required double lon,
    required DateTime targetTime,
  }) async {
    final forecastList = await fetchHourlyForecast(lat, lon);
    Map<String, dynamic>? closestForecast;
    Duration? closestDiff;

    for (var forecast in forecastList) {
      final forecastTime = DateTime.parse(forecast['dt_txt']);
      final diff = forecastTime.difference(targetTime).abs();
      if (closestDiff == null || diff < closestDiff) {
        closestDiff = diff;
        closestForecast = forecast;
      }
    }

    return closestForecast;
  }

  Future<bool> isWeatherSuitableForOutdoorActivity(
    double lat,
    double lon,
    DateTime activityTime,
  ) async {
    final forecast = await getForecastForTime(
      lat: lat,
      lon: lon,
      targetTime: activityTime,
    );
    if (forecast == null) return false;

    final weather = forecast['weather'][0]['main'];
    final hasRain = forecast.containsKey('rain') && forecast['rain'] != null;

    // Misal: kita anggap aktivitas luar cocok hanya jika cuaca cerah dan tidak hujan
    return weather == 'Clear' && !hasRain;
  }
}

import 'package:weather/weather.dart';

class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final DateTime date;
  final double lat;
  final double lon;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.date,
    required this.lat,
    required this.lon,
  });

  factory WeatherModel.fromWeather(Weather w) {
    return WeatherModel(
      cityName: w.areaName ?? 'Unknown',
      temperature: w.temperature?.celsius ?? 0.0,
      description: w.weatherDescription ?? '',
      iconCode: w.weatherIcon ?? '01d',
      humidity: (w.humidity ?? 0).toInt(),
      windSpeed: w.windSpeed ?? 0.0,
      date: w.date ?? DateTime.now(),
      lat: w.latitude ?? 0.0,
      lon: w.longitude ?? 0.0,
    );
  }
}

class HourlyForecastModel {
  final int dt;
  final double temp;
  final String icon;

  HourlyForecastModel({
    required this.dt,
    required this.temp,
    required this.icon,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlyForecastModel(
      dt: json['dt'],
      temp: (json['main']['temp'] as num).toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }
}

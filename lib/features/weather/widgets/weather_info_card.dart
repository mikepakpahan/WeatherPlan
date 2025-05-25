import 'package:flutter/material.dart';
import '../../../../data/models/weather_model.dart';
// import 'package:intl/intl.dart';

class WeatherInfoCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherInfoCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(weather.cityName,
            style:
                const TextStyle(fontSize: 50, color: Colors.white, height: 1)),
        // const SizedBox(height: 0),
        Text(
          "${weather.temperature.toStringAsFixed(0)}°",
          style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 90,
              height: 1),
        ),
        // const SizedBox(height: 0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weather.description,
                style: const TextStyle(
                    color: Color.fromRGBO(200, 200, 200, 1),
                    fontSize: 20,
                    fontFamily: 'SfProDisplay')),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10), // Bisa dikurangi juga jika ingin
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Humidity: ${weather.humidity}%",
                  style: const TextStyle(color: Colors.white)),
              Text("Wind: ${weather.windSpeed} m/s",
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 6), // Bisa dihapus atau kecilkan nilainya
        Transform.translate(
          offset: const Offset(
              0, -90), // Geser gambar ke atas, atur sesuai kebutuhan
          child: Image.network(
            "http://openweathermap.org/img/wn/${weather.iconCode}@4x.png",
            height: 300, // Gambar lebih besar
          ),
        ),
      ],
    );
  }
}

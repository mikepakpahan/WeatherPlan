import 'package:flutter/material.dart';
import 'package:weather_plan/core/services/weather_service.dart';
import 'package:weather_plan/data/models/weather_model.dart';
import 'package:weather_plan/core/constants/app_constants.dart';
import 'package:weather_plan/features/weather/widgets/weather_info_card.dart';
import 'dart:ui';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:weather_plan/features/weather/widgets/hourly_forecast_card.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _weather;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  List<HourlyForecastModel> _hourlyForecast = [];

  Future<void> _loadWeather() async {
    try {
      final rawWeather = await _weatherService.fetchWeather(DEFAULT_CITY);
      setState(() {
        _weather = WeatherModel.fromWeather(rawWeather);
      });

      // Ambil lat dan lon dari rawWeather atau _weather
      final lat = _weather!.lat;
      final lon = _weather!.lon;
      final hourlyData = await _weatherService.fetchHourlyForecast(lat, lon);
      setState(() {
        _hourlyForecast =
            hourlyData
                .take(6) // misal ambil 6 jam ke depan
                .map<HourlyForecastModel>(
                  (json) => HourlyForecastModel.fromJson(json),
                )
                .toList();
      });
    } catch (e) {
      print("Gagal mengambil data cuaca: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // WeatherInfoCard tetap di atas
          if (_weather == null)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: WeatherInfoCard(weather: _weather!),
              ),
            ),
          // Expanding Bottom Sheet di bawah
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.30,
            maxChildSize: 0.77,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(35),
                      ),
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero, // Hindari padding default
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            margin: const EdgeInsets.only(top: 15, bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'Hourly Forecast',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 130,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _hourlyForecast.length,
                            itemBuilder: (context, index) {
                              final forecast = _hourlyForecast[index];
                              final time = DateTime.fromMillisecondsSinceEpoch(
                                forecast.dt * 1000,
                              );
                              return HourlyForecastCard(
                                time: DateFormat.Hm().format(time),
                                icon:
                                    "http://openweathermap.org/img/wn/${forecast.icon}@2x.png",
                                temperature: forecast.temp.round().toString(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Tambahan konten lainnya bisa masuk sini...
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        index: 1,
        items: <Widget>[
          Icon(Icons.list, size: 30),
          Icon(Icons.home, size: 40),
          Icon(Icons.compare_arrows, size: 30),
        ],
        onTap: (index) {
          //Handle button tap
        },
      ),
    );
  }
}

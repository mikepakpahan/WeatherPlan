import 'package:flutter/material.dart';
import 'package:weather_plan/core/services/weather_service.dart';
import 'package:weather_plan/data/models/weather_model.dart';
import 'package:weather_plan/core/constants/app_constants.dart';
import 'package:weather_plan/features/weather/widgets/weather_info_card.dart';
import 'dart:ui';
import 'package:weather_plan/features/weather/widgets/hourly_forecast_card.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:another_flushbar/flushbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  WeatherModel? _weather;
  bool _isJemuranTerbuka = false;
  List<HourlyForecastModel> _hourlyForecast = [];

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _listenJemuranStatus();
  }

  void _listenJemuranStatus() {
    _dbRef.child('jemuran_status').onValue.listen((event) {
      final status = event.snapshot.value;
      setState(() {
        _isJemuranTerbuka = status == 'buka';
      });
    });
  }

  Future<void> _loadWeather() async {
    try {
      final rawWeather = await _weatherService.fetchWeather(DEFAULT_CITY);
      setState(() {
        _weather = WeatherModel.fromWeather(rawWeather);
      });

      final lat = _weather!.lat;
      final lon = _weather!.lon;
      final hourlyData = await _weatherService.fetchHourlyForecast(lat, lon);
      setState(() {
        _hourlyForecast =
            hourlyData
                .take(6)
                .map<HourlyForecastModel>(
                  (json) => HourlyForecastModel.fromJson(json),
                )
                .toList();
      });
    } catch (e) {
      print("Gagal mengambil data cuaca: $e");
    }
  }

  Future<void> _toggleJemuran() async {
    final newStatus = _isJemuranTerbuka ? "tutup" : "buka";
    try {
      await _dbRef.child('jemuran_status').set(newStatus);
      Flushbar(
        message: "Jemuran ${newStatus == 'buka' ? 'dibuka' : 'ditutup'}!",
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.deepPurple,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
        icon: Icon(
          newStatus == 'buka' ? Icons.wb_sunny : Icons.close,
          color: Colors.white,
        ),
      ).show(context);
    } catch (e) {
      print("Gagal mengubah status jemuran: $e");
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
          // Weather info
          if (_weather == null)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: WeatherInfoCard(weather: _weather!),
              ),
            ),
          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.30,
            maxChildSize: 0.48,
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
                      padding: EdgeInsets.zero,
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

                        const SizedBox(height: 10),
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
                          height: 170,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _hourlyForecast.length + 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // Card untuk jam sebelumnya
                                final prevForecast =
                                    _hourlyForecast.isNotEmpty
                                        ? _hourlyForecast.first
                                        : null;
                                if (prevForecast == null)
                                  return SizedBox.shrink();
                                final prevTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                      prevForecast.dt * 1000,
                                    ).subtract(const Duration(hours: 3));
                                return HourlyForecastCard(
                                  time: DateFormat.Hm().format(prevTime),
                                  icon:
                                      "http://openweathermap.org/img/wn/${prevForecast.icon}@2x.png",
                                  temperature:
                                      prevForecast.temp.round().toString(),
                                );
                              }
                              if (index == 1) {
                                // Card untuk "Now"
                                return HourlyForecastCard(
                                  time: "Now",
                                  icon:
                                      "http://openweathermap.org/img/wn/${_weather?.iconCode ?? '01d'}@2x.png",
                                  temperature:
                                      _weather?.temperature
                                          .round()
                                          .toString() ??
                                      "-",
                                  isNow: true,
                                );
                              }
                              // Sisanya: forecast ke depan
                              final forecast = _hourlyForecast[index - 2];
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 70,
        ), // Naikkan FAB agar tidak ketutup nav bar
        child: FloatingActionButton(
          onPressed: _toggleJemuran,
          backgroundColor: Colors.white,
          child: Icon(_isJemuranTerbuka ? Icons.close : Icons.wb_sunny),
          tooltip: _isJemuranTerbuka ? 'Tutup Jemuran' : 'Buka Jemuran',
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HourlyForecastCard extends StatelessWidget {
  final String time;
  final String icon;
  final String temperature;
  final String? precipitation; // opsional

  const HourlyForecastCard({
    super.key,
    required this.time,
    required this.icon,
    required this.temperature,
    this.precipitation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), // semi transparan
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(time, style: const TextStyle(color: Colors.white)),
          Image.network(
            icon,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
          ),
          Text('$temperature°', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

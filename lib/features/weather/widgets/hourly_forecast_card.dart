import 'dart:ui';
import 'package:flutter/material.dart';

class HourlyForecastCard extends StatelessWidget {
  final String time;
  final String icon;
  final String temperature;
  final String? precipitation;
  final bool isNow;

  const HourlyForecastCard({
    super.key,
    required this.time,
    required this.icon,
    required this.temperature,
    this.precipitation,
    this.isNow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: 70,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isNow ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(70),
        boxShadow:
            isNow
                ? [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.25),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ]
                : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
              fontSize: isNow ? 18 : 16,
            ),
          ),
          Image.network(
            icon,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
          ),
          Text(
            '$temperature°',
            style: TextStyle(
              color: Colors.white,
              fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
              fontSize: isNow ? 18 : 16,
            ),
          ),
        ],
      ),
    );

    // Tambahkan efek blur hanya untuk "Now"
    if (isNow) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: cardContent,
        ),
      );
    } else {
      return cardContent;
    }
  }
}

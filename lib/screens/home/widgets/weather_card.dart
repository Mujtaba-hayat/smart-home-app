import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container (
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),

      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: const [
              Text("Living Room",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              ),

              SizedBox(height: 10),

              Text(
                "29°C",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 5),

              Text(
                "Humidity 58%",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),

      const Icon(
        Icons.cloud,
        size: 70,
        color: Colors.white,
      ),
        ],
      ),
    );
  }
}

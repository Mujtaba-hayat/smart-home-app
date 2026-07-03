import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PumpCard extends StatelessWidget {
  final bool isRunning;
  final int selectedMinutes;
  final ValueChanged<int?> onDurationChanged;

  final String remainingTime;

  final VoidCallback onStart;
  final VoidCallback onStop;


  const PumpCard({
    super.key,
    required this.isRunning,
    required this.selectedMinutes,
    required this.onDurationChanged,
    required this.onStart,
    required this.onStop,
    required this.remainingTime,
});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // Pump Icon
          Center(
            child: Icon(
              Icons.water_drop,
              size: 55,
              color: Colors.blue,
            ),
          ),

          const SizedBox(height: 15),

          // Title
          const Center(
            child: Text(
              "Water Pump",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Status
          Row(
            children: [

              const Text(
                "Status",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                isRunning ? "RUNNING" : "OFF",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                  isRunning ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Center(

            child: Column(

              children: [

                const Text(

                  "Remaining Time",

                  style: TextStyle(

                    fontWeight: FontWeight.bold,

                  ),

                ),

                const SizedBox(height: 8),

                Text(

                  remainingTime,

                  style: const TextStyle(

                    fontSize: 32,

                    fontWeight: FontWeight.bold,

                    color: Colors.blue,

                  ),

                ),

              ],

            ),

          ),

          const SizedBox(height: 20),

          const SizedBox(height: 20),

          const Text(
            "Duration",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey.shade400,
              ),
            ),

            child: DropdownButton<int>(
              value: selectedMinutes,

              isExpanded: true,

              underline: const SizedBox(),

              items: const [

                DropdownMenuItem(
                  value: 5,
                  child: Text("5 Minutes"),
                ),

                DropdownMenuItem(
                  value: 10,
                  child: Text("10 Minutes"),
                ),

                DropdownMenuItem(
                  value: 15,
                  child: Text("15 Minutes"),
                ),

                DropdownMenuItem(
                  value: 20,
                  child: Text("20 Minutes"),
                ),

                DropdownMenuItem(
                  value: 30,
                  child: Text("30 Minutes"),
                ),
              ],

              onChanged: onDurationChanged,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,

            height: 50,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isRunning ? Colors.red : AppColors.primary,

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),

              onPressed:
              isRunning ? onStop : onStart,

              child: Text(
                isRunning
                    ? "STOP PUMP"
                    : "START PUMP",

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
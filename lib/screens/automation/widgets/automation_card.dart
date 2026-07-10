import 'package:flutter/material.dart';

class AutomationCard extends StatelessWidget {
  final String deviceName;
  final String time;
  final bool turnOn;
  final String repeatDays;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const AutomationCard({
    super.key,
    required this.deviceName,
    required this.time,
    required this.turnOn,
    required this.repeatDays,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card (
      margin: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: ListTile(

        leading: const Icon(
          Icons.schedule,
          size: 32,
        ),

        title: Text(
          deviceName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 6),

            Text("Time: $time"),

            Text(
              turnOn
              ? "Action: Turn ON"
                  : "Action OFF",

            ),

            Text("Repeat: $repeatDays"),
          ],
        ),

        trailing: Switch(
          value: enabled,

          onChanged: onToggle,
        ),
      ),
    );
  }
}

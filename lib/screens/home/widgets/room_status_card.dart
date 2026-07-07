import 'package:flutter/material.dart';

class RoomStatusCard extends StatelessWidget {
  final String roomName;
  final int activeDevices;
  final int totalDevices;

  const RoomStatusCard({
    super.key,
    required this.roomName,
    required this.activeDevices,
    required this.totalDevices,
  });
  IconData getRoomIcon(String roomName) {
    switch (roomName){
      case "Living Room":
        return Icons.weekend;

      case "Bedroom":
        return Icons.bed;

      case "Kitchen":
        return Icons.kitchen;

      case "Entrance":
        return Icons.door_front_door;

      case "Security":
        return Icons.security;

      case "Water System":
        return Icons.water_drop;

      default:
        return Icons.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsetsGeometry.all(16),

        child: Row(
          children: [

            Icon(
             getRoomIcon(roomName),
              size: 32,
              color: Colors.blue,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                      roomName,
                    style: const TextStyle(
                      fontSize:  18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "$activeDevices / $totalDevices Active Devices",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/room_card.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final rooms =[
      {
        "name": "Living Room",
        "devices": 5,
        "active": 3,
        "icon": Icons.weekend,
      },

      {
        "name": "Bedroom",
        "devices": 4,
        "active": 2,
        "icon": Icons.bed,
      },

      {
        "name": "Kitchen",
        "devices": 6,
        "active": 4,
        "icon": Icons.kitchen,
      },

      {
        "name": "Garage",
        "devices": 3,
        "active": 1,
        "icon": Icons.garage,
      },

      {
        "name": "Office",
        "devices": 7,
        "active": 5,
        "icon": Icons.computer,
      },

      {
        "name": "Bathroom",
        "devices": 2,
        "active": 1,
        "icon": Icons.bathtub,
      },

    ];
    return Scaffold(
      appBar: AppBar(
        title:  Text("Rooms"),
      ),

      body: Padding(
        padding: const EdgeInsetsGeometry.all(20),

        child: GridView.builder(
          itemCount: rooms.length,

          gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,

              crossAxisSpacing: 16,
              mainAxisSpacing: 16,

              childAspectRatio: 0.85,
            ),

          itemBuilder: (context, index){
            final room = rooms[index];

            return RoomCard(
                roomName: room["name"] as String,
                devices: room["devices"] as int,
                activeDevice: room["active"] as int,
                icon: room["icon"] as IconData,
            );
          },
        ),
      ),
    );
  }
}

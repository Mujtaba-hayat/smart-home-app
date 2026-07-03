import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/device_provider.dart';
import '../../data/room_data.dart';

import '../room_details/room_details_screen.dart';

import 'widgets/room_card.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final deviceProvider =
    Provider.of<DeviceProvider>(context);

    // Remove Water System room from the list
    final displayRooms = roomList
        .where((room) => room.name != "Water System")
        .toList();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Rooms"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: GridView.builder(

          itemCount: displayRooms.length,

          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(

            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,

          ),

          itemBuilder: (context, index) {

            final room = displayRooms[index];

            return RoomCard(
              roomName: room.name,
              devices: deviceProvider.getDeviceCount(room.name),
              activeDevice: deviceProvider.getActiveDeviceCount(room.name),
              icon: room.icon,

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomDetailsScreen(
                      room: room,
                    ),
                  ),
                );
              },
            );

          },

        ),

      ),

    );

  }

}
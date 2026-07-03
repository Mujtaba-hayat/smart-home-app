import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/room_model.dart';
import '../../providers/device_provider.dart';
import '../home/widgets/device_card.dart';

import '../device_details/device_details_screen.dart';

class RoomDetailsScreen extends StatelessWidget {
  final RoomModel room;

  const RoomDetailsScreen({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeviceProvider>(context);

    final roomDevices =
    provider.getDevicesByRoom(room.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(room.name),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: GridView.builder(
          itemCount: roomDevices.length,

          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,

            crossAxisSpacing: 15,
            mainAxisSpacing: 15,

            childAspectRatio: 0.75,
          ),

          itemBuilder: (context, index) {

            final device = roomDevices[index];

            return DeviceCard(
              deviceName: device.name,
              icon: _getIcon(device.iconName),
              isOn: device.isOn,

              onToggle: () {
                provider.toggleDevice(device);
              },

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeviceDetailsScreen(
                      device: device,
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

  IconData _getIcon(String iconName) {

    switch (iconName) {

      case "lightbulb":
        return Icons.lightbulb;

      case "fan":
        return Icons.air;

      case "pump":
        return Icons.water_drop;

      case "alarm":
        return Icons.security;

      default:
        return Icons.devices;
    }
  }
}
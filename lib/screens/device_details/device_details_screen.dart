import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/device_model.dart';
import '../../providers/device_provider.dart';

import '../add_device/add_device_screen.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final DeviceModel device;

  const DeviceDetailsScreen({
    super.key,
    required this.device,
  });

  IconData getIcon(String iconName){
    switch (iconName) {
      case "lightbulb":
        return Icons.lightbulb;

      case "fan":
        return Icons.air;

      case "alarm":
        return Icons.security;

      case "pump":
        return Icons.water_drop;

      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeviceProvider>(context);

    final currentDevice =
        provider.devices.firstWhere((d) => d.id == device.id);

    return Scaffold(
      appBar: AppBar(
       title: Text(currentDevice.name),

        actions: [

          IconButton(

            icon: Icon(
              currentDevice.isFavorite
                  ? Icons.star
                  : Icons.star_border,
            ),

            onPressed: () {
              provider.toggleFavorite(currentDevice);


            },

          ),

        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Center(
              child: Icon(
                getIcon(currentDevice.iconName),
                size: 90,
                color: Colors.amber,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Device ID",
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            Text(
              currentDevice.id,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

    Text(
    "Room",
    style: TextStyle(
    color: Colors.grey.shade700,
    ),
    ),

    Text(
    currentDevice.room,
    style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    ),
    ),

    const SizedBox(height: 20),

    Text(
    "Status",
    style: TextStyle(
    color: Colors.grey.shade700,
    ),
    ),

    Row(
    children: [

    Text(
    currentDevice.isOn ? "ON" : "OFF",
    style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: currentDevice.isOn
    ? Colors.green
        : Colors.red,
    ),
    ),

      const Spacer(),

      Switch(
        value: currentDevice.isOn,
        onChanged: (_) {
          provider.toggleDevice(currentDevice);
        },
      )
    ],
    ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            const Text(
              "Device Information",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.memory),
              title: const Text("Type"),
              subtitle: Text(currentDevice.type.name),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Room"),
              subtitle: Text(currentDevice.room),
            ),

            ListTile(
              leading: const Icon(Icons.tag),
              title: const Text("Device Name"),
              subtitle: Text(currentDevice.name),
            ),
            const SizedBox(height: 30),


            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                label: const Text("DELETE DEVICE",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),),
                onPressed: () async {

                  final shouldDelete = await showDialog<bool>(

                    context: context,

                    builder: (context) {

                      return AlertDialog(

                        title: const Text("Delete Device"),

                        content: Text(
                          "Are you sure you want to delete '${currentDevice.name}'?",
                        ),

                        actions: [

                          TextButton(

                            onPressed: () {

                              Navigator.pop(context, false);

                            },

                            child: const Text("Cancel"),

                          ),

                          ElevatedButton(

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),

                            onPressed: () {

                              Navigator.pop(context, true);

                            },

                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.white),
                            ),

                          ),

                        ],

                      );

                    },

                  );

                  if (shouldDelete == true) {

                    provider.deleteDevice(currentDevice.id);

                    Navigator.pop(context);

                  }

                },
              ),
            )
    ],
        ),
      ),
      ),
    );
  }
}

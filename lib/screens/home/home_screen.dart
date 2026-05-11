import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

import 'widgets/greeting_section.dart';
import 'widgets/weather_card.dart';
import 'widgets/status_card.dart';
import 'widgets/device_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: ( ){},
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const GreetingSection(),

              const SizedBox(height: 25),

              const WeatherCard(),

              const SizedBox(height: 25),

              Row(
                children: const [
                  StatusCard(
                      title: "Online",
                      value: "8",
                      icon: Icons.wifi,
                  ),

                  StatusCard(
                    title: "Active",
                    value: "5",
                    icon: Icons.flash_on,
                  ),

                ],
              ),

              Row(
                children: const [
                  StatusCard(
                    title: "Energy",
                    value: "12kwh",
                    icon: Icons.bolt,
                  ),

                  StatusCard(
                    title: "Security",
                    value: "Safe",
                    icon: Icons.security,
                  ),

                ],
              ),

              const SizedBox(height: 25),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85,

                children: const [
                  DeviceCard(
                      deviceName: "Living Light",
                      icon: Icons.lightbulb,
                      isOn: true
                  ),

                  DeviceCard(
                    deviceName: "Fan",
                    icon: Icons.air,
                    isOn: true,
                  ),

                  DeviceCard(
                    deviceName: "Television",
                    icon: Icons.tv,
                    isOn: true,
                  ),

                  DeviceCard(
                    deviceName: "AC Inverter",
                    icon: Icons.ac_unit,
                    isOn: true,
                  ),

                  DeviceCard(
                    deviceName: "Gallery Light",
                    icon: Icons.lightbulb,
                    isOn: false,
                  ),

                  DeviceCard(
                    deviceName: "Room1 Fan",
                    icon: Icons.air,
                    isOn: false,
                  ),

                  DeviceCard(
                    deviceName: "Main Gate",
                    icon: Icons.sensor_door_outlined,
                    isOn: true,
                  ),

                  DeviceCard(
                    deviceName: "Water Pump",
                    icon: Icons.heat_pump_sharp,
                    isOn: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


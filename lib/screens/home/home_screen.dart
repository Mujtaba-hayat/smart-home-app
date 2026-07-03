import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/device_provider.dart';

import 'widgets/greeting_section.dart';
import 'widgets/weather_card.dart';
import 'widgets/status_card.dart';
import 'widgets/device_card.dart';
import 'widgets/pump_card.dart';

import 'widgets/search_bar_widget.dart';
import 'widgets/filter_chips.dart';

import '../device_details/device_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = Provider.of<DeviceProvider>(
        context,
        listen: false,
      );

      await provider.fetchDevices();

      await provider.fetchPumpStatus();

      provider.startPumpPolling();
    });
  }

  @override
  void dispose() {
    Provider.of<DeviceProvider>(
      context,
      listen: false,
    ).stopPumpPolling();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final deviceProvider =
    Provider.of<DeviceProvider>(context);

    final displayDevices = deviceProvider.devices
        .where((device) => device.id != "R8")
        .toList();

    return Scaffold(

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
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

                children: [

                  StatusCard(
                    title: "Online",
                    value: deviceProvider.onlineDevices.toString(),
                    icon: Icons.wifi,
                  ),

                  StatusCard(
                    title: "Active",
                    value: deviceProvider.activeDevices.toString(),
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

              PumpCard(

                isRunning: deviceProvider.pumpRunning,

                selectedMinutes:
                deviceProvider.selectedPumpMinutes,

                remainingTime:
                deviceProvider.formattedRemainingTime,

                onDurationChanged: (value) {

                  if (value != null) {

                    deviceProvider.changePumpDuration(value);

                  }

                },

                onStart: () {

                  deviceProvider.startPump();

                },

                onStop: () {

                  deviceProvider.stopPump();

                },

              ),

              const SizedBox(height: 25),


              SearchBarWidget(

                onChanged: (value) {

                  deviceProvider.updateSearch(value);

                },

              ),

              const SizedBox(height: 15),

              FilterChips(

                selected: deviceProvider.selectedFilter,

                onSelected: (type) {

                  deviceProvider.updateFilter(type);

                },

              ),



              const SizedBox(height: 25),

              GridView.builder(

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: deviceProvider.filteredDevices.length,

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(

                  crossAxisCount: 2,

                  crossAxisSpacing: 15,

                  mainAxisSpacing: 15,

                  childAspectRatio: 0.72,

                ),

                itemBuilder: (context, index) {

                  final device = deviceProvider.filteredDevices[index];

                  return DeviceCard(

                    deviceName: device.name,

                    icon: _getIcon(device.iconName),

                    isOn: device.isOn,

                    onToggle: () {

                      deviceProvider.toggleDevice(device);

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

            ],

          ),

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
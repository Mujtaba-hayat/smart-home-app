import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/device_provider.dart';

import 'widgets/power_usage_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeviceProvider>(context);

    final highest = provider.highestPowerDevice;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Energy Analytics"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
        
          child: Column(
            children: [
        
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
        
                  child: Column(
                    children: [
        
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 50,
                      ),
        
                      const SizedBox(height: 10),
        
                      const Text(
                        "Highest Consumer",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
        
                      const SizedBox(height: 15),
        
                      Text(
                        highest.name,
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
        
                      Text(
                        "${highest.power} W",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        
              const SizedBox(height: 20),

        
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
        
                      const Text(
                        "Estimated Usage",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
        
                      const SizedBox(height: 20),
        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
        
                          Column(
                            children: [
        
                              const Icon(
                                Icons.bolt,
                                color: Colors.amber,
                                size: 35,
                              ),
        
                              const SizedBox(height: 10),
        
                              Text(
                                "${provider.estimateHourlyEnergy.toStringAsFixed(2)} kWh",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
        
                              const Text("Per Hour"),
        
                            ],
                          ),
        
                          Column(
                            children: [
                              const Icon(
                                Icons.currency_rupee,
                                color: Colors.green,
                                size: 35,
                              ),
        
                              const SizedBox(height: 10),
        
                              Text(
                                "Rs. ${provider.estimatedHourlyCost.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
        
                              const Text("Estimated Cost"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        
        
        
              const SizedBox(height: 20),
        
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
        
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
        
                    children: [
                      const Text(
                        "Top Power Devices",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
        
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.topPowerDevices.length,
                        itemBuilder: (context, index){
        
                          final device = provider.topPowerDevices[index];
        
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text("${index + 1}"),
                            ),
        
                            title: Text(
                              device.name
                            ),
        
                            trailing: Text(
                              "${device.power} W",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      )
        
                    ],
                  )
                ),
              ),

              const SizedBox(height: 30),
              const PowerUsageChart(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

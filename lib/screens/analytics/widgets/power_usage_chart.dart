import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../providers/device_provider.dart';

class PowerUsageChart extends StatelessWidget {
  const PowerUsageChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeviceProvider>(context);
    debugPrint("Living: ${provider.getRoomPower("Living Room")}");
    debugPrint("Bedroom: ${provider.getRoomPower("Bedroom")}");
    debugPrint("Kitchen: ${provider.getRoomPower("Kitchen")}");
    debugPrint("Security: ${provider.getRoomPower("Security")}");
    debugPrint("Water: ${provider.getRoomPower("Water System")}");

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Text(
              "Power Usage by Room",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,

              child: BarChart(
                BarChartData(
                  maxY: 600,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),

                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text("LR");
                            case 1:
                              return const Text("BR");
                            case 2:
                              return const Text("KIT");
                            case 3:
                              return const Text("SEC");
                            case 4:
                              return const Text("WS");
                            default:
                              return const Text("");
                          }
                        },
                      ),
                    ),
                  ),

                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: provider.getRoomPower("Living Room"),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),

                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: provider.getRoomPower("Bedroom"),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),

                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: provider.getRoomPower("Kitchen"),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),

                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: provider.getRoomPower("Security"),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),

                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: provider.getRoomPower("Water System"),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

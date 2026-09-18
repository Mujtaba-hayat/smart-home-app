import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/device_provider.dart';

import 'widgets/power_usage_chart.dart';

class AnalyticsScreen extends StatefulWidget {
const AnalyticsScreen({super.key});

@override
State<AnalyticsScreen> createState() =>
_AnalyticsScreenState();
}

class _AnalyticsScreenState
extends State<AnalyticsScreen> {

String _selectedPeriod = "Today";

@override
void initState() {
super.initState();

// -------------------------------------------------
// Load latest sensor data when Analytics opens
// -------------------------------------------------

WidgetsBinding.instance.addPostFrameCallback(
(_) {

final provider =
Provider.of<DeviceProvider>(
context,
listen: false,
);

provider.fetchSensorData();
},
);
}

// ===================================================
// REFRESH SENSOR DATA
// ===================================================

Future<void> _refreshSensorData() async {

final provider =
Provider.of<DeviceProvider>(
context,
listen: false,
);

await provider.fetchSensorData();
}

// ===================================================
// FORMAT SENSOR UPDATE TIME
// ===================================================

String _formatDateTime(
DateTime? dateTime,
) {

if (dateTime == null) {
return "No update time";
}

final local =
dateTime.toLocal();

final hour =
local.hour == 0
? 12
    : local.hour > 12
? local.hour - 12
    : local.hour;

final minute =
local.minute
    .toString()
    .padLeft(2, "0");

final period =
local.hour >= 12
? "PM"
    : "AM";

return "${local.day}/"
"${local.month}/"
"${local.year} "
"$hour:$minute $period";
}

// ===================================================
// DOOR STATUS TEXT
// ===================================================

String _doorStatusText(
DeviceProvider provider,
) {

if (provider.doorOpen) {
return "Currently Open";
}

if (provider.doorClosed) {
return "Currently Closed";
}

return "No door data available";
}

// ===================================================
// DOOR ICON
// ===================================================

IconData _doorIcon(
DeviceProvider provider,
) {

if (provider.doorOpen) {
return Icons.door_front_door;
}

if (provider.doorClosed) {
return Icons.lock;
}

return Icons.door_front_door_outlined;
}

// ===================================================
// DOOR COLOR
// ===================================================

Color _doorColor(
DeviceProvider provider,
) {

if (provider.doorOpen) {
return Colors.orange;
}

if (provider.doorClosed) {
return Colors.green;
}

return Colors.grey;
}

// ===================================================
// TEMPERATURE DISPLAY
// ===================================================

String _temperatureText(
DeviceProvider provider,
) {

final temperature =
provider.temperature;

if (temperature == null) {
return "-- °C";
}

return "${temperature.toStringAsFixed(1)} °C";
}

// ===================================================
// HUMIDITY DISPLAY
// ===================================================

String _humidityText(
DeviceProvider provider,
) {

final humidity =
provider.humidity;

if (humidity == null) {
return "-- %";
}

return "${humidity.toStringAsFixed(1)} %";
}

@override
Widget build(BuildContext context) {

final provider =
Provider.of<DeviceProvider>(
context,
);

final highest =
provider.highestPowerDevice;

return Scaffold(

// =================================================
// APP BAR
// =================================================

appBar: AppBar(
title: const Text(
"Energy Analytics",
),
),

// =================================================
// BODY
// =================================================

body: RefreshIndicator(

onRefresh:
_refreshSensorData,

child: SingleChildScrollView(

physics:
const AlwaysScrollableScrollPhysics(),

padding:
const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,

children: [

// =========================================
// ENERGY ANALYTICS
// =========================================

const Text(
"Energy Analytics",
style: TextStyle(
fontSize: 24,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 15,
),

// =========================================
// HIGHEST POWER CONSUMER
// =========================================

Card(
child: Padding(
padding:
const EdgeInsets.all(20),

child: Column(
children: [

const Icon(
Icons.local_fire_department,
color: Colors.orange,
size: 50,
),

const SizedBox(
height: 10,
),

const Text(
"Highest Consumer",
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 15,
),

Text(
highest.name,
style:
const TextStyle(
fontSize: 22,
),
),

Text(
"${highest.power} W",
style:
const TextStyle(
fontSize: 30,
fontWeight:
FontWeight.bold,
),
),
],
),
),
),

const SizedBox(
height: 20,
),

// =========================================
// ESTIMATED USAGE
// =========================================

Card(
child: Padding(
padding:
const EdgeInsets.all(20),

child: Column(
children: [

const Text(
"Estimated Usage",
style: TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 20,
),

Row(
mainAxisAlignment:
MainAxisAlignment.spaceAround,

children: [

// --------------------------------
// ENERGY
// --------------------------------

Column(
children: [

const Icon(
Icons.bolt,
color:
Colors.amber,
size: 35,
),

const SizedBox(
height: 10,
),

Text(
"${provider.estimateHourlyEnergy.toStringAsFixed(2)} kWh",
style:
const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),

const Text(
"Per Hour",
),
],
),

// --------------------------------
// COST
// --------------------------------

Column(
children: [

const Icon(
Icons.currency_rupee,
color:
Colors.green,
size: 35,
),

const SizedBox(
height: 10,
),

Text(
"Rs. ${provider.estimatedHourlyCost.toStringAsFixed(2)}",
style:
const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),

const Text(
"Estimated Cost",
),
],
),
],
),
],
),
),
),

const SizedBox(
height: 20,
),

// =========================================
// TOP POWER DEVICES
// =========================================

Card(
child: Padding(
padding:
const EdgeInsets.all(16),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

const Text(
"Top Power Devices",
style: TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 15,
),

if (provider
    .topPowerDevices
    .isEmpty)

const Padding(
padding:
EdgeInsets.all(15),

child: Center(
child: Text(
"No devices available",
style:
TextStyle(
color:
Colors.grey,
),
),
),
)

else

ListView.builder(

shrinkWrap:
true,

physics:
const NeverScrollableScrollPhysics(),

itemCount:
provider
    .topPowerDevices
    .length,

itemBuilder:
(context, index) {

final device =
provider
    .topPowerDevices[
index];

return ListTile(

leading:
CircleAvatar(
child:
Text(
"${index + 1}",
),
),

title:
Text(
device.name,
),

trailing:
Text(
"${device.power} W",
style:
const TextStyle(
fontWeight:
FontWeight.bold,
),
),
);
},
),
],
),
),
),

const SizedBox(
height: 30,
),

// =========================================
// POWER USAGE CHART
// =========================================

const PowerUsageChart(),

const SizedBox(
height: 40,
),

// =========================================
// SENSOR ANALYTICS
// =========================================

const Text(
"Sensor Analytics",
style: TextStyle(
fontSize: 24,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 15,
),

// =========================================
// SENSOR LOADING
// =========================================

if (provider.sensorLoading)

const Card(
child: Padding(
padding:
EdgeInsets.all(20),

child: Column(
children: [

SizedBox(
width: 28,
height: 28,

child:
CircularProgressIndicator(),
),

SizedBox(
height: 12,
),

Text(
"Loading sensor data...",
),
],
),
),
),

// =========================================
// SENSOR ERROR
// =========================================

if (!provider.sensorLoading &&
provider.sensorError != null)

Card(
child: Padding(
padding:
const EdgeInsets.all(20),

child: Column(
children: [

const Icon(
Icons.error_outline,
size: 40,
color: Colors.red,
),

const SizedBox(
height: 10,
),

const Text(
"Unable to load sensor data",
style: TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 8,
),

Text(
provider
    .sensorError!
    .replaceFirst(
"Unable to load sensor data: ",
"",
),
textAlign:
TextAlign.center,

style:
const TextStyle(
color:
Colors.grey,
),
),

const SizedBox(
height: 15,
),

ElevatedButton.icon(

onPressed:
_refreshSensorData,

icon:
const Icon(
Icons.refresh,
),

label:
const Text(
"Retry",
),
),
],
),
),
),

const SizedBox(
height: 15,
),

// =========================================
// TIME PERIOD
// =========================================

Card(
child: Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
vertical: 8,
),

child: Row(
mainAxisAlignment:
MainAxisAlignment
    .spaceBetween,

children: [

const Row(
children: [

Icon(
Icons.calendar_month,
),

SizedBox(
width: 10,
),

Text(
"Time Period",
style:
TextStyle(
fontSize: 16,
fontWeight:
FontWeight.bold,
),
),
],
),

DropdownButton<String>(

value:
_selectedPeriod,

underline:
const SizedBox(),

items: const [

DropdownMenuItem(
value: "Today",
child:
Text(
"Today",
),
),

DropdownMenuItem(
value: "7 Days",
child:
Text(
"7 Days",
),
),

DropdownMenuItem(
value: "30 Days",
child:
Text(
"30 Days",
),
),
],

onChanged:
(value) {

if (value ==
null) {
return;
}

setState(() {
_selectedPeriod =
value;
});
},
),
],
),
),
),

const SizedBox(
height: 20,
),

// =========================================
// TEMPERATURE
// =========================================

Card(
child: Padding(
padding:
const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [

const Row(
children: [

Icon(
Icons.thermostat,
size: 32,
),

SizedBox(
width: 10,
),

Text(
"Temperature",
style:
TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),
],
),

const SizedBox(
height: 20,
),

Center(
child: Text(
_temperatureText(
provider,
),

style:
const TextStyle(
fontSize: 36,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(
height: 10,
),

Center(
child: Text(
provider.temperature ==
null
? "No temperature data available"
    : "Latest reading",

style:
const TextStyle(
color:
Colors.grey,
),
),
),

const SizedBox(
height: 15,
),

Container(
height: 100,

width:
double.infinity,

decoration:
BoxDecoration(
borderRadius:
BorderRadius
    .circular(
12,
),

border:
Border.all(
color:
Colors.grey,
),
),

child: Center(
child: Text(
provider.temperature ==
null
? "Temperature history\nnot available yet"
    : "Latest temperature:\n"
"${_temperatureText(provider)}",

textAlign:
TextAlign.center,

style:
const TextStyle(
color:
Colors.grey,
),
),
),
),
],
),
),
),

const SizedBox(
height: 20,
),

// =========================================
// HUMIDITY
// =========================================

Card(
child: Padding(
padding:
const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [

const Row(
children: [

Icon(
Icons.water_drop,
size: 32,
),

SizedBox(
width: 10,
),

Text(
"Humidity",
style:
TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),
],
),

const SizedBox(
height: 20,
),

Center(
child: Text(
_humidityText(
provider,
),

style:
const TextStyle(
fontSize: 36,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(
height: 10,
),

Center(
child: Text(
provider.humidity ==
null
? "No humidity data available"
    : "Latest reading",

style:
const TextStyle(
color:
Colors.grey,
),
),
),

const SizedBox(
height: 15,
),

Container(
height: 100,

width:
double.infinity,

decoration:
BoxDecoration(
borderRadius:
BorderRadius
    .circular(
12,
),

border:
Border.all(
color:
Colors.grey,
),
),

child: Center(
child: Text(
provider.humidity ==
null
? "Humidity history\nnot available yet"
    : "Latest humidity:\n"
"${_humidityText(provider)}",

textAlign:
TextAlign.center,

style:
const TextStyle(
color:
Colors.grey,
),
),
),
),
],
),
),
),

const SizedBox(
height: 20,
),

// =========================================
// DOOR ACTIVITY
// =========================================

Card(
child: Padding(
padding:
const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [

Row(
children: [

Icon(
Icons.door_front_door,
size: 32,

color:
_doorColor(
provider,
),
),

const SizedBox(
width: 10,
),

const Text(
"Door Activity",
style:
TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),
],
),

const SizedBox(
height: 20,
),

Row(
mainAxisAlignment:
MainAxisAlignment
    .center,

children: [

Icon(
_doorIcon(
provider,
),

size: 40,

color:
_doorColor(
provider,
),
),

const SizedBox(
width: 15,
),

Text(
_doorStatusText(
provider,
),

style:
TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,

color:
_doorColor(
provider,
),
),
),
],
),

const SizedBox(
height: 15,
),

Container(
height: 80,

width:
double.infinity,

decoration:
BoxDecoration(
borderRadius:
BorderRadius
    .circular(
12,
),

border:
Border.all(
color:
Colors.grey,
),
),

child: Center(
child: Text(
provider.doorStatus ==
null
? "No door activity data available"
    : "Latest door status: "
"${provider.doorStatus}",

textAlign:
TextAlign.center,

style:
const TextStyle(
color:
Colors.grey,
),
),
),
),
],
),
),
),

const SizedBox(
height: 20,
),

// =========================================
// WATER PUMP ANALYTICS
// =========================================

Card(
child: Padding(
padding:
const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [

const Row(
children: [

Icon(
Icons.water,
size: 32,
),

SizedBox(
width: 10,
),

Text(
"Water Pump",
style:
TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),
],
),

const SizedBox(
height: 20,
),

Row(
mainAxisAlignment:
MainAxisAlignment
    .spaceAround,

children: [

// --------------------------------
// PUMP STATUS
// --------------------------------

Column(
children: [

Icon(
provider.pumpRunning
? Icons
    .play_circle
    : Icons
    .stop_circle,

size: 30,

color:
provider
    .pumpRunning
? Colors.green
    : Colors.grey,
),

const SizedBox(
height: 8,
),

Text(
provider
    .pumpRunning
? "ON"
    : "OFF",

style:
const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),

const Text(
"Status",
),
],
),

// --------------------------------
// PUMP POWER
// --------------------------------

const Column(
children: [

Icon(
Icons.bolt,
size: 30,
),

SizedBox(
height: 8,
),

Text(
"550 W",
style:
TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),

Text(
"Power",
),
],
),

// --------------------------------
// HOURLY ENERGY
// --------------------------------

Column(
children: [

const Icon(
Icons
    .electric_bolt,
size: 30,
),

const SizedBox(
height: 8,
),

Text(
"0.55 kWh",
style:
const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),

const Text(
"Per Hour",
),
],
),
],
),

const SizedBox(
height: 20,
),

Container(
width:
double.infinity,

padding:
const EdgeInsets
    .all(15),

decoration:
BoxDecoration(
borderRadius:
BorderRadius
    .circular(
12,
),

border:
Border.all(
color:
Colors.grey,
),
),

child: Column(
children: [

const Text(
"Estimated Pump Cost",
style:
TextStyle(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 8,
),

const Text(
"Rs. 35.75 / hour",
style:
TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 5,
),

const Text(
"Based on 550 W pump "
"and Rs. 65/kWh",
style:
TextStyle(
color:
Colors.grey,
fontSize: 12,
),
),
],
),
),
],
),
),
),

const SizedBox(
height: 30,
),

// =========================================
// LAST SENSOR UPDATE
// =========================================

if (provider.sensorLastUpdated !=
null)

Card(
child: Padding(
padding:
const EdgeInsets.all(15),

child: Row(
mainAxisAlignment:
MainAxisAlignment.center,

children: [

const Icon(
Icons.update,
size: 20,
),

const SizedBox(
width: 8,
),

Text(
"Sensor updated: "
"${_formatDateTime(provider.sensorLastUpdated)}",

style:
const TextStyle(
color:
Colors.grey,
fontSize: 13,
),
),
],
),
),
),

const SizedBox(
height: 30,
),
],
),
),
),
);
}
}


import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/api_service.dart';
import '../models/sensor_model.dart';

class SensorProvider extends ChangeNotifier {
// ====================================================
// SENSOR DATA
// ====================================================

SensorModel? _sensor;

SensorModel? get sensor => _sensor;

// ====================================================
// LOADING
// ====================================================

bool _isLoading = false;

bool get isLoading => _isLoading;

// ====================================================
// ERROR
// ====================================================

String? _errorMessage;

String? get errorMessage => _errorMessage;

// ====================================================
// AUTO REFRESH
// ====================================================

Timer? _refreshTimer;

// ====================================================
// SENSOR GETTERS
// ====================================================

double? get temperature =>
_sensor?.temperature;

double? get humidity =>
_sensor?.humidity;

String? get doorStatus =>
_sensor?.doorStatus;

bool get isDoorOpen =>
_sensor?.isDoorOpen ?? false;

bool get esp32Connected =>
_sensor?.isConnected ?? false;

String? get esp32Id =>
_sensor?.esp32Id;

String? get smartHomeName =>
_sensor?.smartHomeName;

DateTime? get sensorLastUpdated =>
_sensor?.sensorLastUpdated;

DateTime? get lastSeen =>
_sensor?.lastSeen;

// ====================================================
// FETCH SENSOR DATA
//
// Backend:
//
// GET /user/sensors
//
// The backend identifies the Smart Home using
// the authenticated user's token.
//
// Therefore, ESP32 ID is NOT required here.
// ====================================================

Future<void> fetchSensorData() async {
_isLoading = true;
_errorMessage = null;

notifyListeners();

try {
debugPrint(
"=================================",
);

debugPrint(
"FETCH SENSOR DATA",
);

debugPrint(
"Using authenticated user's Smart Home",
);

debugPrint(
"=================================",
);

// ==================================================
// GET SENSOR DATA
// ==================================================

final data =
await ApiService.getSensorData();

// ==================================================
// CONVERT RESPONSE TO MODEL
// ==================================================

_sensor =
SensorModel.fromJson(
data,
);

// ==================================================
// DEBUG INFORMATION
// ==================================================

debugPrint(
"Temperature: ${_sensor?.temperature}",
);

debugPrint(
"Humidity: ${_sensor?.humidity}",
);

debugPrint(
"Door: ${_sensor?.doorStatus}",
);

debugPrint(
"ESP32 ID: ${_sensor?.esp32Id}",
);

debugPrint(
"Smart Home: ${_sensor?.smartHomeName}",
);

debugPrint(
"ESP32 Status: ${_sensor?.status}",
);

debugPrint(
"Last Seen: ${_sensor?.lastSeen}",
);

debugPrint(
"=================================",
);
} catch (e) {
debugPrint(
"FETCH SENSOR DATA ERROR: $e",
);

_errorMessage =
"Unable to load sensor data: $e";
} finally {
_isLoading = false;

notifyListeners();
}
}

// ====================================================
// START AUTO REFRESH
//
// Sensor data refreshes every 5 seconds.
// ====================================================

void startAutoRefresh() {
// Stop any existing timer first.
stopAutoRefresh();

// Fetch immediately.
fetchSensorData();

// Then refresh every 5 seconds.
_refreshTimer =
Timer.periodic(
const Duration(
seconds: 5,
),
(_) {
fetchSensorData();
},
);
}

// ====================================================
// STOP AUTO REFRESH
// ====================================================

void stopAutoRefresh() {
_refreshTimer?.cancel();

_refreshTimer = null;
}

// ====================================================
// CLEAR SENSOR DATA
// ====================================================

void clearSensorData() {
stopAutoRefresh();

_sensor = null;

_errorMessage = null;

_isLoading = false;

notifyListeners();
}

// ====================================================
// DISPOSE
// ====================================================

@override
void dispose() {
stopAutoRefresh();

super.dispose();
}
}

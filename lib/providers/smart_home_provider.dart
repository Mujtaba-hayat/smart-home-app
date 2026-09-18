import 'package:flutter/material.dart';

import '../services/smart_home_service.dart';
import '../api/api_service.dart';

class SmartHomeProvider extends ChangeNotifier {
bool _isLoading = false;
String? _errorMessage;

Map<String, dynamic>? _smartHome;

bool _esp32Connected = false;
String? _esp32Id;

// =========================================
// SENSOR DATA
// =========================================

double? _temperature;
double? _humidity;
String? _doorStatus;
DateTime? _sensorLastUpdated;

// =========================================
// DOOR ALARM
// =========================================

bool _alarmEnabled = false;
bool _isAlarmLoading = false;

// =========================================
// GETTERS
// =========================================

bool get isLoading => _isLoading;

String? get errorMessage => _errorMessage;

Map<String, dynamic>? get smartHome => _smartHome;

bool get hasSmartHome => _smartHome != null;

bool get esp32Connected => _esp32Connected;

String? get esp32Id => _esp32Id;

bool get isAlarmLoading => _isAlarmLoading;

String get smartHomeName {
return _smartHome?["name"]?.toString() ??
"My Smart Home";
}

String get esp32Status {
return _esp32Connected
? "Connected"
    : "Disconnected";
}

// =========================================
// SENSOR GETTERS
// =========================================

double? get temperature => _temperature;

double? get humidity => _humidity;

String get doorStatus {
return _doorStatus ?? "closed";
}

bool get doorOpen {
return doorStatus.toLowerCase() == "open";
}

DateTime? get sensorLastUpdated =>
_sensorLastUpdated;

bool get hasSensorData {
return _temperature != null ||
_humidity != null ||
_doorStatus != null;
}

// =========================================
// ALARM GETTERS
// =========================================

bool get alarmEnabled => _alarmEnabled;

bool get doorAlarmActive {
return _alarmEnabled && doorOpen;
}

String get alarmStatus {
if (!_alarmEnabled) {
return "Disabled";
}

if (doorOpen) {
return "Alert";
}

return "Armed";
}

// =========================================
// TOGGLE DOOR ALARM
//
// This now sends the command to backend.
// =========================================

Future<void> toggleDoorAlarm() async {
await setDoorAlarm(!_alarmEnabled);
}

// =========================================
// SET DOOR ALARM
//
// ON  -> Backend -> ESP32 R7 ON
// OFF -> Backend -> ESP32 R7 OFF
// =========================================

Future<void> setDoorAlarm(bool enabled) async {
// Prevent duplicate requests
if (_isAlarmLoading) {
return;
}

// Check ESP32 connection
if (!_esp32Connected) {
_errorMessage =
"ESP32 is disconnected. "
"Connect the ESP32 before controlling the alarm.";

debugPrint(
"DOOR ALARM ERROR: $_errorMessage",
);

notifyListeners();
return;
}

final bool previousValue = _alarmEnabled;

// =========================================
// Optimistic UI update
// =========================================

_alarmEnabled = enabled;
_isAlarmLoading = true;
_errorMessage = null;

debugPrint(
"=================================",
);

debugPrint(
"DOOR ALARM CONTROL",
);

debugPrint(
"PREVIOUS: "
"${previousValue ? "ON" : "OFF"}",
);

debugPrint(
"REQUESTED: "
"${enabled ? "ON" : "OFF"}",
);

debugPrint(
"RELAY: R7",
);

debugPrint(
"=================================",
);

notifyListeners();

try {
// =========================================
// Send command to backend
// =========================================

final response =
await ApiService.controlAlarm(
enabled ? "ON" : "OFF",
);

debugPrint(
"=================================",
);

debugPrint(
"DOOR ALARM BACKEND RESPONSE",
);

debugPrint(
"$response",
);

debugPrint(
"=================================",
);

// =========================================
// Read returned alarm state
// =========================================

bool? serverAlarmState;

if (response["alarmEnabled"] is bool) {
serverAlarmState =
response["alarmEnabled"] as bool;
}

// Some backends may return "alarm" object
if (serverAlarmState == null &&
response["alarm"] is Map) {
final alarm =
Map<String, dynamic>.from(
response["alarm"],
);

if (alarm["enabled"] is bool) {
serverAlarmState =
alarm["enabled"] as bool;
}

if (serverAlarmState == null &&
alarm["isOn"] is bool) {
serverAlarmState =
alarm["isOn"] as bool;
}
}

// =========================================
// Use server value if available
// =========================================

if (serverAlarmState != null) {
_alarmEnabled =
serverAlarmState;
} else {
// Backend successfully accepted
// our requested state.
_alarmEnabled = enabled;
}

debugPrint(
"DOOR ALARM FINAL STATE: "
"${_alarmEnabled ? "ENABLED" : "DISABLED"}",
);
} catch (e) {
// =========================================
// Backend request failed
// =========================================

_alarmEnabled = previousValue;

_errorMessage = e
    .toString()
    .replaceFirst(
"Exception: ",
"",
);

debugPrint(
"=================================",
);

debugPrint(
"DOOR ALARM CONTROL ERROR",
);

debugPrint(
"$_errorMessage",
);

debugPrint(
"RESTORED ALARM STATE: "
"${_alarmEnabled ? "ON" : "OFF"}",
);

debugPrint(
"=================================",
);
} finally {
_isAlarmLoading = false;

notifyListeners();
}
}

// =========================================
// UPDATE SMART HOME + SENSOR DATA
// =========================================

void updateFromDeviceResponse(
Map<String, dynamic>? smartHomeData,
) {
if (smartHomeData == null) {
_smartHome = null;

_esp32Connected = false;
_esp32Id = null;

_temperature = null;
_humidity = null;
_doorStatus = null;
_sensorLastUpdated = null;

debugPrint(
"SMART HOME FROM DEVICE RESPONSE: NULL",
);

notifyListeners();
return;
}

_smartHome =
Map<String, dynamic>.from(
smartHomeData,
);

// =========================================
// ESP32
// =========================================

_esp32Id =
smartHomeData["esp32Id"]?.toString();

final status =
smartHomeData["status"]
    ?.toString()
    .toLowerCase()
    .trim();

_esp32Connected =
status == "connected";

// =========================================
// SENSOR DATA
// =========================================

_temperature =
_parseDouble(
smartHomeData["temperature"],
);

_humidity =
_parseDouble(
smartHomeData["humidity"],
);

final door =
smartHomeData["doorStatus"]
    ?.toString()
    .toLowerCase()
    .trim();

if (door == "open" ||
door == "closed") {
_doorStatus = door;
} else {
_doorStatus = null;
}

_sensorLastUpdated =
_parseDateTime(
smartHomeData["sensorLastUpdated"],
);

// =========================================
// ALARM STATE FROM BACKEND
// =========================================

if (smartHomeData["alarmEnabled"] is bool) {
_alarmEnabled =
smartHomeData["alarmEnabled"] as bool;
}

if (smartHomeData["alarm"] is Map) {
final alarm =
Map<String, dynamic>.from(
smartHomeData["alarm"],
);

if (alarm["enabled"] is bool) {
_alarmEnabled =
alarm["enabled"] as bool;
} else if (alarm["isOn"] is bool) {
_alarmEnabled =
alarm["isOn"] as bool;
}
}

debugPrint(
"=================================",
);

debugPrint(
"SMART HOME UPDATED",
);

debugPrint(
"SMART HOME NAME: "
"${smartHomeData["name"]}",
);

debugPrint(
"ESP32 ID: $_esp32Id",
);

debugPrint(
"ESP32 STATUS: $status",
);

debugPrint(
"ESP32 CONNECTED: "
"$_esp32Connected",
);

debugPrint(
"TEMPERATURE: $_temperature °C",
);

debugPrint(
"HUMIDITY: $_humidity %",
);

debugPrint(
"DOOR STATUS: $_doorStatus",
);

debugPrint(
"DOOR OPEN: $doorOpen",
);

debugPrint(
"ALARM ENABLED: $_alarmEnabled",
);

debugPrint(
"ALARM STATUS: $alarmStatus",
);

debugPrint(
"SENSOR LAST UPDATED: "
"$_sensorLastUpdated",
);

debugPrint(
"=================================",
);

notifyListeners();
}

// =========================================
// LOAD SMART HOME
// =========================================

Future<bool> loadSmartHome() async {
_isLoading = true;
_errorMessage = null;

notifyListeners();

try {
final home =
await SmartHomeService.getSmartHome();

if (home != null) {
updateFromDeviceResponse(home);

debugPrint(
"SMART HOME FOUND: "
"${home["name"]}",
);
} else {
_smartHome = null;

_esp32Connected = false;
_esp32Id = null;

_temperature = null;
_humidity = null;
_doorStatus = null;
_sensorLastUpdated = null;

debugPrint(
"NO SMART HOME FOUND",
);

notifyListeners();
}

return home != null;
} catch (e) {
_errorMessage = e
    .toString()
    .replaceFirst(
"Exception: ",
"",
);

debugPrint(
"SMART HOME LOAD ERROR: "
"$_errorMessage",
);

return false;
} finally {
_isLoading = false;

notifyListeners();
}
}

// =========================================
// REFRESH
// =========================================

Future<void> refresh() async {
debugPrint(
"=================================",
);

debugPrint(
"SMART HOME PROVIDER REFRESH",
);

debugPrint(
"=================================",
);

await loadSmartHome();
}

// =========================================
// LOAD ESP32 CONNECTION STATUS
// =========================================

Future<void> loadConnectionStatus() async {
try {
final data =
await SmartHomeService
    .getConnectionStatus();

_esp32Connected =
data["esp32Connected"] == true;

_esp32Id =
data["esp32Id"]?.toString();

if (data["smartHome"] != null) {
final smartHomeData =
Map<String, dynamic>.from(
data["smartHome"],
);

updateFromDeviceResponse(
smartHomeData,
);

return;
}

notifyListeners();
} catch (e) {
debugPrint(
"SMART HOME STATUS ERROR: $e",
);
}
}

// =========================================
// CREATE SMART HOME
// =========================================

Future<bool> createSmartHome({
required String name,
}) async {
_isLoading = true;
_errorMessage = null;

notifyListeners();

try {
final data =
await SmartHomeService
    .createSmartHome(
name: name,
);

if (data["smartHome"] != null) {
updateFromDeviceResponse(
Map<String, dynamic>.from(
data["smartHome"],
),
);

debugPrint(
"SMART HOME CREATED: "
"${_smartHome?["name"]}",
);
}

return true;
} catch (e) {
_errorMessage = e
    .toString()
    .replaceFirst(
"Exception: ",
"",
);

debugPrint(
"CREATE SMART HOME ERROR: "
"$_errorMessage",
);

return false;
} finally {
_isLoading = false;

notifyListeners();
}
}

// =========================================
// CLEAR SMART HOME
// =========================================

void clearSmartHome() {
_smartHome = null;

_esp32Connected = false;
_esp32Id = null;

_temperature = null;
_humidity = null;
_doorStatus = null;
_sensorLastUpdated = null;

_alarmEnabled = false;
_isAlarmLoading = false;

_errorMessage = null;

notifyListeners();
}

// =========================================
// CLEAR ERROR
// =========================================

void clearError() {
_errorMessage = null;

notifyListeners();
}

// =========================================
// PARSE DOUBLE
// =========================================

double? _parseDouble(dynamic value) {
if (value == null) {
return null;
}

if (value is num) {
return value.toDouble();
}

return double.tryParse(
value.toString(),
);
}

// =========================================
// PARSE DATETIME
// =========================================

DateTime? _parseDateTime(dynamic value) {
if (value == null) {
return null;
}

if (value is DateTime) {
return value;
}

return DateTime.tryParse(
value.toString(),
);
}
}


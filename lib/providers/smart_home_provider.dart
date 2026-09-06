import 'package:flutter/material.dart';

import '../services/smart_home_service.dart';

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

  // =========================================
  // GETTERS
  // =========================================

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? get smartHome => _smartHome;

  bool get hasSmartHome => _smartHome != null;

  bool get esp32Connected => _esp32Connected;

  String? get esp32Id => _esp32Id;

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
  // =========================================

  void toggleDoorAlarm() {
    _alarmEnabled = !_alarmEnabled;

    debugPrint(
      "DOOR ALARM: "
          "${_alarmEnabled ? "ENABLED" : "DISABLED"}",
    );

    notifyListeners();
  }

  // =========================================
  // SET DOOR ALARM
  // =========================================

  void setDoorAlarm(bool enabled) {
    _alarmEnabled = enabled;

    debugPrint(
      "DOOR ALARM SET: "
          "${_alarmEnabled ? "ENABLED" : "DISABLED"}",
    );

    notifyListeners();
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
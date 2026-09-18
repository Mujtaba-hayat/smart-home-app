import 'dart:async';

import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/device_model.dart';
import '../models/device_type.dart';

class DeviceProvider extends ChangeNotifier {
  // ====================================================
  // DEVICES
  //
  // R1-R6 = Normal devices
  // R7    = Door Alarm
  // R8    = Water Pump
  //
  // R7 and R8 are NOT stored in devices list.
  // ====================================================

  final List<DeviceModel> devices = [];

  // ====================================================
  // LOADING / ERROR
  // ====================================================

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ====================================================
  // SENSOR DATA
  // ====================================================

  double? _temperature;
  double? _humidity;
  String? _doorStatus;
  DateTime? _sensorLastUpdated;

  bool _sensorLoading = false;
  String? _sensorError;

  double? get temperature => _temperature;

  double? get humidity => _humidity;

  String? get doorStatus => _doorStatus;

  DateTime? get sensorLastUpdated => _sensorLastUpdated;

  bool get sensorLoading => _sensorLoading;

  String? get sensorError => _sensorError;

  // ====================================================
  // DOOR HELPERS
  // ====================================================

  bool get doorOpen =>
      _doorStatus?.toLowerCase() == "open";

  bool get doorClosed =>
      _doorStatus?.toLowerCase() == "closed";

  // ====================================================
  // DEVICE COMMAND PROTECTION
  //
  // IMPORTANT
  //
  // When user presses a toggle, we store the requested
  // state here.
  //
  // Example:
  //
  // Current: ON
  // User presses toggle
  // Requested: OFF
  //
  // Even if a refresh temporarily receives ON from the
  // backend, we keep OFF until the command synchronization
  // is finished.
  // ====================================================

  final Set<String> _deviceCommandsInProgress = {};

  final Map<String, bool> _pendingDeviceStates = {};

  // ====================================================
  // DOOR ALARM - R7
  // ====================================================

  bool _alarmEnabled = false;

  bool _alarmRunning = false;

  bool _alarmSilenced = false;

  bool _alarmCommandPending = false;

  bool get alarmEnabled => _alarmEnabled;

  bool get alarmRunning => _alarmRunning;

  bool get alarmSilenced => _alarmSilenced;

  bool get alarmArmed => _alarmEnabled;

  bool get alarmActive => _alarmRunning;

  bool get alarmHasBeenSilenced => _alarmSilenced;

  // ====================================================
  // WATER PUMP - R8
  // ====================================================

  bool _pumpRunning = false;

  int _selectedPumpMinutes = 5;

  int _remainingSeconds = 0;

  Timer? _pumpStatusTimer;

  bool get pumpRunning => _pumpRunning;

  int get selectedPumpMinutes => _selectedPumpMinutes;

  int get remainingSeconds => _remainingSeconds;

  String get formattedRemainingTime {
    final minutes = _remainingSeconds ~/ 60;

    final seconds = _remainingSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  // ====================================================
  // STATISTICS
  // ====================================================

  int get totalDevices => devices.length;

  int get activeDevices {
    final activeNormalDevices = devices
        .where((device) => device.isOn)
        .length;

    return activeNormalDevices +
        (_pumpRunning ? 1 : 0) +
        (_alarmRunning ? 1 : 0);
  }

  int get onlineDevices => devices.length;

  double get currentPowerUsage {
    double total = 0;

    for (final device in devices) {
      if (device.isOn) {
        total += device.power;
      }
    }

    // R8 Water Pump = 550W
    if (_pumpRunning) {
      total += 550;
    }

    // R7 Alarm = 5W
    if (_alarmRunning) {
      total += 5;
    }

    return total;
  }

  DeviceModel get highestPowerDevice {
    final poweredDevices = devices
        .where((device) => device.isOn)
        .toList();

    if (poweredDevices.isEmpty) {
      return devices.isNotEmpty
          ? devices.first
          : DeviceModel(
        id: "",
        deviceId: "",
        relay: "R1",
        name: "No Device",
        room: "Unassigned",
        type: DeviceType.other,
        iconName: "devices",
        isOn: false,
        power: 0,
      );
    }

    return poweredDevices.reduce(
          (current, next) =>
      current.power > next.power ? current : next,
    );
  }

  double get estimateHourlyEnergy {
    return currentPowerUsage / 1000;
  }

  double get estimatedHourlyCost {
    const ratePerKwh = 65.0;

    return estimateHourlyEnergy * ratePerKwh;
  }

  List<DeviceModel> get topPowerDevices {
    final sortedDevices = List<DeviceModel>.from(devices);

    sortedDevices.sort(
          (a, b) => b.power.compareTo(a.power),
    );

    return sortedDevices.take(5).toList();
  }

  // ====================================================
  // SEARCH / FILTER
  // ====================================================

  String _searchText = "";

  DeviceType? _selectedFilter;

  bool _showFavoritesOnly = false;

  String get searchText => _searchText;

  DeviceType? get selectedFilter => _selectedFilter;

  bool get showFavoriteOnly => _showFavoritesOnly;

  void updateSearch(String value) {
    _searchText = value;

    notifyListeners();
  }

  void updateFilter(DeviceType? type) {
    _selectedFilter = type;

    _showFavoritesOnly = false;

    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;

    if (_showFavoritesOnly) {
      _selectedFilter = null;
    }

    notifyListeners();
  }

  List<DeviceModel> get filteredDevices {
    return devices.where((device) {
      final matchesSearch = device.name
          .toLowerCase()
          .contains(_searchText.toLowerCase());

      final matchesFilter =
          _selectedFilter == null ||
              device.type == _selectedFilter;

      final matchesFavorite =
          !_showFavoritesOnly ||
              device.isFavorite;

      return matchesSearch &&
          matchesFilter &&
          matchesFavorite;
    }).toList();
  }

  // ====================================================
  // ROOM FUNCTIONS
  // ====================================================

  List<DeviceModel> getDevicesByRoom(
      String roomName,
      ) {
    return devices
        .where(
          (device) => device.room == roomName,
    )
        .toList();
  }

  int getDeviceCount(
      String roomName,
      ) {
    return devices
        .where(
          (device) => device.room == roomName,
    )
        .length;
  }

  int getActiveDeviceCount(
      String roomName,
      ) {
    return devices
        .where(
          (device) =>
      device.room == roomName &&
          device.isOn,
    )
        .length;
  }

  double getRoomPower(
      String roomName,
      ) {
    return devices
        .where(
          (device) =>
      device.room == roomName &&
          device.isOn,
    )
        .fold(
      0.0,
          (total, device) =>
      total + device.power,
    );
  }

  // ====================================================
  // DEVICE TYPE
  // ====================================================

  DeviceType _parseDeviceType(
      String? value,
      ) {
    switch (value?.toLowerCase()) {
      case "light":
        return DeviceType.light;

      case "fan":
        return DeviceType.fan;

      case "socket":
        return DeviceType.socket;

      case "appliance":
        return DeviceType.appliance;

      case "alarm":
        return DeviceType.alarm;

      case "pump":
        return DeviceType.pump;

      default:
        return DeviceType.other;
    }
  }

  String _iconForType(
      DeviceType type,
      ) {
    switch (type) {
      case DeviceType.light:
        return "lightbulb";

      case DeviceType.fan:
        return "fan";

      case DeviceType.socket:
        return "socket";

      case DeviceType.appliance:
        return "appliance";

      case DeviceType.alarm:
        return "alarm";

      case DeviceType.pump:
        return "pump";

      case DeviceType.other:
        return "devices";
    }
  }

  double _defaultPower(
      DeviceType type,
      ) {
    switch (type) {
      case DeviceType.light:
        return 10;

      case DeviceType.fan:
        return 75;

      case DeviceType.socket:
        return 100;

      case DeviceType.appliance:
        return 150;

      case DeviceType.alarm:
        return 5;

      case DeviceType.pump:
        return 550;

      case DeviceType.other:
        return 50;
    }
  }

  // ====================================================
  // LOADING / ERROR
  // ====================================================

  void _setLoading(bool value) {
    _isLoading = value;

    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;

    notifyListeners();
  }

  void _setSensorError(String? message) {
    _sensorError = message;

    notifyListeners();
  }

  // ====================================================
  // FETCH SENSOR DATA
  // ====================================================

  Future<void> fetchSensorData() async {
    _sensorLoading = true;

    _setSensorError(null);

    notifyListeners();

    debugPrint(
      "=================================",
    );

    debugPrint("FETCH SENSOR DATA");

    debugPrint(
      "=================================",
    );

    try {
      final data =
      await ApiService.getSensorData();

      debugPrint(
        "SENSOR API RESPONSE: $data",
      );

      final rawSensor = data["sensors"];

      if (rawSensor == null) {
        _temperature = null;
        _humidity = null;
        _doorStatus = null;
        _sensorLastUpdated = null;

        debugPrint(
          "No sensor data available yet.",
        );

        return;
      }

      if (rawSensor is! Map<String, dynamic>) {
        throw Exception(
          "Invalid sensor response.",
        );
      }

      final sensor =
      Map<String, dynamic>.from(rawSensor);

      // =================================================
      // TEMPERATURE
      // =================================================

      final rawTemperature =
      sensor["temperature"];

      _temperature =
      rawTemperature == null
          ? null
          : double.tryParse(
        rawTemperature.toString(),
      );

      // =================================================
      // HUMIDITY
      // =================================================

      final rawHumidity =
      sensor["humidity"];

      _humidity =
      rawHumidity == null
          ? null
          : double.tryParse(
        rawHumidity.toString(),
      );

      // =================================================
      // DOOR
      // =================================================

      final rawDoorStatus =
      sensor["doorStatus"];

      _doorStatus =
      rawDoorStatus == null
          ? null
          : rawDoorStatus
          .toString()
          .toLowerCase();

      // =================================================
      // SENSOR UPDATED
      // =================================================

      final rawUpdatedAt =
      sensor["sensorLastUpdated"];

      _sensorLastUpdated =
      rawUpdatedAt == null
          ? null
          : DateTime.tryParse(
        rawUpdatedAt.toString(),
      );

      // =================================================
      // SMART HOME
      // =================================================

      final rawSmartHome =
      data["smartHome"];

      if (rawSmartHome
      is Map<String, dynamic>) {
        final smartHome =
        Map<String, dynamic>.from(
          rawSmartHome,
        );

        if (!_alarmCommandPending &&
            smartHome.containsKey(
              "alarmEnabled",
            )) {
          _alarmEnabled =
              smartHome["alarmEnabled"] == true;
        }

        if (smartHome.containsKey(
          "alarmIsOn",
        )) {
          _alarmRunning =
              smartHome["alarmIsOn"] == true;
        }

        if (smartHome.containsKey(
          "alarmSilenced",
        )) {
          _alarmSilenced =
              smartHome["alarmSilenced"] == true;
        }
      }

      // =================================================
      // ALARM OBJECT
      // =================================================

      final rawAlarm = data["alarm"];

      if (rawAlarm
      is Map<String, dynamic>) {
        final alarm =
        Map<String, dynamic>.from(
          rawAlarm,
        );

        if (!_alarmCommandPending &&
            alarm.containsKey("enabled")) {
          _alarmEnabled =
              alarm["enabled"] == true;
        }

        if (alarm.containsKey("isOn")) {
          _alarmRunning =
              alarm["isOn"] == true;
        }

        if (alarm.containsKey("silenced")) {
          _alarmSilenced =
              alarm["silenced"] == true;
        }
      }

      debugPrint(
        "TEMPERATURE: $_temperature",
      );

      debugPrint(
        "HUMIDITY: $_humidity",
      );

      debugPrint(
        "DOOR: $_doorStatus",
      );

      debugPrint(
        "ALARM ENABLED: $_alarmEnabled",
      );

      debugPrint(
        "ALARM RUNNING: $_alarmRunning",
      );

      debugPrint(
        "ALARM SILENCED: $_alarmSilenced",
      );
    } catch (e) {
      debugPrint(
        "FETCH SENSOR DATA ERROR: $e",
      );

      _setSensorError(
        "Unable to load sensor data: $e",
      );
    } finally {
      _sensorLoading = false;

      notifyListeners();
    }
  }

  // ====================================================
  // FETCH DEVICES
  // ====================================================

  Future<void> fetchDevices() async {
    _setLoading(true);

    _setError(null);

    debugPrint(
      "=================================",
    );

    debugPrint("FETCH DEVICES CALLED");

    debugPrint(
      "=================================",
    );

    try {
      final data =
      await ApiService.getUserDevices();

      // =================================================
      // NORMAL DEVICES
      // =================================================

      final rawDevices = data["devices"];

      if (rawDevices is! List) {
        throw Exception(
          "Invalid devices response: "
              "'devices' is missing or is not a list.",
        );
      }

      final backendDevices =
      List<Map<String, dynamic>>.from(
        rawDevices.map(
              (item) =>
          Map<String, dynamic>.from(item),
        ),
      );

      // =================================================
      // PRESERVE OLD DEVICE INFORMATION
      // =================================================

      final oldDevices = {
        for (final device in devices)
          device.id: device,
      };

      final updatedDevices =
      <DeviceModel>[];

      for (final item in backendDevices) {
        final id =
            item["_id"]?.toString() ?? "";

        final deviceId =
            item["deviceId"]?.toString() ?? "";

        final name =
            item["name"]?.toString() ??
                "Device";

        final relay =
            item["relay"]?.toString() ??
                "R1";

        // =================================================
        // R7 / R8 RESERVED
        // =================================================

        if (relay == "R7" ||
            relay == "R8") {
          debugPrint(
            "Ignoring reserved relay: $relay",
          );

          continue;
        }

        final type =
        _parseDeviceType(
          item["type"]?.toString(),
        );

        final previous =
        oldDevices[id];

        final backendIsOn =
            item["isOn"] == true;

        // =================================================
        // IMPORTANT STATE PROTECTION
        //
        // If a command is active for this device,
        // NEVER replace its requested state with an
        // old backend state.
        // =================================================

        bool finalIsOn = backendIsOn;

        if (_deviceCommandsInProgress
            .contains(id)) {
          final pending =
          _pendingDeviceStates[id];

          if (pending != null) {
            finalIsOn = pending;

            debugPrint(
              "STATE PROTECTED: "
                  "$name | "
                  "backend=$backendIsOn | "
                  "pending=$pending",
            );
          }
        }

        updatedDevices.add(
          DeviceModel(
            id: id,
            deviceId: deviceId,
            relay: relay,
            name: name,
            room:
            previous?.room ??
                "Unassigned",
            type: type,
            iconName:
            _iconForType(type),
            isOn: finalIsOn,
            isFavorite:
            previous?.isFavorite ??
                false,
            power:
            previous?.power ??
                _defaultPower(type),
          ),
        );
      }

      devices
        ..clear()
        ..addAll(updatedDevices);

      // =================================================
      // SMART HOME
      // =================================================

      final rawSmartHome =
      data["smartHome"];

      if (rawSmartHome
      is Map<String, dynamic>) {
        final smartHome =
        Map<String, dynamic>.from(
          rawSmartHome,
        );

        if (!_alarmCommandPending &&
            smartHome.containsKey(
              "alarmEnabled",
            )) {
          _alarmEnabled =
              smartHome["alarmEnabled"] == true;
        }

        if (smartHome.containsKey(
          "alarmIsOn",
        )) {
          _alarmRunning =
              smartHome["alarmIsOn"] == true;
        }

        if (smartHome.containsKey(
          "alarmSilenced",
        )) {
          _alarmSilenced =
              smartHome["alarmSilenced"] == true;
        }

        if (smartHome.containsKey(
          "doorStatus",
        )) {
          final value =
          smartHome["doorStatus"];

          if (value != null) {
            _doorStatus =
                value.toString().toLowerCase();
          }
        }

        if (smartHome.containsKey(
          "temperature",
        )) {
          final value =
          smartHome["temperature"];

          if (value != null) {
            _temperature =
                double.tryParse(
                  value.toString(),
                );
          }
        }

        if (smartHome.containsKey(
          "humidity",
        )) {
          final value =
          smartHome["humidity"];

          if (value != null) {
            _humidity =
                double.tryParse(
                  value.toString(),
                );
          }
        }

        if (smartHome.containsKey(
          "sensorLastUpdated",
        )) {
          final value =
          smartHome[
          "sensorLastUpdated"];

          if (value != null) {
            _sensorLastUpdated =
                DateTime.tryParse(
                  value.toString(),
                );
          }
        }
      }

      // =================================================
      // ALARM
      // =================================================

      final rawAlarm = data["alarm"];

      if (rawAlarm
      is Map<String, dynamic>) {
        final alarm =
        Map<String, dynamic>.from(
          rawAlarm,
        );

        if (!_alarmCommandPending &&
            alarm.containsKey("enabled")) {
          _alarmEnabled =
              alarm["enabled"] == true;
        }

        if (alarm.containsKey("isOn")) {
          _alarmRunning =
              alarm["isOn"] == true;
        }

        if (alarm.containsKey("silenced")) {
          _alarmSilenced =
              alarm["silenced"] == true;
        }
      }

      // =================================================
      // PUMP
      // =================================================

      final rawPump = data["pump"];

      if (rawPump
      is Map<String, dynamic>) {
        final pump =
        Map<String, dynamic>.from(
          rawPump,
        );

        _pumpRunning =
            pump["isOn"] == true;
      }

      // =================================================
      // LOG
      // =================================================

      debugPrint(
        "=================================",
      );

      debugPrint(
        "DEVICES UPDATED",
      );

      for (final device in devices) {
        debugPrint(
          "${device.name} | "
              "${device.relay} | "
              "isOn=${device.isOn}",
        );
      }

      debugPrint(
        "=================================",
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        "FETCH DEVICES ERROR: $e",
      );

      _setError(
        "Unable to load devices: $e",
      );
    } finally {
      _setLoading(false);
    }
  }

  // ====================================================
  // CREATE DEVICE
  // ====================================================

  Future<bool> createDevice({
    required String name,
    required String room,
    required DeviceType type,
  }) async {
    _setLoading(true);

    _setError(null);

    try {
      final usedRelays =
      devices
          .map(
            (device) => device.relay,
      )
          .toSet();

      const availableRelays = [
        "R1",
        "R2",
        "R3",
        "R4",
        "R5",
        "R6",
      ];

      final relay =
      availableRelays.firstWhere(
            (item) =>
        !usedRelays.contains(item),
        orElse: () => "",
      );

      if (relay.isEmpty) {
        _setError(
          "Maximum of 6 normal devices has been reached.",
        );

        return false;
      }

      final generatedDeviceId =
          "DEVICE_"
          "${DateTime.now().millisecondsSinceEpoch}";

      final response =
      await ApiService.addDevice(
        name: name,
        deviceId: generatedDeviceId,
        type: type.name,
        relay: relay,
      );

      final rawDevice =
      response["device"];

      if (rawDevice == null) {
        throw Exception(
          "Backend response does not contain 'device'.",
        );
      }

      final item =
      Map<String, dynamic>.from(
        rawDevice,
      );

      final parsedType =
      _parseDeviceType(
        item["type"]?.toString(),
      );

      final newDevice =
      DeviceModel(
        id:
        item["_id"]?.toString() ?? "",
        deviceId:
        item["deviceId"]?.toString() ??
            generatedDeviceId,
        relay:
        item["relay"]?.toString() ??
            relay,
        name:
        item["name"]?.toString() ??
            name,
        room: room,
        type: parsedType,
        iconName:
        _iconForType(parsedType),
        isOn: item["isOn"] == true,
        isFavorite: false,
        power:
        _defaultPower(parsedType),
      );

      devices.add(newDevice);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(
        "Unable to add device: $e",
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ====================================================
  // TOGGLE DEVICE
  //
  // IMPORTANT
  //
  // This is the main fix.
  //
  // We do NOT immediately perform a normal
  // getUserDevices() and overwrite the requested state.
  //
  // The requested ON/OFF state stays protected while
  // backend synchronization happens.
  // ====================================================

  Future<void> toggleDevice(
      DeviceModel device,
      ) async {
    // =================================================
    // RESERVED RELAYS
    // =================================================

    if (device.relay == "R7" ||
        device.relay == "R8") {
      debugPrint(
        "TOGGLE BLOCKED: "
            "Reserved relay ${device.relay}",
      );

      return;
    }

    // =================================================
    // PREVENT DOUBLE TAP
    // =================================================

    if (_deviceCommandsInProgress
        .contains(device.id)) {
      debugPrint(
        "TOGGLE IGNORED: "
            "command already in progress",
      );

      return;
    }

    // =================================================
    // CURRENT STATE
    // =================================================

    final oldState = device.isOn;

    // =================================================
    // NEW STATE
    // =================================================

    final newState = !oldState;

    final stateText =
    newState ? "ON" : "OFF";

    debugPrint(
      "=================================",
    );

    debugPrint(
      "TOGGLE DEVICE START",
    );

    debugPrint(
      "Name: ${device.name}",
    );

    debugPrint(
      "Relay: ${device.relay}",
    );

    debugPrint(
      "Mongo ID: ${device.id}",
    );

    debugPrint(
      "Device ID: ${device.deviceId}",
    );

    debugPrint(
      "OLD STATE: $oldState",
    );

    debugPrint(
      "NEW STATE: $newState",
    );

    debugPrint(
      "COMMAND: $stateText",
    );

    debugPrint(
      "=================================",
    );

    // =================================================
    // PROTECT STATE BEFORE UI UPDATE
    // =================================================

    _deviceCommandsInProgress.add(
      device.id,
    );

    _pendingDeviceStates[
    device.id] = newState;

    // =================================================
    // UPDATE UI IMMEDIATELY
    // =================================================

    device.isOn = newState;

    notifyListeners();

    try {
      // =================================================
      // SEND COMMAND TO BACKEND
      // =================================================

      final response =
      await ApiService.controlDevice(
        device.id,
        stateText,
      );

      debugPrint(
        "=================================",
      );

      debugPrint(
        "CONTROL DEVICE SUCCESS",
      );

      debugPrint(
        "REQUESTED: $stateText",
      );

      debugPrint(
        "RESPONSE: $response",
      );

      debugPrint(
        "=================================",
      );

      // =================================================
      // READ RESPONSE STATE
      // =================================================

      bool? backendState;

      final rawDevice =
      response["device"];

      if (rawDevice
      is Map<String, dynamic>) {
        if (rawDevice.containsKey(
          "isOn",
        )) {
          backendState =
              rawDevice["isOn"] == true;
        }
      }

      if (backendState == null &&
          response.containsKey("isOn")) {
        backendState =
            response["isOn"] == true;
      }

      // =================================================
      // IMPORTANT
      //
      // If backend explicitly returns a state, use it.
      //
      // Otherwise assume the command succeeded and
      // KEEP the requested state.
      // =================================================

      if (backendState != null) {
        debugPrint(
          "BACKEND RETURNED STATE: "
              "$backendState",
        );

        device.isOn = backendState;
      } else {
        debugPrint(
          "BACKEND DID NOT RETURN isOn.",
        );

        debugPrint(
          "KEEPING REQUESTED STATE: "
              "$newState",
        );

        device.isOn = newState;
      }

      notifyListeners();

      // =================================================
      // WAIT FOR ESP32 / DATABASE
      //
      // IMPORTANT:
      // Keep command protection during this period.
      // =================================================

      await Future.delayed(
        const Duration(
          milliseconds: 1500,
        ),
      );

      // =================================================
      // VERIFY ONLY IF NECESSARY
      // =================================================

      try {
        final latest =
        await ApiService.getUserDevices();

        final latestDevices =
        latest["devices"];

        if (latestDevices is List) {
          for (final raw in latestDevices) {
            if (raw is! Map) {
              continue;
            }

            final backendId =
            raw["_id"]?.toString();

            if (backendId != device.id) {
              continue;
            }

            final latestState =
                raw["isOn"] == true;

            debugPrint(
              "=================================",
            );

            debugPrint(
              "TOGGLE VERIFICATION",
            );

            debugPrint(
              "Device: ${device.name}",
            );

            debugPrint(
              "Requested: $newState",
            );

            debugPrint(
              "Backend: $latestState",
            );

            debugPrint(
              "=================================",
            );

            // =================================================
            // IF BACKEND HAS FINALLY ACCEPTED OUR COMMAND
            // =================================================

            if (latestState == newState) {
              device.isOn = latestState;

              debugPrint(
                "STATE VERIFIED SUCCESSFULLY.",
              );
            }

            // =================================================
            // IF BACKEND STILL HAS OLD STATE
            //
            // DO NOT immediately change the UI back.
            //
            // This is important for your current problem.
            // =================================================

            else {
              debugPrint(
                "BACKEND STILL HAS OLD STATE.",
              );

              debugPrint(
                "Keeping requested UI state: "
                    "$newState",
              );

              device.isOn = newState;
            }

            break;
          }
        }

        notifyListeners();
      } catch (e) {
        debugPrint(
          "TOGGLE VERIFICATION ERROR: $e",
        );

        // Keep requested state.
        device.isOn = newState;

        notifyListeners();
      }

      // =================================================
      // COMMAND FINISHED
      // =================================================

      _deviceCommandsInProgress.remove(
        device.id,
      );

      _pendingDeviceStates.remove(
        device.id,
      );

      notifyListeners();

      debugPrint(
        "=================================",
      );

      debugPrint(
        "TOGGLE DEVICE FINISHED",
      );

      debugPrint(
        "FINAL UI STATE: ${device.isOn}",
      );

      debugPrint(
        "=================================",
      );
    } catch (e) {
      // =================================================
      // COMMAND FAILED
      // =================================================

      _deviceCommandsInProgress.remove(
        device.id,
      );

      _pendingDeviceStates.remove(
        device.id,
      );

      // =================================================
      // ROLLBACK ONLY IF HTTP COMMAND FAILED
      // =================================================

      device.isOn = oldState;

      notifyListeners();

      debugPrint(
        "=================================",
      );

      debugPrint(
        "TOGGLE DEVICE FAILED",
      );

      debugPrint(
        "Device: ${device.name}",
      );

      debugPrint(
        "Requested: $stateText",
      );

      debugPrint(
        "Restored: $oldState",
      );

      debugPrint(
        "ERROR: $e",
      );

      debugPrint(
        "=================================",
      );

      _setError(
        "Unable to control device: $e",
      );
    }
  }

  // ====================================================
  // ARM / DISARM ALARM
  // ====================================================

  Future<void> toggleAlarm() async {
    if (_alarmCommandPending) {
      debugPrint("ALARM TOGGLE IGNORED: Command already in progress");
      return;
    }

    final oldEnabled = _alarmEnabled;
    final newEnabled = !oldEnabled;

    _alarmCommandPending = true;
    _alarmEnabled = newEnabled;

    if (!newEnabled) {
      _alarmRunning = false;
      _alarmSilenced = false;
    } else {
      _alarmSilenced = false;
    }

    notifyListeners();

    debugPrint("---------------------------------");
    debugPrint("TOGGLE ALARM TRIGGERED");
    debugPrint("Old State: $oldEnabled -> Target State: $newEnabled");
    debugPrint("Sending: ${newEnabled ? "ON" : "OFF"}");
    debugPrint("---------------------------------");

    try {
      final response = await ApiService.controlAlarm(
        newEnabled ? "ON" : "OFF",
      );

      debugPrint("ALARM API RAW RESPONSE: $response");

      final alarm = Map<String, dynamic>.from(
        response["alarm"] ?? response ?? {},
      );

      // Only adopt backend enabled state if explicitly present,
      // otherwise trust the optimistic toggle.
      if (alarm.containsKey("enabled")) {
        _alarmEnabled = alarm["enabled"] == true;
      } else if (alarm.containsKey("alarmEnabled")) {
        _alarmEnabled = alarm["alarmEnabled"] == true;
      } else {
        _alarmEnabled = newEnabled;
      }

      if (alarm.containsKey("isOn")) {
        _alarmRunning = alarm["isOn"] == true;
      } else if (alarm.containsKey("alarmIsOn")) {
        _alarmRunning = alarm["alarmIsOn"] == true;
      }

      if (alarm.containsKey("silenced")) {
        _alarmSilenced = alarm["silenced"] == true;
      } else if (alarm.containsKey("alarmSilenced")) {
        _alarmSilenced = alarm["alarmSilenced"] == true;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("ALARM CONTROL ERROR: $e");

      // Rollback only on network/API failure
      _alarmEnabled = oldEnabled;
      notifyListeners();

      _setError("Unable to control door alarm: $e");
    } finally {
      // Delay resetting the lock to prevent the 10-second polling timer
      // from overwriting with an old state while DB/ESP updates
      Future.delayed(const Duration(seconds: 2), () {
        _alarmCommandPending = false;
      });
    }
  }

  // ====================================================
  // SILENCE ALARM
  // ====================================================

  Future<void> silenceAlarm() async {
    if (!_alarmEnabled) {
      _setError(
        "Alarm is not armed.",
      );

      return;
    }

    if (!_alarmRunning) {
      _setError(
        "Door alarm is not currently active.",
      );

      return;
    }

    final oldRunning = _alarmRunning;

    final oldSilenced = _alarmSilenced;

    _alarmRunning = false;

    _alarmSilenced = true;

    notifyListeners();

    try {
      final response =
      await ApiService.silenceAlarm();

      final alarm =
      Map<String, dynamic>.from(
        response["alarm"] ?? {},
      );

      if (alarm.containsKey("enabled")) {
        _alarmEnabled =
            alarm["enabled"] == true;
      }

      if (alarm.containsKey("isOn")) {
        _alarmRunning =
            alarm["isOn"] == true;
      }

      if (alarm.containsKey("silenced")) {
        _alarmSilenced =
            alarm["silenced"] == true;
      }

      notifyListeners();
    } catch (e) {
      _alarmRunning = oldRunning;

      _alarmSilenced = oldSilenced;

      notifyListeners();

      _setError(
        "Unable to silence door alarm: $e",
      );
    }
  }

  // ====================================================
  // DELETE DEVICE
  // ====================================================

  Future<bool> removeDevice(
      String id,
      ) async {
    try {
      await ApiService.deleteDevice(id);

      devices.removeWhere(
            (device) => device.id == id,
      );

      _deviceCommandsInProgress.remove(
        id,
      );

      _pendingDeviceStates.remove(
        id,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _setError(
        "Unable to delete device: $e",
      );

      return false;
    }
  }

  // ====================================================
  // PUMP DURATION
  // ====================================================

  void changePumpDuration(
      int minutes,
      ) {
    _selectedPumpMinutes = minutes;

    notifyListeners();
  }

  // ====================================================
  // FETCH PUMP STATUS
  // ====================================================

  Future<void> fetchPumpStatus() async {
    try {
      final data =
      await ApiService.getUserDevices();

      final pump =
      Map<String, dynamic>.from(
        data["pump"] ?? {},
      );

      _pumpRunning =
          pump["isOn"] == true;

      notifyListeners();
    } catch (e) {
      _setError(
        "Unable to fetch pump status: $e",
      );
    }
  }

  // ====================================================
  // START PUMP
  // ====================================================

  Future<void> startPump() async {
    try {
      await ApiService.controlPump("ON");

      _pumpRunning = true;

      _remainingSeconds =
          _selectedPumpMinutes * 60;

      startPumpPolling();

      notifyListeners();
    } catch (e) {
      _setError(
        "Unable to start pump: $e",
      );
    }
  }

  // ====================================================
  // STOP PUMP
  // ====================================================

  Future<void> stopPump() async {
    try {
      await ApiService.controlPump("OFF");

      stopPumpPolling();

      _pumpRunning = false;

      _remainingSeconds = 0;

      notifyListeners();
    } catch (e) {
      _setError(
        "Unable to stop pump: $e",
      );
    }
  }

  // ====================================================
  // PUMP TIMER
  // ====================================================

  void startPumpPolling() {
    _pumpStatusTimer?.cancel();

    _pumpStatusTimer =
        Timer.periodic(
          const Duration(seconds: 1),
              (_) async {
            if (_remainingSeconds > 0) {
              _remainingSeconds--;

              if (_remainingSeconds == 0) {
                await stopPump();

                return;
              }

              notifyListeners();
            }
          },
        );
  }

  // ====================================================
  // STOP PUMP TIMER
  // ====================================================

  void stopPumpPolling() {
    _pumpStatusTimer?.cancel();

    _pumpStatusTimer = null;
  }

  // ====================================================
  // REFRESH EVERYTHING
  // ====================================================

  Future<void> refreshAll() async {
    await Future.wait([
      fetchDevices(),
      fetchSensorData(),
    ]);
  }

  // ====================================================
  // FAVORITE
  // ====================================================

  void toggleFavorite(
      DeviceModel device,
      ) {
    device.isFavorite =
    !device.isFavorite;

    notifyListeners();
  }

  // ====================================================
  // DISPOSE
  // ====================================================

  @override
  void dispose() {
    _pumpStatusTimer?.cancel();

    _deviceCommandsInProgress.clear();

    _pendingDeviceStates.clear();

    super.dispose();
  }
}
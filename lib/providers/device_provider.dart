import 'dart:async';

import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/device_model.dart';
import '../models/device_type.dart';

class DeviceProvider extends ChangeNotifier {
  // ====================================================
  // Devices
  //
  // R1-R6 ONLY
  // ====================================================

  final List<DeviceModel> devices = [];

  // ====================================================
  // Loading / Error
  // ====================================================

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ====================================================
  // DEVICE CONTROL SYNC
  //
  // Keeps the latest user command temporarily so that
  // fetchDevices() does not immediately overwrite it
  // with an old ESP32 state.
  // ====================================================

  final Map<String, bool> _pendingDeviceStates = {};

  final Map<String, Timer> _pendingDeviceTimers = {};

  // ====================================================
  // Door Alarm - R7
  // ====================================================

  bool _alarmEnabled = false;
  bool _alarmRunning = false;

  bool get alarmEnabled => _alarmEnabled;

  bool get alarmRunning => _alarmRunning;

  // ====================================================
  // Pump - R8
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
  // Statistics
  // ====================================================

  int get totalDevices => devices.length;

  int get activeDevices {
    final activeNormalDevices = devices
        .where(
          (device) => device.isOn,
    )
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

    if (_pumpRunning) {
      total += 550;
    }

    return total;
  }

  DeviceModel get highestPowerDevice {
    final poweredDevices = devices
        .where(
          (device) => device.isOn,
    )
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
    final sortedDevices = List<DeviceModel>.from(
      devices,
    );

    sortedDevices.sort(
          (a, b) => b.power.compareTo(a.power),
    );

    return sortedDevices.take(5).toList();
  }

  // ====================================================
  // Search / Filter
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
    return devices.where(
          (device) {
        final matchesSearch = device.name
            .toLowerCase()
            .contains(
          _searchText.toLowerCase(),
        );

        final matchesFilter =
            _selectedFilter == null ||
                device.type == _selectedFilter;

        final matchesFavorite =
            !_showFavoritesOnly ||
                device.isFavorite;

        return matchesSearch &&
            matchesFilter &&
            matchesFavorite;
      },
    ).toList();
  }

  // ====================================================
  // Room Functions
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
  // Helpers
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
  // Loading / Error Helpers
  // ====================================================

  void _setLoading(
      bool value,
      ) {
    _isLoading = value;

    notifyListeners();
  }

  void _setError(
      String? message,
      ) {
    _errorMessage = message;

    notifyListeners();
  }

  // ====================================================
  // DEVICE COMMAND SYNC
  //
  // Keep user's latest command for 7 seconds.
  // ====================================================

  void _setPendingDeviceState(
      String deviceId,
      bool state,
      ) {
    _pendingDeviceStates[deviceId] = state;

    _pendingDeviceTimers[deviceId]?.cancel();

    _pendingDeviceTimers[deviceId] = Timer(
      const Duration(
        seconds: 7,
      ),
          () {
        _pendingDeviceStates.remove(deviceId);

        _pendingDeviceTimers.remove(deviceId);
      },
    );
  }

  // ====================================================
  // Fetch Devices
  //
  // R1-R6 -> normal devices
  // R7    -> alarm
  // R8    -> pump
  //
  // IMPORTANT:
  // The current device list is NOT cleared until the
  // backend has returned and successfully provided a
  // valid devices list.
  // ====================================================

  Future<void> fetchDevices() async {
    _setLoading(true);

    _setError(null);

    debugPrint(
      "=================================",
    );

    debugPrint(
      "FETCH DEVICES CALLED",
    );

    debugPrint(
      "=================================",
    );

    try {
      final data = await ApiService.getUserDevices();

      // ==================================================
      // VALIDATE DEVICES RESPONSE
      // ==================================================

      final rawDevices = data["devices"];

      if (rawDevices is! List) {
        throw Exception(
          "Invalid devices response: "
              "'devices' is missing or is not a list.",
        );
      }

      // ==================================================
      // CONVERT BACKEND DEVICES
      // ==================================================

      final backendDevices =
      List<Map<String, dynamic>>.from(
        rawDevices.map(
              (item) => Map<String, dynamic>.from(
            item,
          ),
        ),
      );

      debugPrint(
        "=================================",
      );

      debugPrint(
        "BACKEND DEVICE STATES",
      );

      debugPrint(
        "Number of devices: "
            "${backendDevices.length}",
      );

      debugPrint(
        "=================================",
      );

      // ==================================================
      // KEEP OLD DEVICE DATA
      //
      // Used to preserve room, favorite and power values.
      // ==================================================

      final oldDevices = {
        for (final device in devices) device.id: device,
      };

      // ==================================================
      // IMPORTANT FIX
      //
      // Build a NEW list first.
      //
      // We do NOT clear devices here.
      //
      // This prevents the UI from temporarily losing all
      // Device Cards if the backend response is invalid.
      // ==================================================

      final updatedDevices = <DeviceModel>[];

      // ==================================================
      // NORMAL DEVICES R1-R6
      // ==================================================

      for (final item in backendDevices) {
        debugPrint(
          "DEVICE FROM BACKEND:"
              " ${item["name"]}"
              " | Relay: ${item["relay"]}"
              " | isOn: ${item["isOn"]}"
              " | isOn TYPE:"
              " ${item["isOn"].runtimeType}",
        );

        final id = item["_id"]?.toString() ?? "";

        final deviceId =
            item["deviceId"]?.toString() ?? "";

        final name =
            item["name"]?.toString() ?? "Device";

        final relay =
            item["relay"]?.toString() ?? "R1";

        // =================================================
        // R7 AND R8 ARE RESERVED
        // =================================================

        if (relay == "R7" || relay == "R8") {
          debugPrint(
            "WARNING:"
                " Ignoring reserved relay"
                " $relay"
                " from normal device list.",
          );

          continue;
        }

        final type = _parseDeviceType(
          item["type"]?.toString(),
        );

        final previous = oldDevices[id];

        final backendIsOn =
            item["isOn"] == true;

        // =================================================
        // PENDING USER COMMAND
        // =================================================

        final pendingState =
        _pendingDeviceStates[id];

        final finalIsOn =
            pendingState ?? backendIsOn;

        debugPrint(
          "CREATING FLUTTER DEVICE:"
              " $name"
              " | Relay: $relay"
              " | Backend isOn: $backendIsOn"
              " | Pending state: $pendingState"
              " | Final isOn: $finalIsOn",
        );

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

      // ==================================================
      // IMPORTANT:
      //
      // Only replace the existing list AFTER all devices
      // have been successfully parsed.
      // ==================================================

      devices
        ..clear()
        ..addAll(updatedDevices);


      // ==================================================
// R7 DOOR ALARM
// ==================================================
//
// Backend currently returns R7 status inside:
//
// data["smartHome"]["alarmEnabled"]
// data["smartHome"]["alarmIsOn"]
//
// ==================================================

      final smartHomeData =
      Map<String, dynamic>.from(
        data["smartHome"] ?? {},
      );

// ==================================================
// READ R7 ALARM STATUS
// ==================================================

      _alarmEnabled =
          smartHomeData["alarmEnabled"] == true;

      _alarmRunning =
          smartHomeData["alarmIsOn"] == true;

// ==================================================
// DEBUG
// ==================================================

      debugPrint(
        "=================================",
      );

      debugPrint(
        "DOOR ALARM R7",
      );

      debugPrint(
        "Enabled: $_alarmEnabled",
      );

      debugPrint(
        "Running: $_alarmRunning",
      );

      debugPrint(
        "Backend alarmEnabled:"
            " ${smartHomeData["alarmEnabled"]}",
      );

      debugPrint(
        "Backend alarmIsOn:"
            " ${smartHomeData["alarmIsOn"]}",
      );

      debugPrint(
        "=================================",
      );

      // ==================================================
      // R8 WATER PUMP
      // ==================================================

      final pump =
      Map<String, dynamic>.from(
        data["pump"] ?? {},
      );

      _pumpRunning =
          pump["isOn"] == true;

      debugPrint(
        "PUMP R8:"
            " isOn = $_pumpRunning",
      );

      // ==================================================
      // FINAL FLUTTER DEVICE STATES
      // ==================================================

      debugPrint(
        "=================================",
      );

      debugPrint(
        "FINAL FLUTTER DEVICE STATES",
      );

      for (final device in devices) {
        debugPrint(
          "${device.name}"
              " | Relay: ${device.relay}"
              " | Flutter isOn:"
              " ${device.isOn}",
        );
      }

      debugPrint(
        "R7 Door Alarm:"
            " $_alarmRunning",
      );

      debugPrint(
        "R8 Water Pump:"
            " $_pumpRunning",
      );

      debugPrint(
        "=================================",
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        "=================================",
      );

      debugPrint(
        "FETCH DEVICES ERROR",
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        "=================================",
      );

      // IMPORTANT:
      //
      // We do NOT clear devices when fetching fails.
      //
      // Existing Device Cards remain visible.

      _setError(
        "Unable to load devices: $e",
      );
    } finally {
      _setLoading(false);
    }
  }

  // ====================================================
  // Create Device
  //
  // R1-R6 ONLY
  // ====================================================

  Future<bool> createDevice({
    required String name,
    required String room,
    required DeviceType type,
  }) async {
    _setLoading(true);

    _setError(null);

    try {
      final usedRelays = devices
          .map(
            (device) => device.relay,
      )
          .toSet();

      // =================================================
      // R7 = Alarm
      // R8 = Pump
      // R1-R6 = Normal Devices
      // =================================================

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
            (item) => !usedRelays.contains(item),
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

      debugPrint(
        "=================================",
      );

      debugPrint(
        "ADDING DEVICE",
      );

      debugPrint(
        "Name: $name",
      );

      debugPrint(
        "Room: $room",
      );

      debugPrint(
        "Type: ${type.name}",
      );

      debugPrint(
        "Relay: $relay",
      );

      debugPrint(
        "Device ID:"
            " $generatedDeviceId",
      );

      debugPrint(
        "=================================",
      );

      final response =
      await ApiService.addDevice(
        name: name,
        deviceId: generatedDeviceId,
        type: type.name,
        relay: relay,
      );

      debugPrint(
        "ADD DEVICE RESPONSE:"
            " $response",
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
        item["_id"]?.toString() ??
            "",
        deviceId:
        item["deviceId"]?.toString() ??
            generatedDeviceId,
        relay:
        item["relay"]?.toString() ??
            relay,
        name:
        item["name"]?.toString() ??
            name,
        room:
        room,
        type:
        parsedType,
        iconName:
        _iconForType(
          parsedType,
        ),
        isOn:
        item["isOn"] == true,
        isFavorite:
        false,
        power:
        _defaultPower(
          parsedType,
        ),
      );

      devices.add(
        newDevice,
      );

      notifyListeners();

      debugPrint(
        "DEVICE ADDED SUCCESSFULLY:"
            " ${newDevice.name}",
      );

      return true;
    } catch (e) {
      debugPrint(
        "=================================",
      );

      debugPrint(
        "CREATE DEVICE ERROR",
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        "=================================",
      );

      _setError(
        "Unable to add device:"
            " ${e.toString()}",
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ====================================================
  // Toggle Normal Device
  //
  // R1-R6 ONLY
  // ====================================================

  Future<void> toggleDevice(
      DeviceModel device,
      ) async {
    // ==================================================
    // SAFETY PROTECTION
    // ==================================================

    if (
    device.relay == "R7" ||
        device.relay == "R8") {
      debugPrint(
        "ERROR:"
            " toggleDevice() cannot control"
            " reserved relay ${device.relay}",
      );

      return;
    }

    final oldState =
        device.isOn;

    final newState =
    !oldState;

    debugPrint(
      "=================================",
    );

    debugPrint(
      "TOGGLE DEVICE",
    );

    debugPrint(
      "Device: ${device.name}",
    );

    debugPrint(
      "Relay: ${device.relay}",
    );

    debugPrint(
      "Old state: $oldState",
    );

    debugPrint(
      "New state: $newState",
    );

    debugPrint(
      "=================================",
    );

    // ==================================================
    // SAVE PENDING STATE BEFORE REQUEST
    // ==================================================

    _setPendingDeviceState(
      device.id,
      newState,
    );

    // ==================================================
    // OPTIMISTIC UI UPDATE
    // ==================================================

    device.isOn =
        newState;

    notifyListeners();

    try {
      final response =
      await ApiService.controlDevice(
        device.id,
        newState
            ? "ON"
            : "OFF",
      );

      debugPrint(
        "DEVICE CONTROL SUCCESS:"
            " ${device.name}"
            " -> "
            "${newState ? "ON" : "OFF"}",
      );

      debugPrint(
        "CONTROL RESPONSE:"
            " $response",
      );

      // =================================================
      // DO NOT REMOVE PENDING STATE HERE.
      //
      // ESP32 may need several seconds to poll the
      // backend and physically change the relay.
      // =================================================
    } catch (e) {
      debugPrint(
        "DEVICE CONTROL ERROR:"
            " $e",
      );

      // =================================================
      // REMOVE PENDING STATE
      // =================================================

      _pendingDeviceStates.remove(
        device.id,
      );

      _pendingDeviceTimers[
      device.id]?.cancel();

      _pendingDeviceTimers.remove(
        device.id,
      );

      // =================================================
      // RESTORE PREVIOUS STATE
      // =================================================

      device.isOn =
          oldState;

      notifyListeners();

      _setError(
        "Unable to control device:"
            " $e",
      );
    }
  }

  // ====================================================
  // Toggle Door Alarm R7
  // ====================================================

  Future<void> toggleAlarm() async {
    final oldState =
        _alarmRunning;

    final newState =
    !oldState;

    debugPrint(
      "=================================",
    );

    debugPrint(
      "TOGGLE DOOR ALARM",
    );

    debugPrint(
      "Relay: R7",
    );

    debugPrint(
      "Old state: $oldState",
    );

    debugPrint(
      "New state: $newState",
    );

    debugPrint(
      "=================================",
    );

    // ==================================================
    // OPTIMISTIC UI UPDATE
    // ==================================================

    _alarmRunning =
        newState;

    _alarmEnabled =
        newState;

    notifyListeners();

    try {
      final response =
      await ApiService.controlAlarm(
        newState
            ? "ON"
            : "OFF",
      );

      debugPrint(
        "ALARM CONTROL SUCCESS:"
            " R7 -> "
            "${newState ? "ON" : "OFF"}",
      );

      final alarm =
      Map<String, dynamic>.from(
        response["alarm"] ?? {},
      );

      _alarmEnabled =
          alarm["enabled"] == true;

      _alarmRunning =
          alarm["isOn"] == true;

      notifyListeners();
    } catch (e) {
      debugPrint(
        "ALARM CONTROL ERROR:"
            " $e",
      );

      _alarmRunning =
          oldState;

      _alarmEnabled =
          oldState;

      notifyListeners();

      _setError(
        "Unable to control door alarm:"
            " $e",
      );
    }
  }

  // ====================================================
  // Delete Device
  // ====================================================

  Future<bool> removeDevice(
      String id,
      ) async {
    try {
      await ApiService.deleteDevice(
        id,
      );

      devices.removeWhere(
            (device) => device.id == id,
      );

      // =================================================
      // CLEAN PENDING STATE
      // =================================================

      _pendingDeviceStates.remove(
        id,
      );

      _pendingDeviceTimers[id]?.cancel();

      _pendingDeviceTimers.remove(
        id,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _setError(
        "Unable to delete device:"
            " $e",
      );

      return false;
    }
  }

  // ====================================================
  // Pump
  // ====================================================

  void changePumpDuration(
      int minutes,
      ) {
    _selectedPumpMinutes =
        minutes;

    notifyListeners();
  }

  // ====================================================
  // Fetch Pump Status
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
        "Unable to fetch pump status:"
            " $e",
      );
    }
  }

  // ====================================================
  // Start Pump
  // ====================================================

  Future<void> startPump() async {
    try {
      await ApiService.controlPump(
        "ON",
      );

      _pumpRunning =
      true;

      _remainingSeconds =
          _selectedPumpMinutes * 60;

      startPumpPolling();

      notifyListeners();
    } catch (e) {
      _setError(
        "Unable to start pump:"
            " $e",
      );
    }
  }

  // ====================================================
  // Stop Pump
  // ====================================================

  Future<void> stopPump() async {
    try {
      await ApiService.controlPump(
        "OFF",
      );

      stopPumpPolling();

      _pumpRunning =
      false;

      _remainingSeconds =
      0;

      notifyListeners();
    } catch (e) {
      _setError(
        "Unable to stop pump:"
            " $e",
      );
    }
  }

  // ====================================================
  // Pump Timer
  // ====================================================

  void startPumpPolling() {
    _pumpStatusTimer?.cancel();

    _pumpStatusTimer =
        Timer.periodic(
          const Duration(
            seconds: 1,
          ),
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
  // Stop Pump Timer
  // ====================================================

  void stopPumpPolling() {
    _pumpStatusTimer?.cancel();

    _pumpStatusTimer =
    null;
  }

  // ====================================================
  // Refresh
  // ====================================================

  Future<void> refreshAll() async {
    await fetchDevices();
  }

  // ====================================================
  // Favorite
  // ====================================================

  void toggleFavorite(
      DeviceModel device,
      ) {
    device.isFavorite =
    !device.isFavorite;

    notifyListeners();
  }

  // ====================================================
  // Dispose
  // ====================================================

  @override
  void dispose() {
    _pumpStatusTimer?.cancel();

    for (
    final timer
    in _pendingDeviceTimers.values
    ) {
      timer.cancel();
    }

    _pendingDeviceTimers.clear();

    _pendingDeviceStates.clear();

    super.dispose();
  }
}
import 'dart:async';

import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/device_model.dart';
import '../models/device_type.dart';

class DeviceProvider extends ChangeNotifier {
  // ====================================================
  // Devices
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
  // Pump
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
    final activeNormalDevices =
        devices.where((device) => device.isOn).length;

    return activeNormalDevices + (_pumpRunning ? 1 : 0);
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
    final poweredDevices =
    devices.where((device) => device.isOn).toList();

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
    return devices.where((device) {
      final matchesSearch = device.name
          .toLowerCase()
          .contains(_searchText.toLowerCase());

      final matchesFilter =
          _selectedFilter == null ||
              device.type == _selectedFilter;

      final matchesFavorite =
          !_showFavoritesOnly || device.isFavorite;

      return matchesSearch &&
          matchesFilter &&
          matchesFavorite;
    }).toList();
  }

  // ====================================================
  // Room Functions
  // ====================================================

  List<DeviceModel> getDevicesByRoom(String roomName) {
    return devices
        .where((device) => device.room == roomName)
        .toList();
  }

  int getDeviceCount(String roomName) {
    return devices
        .where((device) => device.room == roomName)
        .length;
  }

  int getActiveDeviceCount(String roomName) {
    return devices
        .where(
          (device) =>
      device.room == roomName &&
          device.isOn,
    )
        .length;
  }

  double getRoomPower(String roomName) {
    return devices
        .where(
          (device) =>
      device.room == roomName &&
          device.isOn,
    )
        .fold(
      0.0,
          (total, device) => total + device.power,
    );
  }

  // ====================================================
  // Helpers
  // ====================================================

  DeviceType _parseDeviceType(String? value) {
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

  String _iconForType(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return "lightbulb";

      case DeviceType.fan:
        return "fan";

      case DeviceType.pump:
        return "pump";

      case DeviceType.socket:
        return "socket";

      case DeviceType.appliance:
        return "appliance";

      case DeviceType.other:
        return "devices";
    }
  }

  double _defaultPower(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return 10;

      case DeviceType.fan:
        return 75;

      case DeviceType.socket:
        return 100;

      case DeviceType.appliance:
        return 150;

      case DeviceType.pump:
        return 550;

      case DeviceType.other:
        return 50;
    }
  }

  // ====================================================
  // Loading / Error Helpers
  // ====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ====================================================
  // Fetch Devices
  // ====================================================

  Future<void> fetchDevices() async {
    _setLoading(true);
    _setError(null);

    try {
      final data = await ApiService.getUserDevices();

      final backendDevices =
      List<Map<String, dynamic>>.from(
        data["devices"] ?? [],
      );

      final oldDevices = {
        for (final device in devices)
          device.id: device,
      };

      devices.clear();

      for (final item in backendDevices) {
        final id = item["_id"]?.toString() ?? "";

        final deviceId =
            item["deviceId"]?.toString() ?? "";

        final name =
            item["name"]?.toString() ?? "Device";

        final relay =
            item["relay"]?.toString() ?? "R1";

        final type = _parseDeviceType(
          item["type"]?.toString(),
        );

        final previous = oldDevices[id];

        devices.add(
          DeviceModel(
            id: id,
            deviceId: deviceId,
            relay: relay,
            name: name,
            room: previous?.room ?? "Unassigned",
            type: type,
            iconName: _iconForType(type),
            isOn: item["isOn"] == true,
            isFavorite: previous?.isFavorite ?? false,
            power: previous?.power ?? _defaultPower(type),
          ),
        );
      }

      final pump = Map<String, dynamic>.from(
        data["pump"] ?? {},
      );

      _pumpRunning = pump["isOn"] == true;

      notifyListeners();
    } catch (e) {
      debugPrint("FETCH DEVICES ERROR: $e");

      _setError(
        "Unable to load devices: $e",
      );
    } finally {
      _setLoading(false);
    }
  }

  // ====================================================
  // Create Device
  // ====================================================

  Future<bool> createDevice({
    required String name,
    required String room,
    required DeviceType type,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // ------------------------------------------------
      // Find available relay
      // R1-R7 = user devices
      // R8 = permanently reserved for water pump
      // ------------------------------------------------

      final usedRelays =
      devices.map((device) => device.relay).toSet();

      const availableRelays = [
        "R1",
        "R2",
        "R3",
        "R4",
        "R5",
        "R6",
        "R7",
      ];

      final relay = availableRelays.firstWhere(
            (item) => !usedRelays.contains(item),
        orElse: () => "",
      );

      if (relay.isEmpty) {
        _setError(
          "Maximum of 7 devices has been reached.",
        );

        return false;
      }

      // ------------------------------------------------
      // Generate device ID
      // ------------------------------------------------

      final generatedDeviceId =
          "DEVICE_${DateTime.now().millisecondsSinceEpoch}";

      debugPrint("=================================");
      debugPrint("ADDING DEVICE");
      debugPrint("Name: $name");
      debugPrint("Room: $room");
      debugPrint("Type: ${type.name}");
      debugPrint("Relay: $relay");
      debugPrint("Device ID: $generatedDeviceId");
      debugPrint("=================================");

      // ------------------------------------------------
      // Send request to backend
      // ------------------------------------------------

      final response = await ApiService.addDevice(
        name: name,
        deviceId: generatedDeviceId,
        type: type.name,
        relay: relay,
      );

      debugPrint("ADD DEVICE RESPONSE: $response");

      // ------------------------------------------------
      // Parse backend response
      // ------------------------------------------------

      final rawDevice = response["device"];

      if (rawDevice == null) {
        throw Exception(
          "Backend response does not contain 'device'.",
        );
      }

      final item =
      Map<String, dynamic>.from(rawDevice);

      final parsedType = _parseDeviceType(
        item["type"]?.toString(),
      );

      final newDevice = DeviceModel(
        id: item["_id"]?.toString() ?? "",
        deviceId:
        item["deviceId"]?.toString() ??
            generatedDeviceId,
        relay:
        item["relay"]?.toString() ?? relay,
        name:
        item["name"]?.toString() ?? name,
        room: room,
        type: parsedType,
        iconName: _iconForType(parsedType),
        isOn: item["isOn"] == true,
        isFavorite: false,
        power: _defaultPower(parsedType),
      );

      devices.add(newDevice);

      notifyListeners();

      debugPrint(
        "DEVICE ADDED SUCCESSFULLY: ${newDevice.name}",
      );

      return true;
    } catch (e) {
      debugPrint("=================================");
      debugPrint("CREATE DEVICE ERROR");
      debugPrint(e.toString());
      debugPrint("=================================");

      _setError(
        "Unable to add device: ${e.toString()}",
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ====================================================
  // Toggle Device
  // ====================================================

  Future<void> toggleDevice(
      DeviceModel device,
      ) async {
    final oldState = device.isOn;
    final newState = !oldState;

    device.isOn = newState;
    notifyListeners();

    try {
      await ApiService.controlDevice(
        device.id,
        newState ? "ON" : "OFF",
      );
    } catch (e) {
      device.isOn = oldState;
      notifyListeners();

      _setError(
        "Unable to control device: $e",
      );
    }
  }

  // ====================================================
  // Delete Device
  // ====================================================

  Future<bool> removeDevice(String id) async {
    try {
      await ApiService.deleteDevice(id);

      devices.removeWhere(
            (device) => device.id == id,
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
  // Pump
  // ====================================================

  void changePumpDuration(int minutes) {
    _selectedPumpMinutes = minutes;
    notifyListeners();
  }

  Future<void> fetchPumpStatus() async {
    try {
      final data =
      await ApiService.getUserDevices();

      final pump = Map<String, dynamic>.from(
        data["pump"] ?? {},
      );

      _pumpRunning = pump["isOn"] == true;

      notifyListeners();
    } catch (e) {
      _setError(
        "Unable to fetch pump status: $e",
      );
    }
  }

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

  void startPumpPolling() {
    _pumpStatusTimer?.cancel();

    _pumpStatusTimer = Timer.periodic(
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

  void stopPumpPolling() {
    _pumpStatusTimer?.cancel();
    _pumpStatusTimer = null;
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

  void toggleFavorite(DeviceModel device) {
    device.isFavorite = !device.isFavorite;
    notifyListeners();
  }

  // ====================================================
  // Dispose
  // ====================================================

  @override
  void dispose() {
    _pumpStatusTimer?.cancel();
    super.dispose();
  }
}
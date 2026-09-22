import 'dart:async';
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/device_model.dart';
import '../models/device_type.dart';

class DeviceProvider extends ChangeNotifier {
  final List<DeviceModel> devices = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  bool get doorOpen => _doorStatus?.toLowerCase() == "open";
  bool get doorClosed => _doorStatus?.toLowerCase() == "closed";

  final Set<String> _deviceCommandsInProgress = {};
  final Map<String, bool> _pendingDeviceStates = {};

  bool _alarmEnabled = false;
  bool _alarmRunning = false;
  bool _alarmCommandPending = false;

  bool get alarmEnabled => _alarmEnabled;
  bool get alarmRunning => _alarmRunning;
  bool get alarmArmed => _alarmEnabled;
  bool get alarmActive => _alarmRunning;

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
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  int get totalDevices => devices.length;
  int get activeDevices => devices.where((d) => d.isOn).length + (_pumpRunning ? 1 : 0) + (_alarmRunning ? 1 : 0);
  int get onlineDevices => devices.length;

  double get currentPowerUsage {
    double total = 0;
    for (final device in devices) {
      if (device.isOn) total += device.power;
    }
    if (_pumpRunning) total += 550;
    if (_alarmRunning) total += 5;
    return total;
  }

  DeviceModel get highestPowerDevice {
    final poweredDevices = devices.where((d) => d.isOn).toList();
    if (poweredDevices.isEmpty) {
      return devices.isNotEmpty
          ? devices.first
          : DeviceModel(id: "", deviceId: "", relay: "R1", name: "No Device", room: "Unassigned", type: DeviceType.other, iconName: "devices", isOn: false, power: 0);
    }
    return poweredDevices.reduce((cur, next) => cur.power > next.power ? cur : next);
  }

  double get estimateHourlyEnergy => currentPowerUsage / 1000;
  double get estimatedHourlyCost => estimateHourlyEnergy * 65.0;

  List<DeviceModel> get topPowerDevices {
    final sorted = List<DeviceModel>.from(devices)..sort((a, b) => b.power.compareTo(a.power));
    return sorted.take(5).toList();
  }

  String _searchText = "";
  DeviceType? _selectedFilter;
  bool _showFavoritesOnly = false;

  String get searchText => _searchText;
  DeviceType? get selectedFilter => _selectedFilter;
  bool get showFavoriteOnly => _showFavoritesOnly;

  void updateSearch(String val) {
    _searchText = val;
    notifyListeners();
  }

  void updateFilter(DeviceType? type) {
    _selectedFilter = type;
    _showFavoritesOnly = false;
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    if (_showFavoritesOnly) _selectedFilter = null;
    notifyListeners();
  }

  List<DeviceModel> get filteredDevices {
    return devices.where((device) {
      final matchesSearch = device.name.toLowerCase().contains(_searchText.toLowerCase());
      final matchesFilter = _selectedFilter == null || device.type == _selectedFilter;
      final matchesFav = !_showFavoritesOnly || device.isFavorite;
      return matchesSearch && matchesFilter && matchesFav;
    }).toList();
  }

  List<DeviceModel> getDevicesByRoom(String room) => devices.where((d) => d.room == room).toList();
  int getDeviceCount(String room) => devices.where((d) => d.room == room).length;
  int getActiveDeviceCount(String room) => devices.where((d) => d.room == room && d.isOn).length;
  double getRoomPower(String room) => devices.where((d) => d.room == room && d.isOn).fold(0.0, (sum, d) => sum + d.power);

  DeviceType _parseDeviceType(String? val) {
    switch (val?.toLowerCase()) {
      case "light": return DeviceType.light;
      case "fan": return DeviceType.fan;
      case "socket": return DeviceType.socket;
      case "appliance": return DeviceType.appliance;
      case "alarm": return DeviceType.alarm;
      case "pump": return DeviceType.pump;
      default: return DeviceType.other;
    }
  }

  String _iconForType(DeviceType type) {
    switch (type) {
      case DeviceType.light: return "lightbulb";
      case DeviceType.fan: return "fan";
      case DeviceType.socket: return "socket";
      case DeviceType.appliance: return "appliance";
      case DeviceType.alarm: return "alarm";
      case DeviceType.pump: return "pump";
      case DeviceType.other: return "devices";
    }
  }

  double _defaultPower(DeviceType type) {
    switch (type) {
      case DeviceType.light: return 10;
      case DeviceType.fan: return 75;
      case DeviceType.socket: return 100;
      case DeviceType.appliance: return 150;
      case DeviceType.alarm: return 5;
      case DeviceType.pump: return 550;
      case DeviceType.other: return 50;
    }
  }

  Future<void> fetchSensorData() async {
    _sensorLoading = true;
    _sensorError = null;
    notifyListeners();

    try {
      final data = await ApiService.getSensorData();
      final rawSensor = data["sensors"];
      if (rawSensor is Map<String, dynamic>) {
        _temperature = rawSensor["temperature"] != null ? double.tryParse(rawSensor["temperature"].toString()) : null;
        _humidity = rawSensor["humidity"] != null ? double.tryParse(rawSensor["humidity"].toString()) : null;
        _doorStatus = rawSensor["doorStatus"]?.toString().toLowerCase();
        _sensorLastUpdated = rawSensor["sensorLastUpdated"] != null ? DateTime.tryParse(rawSensor["sensorLastUpdated"].toString()) : null;
      }
      final rawAlarm = data["alarm"];
      if (rawAlarm is Map<String, dynamic> && !_alarmCommandPending) {
        if (rawAlarm.containsKey("enabled")) _alarmEnabled = rawAlarm["enabled"] == true;
        if (rawAlarm.containsKey("isOn")) _alarmRunning = rawAlarm["isOn"] == true;
      }
    } catch (e) {
      _sensorError = "Unable to load sensor data: $e";
    } finally {
      _sensorLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDevices() async {
    _isLoading = true;
    _errorMessage = null;
    try {
      final data = await ApiService.getUserDevices();
      final rawDevices = data["devices"] as List;
      final oldMap = {for (final d in devices) d.id: d};
      final updated = <DeviceModel>[];

      for (final raw in rawDevices) {
        final item = Map<String, dynamic>.from(raw);
        final relay = item["relay"]?.toString() ?? "R1";
        if (relay == "R7" || relay == "R8") continue;

        final id = item["_id"]?.toString() ?? "";
        final backendIsOn = item["isOn"] == true;
        bool finalIsOn = backendIsOn;

        if (_deviceCommandsInProgress.contains(id)) {
          finalIsOn = _pendingDeviceStates[id] ?? backendIsOn;
        }

        final type = _parseDeviceType(item["type"]?.toString());
        final prev = oldMap[id];

        updated.add(DeviceModel(
          id: id,
          deviceId: item["deviceId"]?.toString() ?? "",
          relay: relay,
          name: item["name"]?.toString() ?? "Device",
          room: prev?.room ?? "Unassigned",
          type: type,
          iconName: _iconForType(type),
          isOn: finalIsOn,
          isFavorite: prev?.isFavorite ?? false,
          power: prev?.power ?? _defaultPower(type),
        ));
      }

      devices..clear()..addAll(updated);

      final rawAlarm = data["alarm"];
      if (rawAlarm is Map && !_alarmCommandPending) {
        _alarmEnabled = rawAlarm["enabled"] == true;
        _alarmRunning = rawAlarm["isOn"] == true;
      }

      final rawPump = data["pump"];
      if (rawPump is Map) {
        _pumpRunning = rawPump["isOn"] == true;
      }
    } catch (e) {
      _errorMessage = "Unable to load devices: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDevice({required String name, required String room, required DeviceType type}) async {
    _isLoading = true;
    _errorMessage = null;
    try {
      final usedRelays = devices.map((d) => d.relay).toSet();
      const available = ["R1", "R2", "R3", "R4", "R5", "R6"];
      final relay = available.firstWhere((r) => !usedRelays.contains(r), orElse: () => "");
      if (relay.isEmpty) {
        _errorMessage = "Maximum of 6 normal devices has been reached.";
        return false;
      }
      final genId = "DEVICE_${DateTime.now().millisecondsSinceEpoch}";
      final res = await ApiService.addDevice(name: name, deviceId: genId, type: type.name, relay: relay);
      final item = Map<String, dynamic>.from(res["device"]);
      final parsedType = _parseDeviceType(item["type"]?.toString());

      devices.add(DeviceModel(
        id: item["_id"]?.toString() ?? "",
        deviceId: item["deviceId"]?.toString() ?? genId,
        relay: item["relay"]?.toString() ?? relay,
        name: item["name"]?.toString() ?? name,
        room: room,
        type: parsedType,
        iconName: _iconForType(parsedType),
        isOn: item["isOn"] == true,
        isFavorite: false,
        power: _defaultPower(parsedType),
      ));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Unable to add device: $e";
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> toggleDevice(DeviceModel device) async {
    if (device.relay == "R7" || device.relay == "R8") return;
    if (_deviceCommandsInProgress.contains(device.id)) return;

    final oldState = device.isOn;
    final newState = !oldState;
    _deviceCommandsInProgress.add(device.id);
    _pendingDeviceStates[device.id] = newState;

    device.isOn = newState;
    notifyListeners();

    try {
      await ApiService.controlDevice(device.id, newState ? "ON" : "OFF");
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      device.isOn = oldState;
      _errorMessage = "Failed to toggle: $e";
      notifyListeners();
    } finally {
      _deviceCommandsInProgress.remove(device.id);
      _pendingDeviceStates.remove(device.id);
      notifyListeners();
    }
  }

  Future<void> toggleAlarm() async {
    if (_alarmCommandPending) return;

    final oldEnabled = _alarmEnabled;
    final newEnabled = !oldEnabled;
    _alarmCommandPending = true;
    _alarmEnabled = newEnabled;
    if (!newEnabled) _alarmRunning = false;
    notifyListeners();

    try {
      final res = await ApiService.controlAlarm(newEnabled ? "ON" : "OFF");
      final alarm = Map<String, dynamic>.from(res["alarm"] ?? {});
      if (alarm.containsKey("enabled")) _alarmEnabled = alarm["enabled"] == true;
      if (alarm.containsKey("isOn")) _alarmRunning = alarm["isOn"] == true;
    } catch (e) {
      _alarmEnabled = oldEnabled;
      _errorMessage = "Failed to control alarm: $e";
    } finally {
      Future.delayed(const Duration(seconds: 1), () {
        _alarmCommandPending = false;
      });
      notifyListeners();
    }
  }

  Future<bool> removeDevice(String id) async {
    try {
      await ApiService.deleteDevice(id);
      devices.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Unable to delete: $e";
      return false;
    }
  }

  void changePumpDuration(int mins) {
    _selectedPumpMinutes = mins;
    notifyListeners();
  }

  Future<void> startPump() async {
    try {
      await ApiService.controlPump("ON");
      _pumpRunning = true;
      _remainingSeconds = _selectedPumpMinutes * 60;
      _pumpStatusTimer?.cancel();
      _pumpStatusTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          if (_remainingSeconds == 0) await stopPump();
          notifyListeners();
        }
      });
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to start pump: $e";
      notifyListeners();
    }
  }

  Future<void> stopPump() async {
    try {
      await ApiService.controlPump("OFF");
      _pumpStatusTimer?.cancel();
      _pumpStatusTimer = null;
      _pumpRunning = false;
      _remainingSeconds = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to stop pump: $e";
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([fetchDevices(), fetchSensorData()]);
  }

  void toggleFavorite(DeviceModel device) {
    device.isFavorite = !device.isFavorite;
    notifyListeners();
  }

  @override
  void dispose() {
    _pumpStatusTimer?.cancel();
    super.dispose();
  }
}
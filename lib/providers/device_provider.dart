import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/device_model.dart';
import '../models/device_type.dart';

import 'dart:async';

class DeviceProvider extends ChangeNotifier {

  //====================================================
  // Devices
  //====================================================

  final List<DeviceModel> devices = [

    DeviceModel(
      id: "R1",
      name: "Living Room Light",
      room: "Living Room",
      type: DeviceType.light,
      iconName: "lightbulb",
      isOn: false,
    ),

    DeviceModel(
      id: "R2",
      name: "Living Room Fan",
      room: "Living Room",
      type: DeviceType.fan,
      iconName: "fan",
      isOn: false,
    ),

    DeviceModel(
      id: "R3",
      name: "Bedroom Light",
      room: "Bedroom",
      type: DeviceType.light,
      iconName: "lightbulb",
      isOn: false,
    ),

    DeviceModel(
      id: "R4",
      name: "Bedroom Fan",
      room: "Bedroom",
      type: DeviceType.fan,
      iconName: "fan",
      isOn: false,
    ),

    DeviceModel(
      id: "R5",
      name: "Kitchen Light",
      room: "Kitchen",
      type: DeviceType.light,
      iconName: "lightbulb",
      isOn: false,
    ),

    DeviceModel(
      id: "R6",
      name: "Porch Light",
      room: "Entrance",
      type: DeviceType.light,
      iconName: "lightbulb",
      isOn: false,
    ),

    DeviceModel(
      id: "R7",
      name: "Security Alarm",
      room: "Security",
      type: DeviceType.alarm,
      iconName: "alarm",
      isOn: false,
    ),

    DeviceModel(
      id: "R8",
      name: "Water Pump",
      room: "Water System",
      type: DeviceType.pump,
      iconName: "pump",
      isOn: false,
    ),
  ];

  //====================================================
  // Statistics
  //====================================================

  int get totalDevices => devices.length;

  int get activeDevices =>
      devices
          .where((device) => device.isOn)
          .length;

  int get onlineDevices => devices.length;

  //====================================================
  // Pump State
  //====================================================

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

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(
        2, '0')}";
  }

  //====================================================
  // Search & Filter
  //====================================================

  String _searchText = "";
  DeviceType? _selectedFilter;
  String get searchText => _searchText;
  DeviceType? get selectedFilter => _selectedFilter;

  void updateSearch(String value) {
    _searchText = value;
    notifyListeners();
  }

  void updateFilter (DeviceType? type) {
    _selectedFilter = type;
    notifyListeners();
  }

  List<DeviceModel> get filteredDevices {
    return devices.where((device){

      final matchesSearch =
          device.name
          .toLowerCase()
          .contains(_searchText.toLowerCase());

      final matchesFilter =
          _selectedFilter ==null ||
      device.type == _selectedFilter;

      //Hide pump because it has its own card
      final hidepump =
          device.type != DeviceType.pump;

      return matchesSearch &&
      matchesFilter &&
      hidepump;
    }).toList();
  }

  //====================================================
  // Room Functions
  //====================================================

  List<DeviceModel> getDevicesByRoom(String roomName) {
    return devices.where((device) {
      return device.room == roomName;
    }).toList();
  }

  int getDeviceCount(String roomName) {
    return devices.where((device) {
      return device.room == roomName;
    }).length;
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

  //====================================================
  // Fetch Devices
  //====================================================

  Future<void> fetchDevices() async {
    try {
      final data = await ApiService.getDevices();

      for (var device in devices) {
        device.isOn = data[device.id] == "ON";
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  //====================================================
  // Toggle Device
  //====================================================

  Future<void> toggleDevice(DeviceModel device) async {
    device.isOn = !device.isOn;

    notifyListeners();

    try {
      await ApiService.controlDevice(

        device.id,

        device.isOn ? "ON" : "OFF",

      );
    } catch (e) {
      device.isOn = !device.isOn;

      notifyListeners();

      debugPrint("Toggle Error: $e");
    }
  }

  //====================================================
  // Pump Duration
  //====================================================

  void changePumpDuration(int minutes) {
    _selectedPumpMinutes = minutes;

    notifyListeners();
  }

  //====================================================
  // Fetch Pump Status
  //====================================================

  Future<void> fetchPumpStatus() async {
    try {
      final data = await ApiService.getPumpStatus();

      _pumpRunning = data["running"];

      _remainingSeconds = data["remaining"];

      notifyListeners();
    } catch (e) {
      debugPrint("Pump Status Error: $e");
    }
  }

  //====================================================
  // Start Pump
  //====================================================
  Future<void> startPump() async {
    try {
      await ApiService.startPump(_selectedPumpMinutes);

      startPumpPolling();

      await fetchPumpStatus();

      await fetchDevices();
    } catch (e) {
      debugPrint("Start Pump Error: $e");
    }
  }


  //====================================================
  // Stop Pump
  //====================================================

  Future<void> stopPump() async {
    try {
      await ApiService.stopPump();

      stopPumpPolling();

      await fetchPumpStatus();

      await fetchDevices();
    } catch (e) {
      debugPrint("Stop Pump Error: $e");
    }
  }

  void startPumpPolling() {

    _pumpStatusTimer?.cancel();

    _pumpStatusTimer = Timer.periodic(

      const Duration(seconds: 1),

          (_) async {

        await fetchPumpStatus();

        await fetchDevices();

      },

    );

  }

  void stopPumpPolling() {

    _pumpStatusTimer?.cancel();

  }


}
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
      power: 10,
    ),

    DeviceModel(
      id: "R2",
      name: "Living Room Fan",
      room: "Living Room",
      type: DeviceType.fan,
      iconName: "fan",
      isOn: false,
      power: 75,
    ),

    DeviceModel(
      id: "R3",
      name: "Bedroom Light",
      room: "Bedroom",
      type: DeviceType.light,
      iconName: "lightbulb",
      isOn: false,
      power: 10,
    ),

    DeviceModel(
      id: "R4",
      name: "Bedroom Fan",
      room: "Bedroom",
      type: DeviceType.fan,
      iconName: "fan",
      isOn: false,
      power: 75,
    ),

    DeviceModel(
      id: "R5",
      name: "Kitchen Light",
      room: "Kitchen",
      type: DeviceType.light,
      iconName: "lightbulb",
      isOn: false,
      power: 12,
    ),

    DeviceModel(
      id: "R6",
      name: "Porch Light",
      room: "Entrance",
      type: DeviceType.light,
      iconName: "lightbulb",
      isOn: false,
      power: 8,
    ),

    DeviceModel(
      id: "R7",
      name: "Security Alarm",
      room: "Security",
      type: DeviceType.alarm,
      iconName: "alarm",
      isOn: false,
      power: 15,
    ),

    DeviceModel(
      id: "R8",
      name: "Water Pump",
      room: "Water System",
      type: DeviceType.pump,
      iconName: "pump",
      isOn: false,
      power: 550,
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

  double get currentPowerUsage {
    return devices
        .where((device) => device.isOn)
        .fold(
      0.0,
        (total, device) => total + device.power,
    );
  }

  //====================================================
  // Loading & Error State
  //====================================================

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message){
    _errorMessage = message;
    notifyListeners();
  }

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

    // Turn off Favorites filter when selecting a type
    _showFavoritesOnly = false;

    notifyListeners();

  }

  void toggleFavoritesFilter() {

    _showFavoritesOnly = !_showFavoritesOnly;

    if (_showFavoritesOnly) {
      // Show all favorite devices regardless of type
      _selectedFilter = null;
    }

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

      final matchesFavorite =
          !_showFavoritesOnly || device.isFavorite;

      //Hide pump because it has its own card
      final hidepump =
          device.type != DeviceType.pump;

      return matchesSearch &&
      matchesFilter &&
          matchesFavorite &&
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

    _setLoading(true);

    _setError(null);

    try {

      final data = await ApiService.getDevices();

      for (var device in devices) {
        device.isOn = data[device.id] == "ON";
      }

    } catch (e) {

      _setError("Unable to connect to the server.");

    }

    _setLoading(false);
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

      _setError("Unable to fetch pump status.");

    }

  }

  //====================================================
  // Refresh Everything
  //====================================================

  Future<void> refreshAll() async {
    await fetchDevices();
    await fetchPumpStatus();

}

  //====================================================
  // Start Pump
  //====================================================
  Future<void> startPump() async {
    try {
      await ApiService.startPump(_selectedPumpMinutes);

      startPumpPolling();

      await refreshAll();

    } catch (e) {
      _setError("Unable to Start Pump");
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

       await refreshAll();

      },

    );

  }

  void stopPumpPolling() {

    _pumpStatusTimer?.cancel();

  }

  void addDevice(DeviceModel device){
    devices.add(device);
    notifyListeners();
  }

  void updateDevice(DeviceModel updateDevice){
    final index = devices.indexWhere(
        (device) => device.id == updateDevice.id,
    );
    if (index != -1){
      devices[index] = updateDevice;
      notifyListeners();
    }
  }
  void deleteDevice(String id ){
    devices.removeWhere(
        (device) => device.id == id,
    );
    notifyListeners();
  }

  void toggleFavorite(DeviceModel device){
    device.isFavorite = !device.isFavorite;
    notifyListeners();
  }

}
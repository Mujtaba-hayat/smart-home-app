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
  // ====================================================

  Future<void> fetchSensorData(
      String esp32Id,
      ) async {
    if (esp32Id.trim().isEmpty) {
      _errorMessage =
      "ESP32 ID is missing.";

      notifyListeners();

      return;
    }

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
        "ESP32 ID: $esp32Id",
      );

      debugPrint(
        "=================================",
      );

      final data =
      await ApiService.getSensorData(
        esp32Id,
      );

      _sensor =
          SensorModel.fromJson(
            data,
          );

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
        "ESP32 Status: ${_sensor?.status}",
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
  // ====================================================

  void startAutoRefresh(
      String esp32Id,
      ) {
    stopAutoRefresh();

    fetchSensorData(
      esp32Id,
    );

    _refreshTimer =
        Timer.periodic(
          const Duration(
            seconds: 5,
          ),
              (_) {
            fetchSensorData(
              esp32Id,
            );
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
    _sensor = null;

    _errorMessage = null;

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
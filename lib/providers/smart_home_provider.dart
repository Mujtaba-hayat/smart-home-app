import 'package:flutter/material.dart';

import '../services/smart_home_service.dart';

class SmartHomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _smartHome;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? get smartHome => _smartHome;

  bool get hasSmartHome => _smartHome != null;

  // =========================================
  // CHECK SMART HOME
  // =========================================

  Future<bool> loadSmartHome() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final home = await SmartHomeService.getSmartHome();

      _smartHome = home;

      return home != null;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst("Exception: ", "");

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      await SmartHomeService.createSmartHome(
        name: name,
      );

      if (data["smartHome"] != null) {
        _smartHome =
        Map<String, dynamic>.from(
          data["smartHome"],
        );
      }

      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst("Exception: ", "");

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
}
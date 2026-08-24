import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isInitializing = true;

  String? _errorMessage;

  Map<String, dynamic>? _user;

  // =====================================
  // GETTERS
  // =====================================

  bool get isLoading => _isLoading;

  bool get isInitializing => _isInitializing;

  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? get user => _user;

  bool get isLoggedIn => _user != null;

  // =====================================
  // CONSTRUCTOR
  // =====================================

  AuthProvider() {
    loadSavedLogin();
  }

  // =====================================
  // LOAD SAVED LOGIN
  // =====================================

  Future<void> loadSavedLogin() async {
    try {
      final data =
      await AuthService.loadSavedLogin();

      if (data != null && data["user"] != null) {
        _user = Map<String, dynamic>.from(
          data["user"],
        );
      }
    } catch (e) {
      _user = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  // =====================================
  // LOGIN
  // =====================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final data = await AuthService.login(
        email: email,
        password: password,
      );

      _user = data["user"] != null
          ? Map<String, dynamic>.from(
        data["user"],
      )
          : null;

      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =====================================
  // REGISTER
  // =====================================

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await AuthService.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =====================================
  // LOGOUT
  // =====================================

  Future<void> logout() async {
    await AuthService.logout();

    _user = null;
    _errorMessage = null;

    notifyListeners();
  }

  // =====================================
  // CLEAR ERROR
  // =====================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
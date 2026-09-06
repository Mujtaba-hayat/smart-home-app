import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isInitializing = true;

  String? _errorMessage;

  Map<String, dynamic>? _user;

  // =========================================
  // GETTERS
  // =========================================

  bool get isLoading => _isLoading;

  bool get isInitializing => _isInitializing;

  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? get user => _user;

  bool get isLoggedIn => _user != null;

  // =========================================
  // CONSTRUCTOR
  // =========================================

  AuthProvider() {
    _initialize();
  }

  // =========================================
  // INITIALIZE AUTHENTICATION
  // =========================================

  Future<void> _initialize() async {
    try {
      debugPrint("=================================");
      debugPrint("AUTH: Checking saved login...");
      debugPrint("=================================");

      final data =
      await AuthService.loadSavedLogin();

      if (data != null && data["user"] != null) {
        _user = Map<String, dynamic>.from(
          data["user"],
        );

        debugPrint("=================================");
        debugPrint("AUTH: SAVED LOGIN FOUND");
        debugPrint(
          "AUTH USER: ${_user?["fullName"]}",
        );
        debugPrint(
          "AUTH EMAIL: ${_user?["email"]}",
        );
        debugPrint(
          "AUTH: User restored successfully",
        );
        debugPrint("=================================");
      } else {
        _user = null;

        debugPrint("=================================");
        debugPrint("AUTH: NO SAVED LOGIN FOUND");
        debugPrint("=================================");
      }
    } catch (e) {
      debugPrint("=================================");
      debugPrint("AUTH INITIALIZATION ERROR");
      debugPrint("ERROR: $e");
      debugPrint("=================================");

      _user = null;
    } finally {
      _isInitializing = false;

      notifyListeners();
    }
  }

  // =========================================
  // LOGIN
  // =========================================

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

      if (data["user"] == null) {
        _errorMessage =
        "User information was not received.";

        return false;
      }

      _user = Map<String, dynamic>.from(
        data["user"],
      );

      debugPrint("=================================");
      debugPrint("AUTH: LOGIN SUCCESSFUL");
      debugPrint(
        "USER: ${_user?["fullName"]}",
      );
      debugPrint(
        "EMAIL: ${_user?["email"]}",
      );
      debugPrint("=================================");

      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst(
        "Exception: ",
        "",
      );

      debugPrint(
        "AUTH LOGIN ERROR: $_errorMessage",
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =========================================
  // REGISTER
  // =========================================

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

  // =========================================
  // DELETE ACCOUNT
  // =========================================

  Future<bool> deleteAccount({
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await AuthService.deleteAccount(
        password: password,
      );

      _user = null;

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

  // =========================================
  // LOGOUT
  // =========================================

  Future<void> logout() async {
    try {
      await AuthService.logout();

      _user = null;
      _errorMessage = null;

      debugPrint("=================================");
      debugPrint("AUTH: LOGOUT SUCCESSFUL");
      debugPrint("AUTH: Local login data cleared");
      debugPrint("=================================");
    } catch (e) {
      debugPrint(
        "AUTH LOGOUT ERROR: $e",
      );
    }

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
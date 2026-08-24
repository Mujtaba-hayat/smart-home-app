import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';

class AuthService {
  static const String baseUrl = ApiService.baseUrl;

  static const String _tokenKey = "auth_token";
  static const String _userKey = "auth_user";

  // =====================================
  // LOGIN
  // =====================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email.trim(),
        "password": password,
      }),
    );

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    if (response.statusCode == 200) {
      final token = data["token"]?.toString();

      if (token == null || token.isEmpty) {
        throw Exception(
          "Login succeeded but token was not received.",
        );
      }

      // =====================================
      // SAVE TOKEN
      // =====================================

      ApiService.token = token;

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        _tokenKey,
        token,
      );

      // =====================================
      // SAVE USER
      // =====================================

      if (data["user"] != null) {
        await prefs.setString(
          _userKey,
          jsonEncode(data["user"]),
        );
      }

      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data["message"]?.toString() ??
          "Login failed. HTTP ${response.statusCode}",
    );
  }

  // =====================================
  // REGISTER
  // =====================================

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "fullName": fullName.trim(),
        "email": email.trim(),
        "password": password,
      }),
    );

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data["message"]?.toString() ??
          "Registration failed. HTTP ${response.statusCode}",
    );
  }

  // =====================================
  // LOAD SAVED LOGIN
  // =====================================

  static Future<Map<String, dynamic>?> loadSavedLogin() async {
    final prefs =
    await SharedPreferences.getInstance();

    final token = prefs.getString(_tokenKey);
    final userString = prefs.getString(_userKey);

    if (token == null || token.isEmpty) {
      return null;
    }

    ApiService.token = token;

    Map<String, dynamic>? user;

    if (userString != null &&
        userString.isNotEmpty) {
      try {
        user = Map<String, dynamic>.from(
          jsonDecode(userString),
        );
      } catch (e) {
        user = null;
      }
    }

    return {
      "token": token,
      "user": user,
    };
  }

  // =====================================
  // LOGOUT
  // =====================================

  static Future<void> logout() async {
    ApiService.token = null;

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';

class AuthService {
  static const String baseUrl = ApiService.baseUrl;

  static const String _tokenKey = "auth_token";
  static const String _userKey = "auth_user";

  // ====================================================
  // LOGIN
  // ====================================================

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

    debugPrint("=================================");
    debugPrint("LOGIN STATUS: ${response.statusCode}");
    debugPrint("LOGIN RESPONSE: ${response.body}");
    debugPrint("=================================");

    final data = _decodeResponse(response);

    // ====================================================
    // SUCCESSFUL LOGIN
    // ====================================================

    if (response.statusCode == 200) {
      final token = data["token"]?.toString().trim();

      // Validate JWT structure.

      if (token == null ||
          token.isEmpty ||
          token.split(".").length != 3) {
        debugPrint(
          "INVALID JWT RECEIVED FROM SERVER",
        );

        debugPrint(
          "TOKEN: $token",
        );

        throw Exception(
          "Login succeeded but server returned an invalid token.",
        );
      }

      // ==================================================
      // Save token in memory
      // ==================================================

      ApiService.token = token;

      debugPrint(
        "JWT TOKEN SAVED IN MEMORY",
      );

      debugPrint(
        "TOKEN PARTS: ${token.split(".").length}",
      );

      // ==================================================
      // Save token locally
      // ==================================================

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        _tokenKey,
        token,
      );

      debugPrint(
        "JWT TOKEN SAVED LOCALLY",
      );

      // ==================================================
      // Save user information
      // ==================================================

      if (data["user"] != null) {
        await prefs.setString(
          _userKey,
          jsonEncode(data["user"]),
        );

        debugPrint(
          "USER INFORMATION SAVED LOCALLY",
        );

        debugPrint(
          "SAVED USER EMAIL: ${data["user"]["email"]}",
        );
      }

      return data;
    }

    // ====================================================
    // LOGIN FAILED
    // ====================================================

    throw Exception(
      data["message"]?.toString() ??
          "Login failed. HTTP ${response.statusCode}",
    );
  }

  // ====================================================
  // REGISTER
  // ====================================================

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

    debugPrint(
      "REGISTER STATUS: ${response.statusCode}",
    );

    debugPrint(
      "REGISTER RESPONSE: ${response.body}",
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data["message"]?.toString() ??
          "Registration failed. HTTP ${response.statusCode}",
    );
  }

  // ====================================================
  // FORGOT PASSWORD
  // ====================================================

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/forgot-password"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email.trim(),
      }),
    );

    debugPrint(
      "FORGOT PASSWORD STATUS: ${response.statusCode}",
    );

    debugPrint(
      "FORGOT PASSWORD RESPONSE: ${response.body}",
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data["message"]?.toString() ??
          "Unable to generate reset code. HTTP ${response.statusCode}",
    );
  }

  // ====================================================
  // RESET PASSWORD
  // ====================================================

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/reset-password"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email.trim(),
        "code": code.trim(),
        "newPassword": newPassword,
      }),
    );

    debugPrint(
      "RESET PASSWORD STATUS: ${response.statusCode}",
    );

    debugPrint(
      "RESET PASSWORD RESPONSE: ${response.body}",
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data["message"]?.toString() ??
          "Unable to reset password. HTTP ${response.statusCode}",
    );
  }

  // ====================================================
  // LOAD SAVED LOGIN
  // ====================================================

  static Future<Map<String, dynamic>?> loadSavedLogin() async {
    final prefs =
    await SharedPreferences.getInstance();

    final token =
    prefs.getString(_tokenKey);

    final userString =
    prefs.getString(_userKey);

    // ==================================================
    // DEBUG SAVED ACCOUNT
    // ==================================================

    debugPrint("=================================");
    debugPrint("SAVED LOGIN CHECK");
    debugPrint(
      "TOKEN EXISTS: ${token != null && token.trim().isNotEmpty}",
    );
    debugPrint(
      "SAVED USER: $userString",
    );
    debugPrint("=================================");

    // ==================================================
    // NO SAVED TOKEN
    // ==================================================

    if (token == null || token.trim().isEmpty) {
      debugPrint(
        "NO SAVED JWT FOUND",
      );

      ApiService.token = null;

      return null;
    }

    final cleanToken =
    token.trim();

    // ==================================================
    // CHECK BASIC JWT STRUCTURE
    // ==================================================

    final parts =
    cleanToken.split(".");

    if (parts.length != 3) {
      debugPrint(
        "=================================",
      );

      debugPrint(
        "INVALID SAVED JWT DETECTED",
      );

      debugPrint(
        "JWT PARTS: ${parts.length}",
      );

      debugPrint(
        "CLEARING OLD AUTHENTICATION DATA",
      );

      debugPrint(
        "=================================",
      );

      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);

      ApiService.token = null;

      return null;
    }

    // ==================================================
    // RESTORE JWT
    // ==================================================

    ApiService.token = cleanToken;

    debugPrint(
      "=================================",
    );

    debugPrint(
      "SAVED JWT RESTORED",
    );

    debugPrint(
      "JWT PARTS: ${parts.length}",
    );

    debugPrint(
      "=================================",
    );

    // ==================================================
    // RESTORE USER INFORMATION
    // ==================================================

    Map<String, dynamic>? user;

    if (userString != null &&
        userString.isNotEmpty) {
      try {
        final decoded =
        jsonDecode(userString);

        if (decoded is Map<String, dynamic>) {
          user =
          Map<String, dynamic>.from(
            decoded,
          );

          debugPrint(
            "RESTORED USER EMAIL: ${user["email"]}",
          );

          debugPrint(
            "RESTORED USER NAME: ${user["fullName"]}",
          );
        }
      } catch (e) {
        debugPrint(
          "LOAD SAVED USER ERROR: $e",
        );

        user = null;
      }
    }

    // ==================================================
    // RETURN SAVED LOGIN
    // ==================================================

    return {
      "token": cleanToken,
      "user": user,
    };
  }

  // ====================================================
  // DELETE ACCOUNT
  // ====================================================

  static Future<Map<String, dynamic>> deleteAccount({
    required String password,
  }) async {
    final currentToken =
        ApiService.token;

    // ==================================================
    // CHECK TOKEN
    // ==================================================

    if (currentToken == null ||
        currentToken.trim().isEmpty) {
      throw Exception(
        "Authentication token is missing. Please login again.",
      );
    }

    final cleanToken =
    currentToken.trim();

    // ==================================================
    // CHECK JWT STRUCTURE
    // ==================================================

    if (cleanToken.split(".").length != 3) {
      debugPrint(
        "INVALID JWT BEFORE DELETE ACCOUNT",
      );

      throw Exception(
        "Authentication token is invalid. Please login again.",
      );
    }

    final response = await http.delete(
      Uri.parse(
        "$baseUrl/auth/delete-account",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
        "Bearer $cleanToken",
      },
      body: jsonEncode({
        "password": password,
      }),
    );

    debugPrint(
      "=================================",
    );

    debugPrint(
      "DELETE ACCOUNT STATUS: ${response.statusCode}",
    );

    debugPrint(
      "DELETE ACCOUNT RESPONSE: ${response.body}",
    );

    debugPrint(
      "TOKEN SENT: YES",
    );

    debugPrint(
      "=================================",
    );

    final data =
    _decodeResponse(response);

    if (response.statusCode == 200) {
      await logout();

      return data;
    }

    throw Exception(
      data["message"]?.toString() ??
          "Unable to delete account. HTTP ${response.statusCode}",
    );
  }

  // ====================================================
  // LOGOUT
  // ====================================================

  static Future<void> logout() async {
    // ==================================================
    // CLEAR TOKEN FROM MEMORY
    // ==================================================

    ApiService.token = null;

    // ==================================================
    // CLEAR SAVED AUTHENTICATION DATA
    // ==================================================

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    debugPrint(
      "USER LOGGED OUT",
    );

    debugPrint(
      "AUTH TOKEN CLEARED",
    );

    debugPrint(
      "SAVED USER CLEARED",
    );
  }

  // ====================================================
  // RESPONSE DECODER
  // ====================================================

  static Map<String, dynamic> _decodeResponse(
      http.Response response,
      ) {
    if (response.body.isEmpty) {
      return {};
    }

    try {
      final decoded =
      jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (e) {
      debugPrint(
        "JSON RESPONSE ERROR: $e",
      );

      return {};
    }
  }
}
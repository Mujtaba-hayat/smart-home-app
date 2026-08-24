import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_service.dart';

class SmartHomeService {
  static const String baseUrl = ApiService.baseUrl;

  // =========================================
  // GET CURRENT USER'S SMART HOME
  // =========================================

  static Future<Map<String, dynamic>?> getSmartHome() async {
    final response = await http.get(
      Uri.parse("$baseUrl/user/smart-home"),
      headers: {
        "Authorization": "Bearer ${ApiService.token}",
      },
    );

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    // Smart home exists
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        data["smartHome"],
      );
    }

    // User does not have a smart home
    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(
      data["message"]?.toString() ??
          "Failed to get smart home. HTTP ${response.statusCode}",
    );
  }

  // =========================================
  // CREATE SMART HOME
  // =========================================

  static Future<Map<String, dynamic>> createSmartHome({
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/user/smart-home"),

      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiService.token}",
      },

      body: jsonEncode({
        "name": name.trim(),
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
          "Failed to create smart home. HTTP ${response.statusCode}",
    );
  }
}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.92:3000";

  static String? token;

  // ====================================================
  // Headers
  // ====================================================

  static Map<String, String> _headers({
    bool jsonBody = false,
  }) {
    return {
      if (jsonBody) "Content-Type": "application/json",
      if (token != null && token!.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  // ====================================================
  // Decode Response
  // ====================================================

  static dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    return json.decode(response.body);
  }

  // ====================================================
  // Get User Devices
  // ====================================================

  static Future<Map<String, dynamic>> getUserDevices() async {
    final url = Uri.parse("$baseUrl/user/devices");

    debugPrint("=================================");
    debugPrint("GET USER DEVICES");
    debugPrint("URL: $url");
    debugPrint(
      "TOKEN EXISTS: ${token != null && token!.isNotEmpty}",
    );
    debugPrint("=================================");

    try {
      final response = await http.get(
        url,
        headers: _headers(),
      );

      debugPrint("GET USER DEVICES RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      if (response.statusCode == 200) {
        final decoded = _decode(response);

        return Map<String, dynamic>.from(decoded);
      }

      throw Exception(
        "Failed to load devices "
            "(HTTP ${response.statusCode}): ${response.body}",
      );
    } catch (e) {
      debugPrint("GET USER DEVICES EXCEPTION: $e");
      rethrow;
    }
  }

  // ====================================================
  // Add Device
  // ====================================================

  static Future<Map<String, dynamic>> addDevice({
    required String name,
    required String deviceId,
    required String type,
    required String relay,
  }) async {
    final url = Uri.parse("$baseUrl/user/devices");

    final body = {
      "name": name,
      "deviceId": deviceId,
      "type": type,
      "relay": relay,
    };

    debugPrint("=================================");
    debugPrint("ADD DEVICE REQUEST");
    debugPrint("URL: $url");
    debugPrint("BODY: ${jsonEncode(body)}");
    debugPrint(
      "TOKEN EXISTS: ${token != null && token!.isNotEmpty}",
    );
    debugPrint("=================================");

    try {
      final response = await http.post(
        url,
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      );

      debugPrint("ADD DEVICE RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      if (response.statusCode == 201 ||
          response.statusCode == 200) {
        final decoded = _decode(response);

        return Map<String, dynamic>.from(decoded);
      }

      throw Exception(
        "Add device failed "
            "(HTTP ${response.statusCode}): ${response.body}",
      );
    } catch (e) {
      debugPrint("ADD DEVICE EXCEPTION: $e");
      rethrow;
    }
  }

  // ====================================================
  // Control Device
  // ====================================================

  // deviceId = MongoDB _id
  // Not relay name such as R1.
  static Future<void> controlDevice(
      String deviceId,
      String state,
      ) async {
    final response = await http.put(
      Uri.parse(
        "$baseUrl/user/devices/$deviceId/control",
      ),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        "state": state,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to control device "
            "(HTTP ${response.statusCode}): ${response.body}",
      );
    }
  }

  // ====================================================
  // Delete Device
  // ====================================================

  static Future<void> deleteDevice(String deviceId) async {
    final response = await http.delete(
      Uri.parse(
        "$baseUrl/user/devices/$deviceId",
      ),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to delete device "
            "(HTTP ${response.statusCode}): ${response.body}",
      );
    }
  }

  // ====================================================
  // Control Pump
  // ====================================================

  static Future<void> controlPump(String state) async {
    final response = await http.put(
      Uri.parse("$baseUrl/user/pump/control"),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        "state": state,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to control pump "
            "(HTTP ${response.statusCode}): ${response.body}",
      );
    }
  }

  // ====================================================
  // Start Pump
  // ====================================================

  static Future<void> startPump(int minutes) async {
    final response = await http.post(
      Uri.parse("$baseUrl/pump/start"),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        "minutes": minutes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to start pump "
            "(HTTP ${response.statusCode}): ${response.body}",
      );
    }
  }

  // ====================================================
  // Stop Pump
  // ====================================================

  static Future<void> stopPump() async {
    final response = await http.post(
      Uri.parse("$baseUrl/pump/stop"),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to stop pump "
            "(HTTP ${response.statusCode}): ${response.body}",
      );
    }
  }

  // ====================================================
  // Get Pump Status
  // ====================================================

  static Future<Map<String, dynamic>> getPumpStatus() async {
    final response = await http.get(
      Uri.parse("$baseUrl/pump/status"),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final decoded = _decode(response);

      return Map<String, dynamic>.from(decoded);
    }

    throw Exception(
      "Failed to get pump status "
          "(HTTP ${response.statusCode}): ${response.body}",
    );
  }
}
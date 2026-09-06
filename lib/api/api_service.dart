import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.83:3000";

  // ====================================================
  // Authentication Token
  // ====================================================

  static String? token;

  // ====================================================
  // Headers
  // ====================================================

  static Map<String, String> _headers({
    bool jsonBody = false,
  }) {
    final headers = <String, String>{};

    if (jsonBody) {
      headers["Content-Type"] = "application/json";
    }

    if (token != null && token!.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${token!.trim()}";
    }

    return headers;
  }

  // ====================================================
  // Decode Response
  // ====================================================

  static dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("JSON DECODE ERROR: $e");
      return null;
    }
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
      "TOKEN EXISTS: ${token != null && token!.trim().isNotEmpty}",
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

      final decoded = _decode(response);

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception("Invalid devices response");
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to load devices",
        );
      }

      throw Exception(
        "Failed to load devices "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint("GET USER DEVICES EXCEPTION: $e");
      rethrow;
    }
  }

  // ====================================================
  // Get Sensor Data
  //
  // GET /esp32/sensors/:esp32Id
  //
  // Used by Flutter to get:
  // Temperature
  // Humidity
  // Door Status
  // ESP32 connection status
  // ====================================================

  static Future<Map<String, dynamic>> getSensorData(
      String esp32Id,
      ) async {
    final url = Uri.parse(
      "$baseUrl/esp32/sensors/${esp32Id.trim()}",
    );

    debugPrint("=================================");
    debugPrint("GET SENSOR DATA");
    debugPrint("ESP32 ID: $esp32Id");
    debugPrint("URL: $url");
    debugPrint(
      "TOKEN EXISTS: "
          "${token != null && token!.trim().isNotEmpty}",
    );
    debugPrint("=================================");

    try {
      final response = await http.get(
        url,
        headers: _headers(),
      );

      debugPrint("GET SENSOR DATA RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      final decoded = _decode(response);

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception(
          "Invalid sensor data response",
        );
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to load sensor data",
        );
      }

      throw Exception(
        "Failed to load sensor data "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint(
        "GET SENSOR DATA EXCEPTION: $e",
      );

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
      "name": name.trim(),
      "deviceId": deviceId.trim(),
      "type": type.trim(),
      "relay": relay.trim(),
    };

    debugPrint("=================================");
    debugPrint("ADD DEVICE REQUEST");
    debugPrint("URL: $url");
    debugPrint("BODY: ${jsonEncode(body)}");
    debugPrint(
      "TOKEN EXISTS: ${token != null && token!.trim().isNotEmpty}",
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

      final decoded = _decode(response);

      if (response.statusCode == 201 ||
          response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception(
          "Invalid add device response",
        );
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to add device",
        );
      }

      throw Exception(
        "Add device failed "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint("ADD DEVICE EXCEPTION: $e");
      rethrow;
    }
  }

  // ====================================================
  // Control Device
  // ====================================================

  static Future<Map<String, dynamic>> controlDevice(
      String deviceId,
      String state,
      ) async {
    final url = Uri.parse(
      "$baseUrl/user/devices/$deviceId/control",
    );

    final body = {
      "state": state,
    };

    debugPrint("=================================");
    debugPrint("CONTROL DEVICE");
    debugPrint("URL: $url");
    debugPrint("BODY: ${jsonEncode(body)}");
    debugPrint("=================================");

    try {
      final response = await http.put(
        url,
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      );

      debugPrint("CONTROL DEVICE RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      final decoded = _decode(response);

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {
          "success": true,
        };
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to control device",
        );
      }

      throw Exception(
        "Failed to control device "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint("CONTROL DEVICE EXCEPTION: $e");
      rethrow;
    }
  }

  // ====================================================
  // Control Door Alarm - R7
  // ====================================================

  static Future<Map<String, dynamic>> controlAlarm(
      String state,
      ) async {
    final url = Uri.parse(
      "$baseUrl/user/alarm/control",
    );

    final body = {
      "state": state,
    };

    debugPrint("=================================");
    debugPrint("CONTROL DOOR ALARM");
    debugPrint("RELAY: R7");
    debugPrint("URL: $url");
    debugPrint("BODY: ${jsonEncode(body)}");
    debugPrint("=================================");

    try {
      final response = await http.put(
        url,
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      );

      debugPrint("CONTROL ALARM RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      final decoded = _decode(response);

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {
          "success": true,
        };
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to control door alarm",
        );
      }

      throw Exception(
        "Failed to control door alarm "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint("CONTROL ALARM EXCEPTION: $e");
      rethrow;
    }
  }

  // ====================================================
  // Delete Device
  // ====================================================

  static Future<Map<String, dynamic>> deleteDevice(
      String deviceId,
      ) async {
    final url = Uri.parse(
      "$baseUrl/user/devices/$deviceId",
    );

    try {
      final response = await http.delete(
        url,
        headers: _headers(),
      );

      final decoded = _decode(response);

      debugPrint("DELETE DEVICE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {
          "success": true,
          "message": "Device deleted successfully",
        };
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to delete device",
        );
      }

      throw Exception(
        "Failed to delete device "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint("DELETE DEVICE EXCEPTION: $e");
      rethrow;
    }
  }

  // ====================================================
  // Control Pump
  // ====================================================

  static Future<Map<String, dynamic>> controlPump(
      String state,
      ) async {
    final url = Uri.parse(
      "$baseUrl/user/pump/control",
    );

    final body = {
      "state": state,
    };

    debugPrint("=================================");
    debugPrint("CONTROL WATER PUMP");
    debugPrint("URL: $url");
    debugPrint("BODY: ${jsonEncode(body)}");
    debugPrint("=================================");

    try {
      final response = await http.put(
        url,
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      );

      debugPrint("CONTROL PUMP RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      final decoded = _decode(response);

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {
          "success": true,
        };
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to control pump",
        );
      }

      throw Exception(
        "Failed to control pump "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint("CONTROL PUMP EXCEPTION: $e");
      rethrow;
    }
  }

  // ====================================================
  // Start Pump
  // ====================================================

  static Future<void> startPump(
      int minutes,
      ) async {
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

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception(
        "Invalid pump status response",
      );
    }

    throw Exception(
      "Failed to get pump status "
          "(HTTP ${response.statusCode}): ${response.body}",
    );
  }

  // ====================================================
  // SMART HOME MEMBERS
  // ====================================================

  // ====================================================
  // Get Members
  // ====================================================

  static Future<Map<String, dynamic>> getMembers() async {
    final url = Uri.parse(
      "$baseUrl/user/members",
    );

    debugPrint("=================================");
    debugPrint("GET SMART HOME MEMBERS");
    debugPrint("URL: $url");
    debugPrint("=================================");

    try {
      final response = await http.get(
        url,
        headers: _headers(),
      );

      debugPrint("GET MEMBERS RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      final decoded = _decode(response);

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception(
          "Invalid members response",
        );
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to load members",
        );
      }

      throw Exception(
        "Failed to load members "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint("GET MEMBERS EXCEPTION: $e");
      rethrow;
    }
  }

  // ====================================================
  // Add / Invite Member
  // ====================================================

  static Future<Map<String, dynamic>> addMember({
    required String email,
    bool controlDevices = true,
    bool controlPump = false,
    bool manageDevices = false,
    bool manageMembers = false,
  }) async {
    final url = Uri.parse(
      "$baseUrl/user/members",
    );

    final body = {
      "email": email.trim().toLowerCase(),
      "controlDevices": controlDevices,
      "controlPump": controlPump,
      "manageDevices": manageDevices,
      "manageMembers": manageMembers,
    };

    debugPrint("=================================");
    debugPrint("ADD SMART HOME MEMBER");
    debugPrint("URL: $url");
    debugPrint("BODY: ${jsonEncode(body)}");
    debugPrint("=================================");

    try {
      final response = await http.post(
        url,
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      );

      debugPrint("ADD MEMBER RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      final decoded = _decode(response);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception(
          "Invalid add member response",
        );
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to add member",
        );
      }

      throw Exception(
        "Failed to add member "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint("ADD MEMBER EXCEPTION: $e");
      rethrow;
    }
  }

  // ====================================================
  // Get My Invitations
  // ====================================================

  static Future<Map<String, dynamic>>
  getMyInvitations() async {
    final url = Uri.parse(
      "$baseUrl/user/members/invitations",
    );

    debugPrint("=================================");
    debugPrint("GET MY MEMBER INVITATIONS");
    debugPrint("URL: $url");
    debugPrint("=================================");

    try {
      final response = await http.get(
        url,
        headers: _headers(),
      );

      debugPrint("GET INVITATIONS RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      final decoded = _decode(response);

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception(
          "Invalid invitations response",
        );
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to load invitations",
        );
      }

      throw Exception(
        "Failed to load invitations "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint(
        "GET INVITATIONS EXCEPTION: $e",
      );
      rethrow;
    }
  }

  // ====================================================
  // Accept Invitation
  // ====================================================

  static Future<Map<String, dynamic>>
  acceptInvitation(
      String memberId,
      ) async {
    final url = Uri.parse(
      "$baseUrl/user/members/$memberId/accept",
    );

    try {
      final response = await http.post(
        url,
        headers: _headers(),
      );

      final decoded = _decode(response);

      debugPrint("ACCEPT INVITATION");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception(
          "Invalid accept invitation response",
        );
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to accept invitation",
        );
      }

      throw Exception(
        "Failed to accept invitation "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint(
        "ACCEPT INVITATION EXCEPTION: $e",
      );
      rethrow;
    }
  }

  // ====================================================
  // Reject Invitation
  // ====================================================

  static Future<Map<String, dynamic>>
  rejectInvitation(
      String memberId,
      ) async {
    final url = Uri.parse(
      "$baseUrl/user/members/$memberId/reject",
    );

    try {
      final response = await http.post(
        url,
        headers: _headers(),
      );

      final decoded = _decode(response);

      debugPrint("REJECT INVITATION");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception(
          "Invalid reject invitation response",
        );
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to reject invitation",
        );
      }

      throw Exception(
        "Failed to reject invitation "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint(
        "REJECT INVITATION EXCEPTION: $e",
      );
      rethrow;
    }
  }

  // ====================================================
  // Remove Member
  // ====================================================

  static Future<Map<String, dynamic>>
  removeMember(
      String memberId,
      ) async {
    final url = Uri.parse(
      "$baseUrl/user/members/$memberId",
    );

    try {
      final response = await http.delete(
        url,
        headers: _headers(),
      );

      final decoded = _decode(response);

      debugPrint("REMOVE MEMBER");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {
          "success": true,
          "message": "Member removed successfully",
        };
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to remove member",
        );
      }

      throw Exception(
        "Failed to remove member "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint(
        "REMOVE MEMBER EXCEPTION: $e",
      );
      rethrow;
    }
  }

  // ====================================================
  // Update Member Permissions
  // ====================================================

  static Future<Map<String, dynamic>>
  updateMemberPermissions({
    required String memberId,
    bool? controlDevices,
    bool? controlPump,
    bool? manageDevices,
    bool? manageMembers,
  }) async {
    final body = <String, dynamic>{};

    if (controlDevices != null) {
      body["controlDevices"] = controlDevices;
    }

    if (controlPump != null) {
      body["controlPump"] = controlPump;
    }

    if (manageDevices != null) {
      body["manageDevices"] = manageDevices;
    }

    if (manageMembers != null) {
      body["manageMembers"] = manageMembers;
    }

    final url = Uri.parse(
      "$baseUrl/user/members/$memberId/permissions",
    );

    debugPrint("=================================");
    debugPrint("UPDATE MEMBER PERMISSIONS");
    debugPrint("URL: $url");
    debugPrint("BODY: ${jsonEncode(body)}");
    debugPrint("=================================");

    try {
      final response = await http.patch(
        url,
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      );

      final decoded = _decode(response);

      debugPrint("UPDATE PERMISSIONS RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception(
          "Invalid permission update response",
        );
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to update permissions",
        );
      }

      throw Exception(
        "Failed to update permissions "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint(
        "UPDATE PERMISSIONS EXCEPTION: $e",
      );
      rethrow;
    }
  }

  // ====================================================
  // Leave Smart Home
  // ====================================================

  static Future<Map<String, dynamic>>
  leaveSmartHome() async {
    final url = Uri.parse(
      "$baseUrl/user/members/leave",
    );

    try {
      final response = await http.delete(
        url,
        headers: _headers(),
      );

      final decoded = _decode(response);

      debugPrint("LEAVE SMART HOME");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {
          "success": true,
          "message":
          "You left the Smart Home successfully",
        };
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Failed to leave Smart Home",
        );
      }

      throw Exception(
        "Failed to leave Smart Home "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint(
        "LEAVE SMART HOME EXCEPTION: $e",
      );
      rethrow;
    }
  }

  // ====================================================
  // Delete Account Permanently
  // ====================================================

  static Future<Map<String, dynamic>>
  deleteAccount({
    required String password,
  }) async {
    final url = Uri.parse(
      "$baseUrl/auth/delete-account",
    );

    debugPrint("=================================");
    debugPrint("DELETE ACCOUNT REQUEST");
    debugPrint("URL: $url");
    debugPrint(
      "TOKEN EXISTS: "
          "${token != null && token!.trim().isNotEmpty}",
    );
    debugPrint("=================================");

    try {
      final response = await http.delete(
        url,
        headers: _headers(jsonBody: true),
        body: jsonEncode({
          "password": password,
        }),
      );

      debugPrint("DELETE ACCOUNT RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================");

      final decoded = _decode(response);

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {
          "success": true,
          "message": "Account deleted successfully",
        };
      }

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"]?.toString() ??
              "Unable to delete account",
        );
      }

      throw Exception(
        "Unable to delete account "
            "(HTTP ${response.statusCode})",
      );
    } catch (e) {
      debugPrint(
        "DELETE ACCOUNT EXCEPTION: $e",
      );
      rethrow;
    }
  }

  // ====================================================
  // Clear Authentication Token
  // ====================================================

  static void clearToken() {
    token = null;
  }
}
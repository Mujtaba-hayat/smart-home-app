import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.11:3000";
  static String? token;

  static Map<String, String> _headers({bool jsonBody = false}) {
    final headers = <String, String>{};
    if (jsonBody) headers["Content-Type"] = "application/json";
    if (token != null && token!.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${token!.trim()}";
    }
    return headers;
  }

  static dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("JSON DECODE ERROR: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> getUserDevices() async {
    final url = Uri.parse("$baseUrl/user/devices");
    final response = await http.get(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to load devices");
  }

  static Future<Map<String, dynamic>> getSensorData() async {
    final url = Uri.parse("$baseUrl/user/sensors");
    final response = await http.get(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to load sensor data");
  }

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
    final response = await http.post(url, headers: _headers(jsonBody: true), body: jsonEncode(body));
    final decoded = _decode(response);
    if ((response.statusCode == 200 || response.statusCode == 201) && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Add device failed");
  }

  static Future<Map<String, dynamic>> controlDevice(String deviceId, String state) async {
    final url = Uri.parse("$baseUrl/user/devices/$deviceId/control");
    final body = {"state": state.trim().toUpperCase()};
    final response = await http.put(url, headers: _headers(jsonBody: true), body: jsonEncode(body));
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to control device");
  }

  static Future<Map<String, dynamic>> controlAlarm(String state) async {
    final url = Uri.parse("$baseUrl/user/alarm/control");
    final body = {"state": state};
    final response = await http.put(url, headers: _headers(jsonBody: true), body: jsonEncode(body));
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to control alarm");
  }

  static Future<Map<String, dynamic>> controlPump(String state) async {
    final url = Uri.parse("$baseUrl/user/pump/control");
    final body = {"state": state};
    final response = await http.put(url, headers: _headers(jsonBody: true), body: jsonEncode(body));
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to control pump");
  }

  static Future<Map<String, dynamic>> deleteDevice(String deviceId) async {
    final url = Uri.parse("$baseUrl/user/devices/$deviceId");
    final response = await http.delete(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to delete device");
  }

  static Future<Map<String, dynamic>> getMembers() async {
    final url = Uri.parse("$baseUrl/user/members");
    final response = await http.get(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to load members");
  }

  static Future<Map<String, dynamic>> addMember({
    required String email,
    bool controlDevices = true,
    bool controlPump = false,
    bool manageDevices = false,
    bool manageMembers = false,
  }) async {
    final url = Uri.parse("$baseUrl/user/members");
    final body = {
      "email": email.trim().toLowerCase(),
      "controlDevices": controlDevices,
      "controlPump": controlPump,
      "manageDevices": manageDevices,
      "manageMembers": manageMembers,
    };
    final response = await http.post(url, headers: _headers(jsonBody: true), body: jsonEncode(body));
    final decoded = _decode(response);
    if ((response.statusCode == 200 || response.statusCode == 201) && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to add member");
  }

  static Future<Map<String, dynamic>> getMyInvitations() async {
    final url = Uri.parse("$baseUrl/user/members/invitations");
    final response = await http.get(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to load invitations");
  }

  static Future<Map<String, dynamic>> acceptInvitation(String memberId) async {
    final url = Uri.parse("$baseUrl/user/members/$memberId/accept");
    final response = await http.post(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to accept invitation");
  }

  static Future<Map<String, dynamic>> rejectInvitation(String memberId) async {
    final url = Uri.parse("$baseUrl/user/members/$memberId/reject");
    final response = await http.post(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to reject invitation");
  }

  static Future<Map<String, dynamic>> removeMember(String memberId) async {
    final url = Uri.parse("$baseUrl/user/members/$memberId");
    final response = await http.delete(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to remove member");
  }

  static Future<Map<String, dynamic>> updateMemberPermissions({
    required String memberId,
    bool? controlDevices,
    bool? controlPump,
    bool? manageDevices,
    bool? manageMembers,
  }) async {
    final body = <String, dynamic>{};
    if (controlDevices != null) body["controlDevices"] = controlDevices;
    if (controlPump != null) body["controlPump"] = controlPump;
    if (manageDevices != null) body["manageDevices"] = manageDevices;
    if (manageMembers != null) body["manageMembers"] = manageMembers;

    final url = Uri.parse("$baseUrl/user/members/$memberId/permissions");
    final response = await http.patch(url, headers: _headers(jsonBody: true), body: jsonEncode(body));
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to update permissions");
  }

  static Future<Map<String, dynamic>> leaveSmartHome() async {
    final url = Uri.parse("$baseUrl/user/members/leave");
    final response = await http.delete(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to leave Smart Home");
  }

  static Future<Map<String, dynamic>> deleteAccount({required String password}) async {
    final url = Uri.parse("$baseUrl/auth/delete-account");
    final response = await http.delete(url, headers: _headers(jsonBody: true), body: jsonEncode({"password": password}));
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Unable to delete account");
  }

  static void clearToken() {
    token = null;
  }

  static Future<Map<String, dynamic>> getNotifications() async {
    final url = Uri.parse("$baseUrl/user/notifications");
    final response = await http.get(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to load notifications");
  }

  static Future<Map<String, dynamic>> markNotificationRead(String notificationId) async {
    final url = Uri.parse("$baseUrl/user/notifications/$notificationId/read");
    final response = await http.put(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to mark notification read");
  }

  static Future<Map<String, dynamic>> markAllNotificationsRead() async {
    final url = Uri.parse("$baseUrl/user/notifications/read-all");
    final response = await http.put(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to mark all read");
  }

  static Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    final url = Uri.parse("$baseUrl/user/notifications/$notificationId");
    final response = await http.delete(url, headers: _headers());
    final decoded = _decode(response);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception(decoded?["message"]?.toString() ?? "Failed to delete notification");
  }
}
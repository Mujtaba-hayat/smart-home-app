import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_service.dart';

class SmartHomeService {
  static const String baseUrl = ApiService.baseUrl;

  // =========================================
  // GET CURRENT USER'S SMART HOME
  // =========================================
  //
  // Uses /user/devices because this endpoint
  // correctly resolves:
  //
  // OWNER
  // ACCEPTED MEMBER
  //
  // =========================================

  static Future<Map<String, dynamic>?> getSmartHome() async {
    final token = ApiService.token;

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        "Authentication token is missing. Please login again.",
      );
    }

    final cleanToken = token.trim();

    final response = await http.get(
      Uri.parse("$baseUrl/user/devices"),
      headers: {
        "Authorization": "Bearer $cleanToken",
        "Content-Type": "application/json",
      },
    );

    print("=================================");
    print("SMART HOME SERVICE");
    print("GET CURRENT USER SMART HOME");
    print("URL: $baseUrl/user/devices");
    print("STATUS: ${response.statusCode}");
    print("=================================");

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (e) {
        throw Exception(
          "Invalid server response.",
        );
      }
    }

    if (response.statusCode == 200) {
      final smartHome = data["smartHome"];

      if (smartHome == null) {
        print("SMART HOME: NOT FOUND");
        print("=================================");

        return null;
      }

      final home = Map<String, dynamic>.from(
        smartHome,
      );

      print(
        "SMART HOME NAME: ${home["name"]}",
      );

      print(
        "ESP32 ID: ${home["esp32Id"]}",
      );

      print(
        "ESP32 STATUS: ${home["status"]}",
      );

      print(
        "LAST SEEN: ${home["lastSeen"]}",
      );

      print(
        "TEMPERATURE: ${home["temperature"]}",
      );

      print(
        "HUMIDITY: ${home["humidity"]}",
      );

      print(
        "DOOR STATUS: ${home["doorStatus"]}",
      );

      print(
        "ALARM ENABLED: ${home["alarmEnabled"]}",
      );

      print(
        "ALARM IS ON: ${home["alarmIsOn"]}",
      );

      print(
        "SENSOR LAST UPDATED: "
            "${home["sensorLastUpdated"]}",
      );

      print("=================================");

      return home;
    }

    if (response.statusCode == 401) {
      throw Exception(
        "Authentication expired. Please login again.",
      );
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(
      data["message"]?.toString() ??
          "Failed to get smart home. "
              "HTTP ${response.statusCode}",
    );
  }

  // =========================================
  // GET SMART HOME CONNECTION STATUS
  // =========================================
  //
  // Uses the same endpoint to ensure the
  // correct Smart Home is used for members.
  //
  // =========================================

  static Future<Map<String, dynamic>> getConnectionStatus() async {
    final token = ApiService.token;

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        "Authentication token is missing. Please login again.",
      );
    }

    final cleanToken = token.trim();

    final response = await http.get(
      Uri.parse("$baseUrl/user/devices"),
      headers: {
        "Authorization": "Bearer $cleanToken",
        "Content-Type": "application/json",
      },
    );

    print("=================================");
    print("LOADING ESP32 CONNECTION STATUS");
    print("=================================");

    print(
      "URL: $baseUrl/user/devices",
    );

    print(
      "STATUS: ${response.statusCode}",
    );

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (e) {
        throw Exception(
          "Invalid server response.",
        );
      }
    }

    if (response.statusCode == 200) {
      final smartHome = data["smartHome"];

      if (smartHome is Map<String, dynamic>) {
        final esp32Id =
        smartHome["esp32Id"]?.toString();

        final status =
        smartHome["status"]
            ?.toString()
            .toLowerCase();

        final connected =
            status == "connected";

        print(
          "SMART HOME: ${smartHome["name"]}",
        );

        print(
          "ESP32 ID: ${esp32Id ?? "null"}",
        );

        print(
          "ESP32 CONNECTED: $connected",
        );

        print(
          "ESP32 STATUS: "
              "${status ?? "disconnected"}",
        );

        print("=================================");

        return {
          "success": true,
          "esp32Connected": connected,
          "esp32Id": esp32Id,
          "status": status ?? "disconnected",
          "smartHome": smartHome,
        };
      }

      print("SMART HOME NOT FOUND");
      print("=================================");

      return {
        "success": false,
        "esp32Connected": false,
        "esp32Id": null,
        "status": "disconnected",
      };
    }

    if (response.statusCode == 401) {
      throw Exception(
        "Authentication expired. Please login again.",
      );
    }

    if (response.statusCode == 404) {
      return {
        "success": false,
        "esp32Connected": false,
        "esp32Id": null,
        "status": "disconnected",
      };
    }

    throw Exception(
      data["message"]?.toString() ??
          "Failed to get smart home status. "
              "HTTP ${response.statusCode}",
    );
  }

  // =========================================
  // GET SENSOR DATA
  // =========================================
  //
  // Gets the sensor information of the
  // Smart Home belonging to the logged-in
  // user.
  //
  // Supports:
  //
  // OWNER
  // ACCEPTED MEMBER
  //
  // Sensors:
  //
  // Temperature
  // Humidity
  // Door Status
  //
  // =========================================

  static Future<Map<String, dynamic>> getSensorData() async {
    final token = ApiService.token;

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        "Authentication token is missing. Please login again.",
      );
    }

    final cleanToken = token.trim();

    final response = await http.get(
      Uri.parse("$baseUrl/user/devices"),
      headers: {
        "Authorization": "Bearer $cleanToken",
        "Content-Type": "application/json",
      },
    );

    print("=================================");
    print("SENSOR SERVICE");
    print("GET SENSOR DATA");
    print("URL: $baseUrl/user/devices");
    print("STATUS: ${response.statusCode}");
    print("=================================");

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (e) {
        throw Exception(
          "Invalid server response.",
        );
      }
    }

    // =========================================
    // SUCCESS
    // =========================================

    if (response.statusCode == 200) {
      final smartHome = data["smartHome"];

      if (smartHome is! Map<String, dynamic>) {
        print("SMART HOME NOT FOUND");
        print("=================================");

        return {
          "success": false,
          "temperature": null,
          "humidity": null,
          "doorStatus": null,
          "sensorLastUpdated": null,
          "alarmEnabled": false,
          "alarmIsOn": false,
        };
      }

      final temperature =
      smartHome["temperature"];

      final humidity =
      smartHome["humidity"];

      final doorStatus =
      smartHome["doorStatus"]?.toString();

      final sensorLastUpdated =
      smartHome["sensorLastUpdated"]?.toString();

      final alarmEnabled =
          smartHome["alarmEnabled"] == true;

      final alarmIsOn =
          smartHome["alarmIsOn"] == true;

      print(
        "SMART HOME: ${smartHome["name"]}",
      );

      print(
        "ESP32 ID: ${smartHome["esp32Id"]}",
      );

      print(
        "TEMPERATURE: ${temperature ?? "null"} °C",
      );

      print(
        "HUMIDITY: ${humidity ?? "null"} %",
      );

      print(
        "DOOR STATUS: ${doorStatus ?? "null"}",
      );

      print(
        "ALARM ENABLED: $alarmEnabled",
      );

      print(
        "ALARM IS ON: $alarmIsOn",
      );

      print(
        "SENSOR LAST UPDATED: "
            "${sensorLastUpdated ?? "null"}",
      );

      print("=================================");

      return {
        "success": true,

        "temperature": temperature,

        "humidity": humidity,

        "doorStatus": doorStatus,

        "sensorLastUpdated":
        sensorLastUpdated,

        "alarmEnabled":
        alarmEnabled,

        "alarmIsOn":
        alarmIsOn,

        "smartHome":
        smartHome,
      };
    }

    // =========================================
    // AUTHENTICATION ERROR
    // =========================================

    if (response.statusCode == 401) {
      throw Exception(
        "Authentication expired. Please login again.",
      );
    }

    // =========================================
    // SMART HOME NOT FOUND
    // =========================================

    if (response.statusCode == 404) {
      return {
        "success": false,
        "temperature": null,
        "humidity": null,
        "doorStatus": null,
        "sensorLastUpdated": null,
        "alarmEnabled": false,
        "alarmIsOn": false,
      };
    }

    // =========================================
    // SERVER ERROR
    // =========================================

    throw Exception(
      data["message"]?.toString() ??
          "Failed to get sensor data. "
              "HTTP ${response.statusCode}",
    );
  }

  // =========================================
  // CONTROL DOOR ALARM
  // =========================================
  //
  // R7 is permanently reserved for the
  // door alarm.
  //
  // State:
  //
  // ON
  // OFF
  //
  // Endpoint:
  //
  // PUT /user/alarm/control
  //
  // =========================================

  static Future<Map<String, dynamic>> controlAlarm({
    required String state,
  }) async {
    final token = ApiService.token;

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        "Authentication token is missing. Please login again.",
      );
    }

    if (!["ON", "OFF"].contains(state)) {
      throw Exception(
        "Alarm state must be ON or OFF.",
      );
    }

    final response = await http.put(
      Uri.parse(
        "$baseUrl/user/alarm/control",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
        "Bearer ${token.trim()}",
      },
      body: jsonEncode({
        "state": state,
      }),
    );

    print("=================================");
    print("DOOR ALARM SERVICE");
    print("CONTROL DOOR ALARM");
    print(
      "URL: $baseUrl/user/alarm/control",
    );
    print(
      "REQUESTED STATE: $state",
    );
    print(
      "STATUS: ${response.statusCode}",
    );
    print("=================================");

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (e) {
        throw Exception(
          "Invalid server response.",
        );
      }
    }

    // =========================================
    // SUCCESS
    // =========================================

    if (response.statusCode == 200) {
      final alarm = data["alarm"];

      if (alarm is Map<String, dynamic>) {
        print(
          "ALARM NAME: "
              "${alarm["name"]}",
        );

        print(
          "ALARM RELAY: "
              "${alarm["relay"]}",
        );

        print(
          "ALARM ENABLED: "
              "${alarm["enabled"]}",
        );

        print(
          "ALARM IS ON: "
              "${alarm["isOn"]}",
        );
      }

      print("=================================");

      return data;
    }

    // =========================================
    // AUTHENTICATION ERROR
    // =========================================

    if (response.statusCode == 401) {
      throw Exception(
        "Authentication expired. Please login again.",
      );
    }

    // =========================================
    // PERMISSION ERROR
    // =========================================

    if (response.statusCode == 403) {
      throw Exception(
        data["message"]?.toString() ??
            "You do not have permission to control the door alarm.",
      );
    }

    // =========================================
    // OTHER ERROR
    // =========================================

    throw Exception(
      data["message"]?.toString() ??
          "Failed to control door alarm. "
              "HTTP ${response.statusCode}",
    );
  }

  // =========================================
  // CREATE SMART HOME
  // =========================================

  static Future<Map<String, dynamic>> createSmartHome({
    required String name,
  }) async {
    final token = ApiService.token;

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        "Authentication token is missing. Please login again.",
      );
    }

    final response = await http.post(
      Uri.parse("$baseUrl/user/smart-home"),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
        "Bearer ${token.trim()}",
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

    if (response.statusCode == 401) {
      throw Exception(
        "Authentication expired. Please login again.",
      );
    }

    throw Exception(
      data["message"]?.toString() ??
          "Failed to create smart home. "
              "HTTP ${response.statusCode}",
    );
  }

  // =========================================
  // GENERATE ESP32 PAIRING CODE
  // =========================================

  static Future<Map<String, dynamic>>
  generatePairingCode() async {
    final token = ApiService.token;

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        "Authentication token is missing. Please login again.",
      );
    }

    final response = await http.post(
      Uri.parse(
        "$baseUrl/user/smart-home/pairing-code",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
        "Bearer ${token.trim()}",
      },
    );

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    if (response.statusCode == 401) {
      throw Exception(
        "Authentication expired. Please login again.",
      );
    }

    throw Exception(
      data["message"]?.toString() ??
          "Failed to generate pairing code. "
              "HTTP ${response.statusCode}",
    );
  }
}
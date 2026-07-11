import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl =
      "http://192.168.1.39:3000";

  //==========================
  // Get All Devices
  //==========================

  static Future<Map<String, dynamic>> getDevices() async {

    final response = await http.get(
      Uri.parse("$baseUrl/devices"),
    );

    if (response.statusCode == 200) {

      return json.decode(response.body);

    }

    throw Exception("Failed to load devices");
  }

  //==========================
  // Control Device
  //==========================

  static Future<void> controlDevice(
      String device,
      String state,
      ) async {

    final response = await http.get(

      Uri.parse(
        "$baseUrl/control?device=$device&state=$state",
      ),

    );

    if (response.statusCode != 200) {

      throw Exception("Failed to control device");

    }

  }

  //==========================
  // Start Pump
  //==========================

  static Future<void> startPump(
      int minutes,
      ) async {

    final response = await http.post(

      Uri.parse("$baseUrl/pump/start"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({

        "minutes": minutes,

      }),

    );

    if (response.statusCode != 200) {

      throw Exception("Failed to start pump");

    }

  }

  //==========================
  // Stop Pump
  //==========================

  static Future<void> stopPump() async {

    final response = await http.post(

      Uri.parse("$baseUrl/pump/stop"),

    );

    if (response.statusCode != 200) {

      throw Exception("Failed to stop pump");

    }

  }

  //==========================
  // Pump Status
  //==========================

  static Future<Map<String, dynamic>> getPumpStatus() async {

    final response = await http.get(

      Uri.parse("$baseUrl/pump/status"),

    );

    if (response.statusCode == 200) {

      return json.decode(response.body);

    }

    throw Exception("Failed to get pump status");

  }

}
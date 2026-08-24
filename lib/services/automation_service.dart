import 'dart:convert';
import 'package:http/http.dart' as http;


import '../models/automation_model.dart';


class AutomationService {
  static const String baseUrl = "http://192.168.1.92:3000";
  Future<http.Response> createAutomation(
      AutomationModel automation,
      ) async {

    return await http.post(
      Uri.parse("$baseUrl/automation"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "deviceId": automation.deviceId,
        "deviceName": automation.deviceName,
        "time": automation.time,
        "turnOn": automation.turnOn,
        "repeatDays": automation.repeatDays,
      }),
    );

  }

  Future<http.Response> updateAutomation(
      AutomationModel automation,
      ) async {

    return await http.put(
      Uri.parse("$baseUrl/automation/${automation.id}"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "deviceId": automation.deviceId,
        "deviceName": automation.deviceName,
        "time": automation.time,
        "turnOn": automation.turnOn,
        "repeatDays": automation.repeatDays,
      }),
    );

  }

  Future<http.Response> deleteAutomation(String id) async {
    return await http.delete(
      Uri.parse("$baseUrl/automation/$id"),
    );
  }

  Future<http.Response> toggleAutomation(String id) async {
    return await http.patch(
      Uri.parse("$baseUrl/automation/$id/toggle"),
    );
  }

  Future<List<AutomationModel>> getAutomations() async {

    final response = await http.get(
      Uri.parse("$baseUrl/automations"),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final List automationsJson = data["automations"];

      return automationsJson
          .map((json) => AutomationModel.fromJson(json))
          .toList();

    } else {
      throw Exception("Failed to load automations");
    }
  }

}
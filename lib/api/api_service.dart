import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
// ====================================================
// BASE URL
// ====================================================

static const String baseUrl =
"http://192.168.1.103:3000";

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
headers["Authorization"] =
"Bearer ${token!.trim()}";
}

return headers;
}

// ====================================================
// Decode Response
// ====================================================

static dynamic _decode(
http.Response response,
) {
if (response.body.isEmpty) {
return null;
}

try {
return jsonDecode(response.body);
} catch (e) {
debugPrint(
"JSON DECODE ERROR: $e",
);

return null;
}
}

// ====================================================
// Get User Devices
//
// GET /user/devices
// ====================================================

static Future<Map<String, dynamic>>
getUserDevices() async {
final url = Uri.parse(
"$baseUrl/user/devices",
);

debugPrint(
"=================================",
);

debugPrint(
"GET USER DEVICES",
);

debugPrint(
"URL: $url",
);

debugPrint(
"TOKEN EXISTS: "
"${token != null && token!.trim().isNotEmpty}",
);

debugPrint(
"=================================",
);

try {
final response = await http.get(
url,
headers: _headers(),
);

debugPrint(
"GET USER DEVICES RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

debugPrint(
"=================================",
);

final decoded = _decode(response);

if (response.statusCode == 200) {
if (decoded is Map<String, dynamic>) {
return decoded;
}

throw Exception(
"Invalid devices response",
);
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
debugPrint(
"GET USER DEVICES EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// Get Sensor Data
//
// GET /esp32/user/sensors
//
// DHT22:
// Temperature
// Humidity
//
// Reed Sensor:
// Door Status
//
// Also returns:
// Smart Home
// Alarm
// ESP32 information
// ====================================================

static Future<Map<String, dynamic>>
getSensorData() async {
final url = Uri.parse(
"$baseUrl/esp32/user/sensors",
);

debugPrint(
"=================================",
);

debugPrint(
"GET SENSOR DATA",
);

debugPrint(
"URL: $url",
);

debugPrint(
"TOKEN EXISTS: "
"${token != null && token!.trim().isNotEmpty}",
);

debugPrint(
"=================================",
);

try {
final response = await http.get(
url,
headers: _headers(),
);

debugPrint(
"GET SENSOR DATA RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

debugPrint(
"=================================",
);

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
//
// POST /user/devices
// ====================================================

static Future<Map<String, dynamic>>
addDevice({
required String name,
required String deviceId,
required String type,
required String relay,
}) async {
final url = Uri.parse(
"$baseUrl/user/devices",
);

final body = {
"name": name.trim(),
"deviceId": deviceId.trim(),
"type": type.trim(),
"relay": relay.trim(),
};

debugPrint(
"=================================",
);

debugPrint(
"ADD DEVICE REQUEST",
);

debugPrint(
"URL: $url",
);

debugPrint(
"BODY: ${jsonEncode(body)}",
);

debugPrint(
"=================================",
);

try {
final response = await http.post(
url,
headers: _headers(
jsonBody: true,
),
body: jsonEncode(body),
);

debugPrint(
"ADD DEVICE RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

debugPrint(
"=================================",
);

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
debugPrint(
"ADD DEVICE EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// Control Device
//
// PUT /user/devices/:deviceId/control
//
// R1-R6 ONLY
// ====================================================

  static Future<Map<String, dynamic>> controlDevice(
      String deviceId,
      String state,
      ) async {
    final url = Uri.parse(
      "$baseUrl/user/devices/$deviceId/control",
    );

    final normalizedState = state.trim().toUpperCase();

    if (normalizedState != "ON" &&
        normalizedState != "OFF") {
      throw Exception(
        "Invalid device state: $state",
      );
    }

    final body = {
      "state": normalizedState,
    };

    debugPrint(
      "=================================",
    );

    debugPrint(
      "CONTROL DEVICE",
    );

    debugPrint(
      "DEVICE ID: $deviceId",
    );

    debugPrint(
      "STATE: $normalizedState",
    );

    debugPrint(
      "URL: $url",
    );

    debugPrint(
      "BODY: ${jsonEncode(body)}",
    );

    debugPrint(
      "=================================",
    );

    try {
      final response = await http.put(
        url,
        headers: _headers(
          jsonBody: true,
        ),
        body: jsonEncode(body),
      );

      debugPrint(
        "CONTROL DEVICE RESPONSE",
      );

      debugPrint(
        "STATUS: ${response.statusCode}",
      );

      debugPrint(
        "BODY: ${response.body}",
      );

      debugPrint(
        "=================================",
      );

      final decoded = _decode(response);

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        return {
          "success": true,
          "state": normalizedState,
          "isOn": normalizedState == "ON",
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
      debugPrint(
        "CONTROL DEVICE EXCEPTION: $e",
      );

      rethrow;
    }
  }
// ====================================================
// Control Door Alarm
//
// PUT /user/alarm/control
//
// R7
//
// ON  = Arm
// OFF = Disarm
// ====================================================

static Future<Map<String, dynamic>>
controlAlarm(
String state,
) async {
final url = Uri.parse(
"$baseUrl/user/alarm/control",
);

final body = {
"state": state,
};

debugPrint(
"=================================",
);

debugPrint(
"CONTROL DOOR ALARM",
);

debugPrint(
"RELAY: R7",
);

debugPrint(
"STATE: $state",
);

debugPrint(
"URL: $url",
);

debugPrint(
"=================================",
);

try {
final response = await http.put(
url,
headers: _headers(
jsonBody: true,
),
body: jsonEncode(body),
);

debugPrint(
"CONTROL ALARM RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

debugPrint(
"=================================",
);

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
debugPrint(
"CONTROL ALARM EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// Silence Door Alarm
//
// PUT /user/alarm/silence
//
// Stops the currently sounding alarm.
//
// IMPORTANT:
// This is different from controlAlarm().
//
// controlAlarm("ON")  = Arm alarm
// controlAlarm("OFF") = Disarm alarm
//
// silenceAlarm()      = Silence active alarm
// ====================================================

static Future<Map<String, dynamic>>
silenceAlarm() async {
final url = Uri.parse(
"$baseUrl/user/alarm/silence",
);

debugPrint(
"=================================",
);

debugPrint(
"SILENCE DOOR ALARM",
);

debugPrint(
"RELAY: R7",
);

debugPrint(
"URL: $url",
);

debugPrint(
"=================================",
);

try {
final response = await http.put(
url,
headers: _headers(),
);

debugPrint(
"SILENCE ALARM RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

debugPrint(
"=================================",
);

final decoded = _decode(response);

if (response.statusCode == 200) {
if (decoded is Map<String, dynamic>) {
return decoded;
}

return {
"success": true,
"message": "Alarm silenced successfully",
};
}

if (decoded is Map<String, dynamic>) {
throw Exception(
decoded["message"]?.toString() ??
"Failed to silence alarm",
);
}

throw Exception(
"Failed to silence alarm "
"(HTTP ${response.statusCode})",
);
} catch (e) {
debugPrint(
"SILENCE ALARM EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// Delete Device
//
// DELETE /user/devices/:deviceId
// ====================================================

static Future<Map<String, dynamic>>
deleteDevice(
String deviceId,
) async {
final url = Uri.parse(
"$baseUrl/user/devices/"
"$deviceId",
);

debugPrint(
"=================================",
);

debugPrint(
"DELETE DEVICE",
);

debugPrint(
"DEVICE ID: $deviceId",
);

debugPrint(
"URL: $url",
);

debugPrint(
"=================================",
);

try {
final response = await http.delete(
url,
headers: _headers(),
);

final decoded = _decode(response);

debugPrint(
"DELETE DEVICE RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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
debugPrint(
"DELETE DEVICE EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// Control Water Pump
//
// PUT /user/pump/control
//
// R8
//
// ON  = Start
// OFF = Stop
// ====================================================

static Future<Map<String, dynamic>>
controlPump(
String state,
) async {
final url = Uri.parse(
"$baseUrl/user/pump/control",
);

final body = {
"state": state,
};

debugPrint(
"=================================",
);

debugPrint(
"CONTROL WATER PUMP",
);

debugPrint(
"RELAY: R8",
);

debugPrint(
"STATE: $state",
);

debugPrint(
"URL: $url",
);

debugPrint(
"=================================",
);

try {
final response = await http.put(
url,
headers: _headers(
jsonBody: true,
),
body: jsonEncode(body),
);

debugPrint(
"CONTROL PUMP RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

debugPrint(
"=================================",
);

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
debugPrint(
"CONTROL PUMP EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// SMART HOME MEMBERS
// ====================================================

// ====================================================
// Get Members
//
// GET /user/members
// ====================================================

static Future<Map<String, dynamic>>
getMembers() async {
final url = Uri.parse(
"$baseUrl/user/members",
);

debugPrint(
"=================================",
);

debugPrint(
"GET SMART HOME MEMBERS",
);

debugPrint(
"URL: $url",
);

debugPrint(
"=================================",
);

try {
final response = await http.get(
url,
headers: _headers(),
);

debugPrint(
"GET MEMBERS RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

debugPrint(
"=================================",
);

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
debugPrint(
"GET MEMBERS EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// Add / Invite Member
//
// POST /user/members
// ====================================================

static Future<Map<String, dynamic>>
addMember({
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

debugPrint(
"=================================",
);

debugPrint(
"ADD SMART HOME MEMBER",
);

debugPrint(
"URL: $url",
);

debugPrint(
"BODY: ${jsonEncode(body)}",
);

debugPrint(
"=================================",
);

try {
final response = await http.post(
url,
headers: _headers(
jsonBody: true,
),
body: jsonEncode(body),
);

final decoded = _decode(response);

debugPrint(
"ADD MEMBER RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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
debugPrint(
"ADD MEMBER EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// Get My Invitations
//
// GET /user/members/invitations
// ====================================================

static Future<Map<String, dynamic>>
getMyInvitations() async {
final url = Uri.parse(
"$baseUrl/user/members/invitations",
);

debugPrint(
"=================================",
);

debugPrint(
"GET MY MEMBER INVITATIONS",
);

debugPrint(
"URL: $url",
);

debugPrint(
"=================================",
);

try {
final response = await http.get(
url,
headers: _headers(),
);

final decoded = _decode(response);

debugPrint(
"GET INVITATIONS RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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
//
// POST /user/members/:memberId/accept
// ====================================================

static Future<Map<String, dynamic>>
acceptInvitation(
String memberId,
) async {
final url = Uri.parse(
"$baseUrl/user/members/"
"$memberId/accept",
);

try {
final response = await http.post(
url,
headers: _headers(),
);

final decoded = _decode(response);

debugPrint(
"ACCEPT INVITATION",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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
//
// POST /user/members/:memberId/reject
// ====================================================

static Future<Map<String, dynamic>>
rejectInvitation(
String memberId,
) async {
final url = Uri.parse(
"$baseUrl/user/members/"
"$memberId/reject",
);

try {
final response = await http.post(
url,
headers: _headers(),
);

final decoded = _decode(response);

debugPrint(
"REJECT INVITATION",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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
//
// DELETE /user/members/:memberId
// ====================================================

static Future<Map<String, dynamic>>
removeMember(
String memberId,
) async {
final url = Uri.parse(
"$baseUrl/user/members/"
"$memberId",
);

try {
final response = await http.delete(
url,
headers: _headers(),
);

final decoded = _decode(response);

debugPrint(
"REMOVE MEMBER",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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
//
// PATCH /user/members/:memberId/permissions
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
"$baseUrl/user/members/"
"$memberId/permissions",
);

debugPrint(
"=================================",
);

debugPrint(
"UPDATE MEMBER PERMISSIONS",
);

debugPrint(
"URL: $url",
);

debugPrint(
"BODY: ${jsonEncode(body)}",
);

debugPrint(
"=================================",
);

try {
final response = await http.patch(
url,
headers: _headers(
jsonBody: true,
),
body: jsonEncode(body),
);

final decoded = _decode(response);

debugPrint(
"UPDATE PERMISSIONS RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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
//
// DELETE /user/members/leave
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

debugPrint(
"LEAVE SMART HOME",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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
//
// DELETE /auth/delete-account
// ====================================================

static Future<Map<String, dynamic>>
deleteAccount({
required String password,
}) async {
final url = Uri.parse(
"$baseUrl/auth/delete-account",
);

debugPrint(
"=================================",
);

debugPrint(
"DELETE ACCOUNT REQUEST",
);

debugPrint(
"URL: $url",
);

debugPrint(
"TOKEN EXISTS: "
"${token != null && token!.trim().isNotEmpty}",
);

debugPrint(
"=================================",
);

try {
final response = await http.delete(
url,
headers: _headers(
jsonBody: true,
),
body: jsonEncode({
"password": password,
}),
);

final decoded = _decode(response);

debugPrint(
"DELETE ACCOUNT RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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

// ====================================================
// NOTIFICATIONS
// ====================================================

// ====================================================
// Get User Notifications
//
// GET /user/notifications
// ====================================================

static Future<Map<String, dynamic>>
getNotifications() async {
final url = Uri.parse(
"$baseUrl/user/notifications",
);

debugPrint(
"=================================",
);

debugPrint(
"GET USER NOTIFICATIONS",
);

debugPrint(
"URL: $url",
);

debugPrint(
"=================================",
);

try {
final response = await http.get(
url,
headers: _headers(),
);

final decoded = _decode(response);

debugPrint(
"GET NOTIFICATIONS RESPONSE",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

if (response.statusCode == 200) {
if (decoded is Map<String, dynamic>) {
return decoded;
}

throw Exception(
"Invalid notifications response",
);
}

if (decoded is Map<String, dynamic>) {
throw Exception(
decoded["message"]?.toString() ??
"Failed to load notifications",
);
}

throw Exception(
"Failed to load notifications "
"(HTTP ${response.statusCode})",
);
} catch (e) {
debugPrint(
"GET NOTIFICATIONS EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// Mark One Notification As Read
//
// PUT /user/notifications/:notificationId/read
// ====================================================

static Future<Map<String, dynamic>>
markNotificationRead(
String notificationId,
) async {
final url = Uri.parse(
"$baseUrl/user/notifications/"
"$notificationId/read",
);

try {
final response = await http.put(
url,
headers: _headers(),
);

final decoded = _decode(response);

debugPrint(
"MARK NOTIFICATION READ",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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
"Failed to mark notification as read",
);
}

throw Exception(
"Failed to mark notification as read "
"(HTTP ${response.statusCode})",
);
} catch (e) {
debugPrint(
"MARK NOTIFICATION READ EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// Mark All Notifications As Read
//
// PUT /user/notifications/read-all
// ====================================================

static Future<Map<String, dynamic>>
markAllNotificationsRead() async {
final url = Uri.parse(
"$baseUrl/user/notifications/read-all",
);

try {
final response = await http.put(
url,
headers: _headers(),
);

final decoded = _decode(response);

debugPrint(
"MARK ALL NOTIFICATIONS AS READ",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

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
"Failed to mark all notifications as read",
);
}

throw Exception(
"Failed to mark all notifications as read "
"(HTTP ${response.statusCode})",
);
} catch (e) {
debugPrint(
"MARK ALL READ EXCEPTION: $e",
);

rethrow;
}
}

// ====================================================
// Delete Notification
//
// DELETE /user/notifications/:notificationId
// ====================================================

static Future<Map<String, dynamic>>
deleteNotification(
String notificationId,
) async {
final url = Uri.parse(
"$baseUrl/user/notifications/"
"$notificationId",
);

try {
final response = await http.delete(
url,
headers: _headers(),
);

final decoded = _decode(response);

debugPrint(
"DELETE NOTIFICATION",
);

debugPrint(
"STATUS: ${response.statusCode}",
);

debugPrint(
"BODY: ${response.body}",
);

if (response.statusCode == 200) {
if (decoded is Map<String, dynamic>) {
return decoded;
}

return {
"success": true,
"message": "Notification deleted",
};
}

if (decoded is Map<String, dynamic>) {
throw Exception(
decoded["message"]?.toString() ??
"Failed to delete notification",
);
}

throw Exception(
"Failed to delete notification "
"(HTTP ${response.statusCode})",
);
} catch (e) {
debugPrint(
"DELETE NOTIFICATION EXCEPTION: $e",
);

rethrow;
}
}
}

